# root image, base on LTS ubuntu
FROM ubuntu:24.04 AS builder

# image labels
# TODO


ARG DEBIAN_FRONTEND=noninteractive


# Setting required environment variables
ENV \
    # set geographical area
    TZ=Europe/Rome \
    # UID of the non-root user 'app'
    APP_UID=1456 \
	# set environment folder(s)
	ENTRYPOINT_DIR=/app/entrypoint/ \
	LIBS_INSTALLER_DIR=/app/library/libs_installer/ \	
	LIBS_PYTHON_DIR=/app/library/libs_python/ \
	#
	# TODO check this
	#
	PACKAGE_HMC_DIR=/app/library/package_hmc/ \ 	
	#
	# TODO check if belows ae fine for the converter
	#
	PYTHON_ENV_FILE=fp_env_python3_hmc_settings \
	PYTHON_ENV_DIR=fp_system_conda_python3_hmc_libraries \	
	PYTHON_ENV_REQ=requirements_fp_system_conda_python_hmc.yaml \
	# prepare share folder(s) to mount external repositories
	INPUT_DIR=/app/mnt_in/ \
	OUTPUT_DIR=/app/mnt_out/ \
	INPUT_STATIC_DIR=/app/mnt_in/data_static/ \
	INPUT_DYNAMIC_DIR=/app/mnt_in/data_dynamic/ \
	INPUT_MODEL_RESTART_DIR=/app/mnt_in/model_restart/ \
	OUTPUT_MODEL_RESULTS_DIR=/app/mnt_out/model_results/ \
	OUTPUT_MODEL_STATE_DIR=/app/mnt_out/model_state/

# install system-wide deps 
RUN apt-get update && apt-get install -y \
	git \
	curl \
	wget \
	libcurl4-openssl-dev \
	bash-completion

# Create a non-root user and group
RUN groupadd \
        --gid=$APP_UID \
        app \
    && useradd -l \
        --uid=$APP_UID \
        --gid=$APP_UID \
        --create-home \
        app  


# activate the application user
WORKDIR /app
RUN chown -R app:app /app
USER app

# create the required folders
RUN mkdir -p ${LIBS_INSTALLER_DIR} \
	&& mkdir -p ${PACKAGE_HMC_DIR} \
	&& mkdir -p ${ENTRYPOINT_DIR} \
	&& mkdir -p ${INPUT_DIR} \
	&& mkdir -p ${OUTPUT_DIR} \
	&& mkdir -p ${INPUT_STATIC_DIR} \
	&& mkdir -p ${INPUT_DYNAMIC_DIR} \
	&& mkdir -p ${INPUT_MODEL_RESTART_DIR} \
	&& mkdir -p ${OUTPUT_MODEL_RESULTS_DIR} \
	&& mkdir -p ${OUTPUT_MODEL_STATE_DIR}



# change default shell (from sh to bash)
SHELL ["/bin/bash", "-c"]



# TODO check brnaches, always replaced with master



# -----------------------------------------------------------------
# INSTALL - DOCKER PYTHON ENVS
# clone library from github repository
RUN git clone https://github.com/c-hydro/fp-system-env.git --branch main --single-branch /tmp/env_system
# copy files from tmp to container folder(s)
RUN cp -r /tmp/env_system/. ${LIBS_INSTALLER_DIR} 

# start installer script for python libraries
WORKDIR ${LIBS_INSTALLER_DIR}
RUN pwd
RUN ./setup_fp_system_conda_python_hmc.sh ${LIBS_PYTHON_DIR} ${PYTHON_ENV_FILE} ${PYTHON_ENV_DIR} ${PYTHON_ENV_REQ}


# -----------------------------------------------------------------
# INSTALL
# clone library from github repository
WORKDIR ${ENTRYPOINT_DIR}
RUN git clone https://github.com/c-hydro/fp-hmc.git --branch main --single-branch /tmp/package_hmc
# copy files from tmp to container folder(s)
RUN cp -r /tmp/package_hmc/. ${PACKAGE_HMC_DIR} 
RUN cp -r /tmp/package_hmc/tools/processing_tool_source2nc_converter/. ${ENTRYPOINT_DIR} 
# -----------------------------------------------------------------


# -----------------------------------------------------------------
# Runtime stage

FROM ubuntu:24.04

# Setting required environment variables  [TODO check if needed in multi-layer build]
ENV \
    # set geographical area
    TZ=Europe/Rome \
    # UID of the non-root user 'app'
    APP_UID=1456 \
	# set environment folder(s)
	ENTRYPOINT_DIR=/app/entrypoint/ \
	LIBS_INSTALLER_DIR=/app/library/libs_installer/ \	
	LIBS_PYTHON_DIR=/app/library/libs_python/ \
	#
	# TODO check this
	#
	PACKAGE_HMC_DIR=/app/library/package_hmc/ \ 	
	#
	# TODO check if belows ae fine for the converter
	#
	PYTHON_ENV_FILE=fp_env_python3_hmc_settings \
	PYTHON_ENV_DIR=fp_system_conda_python3_hmc_libraries \	
	PYTHON_ENV_REQ=requirements_fp_system_conda_python_hmc.yaml \
	# prepare share folder(s) to mount external repositories
	INPUT_DIR=/app/mnt_in/ \
	OUTPUT_DIR=/app/mnt_out/ \
	INPUT_STATIC_DIR=/app/mnt_in/data_static/ \
	INPUT_DYNAMIC_DIR=/app/mnt_in/data_dynamic/ \
	INPUT_MODEL_RESTART_DIR=/app/mnt_in/model_restart/ \
	OUTPUT_MODEL_RESULTS_DIR=/app/mnt_out/model_results/ \
	OUTPUT_MODEL_STATE_DIR=/app/mnt_out/model_state/

	# Create a non-root user and group
RUN groupadd \
	--gid=$APP_UID \
	app \
	&& useradd -l \
	--uid=$APP_UID \
	--gid=$APP_UID \
	--create-home \
	app  

# activate the application user
WORKDIR /app
RUN chown -R app:app /app
USER app

# create the required folders
RUN mkdir -p ${LIBS_INSTALLER_DIR} \
	&& mkdir -p ${PACKAGE_HMC_DIR} \
	&& mkdir -p ${ENTRYPOINT_DIR} \
	&& mkdir -p ${INPUT_DIR} \
	&& mkdir -p ${OUTPUT_DIR} \
	&& mkdir -p ${INPUT_STATIC_DIR} \
	&& mkdir -p ${INPUT_DYNAMIC_DIR} \
	&& mkdir -p ${INPUT_MODEL_RESTART_DIR} \
	&& mkdir -p ${OUTPUT_MODEL_RESULTS_DIR} \
	&& mkdir -p ${OUTPUT_MODEL_STATE_DIR}



# change default shell (from sh to bash)
SHELL ["/bin/bash", "-c"]


COPY --from=builder ${LIBS_PYTHON_DIR} ${LIBS_PYTHON_DIR}
COPY --from=builder ${PACKAGE_HMC_DIR} ${PACKAGE_HMC_DIR}
COPY --from=builder ${ENTRYPOINT_DIR} ${ENTRYPOINT_DIR} 


ENV PYTHON_ENV_FILE=${LIBS_PYTHON_DIR}/${PYTHON_ENV_FILE}
ENV PYTHONPATH=${PYTHONPATH}:/${PACKAGE_HMC_DIR}


# -----------------------------------------------------------------
# SET - DOCKER ENTRYPOINT
# set entrypoint
WORKDIR ${ENTRYPOINT_DIR}
COPY ./launcher.sh .
ENTRYPOINT ["./launcher.sh"]

# ENTRYPOINT /bin/bash
# -----------------------------------------------------------------

