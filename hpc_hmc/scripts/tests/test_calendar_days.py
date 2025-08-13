
# Standard library imports
import os
import pytest
from hpc_hmc.scripts.calendar import createMonthlyFiles


@pytest.mark.parametrize("year, month, expected_days", [
    (2021, 1, 31),   # January
    (2021, 2, 28),   # February (non-leap)
    (2020, 2, 29),   # February (leap)
    (2021, 3, 31),   # March
    (2021, 4, 30),   # April
    (2021, 5, 31),   # May
    (2021, 6, 30),   # June
    (2021, 7, 31),   # July
    (2021, 8, 31),   # August
    (2021, 9, 30),   # September
    (2021, 10, 31),  # October
    (2021, 11, 30),  # November
    (2021, 12, 31),  # December
])
def test_create_monthly_files_days(tmp_path, year, month, expected_days):
    """
    Test that createMonthlyFiles writes the correct header and lines for each day of the month using a temporary directory.
    """
    directory = tmp_path
    createMonthlyFiles(
        startYear=year,
        startMonth=month,
        endYear=year,
        endMonth=month,
        directory=str(directory)
    )
    filename = directory / f"{year}{month:02d}.time"
    assert filename.exists(), f"Missing file: {filename}"
    with filename.open("r", encoding="utf-8") as f:
        lines = f.readlines()
    assert lines[0].strip() == "TimeStart\tTimeEnd"
    # Check first and last day
    assert lines[1].strip() == f"{year}-{month:02d}-01T00:00\t{year}-{month:02d}-01T23:00"
    assert lines[-1].strip() == f"{year}-{month:02d}-{expected_days:02d}T00:00\t{year}-{month:02d}-{expected_days:02d}T23:00"


def test_create_monthly_files_leap_year(tmp_path):
    """
    Test that createMonthlyFiles writes correct header and daily lines for multiple months including leap year February using a temporary directory.
    """
    directory = tmp_path
    createMonthlyFiles(
        startYear=2020,
        startMonth=1,
        endYear=2020,
        endMonth=3,
        directory=str(directory)
    )
    expected = {
        directory / "202001.time": (2020, 1, 31),
        directory / "202002.time": (2020, 2, 29),
        directory / "202003.time": (2020, 3, 31),
    }
    for fname, (year, month, days) in expected.items():
        assert fname.exists(), f"Missing file: {fname}"
        with fname.open("r", encoding="utf-8") as f:
            lines = f.readlines()
        assert lines[0].strip() == "TimeStart\tTimeEnd"
        assert lines[1].strip() == f"{year}-{month:02d}-01T00:00\t{year}-{month:02d}-01T23:00"
        assert lines[-1].strip() == f"{year}-{month:02d}-{days:02d}T00:00\t{year}-{month:02d}-{days:02d}T23:00"
