# Launch 6 processes to check dates in both S3M input and S3m Output
screen -dm bash -c '$WORK/check_date_sequence.sh /g100_scratch/userexternal/mmenapac/shared/S3M_input/reanalysis/ --loop-subfolders > $WORK/Check/Check_S3M_Input_reanalysis.txt'
screen -dm bash -c '$WORK/check_date_sequence.sh /g100_scratch/userexternal/mmenapac/shared/S3M_input/rcp45/ --loop-subfolders > $WORK/Check/Check_S3M_Input_rcp45.txt'
screen -dm bash -c '$WORK/check_date_sequence.sh /g100_scratch/userexternal/mmenapac/shared/S3M_input/rcp85 --loop-subfolders > $WORK/Check/Check_S3M_Input_rcp85.txt'

screen -dm bash -c '$WORK/check_date_sequence.sh /g100_scratch/userexternal/mmenapac/shared/S3M_output/reanalysis/ --loop-subfolders > $WORK/Check/Check_S3M_Output_reanalysis.txt'
screen -dm bash -c '$WORK/check_date_sequence.sh /g100_scratch/userexternal/mmenapac/shared/S3M_output/rcp45/ --loop-subfolders > $WORK/Check/Check_S3M_Output_rcp45.txt'
screen -dm bash -c '$WORK/check_date_sequence.sh /g100_scratch/userexternal/mmenapac/shared/S3M_output/rcp85/ --loop-subfolders > $WORK/Check/Check_S3M_Output_rcp85.txt'