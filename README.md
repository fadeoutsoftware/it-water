# it-water
Repo for it-water related activities 


### Folder structure
The project is organized in several folder.
Each one represents a single step of the elaboration:

- *converter* is the first step of the algorithm 
- 


### Input/Output data
The data should be mounted for the during the execution of the container.

Reference command :
```
docker run -v [host_dir]:[container_dir] [...]
```

All docker images relies on the following internal directory organization:

```	
    INPUT_DIR=/app/mnt_in/ \
	OUTPUT_DIR=/app/mnt_out/ \
	INPUT_STATIC_DIR=/app/mnt_in/data_static/ \
	INPUT_DYNAMIC_DIR=/app/mnt_in/data_dynamic/ \
	INPUT_MODEL_RESTART_DIR=/app/mnt_in/model_restart/ \
	OUTPUT_MODEL_RESULTS_DIR=/app/mnt_out/model_results/ \
	OUTPUT_MODEL_STATE_DIR=/app/mnt_out/model_state/
```