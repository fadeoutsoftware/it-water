dos2unix .env-mergertime

docker run -it \
-u root \
--name merger \
--mount type=bind,source=./data/case_study_merger_time,target=/app/exec/data \
--mount type=bind,source=./data/case_study_merger_time/logs,target=/app/exec/logs \
--env-file .env-mergertime \
docker.io/it-water/mergertime:dev

docker rm merger
