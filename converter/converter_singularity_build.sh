
#cleanup previous versions 
rm converter.sif
rm converter.tar
# Build docker image
docker build --progress=plain -t it-water/converter:dev .
# Save image in tar format 
docker save it-water/converter:dev -o converter.tar
# Convert to singularity 
singularity build converter.sif docker-archive://converter.tar
