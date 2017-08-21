FROM sshuair/dl-satellite:caffe-py2-cpu

MAINTAINER takuya.wakisaka@moldweorp.com


ENV CAFFE_ROOT=/opt/caffe
WORKDIR $CAFFE_ROOT
ENV PYCAFFE_ROOT $CAFFE_ROOT/python
ENV PYTHONPATH $PYCAFFE_ROOT:$PYTHONPATH
ENV PATH $CAFFE_ROOT/build/tools:$PYCAFFE_ROOT:$PATH




# faster apt source
RUN echo "deb mirror://mirrors.ubuntu.com/mirrors.txt trusty main restricted universe multiverse \n\
deb mirror://mirrors.ubuntu.com/mirrors.txt trusty-updates main restricted universe multiverse \n\
deb mirror://mirrors.ubuntu.com/mirrors.txt trusty-backports main restricted universe multiverse \n\
deb mirror://mirrors.ubuntu.com/mirrors.txt trusty-security main restricted universe multiverse" > /etc/apt/sources.list

RUN apt-get update --fix-missing && apt-get install -y --no-install-recommends\ 
  bc \
  git \
  unzip \
  wget \
  curl \

  # for caffe
  libprotobuf-dev \
  libleveldb-dev \
  libsnappy-dev \
  libopencv-dev \
  libhdf5-dev \
  protobuf-compiler \
  libatlas-base-dev \
  libgflags-dev \
  libgoogle-glog-dev \
  liblmdb-dev \
  libboost-all-dev \

  # for caffe python
  python-dev \
  python-pip \
  python-numpy \
  # for scipy
  gfortran \
  # fix: InsecurePlatformWarning: A true SSLContext object is not available.
  build-essential \
  software-properties-common \
  cmake \
  

  && apt-get clean \
  && rm -rf /var/lib/apt/lists/

RUN cd /opt && git clone https://github.com/alexgkendall/caffe-segnet.git && cd caffe-segnet

WORKDIR /opt/caffe-segnet

# Build Caffe core
RUN cp Makefile.config.example Makefile.config && \
    echo "CPU_ONLY := 1" >> Makefile.config && \

    make -j"$(nproc)" all

# Install python deps
RUN pip install --upgrade pip && \
    # fix: InsecurePlatformWarning: A true SSLContext object is not available.
    pip install pyopenssl ndg-httpsclient pyasn1 && \
    for req in $(cat python/requirements.txt); do pip install $req; done

# Build Caffe python
RUN make -j"$(nproc)" pycaffe

# test + run tests
RUN make -j"$(nproc)" test
# RUN cd /opt/caffe && make runtes




