
#cleanup previous versions 
rm s3m.sif
rm s3m.tar
# Build docker image
docker build --progress=plain -t it-water/s3m-runner:dev .
# Save image in tar format 
docker save it-water/s3m-runner -o s3m.tar
# Convert to singularity 
singularity build s3m.sif docker-archive://s3m.tar
