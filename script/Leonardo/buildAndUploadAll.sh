
echo " BEGIN Build all singularity images";
echo " converter 1/4";
(cd ../../converter/ ; sh converter_singularity_build.sh)
echo " merger 2/4";
(cd ../../merger/ ; sh merger_singularity_build.sh
echo " s3m 3/4";
(cd ../../s3m-runner/ ; sh s3m_singularity_build.sh)
echo " hmc 4/4";
(cd ../../hmc-runner/ ; sh hmc_singularity_build.sh)


