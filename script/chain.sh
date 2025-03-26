## script to execute the complete chain
##print first argument -> objective extract domain name to make parallel executions
#./chain.sh Marche
echo $1

## Execute the converter 
#./converter.sh
## Copy data for S3M e.g. 1981
#cp -r ./data/case_study_converter/output/* ./data/case_study_s3m/input

## Copy static asset for S3M considering the current Domain name -> TODO 
#cp -r ./data/case_study_converter/output ./data/case_study_s3m/input
# Rename the file as TerrainData

## Launch S3M 
#./s3m-runner.sh
## Copy data for the merger e.g. 1981
#cp -r ./data/case_study_s3m/output ./data/case_study_s3m/inputexit