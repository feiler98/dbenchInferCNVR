FROM fedora:42

# 1. Systemabhängigkeiten, R und Build-Tools via DNF installieren
RUN dnf update -y && \
    dnf install -y \
        R-core \
        R-core-devel \
        gcc \
        gcc-c++ \
        gcc-gfortran \
        make \
        wget \
        libxml2-devel \
        openssl-devel \
        libcurl-devel \
        gsl-devel \
        harfbuzz-devel \
        fribidi-devel \
        freetype-devel \
        libpng-devel \
        libtiff-devel \
        libjpeg-turbo-devel \
        git \
    && dnf clean all

RUN mkdir -p /scratch/tmp/feiler/dbenchInferCNV_R
WORKDIR /scratch/tmp/feiler/dbenchInferCNV_R
COPY . .

# 2. JAGS aus den Quelltexten kompilieren (für HMM-Analysen in inferCNV zwingend erforderlich)
RUN sudo dnf -y install lapack lapack-devel
RUN cd JAGS-4.3.2 && \
    ./configure && \
    make -j$(nproc) && \
    make install && \
    cd .. && \
    rm -rf JAGS-4.3.2*


# 4. BiocManager, rjags und inferCNV direkt über R installieren
RUN R -e "install.packages(c('devtools', 'remotes', 'rjags'), repos='https://r-project.org')"
RUN R -e "if (!requireNamespace('BiocManager', quietly = TRUE)) install.packages('BiocManager', repos = 'http://cran.rstudio.com/'); BiocManager::install('infercnv', ask=FALSE)"

RUN yum install -y python3 python3-pip
RUN pip install -r requirements.txt

CMD ["python3", "/scratch/tmp/feiler/dbenchInferCNV_R/run_infercnv.py"]
