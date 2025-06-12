import os

def checkcpu():
    print ("On current sys we have %s CPUs/Workers " % os.cpu_count())
    


if __name__ == '__main__':
    checkcpu()
