#!/bin/bash -e

#-----------------------------------------------------------------------------------------
# NOTE:
# Extra libraries (for preparing machine to install zip, hdf5 and netcdf libraries)
# sudo apt-get install gfortran
# sudo apt-get install gcc
# sudo apt-get install m4
# sudo apt-get install g++
# sudo apt-get install make
# sudo apt-get install libcurl4-openssl-dev
#-----------------------------------------------------------------------------------------

#-----------------------------------------------------------------------------------------
# Script information
script_name='FP ENVIRONMENT - SYSTEM LIBRARIES S3M'
script_version="1.0.2"
script_date='2025/01/21'

# Define file reference path according with https link(s)
fileref_zlib='http://www.zlib.net/current/zlib.tar.gz'
fileref_hdf5='https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.8/hdf5-1.8.17/src/hdf5-1.8.17.tar.gz'
fileref_nc4_c='https://github.com/Unidata/netcdf-c/archive/refs/tags/v4.6.0.tar.gz'
fileref_nc4_fortran='https://github.com/Unidata/netcdf-fortran/archive/refs/tags/v4.4.3.tar.gz'

# Argument(s) default definition(s)
fp_folder_root_default=$HOME/fp_system_libs_s3m
fileref_env_default='fp_system_libs_s3m'

# compiler option(s) :: value=[0,1] ---> error(s) due to the compiler version
flag_allow_argument_mismatch=1
# ----------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------
# Info script start
echo " ==================================================================================="
echo " ==> "$script_name" (Version: "$script_version" Release_Date: "$script_date")"
echo " ==> START ..."

# Get arguments number and values
script_args_n=$#
script_args_values=$@

echo ""
echo " ==> Script arguments number: $script_args_n"
echo " ==> Script arguments values: $script_args_values"
echo ""
echo " ==> Script arguments 1 - Directory of libraries [string: path]-> $1"
echo " ==> Script arguments 2 - Filename of system environment [string: filename] -> $2"
echo ""

# Get folder root path
if [ $# -eq 0 ]; then
    fp_folder_root=$fp_folder_root_default
	fileref_env=$fileref_env_default
elif [ $# -eq 1 ]; then
	fp_folder_root=$1
	fileref_env=$fileref_env_default
elif [ $# -eq 2 ]; then
	fp_folder_root=$1
	fileref_env=$2
fi

# Create root folder
if [ ! -d "$fp_folder_root" ]; then
	mkdir -p $fp_folder_root
fi

# Define folder path(s)
fp_folder_libs=$fp_folder_root
fp_folder_source=$fp_folder_libs/source

fp_folder_zlib=$fp_folder_libs/zlib
fp_folder_hdf5=$fp_folder_libs/hdf5
fp_folder_nc4_c=$fp_folder_libs/nc4
fp_folder_nc4_fortran=$fp_folder_libs/nc4

# Define environment filename
fp_file_env=$fp_folder_libs/$fileref_env

# Create folder(s)
if [ ! -d "$fp_folder_libs" ]; then
	mkdir -p $fp_folder_libs
fi
if [ ! -d "$fp_folder_source" ]; then
	mkdir -p $fp_folder_source
fi

# multilines comment: if [ 1 -eq 0 ]; then ... fi
# ----------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------
# Download library source codes
echo " ====> GET LIBRARY FILES ... "
cd $fp_folder_source
wget $fileref_zlib -O zlib.tar.gz
wget $fileref_hdf5 -O hdf5.tar.gz
wget $fileref_nc4_fortran -O nc4_fortran.tar.gz
wget $fileref_nc4_c -O nc4_c.tar.gz
echo " ====> GET LIBRARY FILES ... DONE!"
# ----------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------
# Install ZLIB library
echo " ====> COMPILE ZLIB LIBRARY ... "

fp_folder_source_zlib=$fp_folder_source/zlib
if [ ! -d "$fp_folder_source_zlib" ]; then
	mkdir -p $fp_folder_source_zlib
fi

tar -xvf zlib.tar.gz -C $fp_folder_source_zlib --strip-components=1
cd $fp_folder_source_zlib

./configure --prefix=$fp_folder_zlib

make
make install
cd $fp_folder_source

echo " ====> COMPILE ZLIB LIBRARY ... DONE!"
# ----------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------
# Install HDF5 library
echo " ====> COMPILE HDF5 LIBRARY ... "

fp_folder_source_hdf5=$fp_folder_source/hdf5
if [ ! -d "$fp_folder_source_hdf5" ]; then
	mkdir -p $fp_folder_source_hdf5
fi

tar -xvf hdf5.tar.gz -C $fp_folder_source_hdf5 --strip-components=1
cd $fp_folder_source_hdf5

CFLAGS=-O1 ./configure --with-zlib=$fp_folder_zlib --prefix=$fp_folder_hdf5

make
make install
cd $fp_folder_source

echo " ====> COMPILE HDF5 LIBRARY ... DONE!"
# ----------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------
# Install HDF5 library
echo " ====> COMPILE NETCDF-4 LIBRARY ... "

echo " =====> COMPILE C INTERFACE ... "
fp_folder_source_nc4_c=$fp_folder_source/nc4_c
if [ ! -d "$fp_folder_source_nc4_c" ]; then
	mkdir -p $fp_folder_source_nc4_c
fi

tar -xvf nc4_c.tar.gz -C $fp_folder_source_nc4_c --strip-components=1
cd $fp_folder_source_nc4_c

export CC=gcc
export CXX=g++
export FC=gfortran
export F77=gfortran
export F90=gfortran
export FFLAGS=-g
if [[ "$flag_allow_argument_mismatch" == 1 ]]; then
	export FCFLAGS="-w -fallow-argument-mismatch -O2" 	# fortran compiler or system/type version errors
	export FFLAGS="-w -fallow-argument-mismatch -O2" 	# fortran compiler or system/type version errors
fi
export CPPFLAGS=-DgFortran

LDFLAGS="-L${fp_folder_hdf5}/lib -L${fp_folder_zlib}/lib" CPPFLAGS="-I${fp_folder_hdf5}/include -I${fp_folder_zlib}/include/" ./configure --enable-netcdf-4 --enable-dap --enable-shared --prefix=$fp_folder_nc4_c --disable-doxygen

make
make install
cd $fp_folder_source

echo " =====> COMPILE C INTERFACE ... DONE!"

echo " =====> COMPILE FORTRAN INTERFACE ... DONE!"

fp_folder_source_nc4_fortran=$fp_folder_source/nc4_fortran
if [ ! -d "$fp_folder_source_nc4_fortran" ]; then
	mkdir -p $fp_folder_source_nc4_fortran
fi

tar -xvf nc4_fortran.tar.gz -C $fp_folder_source_nc4_fortran --strip-components=1
cd $fp_folder_source_nc4_fortran

export CC=gcc
export FC=gfortran
if [[ "$flag_allow_argument_mismatch" == 1 ]]; then
	export FCFLAGS="-w -fallow-argument-mismatch -O2" 	# fortran compiler or system/type version errors
	export FFLAGS="-w -fallow-argument-mismatch -O2" 	# fortran compiler or system/type version errors
else
	export FCFLAGS=""
	export FFLAGS=""
fi
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${fp_folder_nc4_c}/lib

LDFLAGS="-L${fp_folder_hdf5}/lib -L${fp_folder_zlib}/lib -L${fp_folder_nc4_c}/lib" CPPFLAGS="-I${fp_folder_hdf5}/include -I${fp_folder_zlib}/include -I${fp_folder_nc4_c}/include"  ./configure --prefix=${fp_folder_nc4_fortran}

make
make install
cd $fp_folder_source

echo " =====> COMPILE FORTRAN INTERFACE ... DONE!"

echo " ====> COMPILE NETCDF-4 LIBRARY ... DONE!"
# ----------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------
# Create environmental file
echo " ====> CREATE ENVIRONMENTAL FILE ... "

# Delete old version of environmetal file
cd $fp_folder_libs

if [ -f $fp_file_env ] ; then
    rm $fp_file_env
fi

# Export LIBRARY PATH(S)
echo "LD_LIBRARY_PATH="'$LD_LIBRARY_PATH'":$fp_folder_zlib/lib/:$fp_folder_hdf5/lib/:$fp_folder_nc4_c/lib/:$fp_folder_nc4_fortran/lib/" >> $fp_file_env
echo "export LD_LIBRARY_PATH" >> $fp_file_env

# Export BINARY PATH(S)
echo "PATH=$fp_folder_zlib/bin:$fp_folder_hdf5/bin:$fp_folder_nc4_c/bin:$fp_folder_nc4_fortran/bin:"'$PATH'"" >> $fp_file_env
echo "export PATH" >> $fp_file_env

echo " ====> CREATE ENVIRONMENTAL FILE ... DONE!"
# ----------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------
# Info script end
echo " ==> "$script_name" (Version: "$script_version" Release_Date: "$script_date")"
echo " ==> ... END"
echo " ==> Bye, Bye"
echo " ==================================================================================="
# ----------------------------------------------------------------------------------------





