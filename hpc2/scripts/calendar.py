import os
import argparse
from datetime import datetime, timedelta

def createMonthlyFiles(startYear: int,
                      startMonth: int,
                      endYear: int,
                      endMonth: int,
                      directory: str = '.'):
    """
    Create files named 'YYYY_MM.time' for each month in the given time frame, containing a line for each day:
    'YYYY-MM-DD 00:00' 'YYYY-MM-DD 23:00', with a header line.

    Args:
        startYear (int): Starting year (e.g., 2022)
        startMonth (int): Starting month (1-12)
        endYear (int): Ending year (e.g., 2024)
        endMonth (int): Ending month (1-12)
        directory (str): Directory to create files in (default: current directory)
    """
    current = datetime(startYear, startMonth, 1)
    end = datetime(endYear, endMonth, 1)
    while current <= end:
        fileName = f"{current.year}{current.month:02d}.time"
        filePath = os.path.join(directory, fileName)
        # Calculate number of days in the current month
        if current.month == 12:
            nextMonth = datetime(current.year + 1, 1, 1)
        else:
            nextMonth = datetime(current.year, current.month + 1, 1)
        numDays = (nextMonth - current).days
        with open(filePath, "w", encoding="utf-8") as f:
            f.write("TimeStart\tTimeEnd\n")
            for day in range(numDays):
                dayDate = current.replace(day=1) + timedelta(days=day)
                startStr = dayDate.strftime("%Y-%m-%dT00:00")
                endStr = dayDate.strftime("%Y-%m-%dT23:00")
                f.write(f"{startStr}\t{endStr}\n")
        current = nextMonth



def main():
    parser = argparse.ArgumentParser(description="Create monthly files with number of days in each month.")
    parser.add_argument("--startYear", type=int, required=True, help="Starting year (e.g., 2022)")
    parser.add_argument("--startMonth", type=int, required=True, help="Starting month (1-12)")
    parser.add_argument("--endYear", type=int, required=True, help="Ending year (e.g., 2024)")
    parser.add_argument("--endMonth", type=int, required=True, help="Ending month (1-12)")
    parser.add_argument("--directory", type=str, default=".", help="Directory to create files in (default: current directory)")
    args = parser.parse_args()
    createMonthlyFiles(args.startYear, args.startMonth, args.endYear, args.endMonth, args.directory)

if __name__ == "__main__":
    main()