dos2unix .env-mergerfinal_sm

docker run -it \
-u root \
--name merger-final_sm \
--mount type=bind,source=./data/case_study_merger_final,target=/app/exec/data \
--mount type=bind,source=./data/case_study_merger_final/logs,target=/app/exec/logs \
--env-file .env-mergerfinal_sm \
docker.io/it-water/mergerfinal_sm:dev

docker rm merger-final_sm
