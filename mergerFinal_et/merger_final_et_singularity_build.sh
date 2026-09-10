
#cleanup previous versions 
rm mergerfinal_et.sif
rm mergerfinal_et.tar
# Build docker image
docker build --progress=plain -t it-water/mergerfinal_et:dev .
# Save image in tar format 
docker save it-water/mergerfinal_et:dev -o mergerfinal_et.tar
# Convert to singularity 
singularity build mergerfinal_et.sif docker-archive://mergerfinal_et.tar
