
## DOS2UNIX launcher.sh
dos2unix ./launcher.sh
dos2unix ./app_converter_workflow_s3m_base.json
dos2unix ./app_converter_workflow_s3m_base_main.py

docker build --no-cache --progress=plain -t it-water/converter:dev . 