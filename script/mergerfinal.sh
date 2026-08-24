dos2unix .env-mergerfinal

docker run -it \
-u root \
--name merger-final \
--mount type=bind,source=./data/case_study_merger_final,target=/app/exec/data \
--mount type=bind,source=./data/case_study_merger_final/logs,target=/app/exec/logs \
--env-file .env-mergerfinal \
docker.io/it-water/mergerfinal:dev

docker rm merger-final
