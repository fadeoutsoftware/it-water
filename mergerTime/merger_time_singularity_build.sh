
#cleanup previous versions 
rm mergertime.sif
rm mergertime.tar
# Build docker image
docker build --no-cache --progress=plain -t it-water/mergertime_days:dev .
# Save image in tar format 
docker save it-water/mergertime_days:dev -o mergertime.tar
# Convert to singularity 
singularity build mergertime.sif docker-archive://mergertime.tar
