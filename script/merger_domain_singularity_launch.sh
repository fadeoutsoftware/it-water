    # Example of local execution with singularity
# NOTE all folders must be declared and ABSOLUTE ! (locally referenced here)
time_start='2003-10-01 00:00'
time_end='2003-10-05 23:00'

path_data="/mnt/c/Users/m.menapace.FADEOUT/Documents/Fadeout/Projects/IT-WATER/it-water/script/data/case_study_merger_domain/"
path_input="/mnt/c/Users/m.menapace.FADEOUT/Documents/Fadeout/Projects/IT-WATER/it-water/script/data/case_study_merger_domain/input/"
path_destination="/mnt/c/Users/m.menapace.FADEOUT/Documents/Fadeout/Projects/IT-WATER/it-water/script/data/case_study_merger_domain/output/"
path_log="/mnt/c/Users/m.menapace.FADEOUT/Documents/Fadeout/Projects/IT-WATER/it-water/script/data/case_study_merger_domain/logs/"
path_geo="/mnt/c/Users/m.menapace.FADEOUT/Documents/Fadeout/Projects/IT-WATER/it-water/script/data/case_study_merger_domain/static/"

singularity exec --writable-tmpfs \
 --env PATH_APP=/app/exec/ \
 --env PATH_SRC=/app/exec/data/input \
 --env PATH_DST=/app/exec/data/output/ \
 --env PATH_TMP=/app/exec/data/tmp/ \
 --env PATH_LOG=/app/exec/data/logs/ \
 --env PATH_GEO=/app/exec/data/static \
 --env TIME_START="${time_start}" \
 --env TIME_END="${time_end}" \
 --bind ${path_data}:/app/exec/data/,${path_input}:/app/exec/data/input,${path_destination}:/app/exec/data/output,${path_geo}:/app/exec/data/static,${path_log}:/app/exec/data/logs,\
 mergerdomain.sif /app/shybox/workflow/merger/launcher_hours.sh