#!/usr/bin/python3
"""
SHYBOX - Snow HYdro toolBOX - WORKFLOW MERGER BY TIME BASE

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


def split_datetime_in_days(start_date: str, end_date: str):
    """
    Split the interval between start_date and end_date in daily intervals, forcing the beginning to 00:00
    and the end to 23:00
    Args:
        start_date (str): Start date in "%Y-%m-%d %H:%M" format.
        end_date (str): End date in "%Y-%m-%d %H:%M" format.
    Returns:
        List[str]: List of datetime strings in "%Y-%m-%d %H:%M" format.
    """

    fmt = "%Y-%m-%d %H:%M"
    # strip single quotes? 
    start_date = start_date.strip("'")
    end_date = end_date.strip("'")
    dt_start = datetime.strptime(start_date, fmt)
    dt_end = datetime.strptime(end_date, fmt)
    num_intervals = (dt_end - dt_start).days
    if num_intervals < 1:
        raise ValueError("num_intervals must be >= 1")
    result = []
    for i in range(num_intervals):
        array = [] 
        dstart = dt_start + timedelta(days=(i))
        dstart = dstart.replace(minute=0)
        dstart = dstart.replace(hour=0)
        dend = dstart + timedelta(days=(i)) 
        dend = dend.replace(minute=0)
        #dend = dend.replace(hour=23)
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

    iCoreCount = 4
    print ("core count %s", iCoreCount)
    
    intervals = split_datetime_in_days(TIME_START,TIME_END)
    print("intervals %s", intervals)
    p = Pool(len(intervals))
    p.map(main, intervals) 

# set logger
logger_stream = logging.getLogger(logger_name)
logger_stream.setLevel(logging.ERROR)
# ----------------------------------------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------------------------------------
# algorithm information
project_name = 'shybox'
alg_name = 'Workflow for datasets merger by time base configuration'
alg_type = 'Package'
alg_version = '1.0.0'
alg_release = '2025-04-03'
# ----------------------------------------------------------------------------------------------------------------------

#global support variable to handle 

orc_process_array = []


# ----------------------------------------------------------------------------------------------------------------------
# script main
def main():


    
    
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
    log_file_name = alg_variables_settings['file_log'] + "_" + str(datetime.now().microsecond) + ".log"

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
    configuration= {
        "WORKFLOW": {
            "options": {
                "intermediate_output": "Tmp",
                "tmp_dir": "tmp"
            },
            "process_list": {
                "REff": [
                    {"function": "merge_data_by_time"}
                ]
            }
        }
    }
    # ------------------------------------------------------------------------------------------------------------------
    
    
    
    
    # ------------------------------------------------------------------------------------------------------------------
    # method to organize time information
    alg_sim_time = select_time_range(
        time_start=alg_variables_application['time']['start'],
        time_end=alg_variables_application['time']['end'],
        time_frequency=alg_variables_application['time']['frequency'])
    alg_sim_time = select_time_format(alg_sim_time, time_format=alg_variables_application['time']['format'])
    # ------------------------------------------------------------------------------------------------------------------

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

        print(sim_time)
        
        # time source data
        alg_data_time = select_time_range(
            time_start=sim_time,
            time_period=5,
            time_frequency='h')
        start_data_time, end_data_time = alg_data_time[0], alg_data_time[-1]


        start_data_time = select_time_format(start_data_time, time_format='%Y-%m-%d %H:%M')
        end_data_time = select_time_format(end_data_time, time_format='%Y-%m-%d %H:%M')

        # get data source settings
        data_src_settings = alg_variables_application['data_source']['dset_01']
        # organize data source obj
        data_src_obj = DataLocal(
            path=data_src_settings['path'],
            file_name=data_src_settings['file_name'],
            file_format="geotiff", file_mode=None, file_variable=['REff'],
            file_template={
                "dims_geo": {"X": "longitude", "Y": "latitude", "time": "time"},
                'coords_geo': {'Longitude': 'longitude', 'Latitude': 'latitude'},
                "vars_data": {"REff": "effective_rainfall", "SnowMask": "snow_mask"}
            },
            time_signature='current',
            time_reference=start_data_time, time_period=1, time_freq='h', time_direction='forward',
        )

        # get data destination settings
        data_dst_settings = alg_variables_application['data_destination']['dset_01']
        # organize data destination obj
        data_dst_obj = DataLocal(
            path=data_dst_settings['path'],
            file_name=data_dst_settings['file_name'], time_signature='start',
            file_format='netcdf', file_type='itwater', file_mode='grid',
            file_variable=data_dst_settings['variable'],
            file_template={
                "dims_geo": {"longitude": "longitude", "latitude": "latitude"},
                "vars_geo": {"longitude": "longitude", "latitude": "longitude"},
                "vars_data": data_dst_settings['vars_data']
            },
            time_period=5, time_format='%Y%m%d%H%M')

        # orchestrator multi time(s) settings
        
        orc_process = Orchestrator.multi_time(
            data_package_in=[data_src_obj], data_package_out=[data_dst_obj],
            data_ref=geo_data,
            configuration=configuration['WORKFLOW']
        )
        '''
        cur_orc_process = {} #empty dictionary
        cur_orc_process["start_data_time"] = start_data_time
        cur_orc_process["end_data_time"] = end_data_time
        cur_orc_process["orc_process"] = orc_process
        '''

        orc_process_array.append([pd.date_range(start_data_time, end_data_time, freq='h'),
                                  [data_src_obj],
                                  [data_dst_obj],
                                  geo_data,
                                  configuration['WORKFLOW']])
        # accumulate in a dict time and orc_processes 
        # exit from for and execute a pool with input time ref : d.date_range(start_data_time, end_data_time, freq='h')
        # orc_process from above 
        # orchestrator multi time(s) execution
    
    p = Pool(int(len(orc_process_array)/3))
    print (f"Array of orc process lenght {len(orc_process_array)}" )
    print(type(orc_process_array[0][0])) 
    #print(type(orc_process_array[0][1]))
    
    print(type(orc_process_array[1][0]))
    #print(type(orc_process_array[1][1]))

    p.map(mapper, orc_process_array)

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

def mapper(work_data):
    print(f"wd0 {work_data[0]}")
    #print(f"wd1 {work_data[1]}")

    orc_process = Orchestrator.multi_time(
            data_package_in=work_data[1],
            data_package_out=work_data[2],
            data_ref=work_data[3],
            configuration=work_data[4]
        )


    orc_process.run(time=work_data[0],group='by_time')
    '''
    actual launch
    orc_process.run(time=pd.date_range
    (start_data_time, end_data_time, freq='h'),
                        group='by_time')
    
    print(type(orc_process_array_in))
    for orc in orc_process_array_in:
        print("start Time:")
        print(orc["start_data_time"])
    '''
    return
# ----------------------------------------------------------------------------------------------------------------------
# call script from external library
if __name__ == "__main__":
    # run script
    main()
# ----------------------------------------------------------------------------------------------------------------------



