
import os
from netCDF4 import Dataset
import numpy as np
import re
from datetime import datetime
import csv

# Path to the input folder and file
input_folder = 'input'
nc_path = os.path.join(input_folder, nc_filename)

# Extract date and time from filename (format: S3M_YYYYMMDDHHMM.nc)
match = re.match(r"S3M_(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})", nc_filename)
if match:
    year, month, day, hour, minute = map(int, match.groups())
    file_datetime = datetime(year, month, day, hour, minute)
    date_str = file_datetime.strftime("%Y-%m-%d")
    time_str = file_datetime.strftime("%H:%M")
else:
    raise ValueError("Filename does not match expected pattern.")

# Path to the input folder
input_folder = 'input'
output_file = 'ice_thickness_stats.csv'

# Prepare output file header if needed
header = ['date', 'time', 'pixels_count', 'average']
write_header = not os.path.exists(output_file)
if write_header:
    with open(output_file, 'w', newline='') as f:
        writer = csv.writer(f)
        writer.writerow(header)

# Process all .nc files in the input directory
for nc_filename in os.listdir(input_folder):
    if not nc_filename.endswith('.nc'):
        continue
    nc_path = os.path.join(input_folder, nc_filename)

    # Extract date and time from filename (format: S3M_YYYYMMDDHHMM.nc)
    match = re.match(r"S3M_(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})", nc_filename)
    if match:
        year, month, day, hour, minute = map(int, match.groups())
        file_datetime = datetime(year, month, day, hour, minute)
        date_str = file_datetime.strftime("%Y-%m-%d")
        time_str = file_datetime.strftime("%H:%M")
    else:
        print(f"Skipping file with invalid name: {nc_filename}")
        continue

    with Dataset(nc_path, 'r') as nc_file:
        # Access the correct variable name: Ice_Thickness
        ice_thickness = nc_file.variables['Ice_Thickness'][:]
        # Count the number of pixels with value different from 0
        count_nonzero = np.count_nonzero(ice_thickness != 0)
        # Compute the average pixel value, excluding -9999 (nodata)
        valid_pixels = ice_thickness[ice_thickness != -9999]
        avg_value = np.mean(valid_pixels)

    # Prepare the row to append
    row = [date_str, time_str, int(count_nonzero), float(avg_value)]

    # Read previous rows and find the closest date
    closest_row = None
    closest_delta = None
    if os.path.exists(output_file):
        with open(output_file, 'r', newline='') as f:
            reader = csv.reader(f)
            next(reader, None)  # skip header
            for r in reader:
                try:
                    prev_dt = datetime.strptime(r[0] + ' ' + r[1], '%Y-%m-%d %H:%M')
                    delta = abs((file_datetime - prev_dt).total_seconds())
                    if closest_delta is None or delta < closest_delta:
                        closest_delta = delta
                        closest_row = r
                except Exception:
                    continue

    # Append the new row
    with open(output_file, 'a', newline='') as f:
        writer = csv.writer(f)
        writer.writerow(row)

    # Check ±20% range if a closest row exists
    if closest_row:
        prev_count = float(closest_row[2])
        prev_avg = float(closest_row[3])
        count_in_range = prev_count * 0.8 <= count_nonzero <= prev_count * 1.2
        avg_in_range = prev_avg * 0.8 <= avg_value <= prev_avg * 1.2
        print(f"{nc_filename} | Closest date: {closest_row[0]} {closest_row[1]}")
        print(f"Previous count: {prev_count}, New count: {count_nonzero}, Within ±20%: {count_in_range}")
        print(f"Previous avg: {prev_avg}, New avg: {avg_value}, Within ±20%: {avg_in_range}")
    else:
        print(f"{nc_filename} | No previous data to compare.")

    print(f"{nc_filename} | Number of pixels with Ice_Thickness != 0: {count_nonzero}")
    print(f"{nc_filename} | Average pixel value of Ice_Thickness (excluding -9999): {avg_value}")
