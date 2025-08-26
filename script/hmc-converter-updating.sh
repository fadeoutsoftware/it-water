dos2unix .env-hmc-converter-updating

docker run -it \
-u root \
--name hmc-converter-updating \
--mount type=bind,source=./data/case_study_hmc_converter_updating,target=/app/exec/data \
--mount type=bind,source=./data/case_study_hmc_converter_updating/logs,target=/app/exec/logs \
--env-file .env-hmc-converter-updating \
docker.io/it-water/hmc-converter-updating:dev

docker rm hmc-converter-updating