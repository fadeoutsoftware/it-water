dos2unix .env-mergerfinal_et

docker run -it \
-u root \
--name merger-final_et \
--mount type=bind,source=./data/case_study_merger_final,target=/app/exec/data \
--mount type=bind,source=./data/case_study_merger_final/logs,target=/app/exec/logs \
--env-file .env-mergerfinal_et \
docker.io/it-water/mergerfinal_et:dev

docker rm merger-final_sm
