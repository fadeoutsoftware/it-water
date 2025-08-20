#!/usr/bin/env python3
import os
import sys
import argparse
import datetime
import calendar
import stat
import grp
from netCDF4 import Dataset
from collections import defaultdict

TARGET_MODE = 0o775
TARGET_GROUP = 'IscrC_IT-WATER'

def parse_args():
	parser = argparse.ArgumentParser(description="Check for missing or corrupted NetCDF files.")
	parser.add_argument("--scan_dir", required=True, help="Directory to scan for year folders.")
	parser.add_argument("--file_format", required=True, help="File format, e.g. REFF_%Y%m%d.nc")
	parser.add_argument("--output_dir", required=True, help="Directory to write missing/corrupted file list.")
	parser.add_argument("--skip_hourly_check", action="store_true", default=True, help="Skip check for hourly records (default: True).")
	parser.add_argument("--acl_check", action="store_true", default=False,
						help="Check and fix file ACL/group (default: False).")
	parser.add_argument("--start_date", type=str, default=None,
						help="Start date for missing/corrupt check in YYYY-MM-DD format (default: None, uses Jan 1 of first year found).")
	parser.add_argument("--end_date", type=str, default=None,
						help="End date for missing/corrupt check in YYYY-MM-DD format (must be last day of a month; default: None, uses Dec 31 of last year found).")
	return parser.parse_args()

def expected_dates(year):
	start = datetime.date(year, 1, 1)
	end = datetime.date(year, 12, 31)
	delta = datetime.timedelta(days=1)
	dates = []
	while start <= end:
		dates.append(start)
		start += delta
	return dates

def check_netcdf_hourly_integrity(filepath):
	"""
	Checks that the NetCDF file at filepath has:
	- 'nt' variable and dimension
	- 24 records in 'nt' dimension
	- 'units' attribute starting with 'hours since'
	- 'calendar' attribute equal to 'gregorian'
	Returns True if all checks pass, False otherwise.
	"""
	try:
		with Dataset(filepath, 'r') as ds:
			if 'nt' not in ds.dimensions or 'nt' not in ds.variables:
				return False
			if len(ds.dimensions['nt']) != 24:
				return False
			nt_var = ds.variables['nt']
			units = getattr(nt_var, 'units', None)
			calendar = getattr(nt_var, 'calendar', None)
			if units is None or not units.startswith('hours since'):
				return False
			if calendar is None or calendar != 'gregorian':
				return False
		return True
	except Exception:
		return False

def main():
	args = parse_args()
	scan_dir = args.scan_dir
	file_format = args.file_format
	output_dir = args.output_dir
	skip_hourly_check = args.skip_hourly_check
	acl_check = args.acl_check
	start_date_str = args.start_date
	end_date_str = args.end_date

	if not os.path.isdir(scan_dir):
		print(f"Scan directory {scan_dir} does not exist.")
		sys.exit(1)
	if not os.path.isdir(output_dir):
		os.makedirs(output_dir, exist_ok=True)

	# Determine start date
	years = [int(entry) for entry in os.listdir(scan_dir) if entry.isdigit() and os.path.isdir(os.path.join(scan_dir, entry))]
	if not years:
		print("No year directories found in scan_dir.")
		sys.exit(1)
	min_year = min(years)
	max_year = max(years)
	if start_date_str:
		try:
			start_date = datetime.datetime.strptime(start_date_str, "%Y-%m-%d").date()
		except Exception:
			print(f"Invalid start_date format: {start_date_str}. Use YYYY-MM-DD.")
			sys.exit(1)
	else:
		start_date = datetime.date(min_year, 1, 1)

	if end_date_str:
		try:
			end_date = datetime.datetime.strptime(end_date_str, "%Y-%m-%d").date()
		except Exception:
			print(f"Invalid end_date format: {end_date_str}. Use YYYY-MM-DD.")
			sys.exit(1)
		# Ensure end_date is the last day of a month
		next_day = end_date + datetime.timedelta(days=1)
		if next_day.day != 1:
			print(f"End date {end_date_str} is not the last day of a month.")
			sys.exit(1)
	else:
		end_date = datetime.date(max_year, 12, 31)

	missing_days = []
	for entry in os.listdir(scan_dir):
		year_path = os.path.join(scan_dir, entry)
		if not os.path.isdir(year_path):
			continue
		try:
			year = int(entry)
		except ValueError:
			continue
		# Skip entire year if it ends before start_date
		if datetime.date(year, 12, 31) < start_date:
			continue
		# Skip entire year if it starts after end_date
		if datetime.date(year, 1, 1) > end_date:
			continue
		for date in expected_dates(year):
			if date < start_date:
				continue
			if date > end_date:
				break
			filename = date.strftime(file_format)
			filepath = os.path.join(year_path, filename)
			is_missing = not os.path.isfile(filepath)
			is_corrupt = False
			if not is_missing and acl_check:
				try:
					st = os.stat(filepath)
					mode = stat.S_IMODE(st.st_mode)
					group_id = st.st_gid
					group_name = grp.getgrgid(group_id).gr_name
					# Check and amend permissions if needed
					if mode != TARGET_MODE:
						os.chmod(filepath, TARGET_MODE)
						print(f"Fixed permissions for {filepath} to {oct(TARGET_MODE)}.")
					# Amend group if needed
					if group_name != TARGET_GROUP:
						import shutil
						shutil.chown(filepath, group=TARGET_GROUP)
						print(f"Changed group for {filepath} to {TARGET_GROUP}.")
				except Exception as e:
					print(f"Failed to fix ACL/group for {filepath}: {e}")
			if not is_missing and not skip_hourly_check:
				if not check_netcdf_hourly_integrity(filepath):
					is_corrupt = True
			if is_missing or is_corrupt:
				missing_days.append(date)

	# Step 1: Group missing days by month
	
	month_groups = defaultdict(list)
	for d in missing_days:
		month_groups[(d.year, d.month)].append(d)

	# Step 2: For each month with missing files, generate a period file for the full month

	idx = 1
	for (year, month), days_list in sorted(month_groups.items()):
		# Get first and last day of the month
		first_day = datetime.date(year, month, 1)
		last_day = datetime.date(year, month, calendar.monthrange(year, month)[1])
		period_file = os.path.join(output_dir, f"periods-missing-{first_day.strftime('%Y%m%d')}-{last_day.strftime('%Y%m%d')}.{idx}")
		time_start = first_day.strftime('%Y-%m-%dT00:00')
		time_end = (last_day + datetime.timedelta(days=1)).strftime('%Y-%m-%dT00:00')
		days = (last_day - first_day).days + 1
		with open(period_file, "w") as pf:
			pf.write("TimeStart            TimeEnd              Days\n")
			pf.write(f"{time_start}     {time_end}     {days}\n")
		print(f"Missing/corrupt period file written: {period_file}")
		idx += 1

if __name__ == "__main__":
	main()
