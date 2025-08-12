
## DOS2UNIX launcher.sh
dos2unix ./launcher_serial.sh
dos2unix ./app_merger_by_time_workflow_s3m_base.json
dos2unix ./app_merger_by_time_workflow_s3m_base_main.py
dos2unix ./venvSetup.sh
dos2unix ./Dockerfile_days

docker build --progress=plain -t it-water/mergertime_days:dev -f Dockerfile_days .