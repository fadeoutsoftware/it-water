docker run \
--name converter \
--mount type=bind,source=/home/taxalb/data,target=/data \
docker.io/it-water/converter:dev

docker rm converter