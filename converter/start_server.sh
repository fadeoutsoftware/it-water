#!/bin/bash -e

if [ -t 0 ] ; then
	echo "(interactive shell)"
	source $HOME/.bashrc
else
	echo "(not interactive shell)"
	source $HOME/.profile
fi

flask --app main run --host=0.0.0.0 --port=80