
#cleanup previous versions 
rm hmc-converter-forcing.sif
rm hmc-converter-forcing.tar
## DOS2UNIX launcher.sh
dos2unix ./launcher.sh
dos2unix ./app_converter_workflow_s3m_base.json
dos2unix ./app_converter_workflow_s3m_base_main.py

# Build docker image
docker build --no-cache --progress=plain -t it-water/hmc-converter-forcing:dev .
# Save image in tar format 
docker save it-water/hmc-converter-forcing:dev -o hmc-converter-forcing.tar
# Convert to singularity 
singularity build hmc-converter-forcing.sif docker-archive://hmc-converter-forcing.tar
