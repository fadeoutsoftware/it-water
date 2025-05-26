dos2unix .env-merger

docker run -it \
-u root \
--name merger \
--mount type=bind,source=./data/case_study_merger,target=/app/exec/data \
--mount type=bind,source=./data/case_study_merger/logs,target=/app/exec/logs \
--env-file .env-merger \
docker.io/it-water/merger:dev

docker rm merger
