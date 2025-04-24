import calendar
from datetime import datetime,timedelta
from dateutil.relativedelta import relativedelta



def generateString (iRestart, oTimeRestart, oTimeStart, oTimeEnd, oTimePeriod, oSlurmTimeLimit, iS3MTerData):
    """_summary_ Support function to generate lines for the simulation setup

    Args:
        iRestart (_type_): _description_
        oTimeRestart (_type_): _description_
        oTimeStart (_type_): _description_
        oTimeEnd (_type_): _description_
        oTimePeriod (_type_): _description_
        oSlurmTimeLimit (_type_): _description_
        iS3MTerData (_type_): _description_

    Returns:
        _type_: A formatted string to be parsed with awk, check script.sh for a reference example
    """
    return iRestart + "          " + oTimeRestart + "       "+ oTimeStart + "     " + oTimeEnd +"     " + oTimePeriod + "            " + oSlurmTimeLimit + "        " + iS3MTerData


def generateFromToWhile (startTime, endTime, stepMonths,stepDays,stepHours):
    """_summary_ Util function to generate the simulation startup parameters considering the start time and end time
    The function consider the Monthly, daily and hourly steps specified and generate a list of lines to be parsed to launch the actual 
    simulations.
    This allows to obtain a file with contiguous time intervals and properly set values
    Also the time period (hours in between the start and end of each line) and time limit is computed.
    For the latest an heuristic is applied considering 2 hours per month of simulation

    Args:
        startTime (_type_): _description_ Stat time for the simulation in format YYYY-MM-DD HH:MM
        endTime (_type_): _description_ End time for the simulation in format YYYY-MM-DD HH:MM
        stepMonths (_type_): _description_ Size of the step in months
        stepDays (_type_): _description_ Size of the step in days
        stepHours (_type_): _description_ Size of the step in hours
    """
    rate = stepMonths + (stepDays/30) + (stepHours/ (24*30)) #heuristic, good enough
    td = (timedelta(hours=2*rate) )
    TIME_LIMIT = str(td.days)+"-"+f"{(int(td.seconds/3600)):02d}"+":00:00" ## Need to be calculated
    DATE_FORMAT = "%Y-%m-%d %H:%M"
    with open('setup.txt',"w", encoding="utf-8") as f:
        f.write("isRestart  TimeRestart            TimeStart            TimeEnd              TimePeriod     SlurmTimeLimit    S3MTerData\n")
        oStart= datetime.strptime(startTime, DATE_FORMAT)
        oEnd = datetime.strptime(endTime, DATE_FORMAT)
        

        print("start " + str(oStart) + " end "+ str(oEnd))
        restart = 1
        cursorTime = oStart
        increment = relativedelta(months=stepMonths,days=stepDays,hours=stepHours)
        while ((oEnd - cursorTime).total_seconds() >= 0 ):
            
            a = cursorTime 
            b = cursorTime + increment
            f.write(generateString(str(int(not restart)),
                                   (a-relativedelta(hours=+1)).strftime("%Y-%m-%dT%H:%M"), 
                                   a.strftime("%Y-%m-%dT%H:%M"),
                                   b.strftime("%Y-%m-%dT%H:%M") ,
                                   str(int((b-a).total_seconds()/3600)),
                                   TIME_LIMIT,
                                   str(restart)))
            f.write("\n")
            restart = 0 # JUST ONCE FOR EACH SIMULATION
            cursorTime += increment


def main():
    generateFromToWhile("1981-09-01 00:00","1982-09-01 00:00",1,0,0) 
    


if __name__ == "__main__":
    main()