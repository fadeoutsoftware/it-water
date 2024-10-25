#!/bin/bash -e

if [ -t 0 ] ; then
	echo "(interactive shell)"
	source $HOME/.bashrc
else
	echo "(not interactive shell)"
	source $HOME/.profile
fi

source ./hmc_tool_running_entrypoint_app_main.sh