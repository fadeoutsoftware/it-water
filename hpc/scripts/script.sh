config=./setup.txt

## Reference file for the extraction of parameters for the orchestrator from a 
## specifically generated file.

## Note: cat + Sed to skip first line (the header)
rowCount=$(wc -l < ${config})
for (( i = 1; i < $rowCount; i++ )) 
do
    isRestart=$(cat ${config}|sed '1d'|awk -v var1=${i} 'NR==var1{print $1}')
    timeRestart=$(cat ${config}|sed '1d'|awk -v var1=${i} 'NR==var1{print $2}')
    timeStart=$(cat ${config}|sed '1d'|awk -v var1=${i} 'NR==var1{print $3}')
    timeEnd=$(cat ${config}|sed '1d'|awk -v var1=${i} 'NR==var1{print $4}')
    timePeriod=$(cat ${config}|sed '1d'|awk -v var1=${i} 'NR==var1{print $5}')
    slurmTimeLimit=$(cat ${config}|sed '1d'|awk -v var1=${i} 'NR==var1{print $6}')
    S3MTerData=$(cat ${config}|sed '1d'|awk -v var1=${i} 'NR==var1{print $7}')


    echo "Launching with " 
    echo "Restart mode " ${isRestart}
    echo "Restart Time " ${timeRestart}
    echo "Start Time " ${timeStart}
    echo "End Time " ${timeEnd}
    echo "Time Period " ${timePeriod}
    echo "Slurm Time limit " ${slurmTimeLimit}
    echo "S3M Ter Data " ${S3MTerData}
done