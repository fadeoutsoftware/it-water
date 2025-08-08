

# Standard library imports
import os
import importlib.util
from unittest import mock

# Dynamically import the create_monthly_files function from the local calendar.py
calendar_path = os.path.join(
    os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
    'calendar.py'
)
spec = importlib.util.spec_from_file_location('calendar_local', calendar_path)
calendar_local = importlib.util.module_from_spec(spec)
spec.loader.exec_module(calendar_local)
createMonthlyFiles = calendar_local.createMonthlyFiles


# Use a pytest fixture for the temporary directory




class TestCalendar:
    @mock.patch("builtins.open", new_callable=mock.mock_open)
    def test_create_monthly_files(self, mock_open):
        """
        Test that create_monthly_files creates the correct files for a given date range.
        The file system is mocked to avoid creating real files.
        """
        dummy_dir = "/dummy"
        createMonthlyFiles(
            startYear=2022,
            startMonth=1,
            endYear=2022,
            endMonth=1,
            directory=dummy_dir
        )
    expected_file = f"{dummy_dir}/202201.time"
    actual_files = [call_args[0][0] for call_args in mock_open.call_args_list]
    assert expected_file in actual_files, f"Missing file: {expected_file}"
    # Check header and a few lines
    mock_open().write.assert_any_call("TimeStart\tTimeEnd\n")
    mock_open().write.assert_any_call("2022-01-01T00:00\t2022-01-01T23:00\n")
    mock_open().write.assert_any_call("2022-01-31T00:00\t2022-01-31T23:00\n")
