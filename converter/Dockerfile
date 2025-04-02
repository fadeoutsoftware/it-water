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
	LIBS_SYSTEM_DIR=/app/library/libs_system/ \
	#
	# TODO check this
	#
	PACKAGE_HMC_DIR=/app/library/package_hmc/ \ 	
	# set environment filename(s)
	SYSTEM_ENV_FILE=fp_env_system \
	#
	# TODO check if belows ae fine for the converter
	#
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
	gfortran \
	gcc \
	m4 \
	g++ \
	make \
	mc \
	curl \
	build-essential \
	wget \
	cmake \
	libcurl4-openssl-dev \
	tzdata \
	openjdk-8-jdk \
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


# TODO check if HMC is the right one

# TODO check branches, always replaced with master

# -----------------------------------------------------------------
# INSTALL - DOCKER SYSTEM LIBRARIES
# clone library from github repository
RUN git clone https://github.com/c-hydro/fp-system-library.git --branch main --single-branch /tmp/libs_system/
# copy files from tmp to container folder(s)
RUN cp -r /tmp/libs_system/. ${LIBS_INSTALLER_DIR} 
# start installer script for system libraries
WORKDIR ${LIBS_INSTALLER_DIR}
RUN pwd
RUN ./setup_fp_system_library_s3m.sh ${LIBS_SYSTEM_DIR} ${SYSTEM_ENV_FILE}
# -----------------------------------------------------------------


# -----------------------------------------------------------------
# INSTALL - DOCKER SYSTEM APPS
# clone library from github repository
RUN git clone https://github.com/c-hydro/fp-system-app.git --branch main --single-branch /tmp/app_system/
# copy files from tmp to container folder(s)
RUN cp -rf /tmp/app_system/. ${LIBS_INSTALLER_DIR} 

# start installer script for hmc libraries
WORKDIR ${LIBS_INSTALLER_DIR}
RUN pwd
RUN ./setup_fp_system_app_s3m.sh ${LIBS_SYSTEM_DIR} ${SYSTEM_ENV_FILE} ${PACKAGE_HMC_DIR}

### TODO ADD similar call in the S3M docker image generation

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
	gfortran \
	gcc \
	m4 \
	g++ \
	make \
	mc \
	curl \
	build-essential \
	wget \
	cmake \
	libcurl4-openssl-dev \
	tzdata \
	openjdk-8-jdk \
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
	&& mkdir -p ${OUTPUT_MODEL_STATE_DIR} \
	&& mkdir -p /app/shybox \
	&& mkdir -p /app/exec



# change default shell (from sh to bash)
#SHELL ["/bin/bash", "-c"]


COPY --from=builder ${LIBS_SYSTEM_DIR} ${LIBS_SYSTEM_DIR}
COPY --from=builder ${PACKAGE_HMC_DIR} ${PACKAGE_HMC_DIR}
COPY --from=builder ${ENTRYPOINT_DIR} ${ENTRYPOINT_DIR} 

#Required for point netcdf libs
ENV LD_LIBRARY_PATH="/app/library/libs_system:/app/library/libs_system/source/nc4_fortran/fortran/.libs/"

# set environmental variable(s) appending in .bashrc
RUN echo "source ${LIBS_SYSTEM_DIR}/${SYSTEM_ENV_FILE}" >> /home/app/.bashrc


# set environmental variable(s) appending in .profile
RUN echo "source ${LIBS_SYSTEM_DIR}/${SYSTEM_ENV_FILE}" >> /home/app/.profile

# -----------------------------------------------------------------

# -----------------------------------------------------------------




### New repository SHYBOX
### TODO initialization of ENV variables 
WORKDIR /app/shybox
RUN git clone https://github.com/c-hydro/shybox.git --branch itwater --single-branch /app/shybox/

RUN /app/shybox/setup_conda_shybox_base.sh

ENV	CONDA_PATH=/app/shybox/conda

WORKDIR /app/shybox/workflow/converter
COPY venvSetup.sh /app/shybox/workflow/converter
RUN /app/shybox/workflow/converter/venvSetup.sh

COPY app_converter_workflow_s3m_base.json /app/shybox/workflow/converter
COPY app_converter_workflow_s3m_base_main.py /app/shybox/workflow/converter

COPY launcher.sh /app/shybox/workflow/converter
ENTRYPOINT ["./launcher.sh"]

