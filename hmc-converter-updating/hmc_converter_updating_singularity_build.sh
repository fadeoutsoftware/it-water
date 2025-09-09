
#cleanup previous versions 
rm hmc-converter-updating.sif
rm hmc-converter-updating.tar
## DOS2UNIX launcher.sh
dos2unix ./launcher.sh
dos2unix ./app_converter_workflow_s3m_base.json
dos2unix ./app_converter_workflow_s3m_base_main.py

#chmod +x ./venvSetup.sh

# Build docker image
docker build --no-cache --progress=plain -t it-water/hmc-converter-updating:dev .
# Save image in tar format 
docker save it-water/hmc-converter-updating:dev -o hmc-converter-updating.tar
# Convert to singularity 
singularity build hmc-converter-updating.sif docker-archive://hmc-converter-updating.tar
