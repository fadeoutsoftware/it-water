#!/usr/bin/python3
"""
SHYBOX - Snow HYdro toolBOX - WORKFLOW MERGER BY DOMAIN BASE

__date__ = '20250403'
__version__ = '1.0.0'
__author__ =
    'Fabio Delogu (fabio.delogu@cimafoundation.org),
     Francesco Avanzi (francesco.avanzi@cimafoundation.org)'
__library__ = 'shybox'

General command line:
python app_workflow_main.py -settings_file configuration.json -time "YYYY-MM-DD HH:MM"

Examples of environment variables declarations:
DOMAIN_NAME='italy';
TIME_START="'2025-01-24 00:00'";
TIME_END="'2025-01-24 05:00'";
PATH_SRC='/home/fabio/Desktop/shybox/dset/itwater';
PATH_DST='/home/fabio/Desktop/shybox/dset/itwater';
PATH_LOG=$HOME/dataset_base/log/;
PATH_TMP=$HOME/dataset_base/tmp/

Version(s):
20250403 (1.0.0) --> Beta release for shybox package

Enhancements by Fadeout for HPC :
- At startup check the number of cores available 
- Creates a pool of workers, leveraging multiprocessing library. 
- Splits the intervals, considering the available cores.
- Launch parallel processes accordingly to the splitted intervals defined above
Notes : 
V1 replicates the access to file setting
V2 (potential enanchement) optimize this by accessing ONCE the files and prepare parameters for the Pool 

This particular versions spreads the elaboration over each hour and is designed to manage 24 threads in the pool 
"""

# ----------------------------------------------------------------------------------------------------------------------
# libraries
import logging
import os
import time

import numpy as np
import pandas as pd
from multiprocessing import Pool

from shybox.generic_toolkit.lib_utils_args import get_args
from shybox.generic_toolkit.lib_utils_logging import set_logging_stream
from shybox.generic_toolkit.lib_utils_time import select_time_range, select_time_format
from shybox.generic_toolkit.lib_utils_string import fill_string

from shybox.generic_toolkit.lib_default_args import logger_name, logger_format, logger_arrow
from shybox.generic_toolkit.lib_default_args import collector_data

from shybox.runner_toolkit.settings.driver_app_settings import DrvSettings
from shybox.runner_toolkit.time.driver_app_time import DrvTime

from shybox.orchestrator_toolkit.orchestrator_handler_base import OrchestratorHandler as Orchestrator
from shybox.dataset_toolkit.dataset_handler_local import DataLocal

# fx imported in the PROCESSES (will be used in the global variables PROCESSES) --> DO NOT REMOVE
from shybox.processing_toolkit.lib_proc_mask import mask_data_by_ref, mask_data_by_limits
from shybox.processing_toolkit.lib_proc_interp import interpolate_data
from shybox.processing_toolkit.lib_proc_merge import merge_data_by_ref

# Util library to manage intervals
from datetime import datetime, timedelta
from dateutil.relativedelta import relativedelta

# set logger
logger_stream = logging.getLogger(logger_name)
logger_stream.setLevel(logging.ERROR)
# ----------------------------------------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------------------------------------
# algorithm information
project_name = 'shybox'
alg_name = 'Workflow for datasets merger by domain base configuration'
alg_type = 'Package'
alg_version = '1.0.0'
alg_release = '2025-04-03'
# ----------------------------------------------------------------------------------------------------------------------
def split_datetime_24h(start_date: str, end_date: str):
    """
    Split the interval between start_date and end_date into num_intervals hourly spaced datetime strings.
    If more than one day is requested, as long that for each days 24 h are requested, the result array is created with 24 * n_days intervals
    Args:
        start_date (str): Start date in "%Y-%m-%d %H:%M" format. The HH:MM MUST be equals to 00:00
        end_date (str): End date in "%Y-%m-%d %H:%M" format. The HH:MM MUST be equals to 23:00
    Returns:
        List[str]: List of datetime strings in "%Y-%m-%d %H:%M" format.
    """

    fmt = "%Y-%m-%d %H:%M"
    # strip single quotes? 
    start_date = start_date.strip("'")
    end_date = end_date.strip("'")
    dt_start = datetime.strptime(start_date, fmt)
    dt_end = datetime.strptime(end_date, fmt)

    if dt_end < dt_start:
        print("ERROR - time_end is greater than time_start, exiting")
        exit(-1)

    if dt_start.hour != 0:
        print("ERROR - Wrong start_time passed - time MUST start at 00:00, exiting")
        exit(-1)

    if dt_end.hour != 23:
        print("ERROR - Wrong end_time passed - time MUST end at 23:00, exiting")
        exit(-1)
    # obtain the number of day in between the specified dates 
    # dt_end is in
    nDays = ((dt_end + timedelta(hours=1))  - dt_start).days

    if (nDays> 1):
        print("INFO - More than 24 hours of elaboration requested, the 1-hour thread will be waiting until a new slot of the pool will become available")

    result = []
    # 23 hours for each day of elaboration. The pool is fixed at 24, so the remaining following days are executed 
    # afterwards
    for j in range (nDays):
        for i in range(23): 
            array = [] 
            dstart = dt_start + timedelta(hours=(i)) + timedelta(days=j)
            
            dend = dt_start + timedelta(hours=(i+1)) + timedelta(days=j)
            array.append(dstart.strftime(fmt))
            array.append(dend.strftime(fmt))

            result.append(array)
    return result


def pool_handler():
###TIME_START='2003-10-01 00:00'
###TIME_END='2003-10-15 23:00'
#above from ENV
    TIME_START = os.environ.get('TIME_START')
    print("time start %s",TIME_START)
    if TIME_START is None:
        raise EnvironmentError("TIME_START environment variable not set")
    TIME_END = os.environ.get('TIME_END')
    print("time end %s",TIME_END)
    if TIME_END is None:
        raise EnvironmentError("TIME_END environment variable not set")

    if os.getenv('SLURM_CPUS_PER_TASK') != None and int(os.getenv('SLURM_CPUS_PER_TASK')) < 24: 
        print("WARNING - Less core allocated than the 24h thread pool's size")
    
    p = Pool(24)
    intervals = split_datetime_24h(TIME_START,TIME_END)
    print("intervals %s", intervals)
    p.map(main, intervals) 



# ----------------------------------------------------------------------------------------------------------------------
# script main
def main(work_data):

    
    if work_data[0] == "" or work_data[1] =="":
        raise Exception("Parallel execution : Missing parameters for start/end date")
        
    # ------------------------------------------------------------------------------------------------------------------
    # get file settings
    alg_file_settings, alg_time_settings = get_args(settings_folder=os.path.dirname(os.path.realpath(__file__)))

    # method to initialize settings class
    driver_settings = DrvSettings(file_name=alg_file_settings, file_time=alg_time_settings,
                                  file_key='settings', settings_collectors=None)

    # method to configure variable settings
    (alg_variables_settings,
     alg_variables_collector, alg_variables_system) = driver_settings.configure_variable_by_settings()
    # method to organize variable settings
    alg_variables_settings = driver_settings.organize_variable_settings(
        alg_variables_settings, alg_variables_collector)
    # method to view variable settings
    driver_settings.view_variable_settings(data=alg_variables_settings, mode=True)

    # get variables application
    alg_variables_application = driver_settings.get_variable_by_tag('application')
    alg_variables_application = driver_settings.fill_variable_by_dict(alg_variables_application, alg_variables_settings)

    # collector data
    collector_data.view(table_print=False)
    
    # support variable used to compose log file with start time and end time (required for each process)
    log_file_name = alg_variables_settings['file_log'] + "_" + work_data[0] + " " + work_data[1] + ".log"

    # set logging stream
    set_logging_stream(
        logger_name=logger_name, logger_format=logger_format,
        logger_folder=alg_variables_settings['path_log'], logger_file=log_file_name)
    # ------------------------------------------------------------------------------------------------------------------

    # ------------------------------------------------------------------------------------------------------------------
    # info algorithm (start)
    logger_stream.info(logger_arrow.arrow_main_break)
    logger_stream.info(
        logger_arrow.main + alg_name + ' (Version: ' + alg_version + ' Release_Date: ' + alg_release + ')')
    logger_stream.info(logger_arrow.main + 'START ... ')
    logger_stream.info(logger_arrow.arrow_main_blank)

    # time algorithm
    start_time = time.time()
    # ------------------------------------------------------------------------------------------------------------------

    # ------------------------------------------------------------------------------------------------------------------
    # configuration workflow
    configuration = {
        "WORKFLOW": {
            "options": {
                "intermediate_output": "Tmp",
                "tmp_dir": alg_variables_settings['path_tmp']
            },
            "process_list": {
                "REff": [
                    {"function": "merge_data_by_ref", "method": 'nn', "max_distance": 25000, "neighbours": 7, 
                     "fill_value": np.nan,
                     "var_no_data": -9999},
                    {"function": "mask_data_by_ref", "ref_value": -9999, "mask_no_data": np.nan}
                ],
                "SnowMask": [
                    {"function": "merge_data_by_ref", "method": 'nn', "max_distance": 25000, "neighbours": 7,
                     "fill_value": np.nan, 
                     "var_no_data": 0},
                    {"function": "mask_data_by_ref", "ref_value": -9999, "mask_no_data": np.nan}
                ]
            }
        }
    }
    # ------------------------------------------------------------------------------------------------------------------

    # ------------------------------------------------------------------------------------------------------------------
    # method to organize time information
    alg_sim_time = select_time_range(
        time_start=work_data[0],
        time_end=work_data[1],
        time_frequency=alg_variables_application['time']['frequency'])
    alg_sim_time = select_time_format(alg_sim_time, time_format=alg_variables_application['time']['format'])
    # ------------------------------------------------------------------------------------------------------------------

    # ------------------------------------------------------------------------------------------------------------------
    # define geo obj
    geo_data = DataLocal(
        path=alg_variables_application['geo']['terrain']['path'],
        file_name=alg_variables_application['geo']['terrain']['file_name'],
        file_mode='grid', file_variable='terrain',
        file_template={
            "dims_geo": {"x": "longitude", "y": "latitude"},
            "vars_geo": {"x": "longitude", "y": "latitude"}
        },
        time_signature=None
    )
    # ------------------------------------------------------------------------------------------------------------------

    # ------------------------------------------------------------------------------------------------------------------
    # time iteration(s)
    for sim_time in alg_sim_time:

        # iterate over src datasets
        data_src_list = []
        for data_src_key, data_src_settings in alg_variables_application['data_source'].items():

            data_src_obj = create_src_dataset(
                file_name=data_src_settings['file_name'], file_path=data_src_settings['path'],
                file_time=sim_time)

            data_src_list.append(data_src_obj)

        # iterate over dst datasets
        data_dst_list = []
        for data_dst_key, data_dst_settings in alg_variables_application['data_destination'].items():

            data_dst_obj = create_dst_dataset(
                file_name=data_dst_settings['file_name'], file_path=data_dst_settings['path'],
                file_time=sim_time, file_variable=data_dst_settings['variable'],
                vars_data=data_dst_settings['vars_data'],
                vars_geo=data_dst_settings['vars_geo'], dims_geo=data_dst_settings['dims_geo'])

            data_dst_list.append(data_dst_obj)

        # orchestrator multi variable settings
        orc_process = Orchestrator.multi_tile(
            data_package_in=data_src_list, data_package_out=data_dst_list,
            data_ref=geo_data,
            configuration=configuration['WORKFLOW']
        )

        # orchestrator multi variable execution
        orc_process.run(time=sim_time)

    # ------------------------------------------------------------------------------------------------------------------

    # ------------------------------------------------------------------------------------------------------------------
    # info algorithm (end)
    alg_time_elapsed = round(time.time() - start_time, 1)

    logger_stream.info(logger_arrow.arrow_main_blank)
    logger_stream.info(
        logger_arrow.main + alg_name + ' (Version: ' + alg_version + ' Release_Date: ' + alg_release + ')')
    logger_stream.info(logger_arrow.main + 'TIME ELAPSED: ' + str(alg_time_elapsed) + ' seconds')
    logger_stream.info(logger_arrow.main + '... END')
    logger_stream.info(logger_arrow.main + 'Bye, Bye')
    logger_stream.info(logger_arrow.arrow_main_break)
    # ------------------------------------------------------------------------------------------------------------------


# ----------------------------------------------------------------------------------------------------------------------


# ----------------------------------------------------------------------------------------------------------------------
# method to define source dataset
def create_dst_dataset(file_name: str, file_path: str, file_time: pd.Timestamp,
                       file_variable: str,
                       vars_data: dict, vars_geo: dict, dims_geo: dict) -> DataLocal:

    # define file name
    file_name = fill_string(file_name, time_source=file_time, domain_name=None)

    data_obj = DataLocal(
        path=file_path,
        file_name=file_name, time_signature='step',
        file_format='geotiff', file_type=None, file_mode='grid', file_variable=[file_variable],
        file_template={
            "dims_geo": dims_geo, "vars_geo": vars_geo, "vars_data": vars_data
        },
        time_period=1, time_format='%Y%m%d%H%M')

    return data_obj
# ----------------------------------------------------------------------------------------------------------------------


# ----------------------------------------------------------------------------------------------------------------------
# method to define source dataset
def create_src_dataset(file_name: str, file_path: str, file_time: pd.Timestamp) -> DataLocal:

    # define file name
    file_name = fill_string(file_name, time_source=file_time, domain_name=None)

    # define file obj
    data_obj = DataLocal(
        path=file_path,
        file_name=file_name,
        file_format="netcdf", file_mode=None, file_variable=['REff', 'SnowMask'],
        file_template={
            "dims_geo": {"X": "longitude", "Y": "latitude", "time": "time"},
            'coords_geo': {'Longitude': 'longitude', 'Latitude': 'latitude'},
            "vars_data": {"REff": "effective_rainfall", "SnowMask": "snow_mask"}
        },
        time_signature='current',
        time_reference=file_time, time_period=1, time_freq='h', time_direction='forward',
    )

    return data_obj
# ----------------------------------------------------------------------------------------------------------------------


# ----------------------------------------------------------------------------------------------------------------------
# call script from external library
if __name__ == "__main__":
    # run script
    pool_handler()
# ----------------------------------------------------------------------------------------------------------------------



