docker run -it \
--name converter \
--env-file .env-converter \
docker.io/it-water/converter:dev

docker rm converter