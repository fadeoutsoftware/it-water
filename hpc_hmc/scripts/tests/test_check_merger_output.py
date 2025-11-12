import os
import tempfile
import shutil
import stat
import grp
import pytest
import datetime
from unittest import mock
from hpc_hmc.scripts import check_merger_output

# Helper to create a dummy NetCDF file with correct/incorrect structure
from netCDF4 import Dataset

def create_netcdf_file(path, nt_dim=24, units="hours since 2010-07-01 00:00:00", calendar="gregorian"):
    with Dataset(path, 'w', format='NETCDF4') as ds:
        ds.createDimension('nt', nt_dim)
        var = ds.createVariable('nt', 'i4', ('nt',))
        var.units = units
        var.calendar = calendar
        var[:] = range(nt_dim)

def test_missing_file(tmp_path):
    year_dir = tmp_path / "2025"
    year_dir.mkdir()
    file_path = year_dir / "REFF_20251201.nc"
    create_netcdf_file(str(file_path))
    args = mock.Mock()
    args.scan_dir = str(tmp_path)
    args.file_format = "REFF_%Y%m%d.nc"
    args.output_dir = str(tmp_path)
    args.skip_hourly_check = True
    args.acl_check = False
    args.start_date = None
    args.end_date = None
    with mock.patch("hpc_hmc.scripts.check_merger_output.parse_args", return_value=args):
        check_merger_output.main()
    files = list(tmp_path.glob("periods-missing-*.1"))
    assert files, "Missing period file not created"
    # Cleanup
    for f in files:
        f.unlink()
    for nc_file in year_dir.glob("*.nc"):
        nc_file.unlink()

def test_corrupt_file(tmp_path):
    year_dir = tmp_path / "2025"
    year_dir.mkdir()
    file_path = year_dir / "REFF_20251201.nc"
    create_netcdf_file(str(file_path), nt_dim=23)
    args = mock.Mock()
    args.scan_dir = str(tmp_path)
    args.file_format = "REFF_%Y%m%d.nc"
    args.output_dir = str(tmp_path)
    args.skip_hourly_check = False
    args.acl_check = False
    args.start_date = None
    args.end_date = None
    with mock.patch("hpc_hmc.scripts.check_merger_output.parse_args", return_value=args):
        check_merger_output.main()
    files = list(tmp_path.glob("periods-missing-*.1"))
    assert files, "Corrupt period file not created"
    # Cleanup
    for f in files:
        f.unlink()
    for nc_file in year_dir.glob("*.nc"):
        nc_file.unlink()

def test_acl_fix(tmp_path):
    year_dir = tmp_path / "2025"
    year_dir.mkdir()
    file_path = year_dir / "REFF_20251201.nc"
    create_netcdf_file(str(file_path))
    os.chmod(file_path, 0o644)
    args = mock.Mock()
    args.scan_dir = str(tmp_path)
    args.file_format = "REFF_%Y%m%d.nc"
    args.output_dir = str(tmp_path)
    args.skip_hourly_check = True
    args.acl_check = True
    args.start_date = None
    args.end_date = None
    with mock.patch("hpc_hmc.scripts.check_merger_output.parse_args", return_value=args), \
         mock.patch("shutil.chown") as mock_chown:
        check_merger_output.main()
    assert stat.S_IMODE(os.stat(file_path).st_mode) == check_merger_output.TARGET_MODE
    mock_chown.assert_called()
    # Cleanup
    for nc_file in year_dir.glob("*.nc"):
        nc_file.unlink()

def test_group_consecutive_periods(tmp_path):
    year_dir = tmp_path / "2025"
    year_dir.mkdir()
    # Create files for 2025-12-01 to 2025-12-16 (16 days)
    for i in range(1, 17):
        date = datetime.date(2025, 12, i)
        create_netcdf_file(str(year_dir / f"REFF_{date.strftime('%Y%m%d')}.nc"))
    # All days before 2025-12-01 are missing
    # 2025-12-17 to 2025-12-31 are missing

    args = mock.Mock()
    args.scan_dir = str(tmp_path)
    args.file_format = "REFF_%Y%m%d.nc"
    args.output_dir = str(tmp_path)
    args.skip_hourly_check = True
    args.acl_check = False
    args.start_date = None
    args.end_date = None
    with mock.patch("hpc_hmc.scripts.check_merger_output.parse_args", return_value=args):
        check_merger_output.main()
    files = sorted(tmp_path.glob("periods-missing-*.*"))
    assert files, "Period file for missing day not created"

    # Expect one file for each month with missing files: Jan-Nov 2025, Dec 2025
    expected_months = [(2025, m) for m in range(1, 12)] + [(2025, 12)]
    assert len(files) == len(expected_months), f"Expected {len(expected_months)} period files, got {len(files)}: {[str(f) for f in files]}"

    # Check each file covers the full month
    for (year, month), f in zip(expected_months, files):
        with open(f) as pf:
            lines = pf.readlines()
            assert len(lines) >= 2
            parts = lines[1].split()
            start_str = parts[0]
            end_str = parts[1]
            start_date = datetime.datetime.strptime(start_str, "%Y-%m-%dT%H:%M").date()
            end_date = datetime.datetime.strptime(end_str, "%Y-%m-%dT%H:%M").date()
            # Start date should be first of month
            assert start_date == datetime.date(year, month, 1), f"File {f} does not start at first of month"
            # End date should be first of next month
            if month < 12:
                expected_end = datetime.date(year, month + 1, 1)
            else:
                expected_end = datetime.date(year + 1, 1, 1)
            assert end_date == expected_end, f"File {f} does not end at first of next month"

    # Cleanup
    for f in files:
        f.unlink()
    for nc_file in year_dir.glob("*.nc"):
        nc_file.unlink()

if __name__ == "__main__":
    pytest.main()
