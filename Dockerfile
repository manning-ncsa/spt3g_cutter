FROM centos:7

ARG SPT3G_CUTTER_VERSION
ARG UID_NUMBER=1006
ARG SPTUSER=sptworker
ARG SPTHOME=/home/${SPTUSER}
ARG MINICONDA_PATH=${SPTHOME}/miniconda
ARG MINICONDA_INSTALL_FILE=Miniconda3-py38_4.10.3-Linux-x86_64.sh

ENV MINICONDA_PATH ${MINICONDA_PATH}

RUN yum -y update && \
    yum -y install \
    epel-release \
    which \
    wget \
    git \
    make \
    fpack \
    screen \
    && yum -y clean all && rm -rf /var/cache

# Add $SPTUSER as user and create groups wheel and spt
RUN adduser --uid ${UID_NUMBER} --home ${SPTHOME} --shell /bin/bash ${SPTUSER} && \
    groupadd --gid 1003 spt

RUN mkdir -p /data/spt3g && \
    chgrp spt /data/spt3g && \
    chmod g+wrx /data/spt3g

USER ${SPTUSER}
WORKDIR ${SPTHOME}

# Conda installation, using python38
RUN mkdir -p ${MINICONDA_PATH} \
    && cd ${MINICONDA_PATH} \
    && wget https://repo.anaconda.com/miniconda/${MINICONDA_INSTALL_FILE} \
    && chmod +x ${MINICONDA_INSTALL_FILE} \
    && ./${MINICONDA_INSTALL_FILE} -b -p ${MINICONDA_PATH} -u \
    && rm ${MINICONDA_INSTALL_FILE}

# Start the env and add channels and base dependencies
RUN source $MINICONDA_PATH/bin/activate && \
    conda config --add channels conda-forge && \
    conda install conda-build

# Install spt-cutter package dependencies
RUN source $MINICONDA_PATH/bin/activate && \
    conda install -y astropy=4.1 fitsio pandas && \
    conda install -y -c conda-forge esutil pyaml-env

# Build the spt-cutter conda package and install
COPY --chown=${SPTUSER}:${SPTUSER} conda src/spt-cutter
RUN source $MINICONDA_PATH/bin/activate && \
    conda build src/spt-cutter && \
    conda install $(ls ${MINICONDA_PATH}/conda-bld/*/spt3g_cutter-${SPT3G_CUTTER_VERSION}*.tar.bz2) && \
    rm $(ls ${MINICONDA_PATH}/conda-bld/*/spt3g_cutter-${SPT3G_CUTTER_VERSION}*.tar.bz2)

# Use entrypoint script to start with conda and spt_cutter initialized
COPY --chown=${SPTUSER}:${SPTUSER} docker/startup.sh .startup.sh
RUN chmod a+x .startup.sh
ENTRYPOINT ["sh",".startup.sh"]
