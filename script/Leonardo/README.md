## Leonardo scripts
This folder contains some script to be executed to interact with Leonardo HPC. 
The only user enabled in the environment is m.menapace@fadeout.it.
Login requires username + password + 2FA.
Small step must be installed. On WSL/Linux launch 

wget https://dl.smallstep.com/cli/docs-cli-install/latest/step-cli_amd64.deb
sudo dpkg -i step-cli_amd64.deb

Then a certificate from Leonardo must be added to the host machine (once and for all)
step ca bootstrap --ca-url=https://sshproxy.hpc.cineca.it --fingerprint 2ae1543202304d3f434bdc1a2c92eff2cd2b02110206ef06317e70c1c1735ecd

The actual login is launched with 
step ssh login m.menapace@fadeout.it --provisioner cineca-hpc

## Scripts
Before running each script a preliminary certificate generation is required with step command above.

### uploadHmcSif
After logging in, it uploads the hmc sif to the home directory 

### uploadS3mSif
After logging in, it uploads the s3m sif to the home directory

## Notes
#### Scratch directory
m.menapace@fadeout.it scratch directory is : 
/leonardo_scratch/large/userexternal/mmenapac

#### Installation of Singularity of the same version as CINECA LEONARDO 

wget https://github.com/sylabs/singularity/releases/download/v3.11.5/singularity-ce_3.11.5-focal_amd64.deb
sudo apt install uidmap
dpkg -i singularity-ce_3.11.5-focal_amd64.deb


#### Run command based on sif mounting data directory
*Example* :
singularity exec --writable-tmpfs --bind /home/marco/data/case_study_hmc:/app/exec/data --env-file ../script/.env-hmc-runner hmc.sif /app/shybox/workflow/runner/launcher.sh

#### Leonardo ssh connection issue 
If at login time an error message is displayed (fingerprint not validated in known host) follow these steps:
https://wiki.u-gov.it/confluence/display/SCAIUS/FAQ#FAQ-Ireceivetheerrormessage%22WARNING:REMOTEHOSTIDENTIFICATIONHASCHANGED!%22whentryingtologin
