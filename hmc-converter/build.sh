
## DOS2UNIX launcher.sh
dos2unix ./launcher.sh
dos2unix ./app_converter_workflow_hmc_base_main.py
dos2unix ./app_converter_workflow_hmc_base.json

docker build --progress=plain -t it-water/hmc-converter-forcing:dev . 