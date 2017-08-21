FROM ubuntu:14.04
MAINTAINER caffe-maint@googlegroups.com

RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        cmake \
        git \
        wget \
        libboost-all-dev \
        libgflags-dev \
        libgoogle-glog-dev \
        libhdf5-serial-dev \
        libleveldb-dev \
        liblmdb-dev \
        libopencv-dev \
        libprotobuf-dev \
        libsnappy-dev \
        protobuf-compiler \
        python-dev \
        python-numpy \
        python-pip \
        python-scipy && \
    rm -rf /var/lib/apt/lists/*

ENV CAFFE_ROOT=/opt/caffe-segnet
WORKDIR $CAFFE_ROOT

# FIXME: clone a specific git tag and use ARG instead of ENV once DockerHub supports this.
ENV CLONE_TAG=master

RUN cd /opt
RUN git clone https://github.com/alexgkendall/caffe-segnet.git && \
    cd caffe-segnet && \
    for req in $(cat python/requirements.txt) pydot; do pip install $req; done && \
    cp Makefile.config.example Makefile.config && \
   echo "CPU_ONLY := 1" >> Makefile.config && \
    make all -j"$(nproc)"

ENV PYCAFFE_ROOT $CAFFE_ROOT/python
ENV PYTHONPATH $PYCAFFE_ROOT:$PYTHONPATH
ENV PATH $CAFFE_ROOT/build/tools:$PYCAFFE_ROOT:$PATH
RUN echo "$CAFFE_ROOT/build/lib" >> /etc/ld.so.conf.d/caffe.conf && ldconfig

WORKDIR /workspace


# version settings
# ARG PYTHON_VERSION=3.5
ARG TENSORFLOW_ARCH=cpu
ARG TENSORFLOW_VERSION=1.2.1
ARG PYTORCH_VERSION=v0.2
ARG MXNET_VERISON=latest
ARG KERAS_VERSION=1.2.0


# # modify the ubuntu mirror to ali
# RUN cp /etc/apt/sources.list /etc/apt/sources_backup.list && \
#     sed -i "s|http://archive.ubuntu.com|http://mirrors.aliyun.com|g" /etc/apt/sources.list && \
#     rm -rf /var/lib/apt/lists/* && \
#     apt-get -y update && apt-get install -y fortunes


# install dependencies
RUN apt-get update --fix-missing && apt-get install -y --no-install-recommends\ 
        build-essential \
        software-properties-common \
        curl \
        cmake \
        libfreetype6-dev \
        libpng12-dev \
        libzmq3-dev \
        pkg-config \
        rsync \
        zip \
        unzip \
        git \
        wget \
        vim \
        ca-certificates \
        python \
        python-dev \
        python-pip \
        ipython \
        # graphviz \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*



# install mapnik ，note: mapnik must install before gdal
RUN apt-get update && apt-get --fix-missing install -y python-mapnik && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*



# install gdal  
RUN add-apt-repository -y ppa:ubuntugis/ppa && \ 
    apt update && \ 
    apt-get install -y --no-install-recommends gdal-bin libgdal-dev python-gdal && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*


# install python package
RUN pip --no-cache-dir install \
        setuptools
# note: due to pytorch 0.2 rely on numpy 1.13, it's have to upgrade numpy from 1.11.0 to 1.13.1
RUN pip --no-cache-dir install --upgrade \
        numpy
RUN pip --no-cache-dir install \
        Pillow \
        ipykernel \
        jupyter \
        scipy \
        # h5py \
        scikit-image \
        # matplotlib \
        pandas \
        # scikit-learn \
        # sympy \
        shapely \
        # bokeh \
        # geopandas \
        # hyperopt \
        # folium \
        # ipyleaflet \
        progressbar \
        && \
    python -m ipykernel.kernelspec







# TODO: 配置jupyter-Notebook，tensorboard已经可以运行
# Set up our notebook config.
COPY jupyter_notebook_config.py /root/.jupyter/

# Copy sample notebooks.
# COPY notebooks /notebooks

# Jupyter has issues with being run directly: https://github.com/ipython/ipython/issues/7062
# We just add a little wrapper script.
COPY run_jupyter.sh /

# TensorBoard
EXPOSE 6006
# jupyter noteboook
EXPOSE 8888

RUN mkdir /workdir

WORKDIR "/workdir"

CMD ["/run_jupyter.sh", "--allow-root" ]

