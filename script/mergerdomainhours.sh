dos2unix .env-mergerdomain

docker run -it \
-u root \
--name merger \
--mount type=bind,source=./data/case_study_merger_domain,target=/app/exec/data \
--mount type=bind,source=./data/case_study_merger_domain/logs,target=/app/exec/logs \
--env-file .env-mergerdomain_hours \
docker.io/it-water/mergerdomain_hours:dev

docker rm merger
 