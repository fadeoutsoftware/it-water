## DOS2UNIX launcher.sh
dos2unix ./launcher.sh
dos2unix ./app_runner_workflow_s3m_base.json
dos2unix ./venvSetup.sh

# Build docker image
docker build --progress=plain -t it-water/s3m-runner:dev .