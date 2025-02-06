
        
docker run /
--name hmc-runner /
--mount type=bind,source=/mnt/c/Users/m.menapace.FADEOUT/Documents/Fadeout/Projects/IT-WATER/case_study_hmc,target=$HOME/run_base/exec/ /
--env-file .env-hmc-runner /
docker.io/it-water/hmc-runner/:dev 