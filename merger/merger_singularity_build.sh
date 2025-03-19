
#cleanup previous versions 
rm merger.sif
rm merger.tar
# Build docker image
docker build --progress=plain -t it-water/merger:dev .
# Save image in tar format 
docker save it-water/merger -o merger.tar
# Convert to singularity 
singularity build merger.sif docker-archive://merger.tar
