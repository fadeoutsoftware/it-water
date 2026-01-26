import calendar
from datetime import datetime, timedelta
from dateutil.relativedelta import relativedelta
import json
import argparse
import os


def generateString(oTimeStart, oTimeEnd, iPeriod, iDays):
    """
    Support function to generate lines for the simulation setup.
    """
    return f"{oTimeStart.strftime('%Y-%m-%dT%H:%M')}     {oTimeEnd.strftime('%Y-%m-%dT%H:%M')}     {iPeriod}              {iDays}"


def generatePeriods(sFileName: str, startTime: str):
    """
    Generate the simulation startup parameters and write to file.
    """
    try:
        oStart = datetime.strptime(startTime, "%Y-%m-%d %H:%M")
        oEnd = oStart + relativedelta(months=1)
        iDays = (oEnd - oStart).days
        with open(sFileName, "w", encoding="utf-8") as f:
            f.write("TimeStart            TimeEnd              Period              Days\n")
            f.write(generateString(oStart, oEnd, iDays*24, iDays))
            f.write("\n")
        return oEnd
    except Exception as e:
        print(f"Error generating periods: {e}")
        return None


def loadControlFile(controlFile: str):
    """
    Load parameters from the control file and return as dict.
    """
    try:
        with open(controlFile, "r", encoding="utf-8") as f:
            params = json.load(f)
        # Check required parameters
        required = ["startTime", "endTime", "periodsFileName", "stopFileName"]
        for key in required:
            if key not in params:
                raise ValueError(f"Missing required parameter: {key}")
        # Check date formats
        date_format = "%Y-%m-%d %H:%M"
        try:
            datetime.strptime(params["startTime"], date_format)            
        except Exception as e:
            raise ValueError("startTime has invalid format, expected 'YYYY-MM-DD HH:MM', provided: " + params["startTime"]) from e
        try:
            datetime.strptime(params["endTime"], date_format)          
        except Exception as e:
            raise ValueError("endTime has invalid format, expected 'YYYY-MM-DD HH:MM', provided: " + params["endTime"]) from e


        # Check file names are non-empty strings
        if not isinstance(params["periodsFileName"], str) or not params["periodsFileName"].strip():
            raise ValueError("periodsFileName must be a non-empty string")
        if not isinstance(params["stopFileName"], str) or not params["stopFileName"].strip():
            raise ValueError("stopFileName must be a non-empty string")
        return params
    except Exception as e:
        raise RuntimeError(f"Error loading control file: {e}")

def updateControlFile(controlFile: str):
    """
    Update the control file with the next period and reset the restart flag.
    """
    try:
        with open(controlFile, "r", encoding="utf-8") as f:
            data = json.load(f)
        DATE_FORMAT = "%Y-%m-%d %H:%M"
        startTime = datetime.strptime(data["startTime"], DATE_FORMAT)
        increment = relativedelta(months=1)
        # Update the start time for the next period
        data["startTime"] = (startTime + increment).strftime(DATE_FORMAT)
        # Save the updated control file
        with open(controlFile, "w", encoding="utf-8") as f:
            json.dump(data, f, indent=4)
    except Exception as e:
        print(f"Error updating control file: {e}")


def main():
    """
    Main entry point: parse arguments, generate setup, update control file.
    """
    args = parse_args()
    try:
        params = loadControlFile(args.controlFile)
        # Generate the setup file
        oEnd = generatePeriods(params["periodsFileName"], params["startTime"])
        if oEnd is not None:
            newStartStr = oEnd.strftime("%Y-%m-%d %H:%M")
            # If new start time equals end time in control file, generate stop file
            if newStartStr == params["endTime"]:
                stop_file_name = params["stopFileName"]
                stop_file = os.path.join(os.path.dirname(params["periodsFileName"]), stop_file_name)
                with open(stop_file, "w", encoding="utf-8") as f:
                    f.write("STOP")
        # Update the control file for the next period
        updateControlFile(args.controlFile)
    except Exception as e:
        print(f"Error: {e}")
        exit(1)

def parse_args():
    """
    Parse command-line arguments.
    """
    parser = argparse.ArgumentParser(description="Generate simulation setup and update control file.")
    parser.add_argument("--controlFile", type=str, default="control.json", help="Path to the control file (default: control.json)")
    return parser.parse_args()


if __name__ == "__main__":
    main()