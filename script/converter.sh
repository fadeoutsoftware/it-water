dos2unix .env-converter

docker run -it \
-u root \
--name converter \
--mount type=bind,source=./data/case_study_converter,target=/app/exec/data \
--mount type=bind,source=./data/case_study_converter/logs,target=/app/exec/logs \
--env-file .env-converter \
docker.io/it-water/converter:dev

docker rm converter