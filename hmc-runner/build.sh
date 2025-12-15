## DOS2UNIX launcher.sh
dos2unix ./launcher.sh
dos2unix ./Dockerfile
dos2unix ./app_runner_workflow_hmc_base.json
dos2unix ./app_runner_workflow_hmc_base_main.py
dos2unix ./venvSetup.sh

docker build --no-cache --progress=plain -t it-water/hmc-runner:dev .