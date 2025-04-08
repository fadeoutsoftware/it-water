
#cleanup previous versions 
rm converter.sif
rm converter.tar
## DOS2UNIX launcher.sh
dos2unix ./launcher.sh
dos2unix ./app_converter_workflow_s3m_base.json
dos2unix ./app_converter_workflow_s3m_base_main.py

# Build docker image
docker build --progress=plain -t it-water/converter:dev .
# Save image in tar format 
docker save it-water/converter:dev -o converter.tar
# Convert to singularity 
singularity build converter.sif docker-archive://converter.tar
