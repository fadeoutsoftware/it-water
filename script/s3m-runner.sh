docker run -it \
--name s3m-runner \
--mount type=bind,source=./data/case_study_s3m,target=/app/exec/data \
--env-file .env-s3m-runner \
docker.io/it-water/s3m-runner:dev


docker rm s3m-runner
