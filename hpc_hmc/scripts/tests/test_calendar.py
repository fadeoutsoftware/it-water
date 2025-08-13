


# Standard library imports
import os
import pytest
from hpc_hmc.scripts.calendar import createMonthlyFiles

def test_create_monthly_files(tmp_path):
    """
    Test that create_monthly_files creates the correct files for a given date range using a temporary directory.
    """
    dummy_dir = tmp_path
    createMonthlyFiles(
        startYear=2022,
        startMonth=1,
        endYear=2022,
        endMonth=1,
        directory=str(dummy_dir)
    )
    expected_file = dummy_dir / "202201.time"
    assert expected_file.exists(), f"Missing file: {expected_file}"
    with expected_file.open("r", encoding="utf-8") as f:
        lines = f.readlines()
    assert lines[0].strip() == "TimeStart\tTimeEnd"
    assert lines[1].strip() == "2022-01-01T00:00\t2022-01-01T23:00"
    assert lines[-1].strip() == "2022-01-31T00:00\t2022-01-31T23:00"
