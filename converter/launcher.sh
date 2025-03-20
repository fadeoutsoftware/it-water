#!/bin/bash -e

source $PYTHON_ENV_FILE

# Argument(s) constants definition(s)
path_entrypoint_app_main='app_converter_workflow_s3m_base_main.py'
path_entrypoint_app_configuration='/data/config/app_converter_workflow_s3m_base.json'



# ----------------------------------------------------------------------------------------
# Info script start
echo " ==================================================================================="
echo " ==> "$script_name" (Version: "$script_version" Release_Date: "$script_date")"
echo " ==> START ..."



# ----------------------------------------------------------------------------------------
# Check availability of file(s) 
echo " ===> Check entrypoint app main [$path_entrypoint_app_main] ... "
if [ -f $path_entrypoint_app_main ] ; then
	echo " ===> Check entrypoint app main ... OK"
else
	echo " ===> Check entrypoint app main ... FILE DOES NOT EXIST - FAILED" 
	exit 1
fi
echo " ===> Check entrypoint app configuration [$path_entrypoint_app_configuration] ... "
if [ -f $path_entrypoint_app_configuration ] ; then
	echo " ===> Check entrypoint app configuration ... OK"
else
	echo " ===> Check entrypoint app configuration ... FILE DOES NOT EXIST - FAILED" 
	exit 1
fi
# ----------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------
# Info 
echo echo " ===> ENTRYPOINT INTERFACE ... "

# Run interface application 
python $path_entrypoint_app_main -settings_file $path_entrypoint_app_configuration

echo echo " ===> ENTRYPOINT INTERFACE ... DONE"
# ----------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------
# Info script end
echo " ==> "$script_name" (Version: "$script_version" Release_Date: "$script_date")"
echo " ==> ... END"
echo " ==> Bye, Bye"
echo " ==================================================================================="
# ----------------------------------------------------------------------------------------

