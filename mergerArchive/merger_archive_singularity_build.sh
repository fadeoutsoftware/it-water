
#cleanup previous versions 
rm mergerarchive.sif
rm mergerarchive.tar
# Build docker image
docker build --progress=plain -t it-water/mergerarchive:dev .
# Save image in tar format 
docker save it-water/mergerarchive:dev -o mergerarchive.tar
# Convert to singularity 
singularity build mergerarchive.sif docker-archive://mergerarchive.tar
