FROM rocker/r-ver:3.3.3

## ------------ ##
## How to build ##
## ------------ ##

## sudo docker build --file containers/Dockerfile --no-cache -t rtpop/process_cel:tag --progress=plain . 2>&1 | tee containers/logs/process_cel:tag

## --------------------------- ##
## Install system requirements ##
## --------------------------- ##

RUN mkdir -p /opt/software
WORKDIR /opt

RUN echo "deb http://archive.debian.org/debian/ jessie main" > /etc/apt/sources.list && \
    echo "deb http://archive.debian.org/debian-security/ jessie/updates main" >> /etc/apt/sources.list && \
    echo "Acquire::Check-Valid-Until false;" > /etc/apt/apt.conf.d/99ignore-release-date

RUN apt-get update -qq && \
        apt-get install -y --allow-unauthenticated \
                apt-utils \
                libxml2-dev \
                libjpeg-dev \
                libpng-dev \
                libtiff-dev \
                libicu-dev \
                libgfortran3 \
                libnlopt-dev \
                build-essential \
                git \
                pkg-config \
                libcurl4-openssl-dev \
                libssl-dev \
                zlib1g-dev \
                libbz2-dev \
                liblzma-dev \
                xz-utils \
                libncurses5-dev

RUN apt-cache policy \
        apt-utils \
        build-essential \
        freetype2-demos \
        freetype2-doc \
        git \
        libcurl4-openssl-dev \
        libcairo2-dev \
        libfontconfig1-dev \
        libfreetype-dev \
        libfreetype6 \
        librsvg2-bin \
        librsvg2-dev \
        libudunits2-dev \
        littlr \
        make \
        pkg-config \
        procps \
        libssl-dev \
        libopenmpi-dev \
        libgsl-dev \
        libcurl4-gnutls-dev \
        libmysqlclient-dev \
        libpq-dev

                
RUN apt-get update -qq && \
        apt-get install -y --allow-unauthenticated \
                build-essential \
                git \
                libcurl4-openssl-dev \
                libcairo2-dev \
                libssl-dev \
                vim

## ------------------- ##
## Copy required files ##
## ------------------- ##

COPY containers/requirements.R /opt/requirements.R
#COPY containers/hta20hsentrezgcdf_25.0.0.tar.gz /opt/hta20hsentrezgcdf_25.0.0.tar.gz

## ---------------------------- ##
## Install package requirements ##
## ---------------------------- ##

RUN Rscript /opt/requirements.R

# install preprocessCore without threading to avoid issues on some systems
RUN Rscript -e 'BiocManager::install("preprocessCore", configure.args = c(preprocessCore = "--disable-threading"), update=TRUE, force=TRUE, ask=FALSE, type="source")'

## --------------- ##
## Switch to shell ##
## --------------- ##

ENV HOME=/home

CMD ["/bin/bash"]