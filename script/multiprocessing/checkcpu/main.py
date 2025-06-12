""" 
Test application to check extraction and parallel launch of several task
Reference be integrated in Python merger from CIMA
"""
from multiprocessing import Pool

import time
import random

intervals = (["01/02/2020", "01/03/2020"],
             ["01/03/2020", "01/04/2020"],
             ["01/04/2020", "01/05/2020"],
             ["01/05/2020", "01/06/2020"])


def work_log(work_data):
    print(" Process starting on dates between %s and %s " %
          (work_data[0], work_data[1]))
    time.sleep(3+random.randint(0, 3))  # simulates process lasting 3-6 sec
    print(" Process between %s and %s Finished." %
          (work_data[0], work_data[1]))


def pool_handler():
    p = Pool(4)
    p.map(work_log, intervals)


if __name__ == '__main__':
    pool_handler()
