
#cleanup previous versions 
rm mergerTime.sif
rm mergerTime.tar
# Build docker image
docker build --progress=plain -t it-water/mergerTime:dev .
# Save image in tar format 
docker save it-water/mergerTime -o mergerTime.tar
# Convert to singularity 
singularity build mergerTime.sif docker-archive://mergerTime.tar
