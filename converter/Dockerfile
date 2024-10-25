# root image, base on LTS ubuntu
FROM ubuntu:24.04 AS builder

# image labels
# TODO

# change default shell (from sh to bash)
SHELL ["/bin/bash", "-c"]


ARG DEBIAN_FRONTEND=noninteractive

ENV \
    # set geographical area
    TZ=Europe/Rome \
    # UID of the non-root user 'app'
    APP_UID=1456 \
	# set environment folder(s)
	fp_folder_entrypoint=/app/entrypoint/ \
	fp_folder_libs_installer=/app/library/libs_installer/ \
	fp_folder_libs_system=/app/library/libs_system/ \
	fp_folder_libs_python=/app/library/libs_python/ \
	#
	# TODO check this
	#
	fp_folder_package_hmc=/app/library/package_hmc/ \ 
	fp_folder_mount_in=/app/mnt_in/ \
	fp_folder_mount_out=/app/mnt_out/ \
	# set environment filename(s)
	fp_file_env_system=fp_env_system \
	#
	# TODO check if belows ae fine for the converter
	#
	fp_file_env_python=fp_env_python3_hmc_settings \
	fp_folder_env_python=fp_system_conda_hmc_libraries \	
	fp_requirements_env_python=requirements_fp_system_conda_python_hmc.yaml 

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
USER app
WORKDIR /app

# create the required folders
RUN mkdir -p ${fp_folder_libs_installer} \
	&& mkdir -p ${fp_folder_package_hmc} \
	&& mkdir -p ${fp_folder_entrypoint} \
	&& mkdir -p ${fp_folder_mount_in} \
	&& mkdir -p ${fp_folder_mount_out}

# TODO check if HMC is the right one

# TODO check brnaches, always replaced with master

# -----------------------------------------------------------------
# INSTALL - DOCKER SYSTEM LIBRARIES
# clone library from github repository
RUN git clone https://github.com/c-hydro/fp-system-library.git --branch main --single-branch /tmp/libs_system/
# copy files from tmp to container folder(s)
RUN cp -r /tmp/libs_system/. ${fp_folder_libs_installer} 
# start installer script for system libraries
WORKDIR ${fp_folder_libs_installer}
RUN pwd
RUN ./setup_fp_system_library_hmc.sh ${fp_folder_libs_system} ${fp_file_env_system}
# -----------------------------------------------------------------


# -----------------------------------------------------------------
# INSTALL - DOCKER SYSTEM APPS
# clone library from github repository
RUN git clone https://github.com/c-hydro/fp-system-app.git --branch main --single-branch /tmp/app_system/
# copy files from tmp to container folder(s)
RUN cp -rf /tmp/app_system/. ${fp_folder_libs_installer} 

# start installer script for hmc libraries
WORKDIR ${fp_folder_libs_installer}
RUN pwd
RUN ./setup_fp_system_app_hmc.sh ${fp_folder_libs_system} ${fp_file_env_system} ${fp_folder_libs_system}
# -----------------------------------------------------------------

# -----------------------------------------------------------------
# INSTALL - DOCKER PYTHON ENVS
# clone library from github repository
RUN git clone https://github.com/c-hydro/fp-system-env.git --branch main --single-branch /tmp/env_system
# copy files from tmp to container folder(s)
RUN cp -r /tmp/env_system/. ${fp_folder_libs_installer} 

# start installer script for python libraries
WORKDIR ${fp_folder_libs_installer}
RUN pwd
RUN ./setup_fp_system_conda_python_hmc.sh ${fp_folder_libs_python} ${fp_file_env_python} ${fp_folder_env_python} ${fp_requirements_env_python}

# set environmental variable(s) appending in .bashrc
RUN echo "source ${fp_folder_libs_system}/${fp_file_env_system}" >> /home/app/.bashrc
RUN echo "source ${fp_folder_libs_python}/${fp_file_env_python}" >> /home/app/.bashrc
RUN echo "export PYTHONPATH="'${PYTHONPATH}'":/${fp_folder_package_hmc}" >> /home/app/.bashrc
# set environmental variable(s) appending in .profile
RUN echo "source ${fp_folder_libs_system}/${fp_file_env_system}" >> /home/app/.profile
RUN echo "source ${fp_folder_libs_python}/${fp_file_env_python}" >> /home/app/.profile
RUN echo "export PYTHONPATH="'${PYTHONPATH}'":/${fp_folder_package_hmc}" >> /home/app/.profile
# -----------------------------------------------------------------

# -----------------------------------------------------------------
# INSTALL
# clone library from github repository
WORKDIR ${fp_folder_entrypoint}
RUN git clone https://github.com/c-hydro/fp-hmc.git --branch main --single-branch /tmp/package_hmc
# copy files from tmp to container folder(s)
RUN cp -r /tmp/package_hmc/. ${fp_folder_package_hmc} 
RUN cp -r /tmp/package_hmc/tools/running_tool_entrypoint_app/. ${fp_folder_entrypoint} 
# -----------------------------------------------------------------

# -----------------------------------------------------------------
# MOUNT - DOCKER SOURCE AND DESTINATION FOLDER(S)
# prepare share folder(s) to mount external repositories
ENV fp_folder_mount_static /app/mnt_in/data_static/
ENV fp_folder_mount_dyn_source /app/mnt_in/data_dynamic/
ENV fp_folder_mount_dyn_restart /app/mnt_in/model_restart/
ENV fp_folder_mount_dyn_destination /app/mnt_out/model_results/
ENV fp_folder_mount_dyn_state /app/mnt_out/model_state/

# create folder(s)
RUN mkdir -p ${fp_folder_mount_static}
RUN mkdir -p ${fp_folder_mount_dyn_source}
RUN mkdir -p ${fp_folder_mount_dyn_restart}
RUN mkdir -p ${fp_folder_mount_dyn_destination}
RUN mkdir -p ${fp_folder_mount_dyn_state}
# -----------------------------------------------------------------


# Setup WebServer
# WORKDIR /app
# COPY ./app /app
# COPY ./requirements.txt /app/requirements.txt 
# COPY ./setup_server.sh /app/setup_server.sh
# COPY ./start_server.sh /app/start_server.sh
# RUN ./setup_server.sh ${fp_folder_libs_python} ${fp_folder_env_python}
# ENTRYPOINT ./start_server.sh




# -----------------------------------------------------------------
# SET - DOCKER ENTRYPOINT
# set entrypoint
WORKDIR ${fp_folder_entrypoint}
COPY ./wrapper.sh ${fp_folder_entrypoint}
#ENTRYPOINT ./wrapper.sh

ENTRYPOINT /bin/bash
# -----------------------------------------------------------------

