import calendar
from datetime import datetime,timedelta
from dateutil.relativedelta import relativedelta

def generateString (iRestart, oTimeRestart, oTimeStart, oTimeEnd, oTimePeriod, oSlurmTimeLimit, iS3MTerData):
    return iRestart + "          " + oTimeRestart + "    "+ oTimeStart + "  " + oTimeEnd +"  " + oTimePeriod + "            " + oSlurmTimeLimit + "        " + iS3MTerData

### DATE AND TIME TO START WITH 
### DELTA T PER RICAVARE RANGE DI OGNI RIGA/SIMULAZIONE
### OCCHIO ORA ALLE DATE RESTART START END
### RESTART SEMPRE 23:00 giorno prima DELLO START del primo giorno 

def generateFromTo (startTime, endTime, stepMonths):
    TIME_LIMIT = "0-02:00:01"
    DATE_FORMAT = "%Y-%m-%d %H:%M"
    with open('test.txt',"w", encoding="utf-8") as f:
        f.write("isRestart  TimeRestart            TimeStart            TimeEnd              TimePeriod       SlurmTimeLimit    S3MTerData\n")
        oStart= datetime.strptime(startTime, DATE_FORMAT)
        oEnd = datetime.strptime(endTime, DATE_FORMAT)
        

        print("start " + str(oStart) + " end "+ str(oEnd))
        # '1981-01-01 00:00' does not match format '%y-%m-%d %H:%M'
        restart = 1
        for i in range(1,stepMonths-1,1):
             
            a = oStart + relativedelta(months=+i-1)
            b = oStart + relativedelta(months=+i) 
            f.write(generateString(str(restart),
                                   str(a-relativedelta(hours=+1)), 
                                   str(a),
                                   str(b) ,
                                   str((b-a).total_seconds()/3600),
                                   TIME_LIMIT,
                                   str(int(not restart))))
            f.write("\n")
            restart = 0 # JUST ONCE FOR EACH SIMULATION

def generateFromToWhile (startTime, endTime, stepMonths,stepDays,stepHours):
    TIME_LIMIT = "0-02:00:01" ## Need to be calculated
    DATE_FORMAT = "%Y-%m-%d %H:%M"
    with open('testWhile.txt',"w", encoding="utf-8") as f:
        f.write("isRestart  TimeRestart            TimeStart            TimeEnd              TimePeriod       SlurmTimeLimit    S3MTerData\n")
        oStart= datetime.strptime(startTime, DATE_FORMAT)
        oEnd = datetime.strptime(endTime, DATE_FORMAT)
        

        print("start " + str(oStart) + " end "+ str(oEnd))
        # '1981-01-01 00:00' does not match format '%y-%m-%d %H:%M'
        restart = 1
        cursorTime = oStart
        increment = relativedelta(months=stepMonths,days=stepDays,hours=stepHours)
        while ((oEnd - cursorTime).total_seconds() >= 0 ):
            
            a = cursorTime 
            b = cursorTime + increment
            f.write(generateString(str(restart),
                                   str(a-relativedelta(hours=+1)), 
                                   str(a),
                                   str(b) ,
                                   str((b-a).total_seconds()/3600),
                                   TIME_LIMIT,
                                   str(int(not restart))))
            f.write("\n")
            restart = 0 # JUST ONCE FOR EACH SIMULATION
            cursorTime += increment

def generateOneYear (iYear, monthOfRestart):
    TIME_LIMIT = "0-02:00:01"
    with open('test.txt',"w", encoding="utf-8") as f:
        f.write("isRestart  TimeRestart   TimeStart   TimeEnd     TimePeriod    SlurmTimeLimit    S3MTerData\n")

        ## Suppose we start simulations at 01-01-Year
        for i in range(1,12,1):
            LastDayOfMonth = calendar.monthrange(iYear,i)[1]
            TimePeriod = 24 * LastDayOfMonth
            ### compute time limit 
            if monthOfRestart>=1:
                restart = 1 
            else:
                restart = 0
            currentMonth = "{:02d}".format(i)
            LastDayNumber = "{:02d}".format(LastDayOfMonth)
            f.write(generateString(str(restart),
                                   str(iYear-1) +"-31-12", 
                                   str(iYear) + "-" + currentMonth + "-01",
                                   str(iYear) + "-" + currentMonth + "-" + LastDayNumber  ,
                                   str(TimePeriod),
                                   TIME_LIMIT,"0"))
            f.write("\n")
            monthOfRestart -=1

def main():
    generateFromToWhile("2024-01-01 00:00","2026-01-15 00:00",1,15,12) 
    


if __name__ == "__main__":
    main()