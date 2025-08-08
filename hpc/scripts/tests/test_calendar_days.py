# Standard library imports
import os
import importlib.util
from unittest import mock
import pytest

# Dynamically import the create_monthly_files function from the local calendar.py
calendar_path = os.path.join(
    os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
    'calendar.py'
)
spec = importlib.util.spec_from_file_location('calendar_local', calendar_path)
calendar_local = importlib.util.module_from_spec(spec)
spec.loader.exec_module(calendar_local)
createMonthlyFiles = calendar_local.createMonthlyFiles


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
@mock.patch("builtins.open", new_callable=mock.mock_open)
@mock.patch("os.path.join", side_effect=lambda d, f: f"{d}/{f}")
def test_create_monthly_files_days(mock_join, mock_open, year, month, expected_days):
    """
    Test that createMonthlyFiles writes the correct header and lines for each day of the month.
    """
    directory = "/dummy"
    createMonthlyFiles(
        startYear=year,
        startMonth=month,
        endYear=year,
        endMonth=month,
        directory=directory
    )
    filename = f"{directory}/{year}{month:02d}.time"
    mock_open.assert_called_with(filename, "w", encoding="utf-8")
    handle = mock_open()
    handle.write.assert_any_call("TimeStart\tTimeEnd\n")
    # Check first and last day
    handle.write.assert_any_call(f"{year}-{month:02d}-01 00:00\t{year}-{month:02d}-01 23:00\n")
    handle.write.assert_any_call(f"{year}-{month:02d}-{expected_days:02d} 00:00\t{year}-{month:02d}-{expected_days:02d} 23:00\n")



@mock.patch("builtins.open", new_callable=mock.mock_open)
@mock.patch("os.path.join", side_effect=lambda d, f: f"{d}/{f}")
def test_create_monthly_files_leap_year(mock_join, mock_open):
    """
    Test that createMonthlyFiles writes correct header and daily lines for multiple months including leap year February.
    """
    directory = "/dummy"
    createMonthlyFiles(
        startYear=2020,
        startMonth=1,
        endYear=2020,
        endMonth=3,
        directory=directory
    )
    expected = {
        f"{directory}/202001.time": (2020, 1, 31),
        f"{directory}/202002.time": (2020, 2, 29),
        f"{directory}/202003.time": (2020, 3, 31),
    }
    calls = [mock.call(fname, "w", encoding="utf-8") for fname in expected.keys()]
    mock_open.assert_has_calls(calls, any_order=True)
    handle = mock_open()
    for fname, (year, month, days) in expected.items():
        # Check header and first/last day for each file
        handle.write.assert_any_call("TimeStart\tTimeEnd\n")
        handle.write.assert_any_call(f"{year}-{month:02d}-01 00:00\t{year}-{month:02d}-01 23:00\n")
        handle.write.assert_any_call(f"{year}-{month:02d}-{days:02d} 00:00\t{year}-{month:02d}-{days:02d} 23:00\n")
