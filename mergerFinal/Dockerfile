
FROM ubuntu:24.04
## setting bash as default 
SHELL ["/bin/bash", "-c"]
# Setting required environment variables  [TODO check if needed in multi-layer build]
ENV \
    # set geographical area
    TZ=Europe/Rome \
    # UID of the non-root user 'app'
    APP_UID=1456 \
	# set environment folder(s)
	ENTRYPOINT_DIR=/app/entrypoint/ \
	LIBS_INSTALLER_DIR=/app/library/libs_installer/ \
	LIBS_SYSTEM_DIR=/app/library/libs_system/ \
	#
	# TODO check this
	#
	# Match on PATH_EXEC on new version 
	PACKAGE_HMC_DIR=/app/library/package_hmc/ \ 	
	# set environment filename(s)
	SYSTEM_ENV_FILE=fp_env_system \
	# prepare share folder(s) to mount external repositories
	INPUT_DIR=/app/mnt_in/ \
	OUTPUT_DIR=/app/mnt_out/ \
	INPUT_STATIC_DIR=/app/mnt_in/data_static/ \
	INPUT_DYNAMIC_DIR=/app/mnt_in/data_dynamic/ \
	INPUT_MODEL_RESTART_DIR=/app/mnt_in/model_restart/ \
	OUTPUT_MODEL_RESULTS_DIR=/app/mnt_out/model_results/ \
	OUTPUT_MODEL_STATE_DIR=/app/mnt_out/model_state/

# install system-wide deps  <-> added to try to solve missing dependecies 
# on startup of HMC_Model_V3_\$RUN.x 
# Missing libgfortran.so.5: cannot open shared object file: No such file or directory 
# Solved with apt install apt-get install libgfortran5
# Missing
RUN apt-get update && apt-get install -y \
	git \
	curl \
	wget 
	#gfortran \
	# gcc \
	# m4 \
	# g++ \
	# make \
	# mc \ 
	# build-essential \
	# cmake \
	# libcurl4-openssl-dev \
	# tzdata \
	# openjdk-8-jdk \
	# bash-completion




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
	&& mkdir -p ${OUTPUT_MODEL_STATE_DIR} \
	&& mkdir -p /app/shybox \
	&& mkdir -p /app/exec



# change default shell (from sh to bash)
#SHELL ["/bin/bash", "-c"]


# set environmental variable(s) appending in .bashrc
RUN echo "source ${LIBS_SYSTEM_DIR}/${SYSTEM_ENV_FILE}" >> /home/app/.bashrc


# set environmental variable(s) appending in .profile
RUN echo "source ${LIBS_SYSTEM_DIR}/${SYSTEM_ENV_FILE}" >> /home/app/.profile

# -----------------------------------------------------------------

# -----------------------------------------------------------------




### New repository SHYBOX
### TODO initialization of ENV variables 
WORKDIR /app/shybox
RUN git clone https://github.com/c-hydro/shybox.git --branch main --single-branch /app/shybox/
RUN git fetch
RUN git checkout 03519c9b4e30714c69a48265720d7e62e4610a98

RUN /app/shybox/setup_shybox_base.sh

ENV	CONDA_PATH=/app/shybox/conda

WORKDIR /app/shybox/workflow/merger
#COPY venvSetup.sh /app/shybox/workflow/merger
#RUN /app/shybox/workflow/merger/venvSetup.sh

COPY app_merger_by_domain_workflow_hmc_et.json /app/shybox/workflow/merger
COPY app_merger_by_domain_workflow_hmc_et.py /app/shybox/workflow/merger

COPY launcher.sh /app/shybox/workflow/merger
ENTRYPOINT ["./launcher.sh"]
#RUN ["./launcher.sh"]
#ENTRYPOINT ["tail", "-f", "/dev/null"]





