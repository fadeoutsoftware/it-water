Run in singularity, after creating the sif file

singularity exec --writable-tmpfs --bind ./data/case_study_s3m:/app/exec/data --env-file .env-s3m-
runner s3m.sif /app/shybox/workflow/runner/launcher.sh