
#cleanup previous versions 
rm mergerfinal.sif
rm mergerfinal.tar
# Build docker image
docker build --progress=plain -t it-water/mergerfinal:dev .
# Save image in tar format 
docker save it-water/mergerfinal:dev -o mergerfinal.tar
# Convert to singularity 
singularity build mergerfinal.sif docker-archive://mergerfinal.tar
