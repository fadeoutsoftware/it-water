config=./example_parameters.txt
isRestart=$(cat example_parameters.txt|sed '1d'|awk '{print $1}')
timeRestart=$(cat example_parameters.txt|sed '1d'|awk '{print $2}')
timeStart=$(cat example_parameters.txt|sed '1d'|awk '{print $3}')
timeEnd=$(cat example_parameters.txt|sed '1d'|awk '{print $4}')