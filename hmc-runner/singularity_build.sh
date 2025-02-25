
#cleanup previous versions 
rm hmc.sif
rm hmc.tar
# Build docker image
docker build --progress=plain -t it-water/hmc-runner:dev .
# Save image in tar format 
docker save it-water/hmc-runner -o hmc.tar
# Convert to singularity 
singularity build hmc.sif docker-archive://hmc.tar
