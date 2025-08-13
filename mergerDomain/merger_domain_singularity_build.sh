
#cleanup previous versions 
rm mergerdomain.sif
rm mergerdomain.tar
# Build docker image
#docker build --no-cache --progress=plain -t it-water/mergerdomain:dev .
# Save image in tar format 
docker save it-water/mergerdomain_hours:dev -o mergerdomain.tar
# Convert to singularity 
singularity build mergerdomain.sif docker-archive://mergerdomain.tar
