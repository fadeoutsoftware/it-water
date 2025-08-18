
#cleanup previous versions 
rm hmc-converter.sif
rm hmc-converter.tar
## DOS2UNIX launcher.sh
dos2unix ./launcher.sh
dos2unix ./app_converter_workflow_s3m_base.json
dos2unix ./app_converter_workflow_s3m_base_main.py

# Build docker image
docker build --no-cache --progress=plain -t it-water/hmc-converter:dev .
# Save image in tar format 
docker save it-water/hmc-converter:dev -o hmc-converter.tar
# Convert to singularity 
singularity build hmc-converter.sif docker-archive://hmc-converter.tar
