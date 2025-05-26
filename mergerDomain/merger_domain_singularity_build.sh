
#cleanup previous versions 
rm mergerdomain.sif
rm mergerdomain.tar
# Build docker image
docker build --progress=plain -t it-water/mergerdomain:dev .
# Save image in tar format 
docker save it-water/mergerdomain -o mergerdomainDomain.tar
# Convert to singularity 
singularity build mergerdomain.sif docker-archive://mergerdomain.tar
