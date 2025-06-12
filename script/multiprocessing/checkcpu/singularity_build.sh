
#cleanup previous versions 
rm checkcpu.sif
rm checkcpu.tar
# Build docker image
docker build --no-cache --progress=plain -t it-water/checkcpu:dev .
# Save image in tar format 
docker save it-water/checkcpu -o checkcpu.tar
# Convert to singularity 
singularity build checkcpu.sif docker-archive://checkcpu.tar
