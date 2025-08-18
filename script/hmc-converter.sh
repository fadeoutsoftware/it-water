dos2unix .env-hmc-converter

docker run -it \
-u root \
--name hmc-converter \
--mount type=bind,source=./data/case_study_hmc_converter,target=/app/exec/data \
--mount type=bind,source=./data/case_study_hmc_converter/logs,target=/app/exec/logs \
--env-file .env-hmc-converter \
docker.io/it-water/hmc-converter:dev

docker rm hmc-converter