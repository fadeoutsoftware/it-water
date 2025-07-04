## DOS2UNIX launcher.sh
dos2unix ./launcher.sh
dos2unix ./Dockerfile
dos2unix ./app_merger_by_domain_workflow_s3m_base.json
dos2unix ./app_merger_by_domain_workflow_s3m_base_main_parallel.py
dos2unix ./venvSetup.sh

docker build --progress=plain -t it-water/mergertime:dev . 