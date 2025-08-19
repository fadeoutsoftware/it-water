docker run -it \
--name hmc-runner \
--mount type=bind,source=./data/case_study_hmc,target=/app/exec/data \
--mount type=bind,source=./data/case_study_hmc/static/MarcheDomain,target=/app/exec/data/data_geo \
--mount type=bind,source=./data/case_study_hmc/input,target=/app/exec/data/data_forcing/gridded \
--env-file .env-hmc-runner \
docker.io/it-water/hmc-runner:dev


docker rm hmc-runner
