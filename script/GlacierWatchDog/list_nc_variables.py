import os
from netCDF4 import Dataset

input_folder = 'input'
nc_filename = 'S3M_200309151200.nc'
nc_path = os.path.join(input_folder, nc_filename)

with Dataset(nc_path, 'r') as nc_file:
    print('Variables in the file:')
    for var in nc_file.variables:
        print(var)
