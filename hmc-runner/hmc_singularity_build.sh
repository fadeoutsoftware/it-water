
#cleanup previous versions 
rm hmc-runner.sif
rm hmc-runner.tar
# Build docker image
docker build --progress=plain -t it-water/hmc-runner:dev .
# Save image in tar format 
docker save it-water/hmc-runner -o hmc-runner.tar
# Convert to singularity 
singularity build hmc-runner.sif docker-archive://hmc-runner.tar
