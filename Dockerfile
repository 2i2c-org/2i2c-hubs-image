FROM buildpack-deps:focal-scm

ENV CONDA_DIR /opt/conda

# Set up common env variables
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV DEBIAN_FRONTEND=noninteractive
ENV NB_USER jovyan
ENV NB_UID 1000

RUN adduser --disabled-password --gecos "Default Jupyter user" ${NB_USER}

RUN apt-get -qq update --yes && \
    apt-get -qq install --yes \
            tar \
            vim \
            micro \
            mc \
            tini \
            build-essential \
            locales > /dev/null

RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen

# for nbconvert
# FIXME: Understand what exactly we want
# texlive-plain-generic is new name of texlive-generic-recommended
RUN apt-get update > /dev/null && \
    apt-get -qq install --yes \
            pandoc \
            texlive-xetex \
            texlive-fonts-recommended \
            # provides FandolSong-Regular.otf for issue #2714
            texlive-lang-chinese \
            texlive-plain-generic > /dev/null

# Install packages needed by notebook-as-pdf
# Default fonts seem ok, we just install an emoji font
RUN apt-get update && \
    apt-get install --yes \
            libx11-xcb1 \
            libxtst6 \
            libxrandr2 \
            libasound2 \
            libpangocairo-1.0-0 \
            libatk1.0-0 \
            libatk-bridge2.0-0 \
            libgtk-3-0 \
            libnss3 \
            libxss1 \
            fonts-noto-color-emoji > /dev/null && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

USER ${NB_USER}
WORKDIR /home/${NB_USER}

ENV PATH ${CONDA_DIR}/bin:$PATH

USER root

# Install mambaforgeas root - the script chowns to $NB_USER by the end
COPY install-mambaforge.bash /tmp/install-mambaforge.bash
RUN /tmp/install-mambaforge.bash

USER ${NB_USER}

COPY environment.yml /tmp/environment.yml

RUN mamba env update -p ${CONDA_DIR} -f /tmp/environment.yml

COPY infra-requirements.txt /tmp/infra-requirements.txt
RUN pip install --no-cache -r /tmp/infra-requirements.txt

COPY install-jupyter-extensions.bash /tmp/install-jupyter-extensions.bash
RUN /tmp/install-jupyter-extensions.bash

# Set bash as shell in terminado.
ADD jupyter_notebook_config.py  ${CONDA_PREFIX}/etc/jupyter/
