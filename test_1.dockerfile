FROM kmader/caffe-segnet

ARG TENSORFLOW_ARCH=cpu
ARG TENSORFLOW_VERSION=1.2.1
ARG PYTORCH_VERSION=v0.2
ARG MXNET_VERISON=latest
ARG KERAS_VERSION=1.2.0

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
RUN wget http://download.osgeo.org/gdal/1.11.0/gdal-1.11.0.tar.gz && \
  tar xvfz gdal-1.11.0.tar.gz && \
  cd gdal-1.11.0 && \
  ./configure --with-python && \
  make && \
  make install && \
  rm -rf /var/lib/apt/lists/*



# install python package
RUN pip install pip --upgrade

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

