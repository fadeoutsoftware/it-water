
## DOS2UNIX launcher.sh
dos2unix ./launcher.sh
dos2unix ./app_converter_workflow_hmc_base_main.py
dos2unix ./app_converter_workflow_hmc_base.json
dos2unix ./venvSetup.sh
dos2unix ./setup_fp_system_app_hmc.sh

docker build --no-cache --progress=plain -t it-water/hmc-converter-forcing:dev . 