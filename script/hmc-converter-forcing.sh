dos2unix .env-hmc-converter-forcing

docker run -it \
-u root \
--name hmc-converter-forcing \
--mount type=bind,source=./data/case_study_hmc_converter_forcing,target=/app/exec/data \
--mount type=bind,source=./data/case_study_hmc_converter_forcing/logs,target=/app/exec/logs \
--env-file .env-hmc-converter-forcing \
docker.io/it-water/hmc-converter-forcing:dev

docker rm hmc-converter-forcing