dos2unix .env-mergertime_days

docker run -it \
-u root \
--name merger \
--mount type=bind,source=./data/case_study_merger_time,target=/app/exec/data \
--mount type=bind,source=./data/case_study_merger_time/logs,target=/app/exec/logs \
--env-file .env-mergertime_days \
docker.io/it-water/mergertime_days:dev

docker rm merger
