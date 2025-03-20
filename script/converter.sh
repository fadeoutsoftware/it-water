docker run -it \
-u root \
--name converter \
--env-file .env-converter \
docker.io/it-water/converter:dev

docker rm converter