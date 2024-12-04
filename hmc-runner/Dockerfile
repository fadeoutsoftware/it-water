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
RUN ./setup_fp_system_library_hmc.sh ${LIBS_SYSTEM_DIR} ${SYSTEM_ENV_FILE}
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
RUN ./setup_fp_system_app_hmc.sh ${LIBS_SYSTEM_DIR} ${SYSTEM_ENV_FILE} ${LIBS_SYSTEM_DIR}
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
	&& mkdir -p ${OUTPUT_MODEL_STATE_DIR}



# change default shell (from sh to bash)
SHELL ["/bin/bash", "-c"]


COPY --from=builder ${LIBS_SYSTEM_DIR} ${LIBS_SYSTEM_DIR}
COPY --from=builder ${PACKAGE_HMC_DIR} ${PACKAGE_HMC_DIR}
COPY --from=builder ${ENTRYPOINT_DIR} ${ENTRYPOINT_DIR} 

#Required for point netcdf libs
ENV LD_LIBRARY_PATH "/app/library/libs_system:/app/library/libs_system/source/nc4_fortran/fortran/.libs/"

# set environmental variable(s) appending in .bashrc
RUN echo "source ${LIBS_SYSTEM_DIR}/${SYSTEM_ENV_FILE}" >> /home/app/.bashrc


# set environmental variable(s) appending in .profile
RUN echo "source ${LIBS_SYSTEM_DIR}/${SYSTEM_ENV_FILE}" >> /home/app/.profile

# -----------------------------------------------------------------


# Setup WebServer
# WORKDIR /app
# COPY ./app /app
# COPY ./requirements.txt /app/requirements.txt 
# COPY ./setup_server.sh /app/setup_server.sh
# COPY ./start_server.sh /app/start_server.sh
# RUN ./setup_server.sh ${LIBS_PYTHON_DIR} ${PYTHON_ENV_DIR}
# ENTRYPOINT ./start_server.sh




# -----------------------------------------------------------------
# SET - DOCKER ENTRYPOINT
# set entrypoint
WORKDIR ${ENTRYPOINT_DIR}
COPY ./launcher.sh ${ENTRYPOINT_DIR}
ENTRYPOINT ["bash"]
#CMD ["./launcher.sh", "-m", "hmc_tool_processing_source2nc_converter.py", "-c", "/data/config/hmc_tool_processing_sourcenc2nc_converter_s3m_itwater.json"]

# ENTRYPOINT /bin/bash
# -----------------------------------------------------------------

