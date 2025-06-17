""" 
Test application to check extraction and parallel launch of several task
Reference be integrated in Python merger from CIMA
"""
from multiprocessing import Pool

import time
import random
from datetime import datetime, timedelta
import os


def split_datetime_intervals(start_date: str, end_date: str, num_intervals: int):
    """
    Split the interval between start_date and end_date into num_intervals equally spaced datetime strings.
    Args:
        start_date (str): Start date in "%Y-%m-%d %H:%M" format.
        end_date (str): End date in "%Y-%m-%d %H:%M" format.
        num_intervals (int): Number of intervals (number of points will be num_intervals + 1).
    Returns:
        List[str]: List of datetime strings in "%Y-%m-%d %H:%M" format.
    """

    fmt = "%Y-%m-%d %H:%M"
    dt_start = datetime.strptime(start_date, fmt)
    dt_end = datetime.strptime(end_date, fmt)
    if num_intervals < 1:
        raise ValueError("num_intervals must be >= 1")
    total_seconds = (dt_end - dt_start).total_seconds()
    step = total_seconds / num_intervals
    result = []
    for i in range(num_intervals):
        array = [] 
        dstart = dt_start + timedelta(seconds=(i) * step)
        dstart = dstart.replace(minute=0)
        dend = dt_start + timedelta(seconds=(i+1) * step) 
        dend = dend.replace(minute=0)
        array.append(dstart.strftime(fmt))
        array.append(dend.strftime(fmt))
        result.append(array)
    return result
    

def work_log(work_data):
    print(" Process starting on dates between %s and %s " %
          (work_data[0], work_data[1]))
    time.sleep(3+random.randint(0, 3))  # simulates process lasting 3-6 sec
    print(" Process between %s and %s Finished." %
          (work_data[0], work_data[1]))


def pool_handler(intervals):
    
    p = Pool(os.cpu_count())
    p.map(work_log, intervals)


if __name__ == '__main__':
    intervals = split_datetime_intervals ("2010-01-01 12:00","2020-01-10 12:00",50) ## 10 days in  10 intervals
    pool_handler(intervals)
