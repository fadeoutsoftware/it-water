#!/bin/bash -e

if [ -t 0 ] ; then
	echo "(interactive shell)"
	source $HOME/.bashrc
else
	echo "(not interactive shell)"
	source $HOME/.profile
fi

# Argument(s) default definition(s)
fp_env_folder_root_default=$HOME/fp_system_env_conda
fp_env_folder_libraries_default='fp_system_conda_python3_hmc_libraries'

# Get arguments number and values
script_args_n=$#
script_args_values=$@

echo ""
echo " ==> Script arguments number: $script_args_n"
echo " ==> Script arguments values: $script_args_values"
echo ""
echo " ==> Script arguments 1 - Directory of libraries [string: path]-> $1"
echo " ==> Script arguments 2 - Name of virtual environment [string: name] -> $2"
echo ""

if [ $# -eq 0 ]; then
    fp_env_folder_root=$fp_env_tag_default
	fp_env_folder_libraries=$fp_env_folder_libraries_default
elif [ $# -eq 1 ]; then
    fp_env_folder_root=$1
	fp_env_folder_libraries=$fp_env_folder_libraries_default
elif [ $# -eq 2 ]; then
    fp_env_folder_root=$1
	fp_env_folder_libraries=$2
fi


echo " =====> INSTALLING SERVER REQUIREMENTS"
conda activate ${fp_env_folder_root}
pip install -r /app/requirements.txt
