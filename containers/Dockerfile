FROM rtpop/basic-r:0.1

## ------------ ##
## How to build ##
## ------------ ##

## sudo docker build --file containers/Dockerfile --no-cache -t rtpop/process_cel:tag --progress=plain . 2>&1 | tee containers/logs/process_cel:tag

## ------------------- ##
## Copy required files ##
## ------------------- ##

COPY containers/requirements.R /opt/requirements.R
COPY containers/*tar.gz /opt

## ---------------------------- ##
## Install package requirements ##
## ---------------------------- ##

RUN Rscript /opt/requirements.R

# install preprocessCore without threading to avoid issues on some systems
RUN Rscript -e 'BiocManager::install("preprocessCore", configure.args = c(preprocessCore = "--disable-threading"), update=TRUE, force=TRUE, ask=FALSE, type="source")'