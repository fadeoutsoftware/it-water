docker run -it \
--name hmc-runner \
--mount type=bind,source=./data/case_study_hmc,target=/app/exec/data \
--env-file .env-hmc-runner \
docker.io/it-water/hmc-runner:dev


docker rm hmc-runner
