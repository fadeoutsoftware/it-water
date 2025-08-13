import calendar
from datetime import datetime, timedelta
from dateutil.relativedelta import relativedelta
import json
import argparse


def generateString(iRestart, oTimeRestart, oTimeStart, oTimeEnd, oTimePeriod, oSlurmTimeLimit, iS3MTerData):
    """Support function to generate lines for the simulation setup."""
    return iRestart + "          " + oTimeRestart + "       " + oTimeStart + "     " + oTimeEnd + "     " + oTimePeriod + "            " + oSlurmTimeLimit + "        " + iS3MTerData


def generateFromToWhile(startTime: str,
                        stepMonths: int,
                        stepDays: int,
                        stepHours: int,
                        numSteps: int,
                        sFileName: str,
                        restart: int):
    """Generate the simulation startup parameters."""
    rate = stepMonths + (stepDays / 30) + (stepHours / (24 * 30))  # heuristic, good enough
    td = (timedelta(hours=2 * rate))
    TIME_LIMIT = str(td.days) + "-" + f"{(int(td.seconds / 3600)):02d}" + ":00:00"  # Need to be calculated
    DATE_FORMAT = "%Y-%m-%d %H:%M"
    increment = relativedelta(months=stepMonths, days=stepDays, hours=stepHours)

    # Calculate endTime based on numSteps
    oStart = datetime.strptime(startTime, DATE_FORMAT)
    oEnd = oStart + (increment * (numSteps - 1))

    with open(sFileName, "w", encoding="utf-8") as f:
        f.write("isRestart  TimeRestart            TimeStart            TimeEnd              TimePeriod     SlurmTimeLimit    S3MTerData\n")
        print("start " + str(oStart) + " end " + str(oEnd))
        cursorTime = oStart
        while ((oEnd - cursorTime).total_seconds() >= 0):
            a = cursorTime
            b = cursorTime + increment
            f.write(generateString(str(restart),
                                   (a - relativedelta(hours=+1)).strftime("%Y-%m-%dT%H:%M"),
                                   a.strftime("%Y-%m-%dT%H:%M"),
                                   b.strftime("%Y-%m-%dT%H:%M"),
                                   str(int((b - a).total_seconds() / 3600)),
                                   TIME_LIMIT,
                                   str(restart)))
            f.write("\n")
            restart = 0  # Reset restart after the first iteration
            cursorTime += increment


def loadControlFile(controlFile: str):
    """Load parameters from the control file."""
    with open(controlFile, "r", encoding="utf-8") as f:
        return json.load(f)


def updateControlFile(controlFile: str, stepMonths: int, stepDays: int, stepHours: int):
    """Update the control file with the next period and reset the restart flag."""
    with open(controlFile, "r", encoding="utf-8") as f:
        data = json.load(f)

    DATE_FORMAT = "%Y-%m-%d %H:%M"
    startTime = datetime.strptime(data["startTime"], DATE_FORMAT)
    increment = relativedelta(months=stepMonths, days=stepDays, hours=stepHours)

    # Update the start time for the next period
    data["startTime"] = (startTime + increment).strftime(DATE_FORMAT)

    # Reset the restart flag to zero
    data["restart"] = 0

    # Save the updated control file
    with open(controlFile, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=4)


def main():
    # Parse command-line arguments
    parser = argparse.ArgumentParser(description="Generate simulation setup and update control file.")
    parser.add_argument("--controlFile", type=str, default="control.json", help="Path to the control file (default: control.json)")
    args = parser.parse_args()

    controlFile = args.controlFile

    # Load parameters from the control file
    params = loadControlFile(controlFile)

    # Generate the setup file
    generateFromToWhile(params["startTime"],
                        params["stepMonths"],
                        params["stepDays"],
                        params["stepHours"],
                        params["numSteps"],
                        params["outputFileName"],
                        params["restart"])

    # Update the control file for the next period
    updateControlFile(controlFile, params["stepMonths"], params["stepDays"], params["stepHours"])


if __name__ == "__main__":
    main()