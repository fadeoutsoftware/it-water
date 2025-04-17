import calendar

def generateString (iRestart, oTimeRestart, oTimeStart, oTimeEnd, oTimePeriod, oSlurmTimeLimit, iS3MTerData):
    return iRestart + "          " + oTimeRestart + "    "+ oTimeStart + "  " + oTimeEnd +"  " + oTimePeriod + "            " + oSlurmTimeLimit + "        " + iS3MTerData

### DATE AND TIME TO START WITH 
### DELTA T PER RIGA 
### QUANTE RUN
### OCCHIO ORA ALLE DATE RESTART START END
### RESTART SEMPRE 23:00 giorno prima DELLO START

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
    generateOneYear(2024,1)
    


if __name__ == "__main__":
    main()