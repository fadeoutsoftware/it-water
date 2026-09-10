
#cleanup previous versions 
rm mergerfinal.sif
rm mergerfinal.tar
# Build docker image
docker build --progress=plain -t it-water/mergerfinal_sm:dev .
# Save image in tar format 
docker save it-water/mergerfinal_sm:dev -o mergerfinal_sm.tar
# Convert to singularity 
singularity build mergerfinal_sm.sif docker-archive://mergerfinal_sm.tar
