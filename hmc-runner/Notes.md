
## TODOs
1) Need to check ont the second stage if we can safely remove the APT stuff

2) Mount example volumes, so far libraries and executable seems ok 

3) Check passing launcher name list as argument of the docker container

Useful command (within this folder..)
build image: 
```docker build -t hmc-runner .```

re-build all reporting all the build logs output:
```docker build --progress=plain --no-cache .```

re-build all and save the output in a separated file build.log:
```docker build --progress=plain --no-cache . > build.log```

Open a bash shell in the container 
```
docker exec -it [container_id] ---user root /bin/bash
```


Working command within the docker container (tested with bash from docker exec)

This has required the adaptation of the root folders in the :
 
/app/library/libs_system/hmc/HMC_Model_V3_\$RUN.x /app/mnt_in/namelist/marche.info.txt

/app/library/libs_system/hmc/HMC_Model_V3_\$RUN.x /app/mnt_in/namelist/marche.info.txt

BUILD 
```
docker build -t hmc-runner .
```

RUN
```
docker run -itd \\
-v C:\Users\m.menapace.FADEOUT\Documents\Fadeout\Projects\IT-WATER\it-water\data\case_study_hmc:/app/mnt_in \\
-v C:\Users\m.menapace.FADEOUT\Documents\Fadeout\Projects\IT-WATER\it-water\data\case_study_hmc_out:/app/mnt_out \\
 hmc-runner
```

SAVE image to a TAR file:
```
docker save hmc-runner -o hmc-runner.ta
```

Upload image on our server:
```
scp .\hmc-runner.tar [user]@[ip]]:/home/fadeout
```

Upload source data on our server: 

RUN
docker run -itd -v C:\Users\m.menapace.FADEOUT\Documents\Fadeout\Projects\IT-WATER\it-water\data\case_study_hmc:/app/mnt_in -v C:\Users\m.menapace.FADEOUT\Documents\Fadeout\Projects\IT-WATER\it-water\data\case_study_hmc_out:/app/mnt_out hmc-runner
docker run -itd -v ~/it-water/case_study_hmc:/app/mnt_in -v ~/it-water/case_study_hmc_out:/app/mnt_out hmc-runner


TODO : 
- Check if reloading image from tar it works in the environment where the image was produced -> yes it does 
- Try to reboot the machine after docker installation -> not solved 
- Try to align the docker version between the machines -> TODO

### Testing singularity 
Convert tar image to singularity:
```singularity build --sandbox  docker-archive://hmc-runner.tar```