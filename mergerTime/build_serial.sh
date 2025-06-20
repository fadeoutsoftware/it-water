
## DOS2UNIX launcher.sh
dos2unix ./launcher.sh
dos2unix ./app_merger_by_time_workflow_s3m_base.json
dos2unix ./app_merger_by_time_workflow_s3m_base_main.py
dos2unix ./venvSetup.sh

docker build --no-cache --progress=plain -t it-water/mergertime_serial:dev -f Dockerfile_serial .