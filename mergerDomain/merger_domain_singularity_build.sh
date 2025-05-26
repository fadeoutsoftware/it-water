
#cleanup previous versions 
rm mergerDomain.sif
rm mergerDomain.tar
# Build docker image
docker build --progress=plain -t it-water/mergerDomain:dev .
# Save image in tar format 
docker save it-water/mergerDomain -o mergerDomainDomain.tar
# Convert to singularity 
singularity build mergerDomain.sif docker-archive://mergerDomain.tar
