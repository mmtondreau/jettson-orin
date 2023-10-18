FROM nvcr.io/nvidia/l4t-pytorch:r35.2.1-pth2.0-py3

ARG PYTORCH_VERSION=v2.1.0

# Other arguments
ENV USE_CUDA=1
ENV USE_CUDNN=1
ENV BUILD_CAFFE2_OPS=0
ENV USE_FBGEMM=0
ENV USE_FAKELOWP=0
ENV BUILD_TEST=0
ENV USE_MKLDNN=0
ENV USE_NNPACK=0
ENV USE_XNNPACK=0
ENV USE_QNNPACK=0
ENV USE_PYTORCH_QNNPACK=0
# Tegra Orin
ENV TORCH_CUDA_ARCH_LIST="8.7" 
ENV USE_NCCL=0
ENV USE_SYSTEM_NCCL=0
ENV USE_OPENCV=0
ENV USE_DISTRIBUTED=1
ENV CUDA_NVCC_EXECUTABLE=/usr/local/cuda/bin/nvcc
ENV CUDA_HOME=/usr/local/cuda/
ENV CUDNN_INCLUDE_PATH=/usr/local/cuda/include 
ENV LIBRARY_PATH=/usr/local/cuda/lib64

ARG V_PYTHON_MAJOR=3
ARG V_PYTHON_MINOR=10
ENV V_PYTHON=${V_PYTHON_MAJOR}.${V_PYTHON_MINOR}
ENV DEBIAN_FRONTEND=noninteractive

# Install Python 
#RUN sudo add-apt-repository "ppa:deadsnakes/ppa" && sudo apt update && sudo apt install -y python${V_PYTHON}-full gcc python${V_PYTHON}-dev curl ninja-build cmake

#RUN rm /usr/bin/python \
#    && rm /usr/bin/python${V_PYTHON_MAJOR} \
#    && ln -s $(which python${V_PYTHON}) /usr/bin/python \
#    && ln -s $(which python${V_PYTHON}) /usr/bin/python${V_PYTHON_MAJOR} 

WORKDIR /src
# Install pip
RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python 

ADD --chmod=744 https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-aarch64.sh Miniconda3-latest-Linux-aarch64.sh 
RUN bash Miniconda3-latest-Linux-aarch64.sh -b -p /opt/miniconda3
ENV PATH=/opt/miniconda3/bin:$PATH
RUN conda update -n base -c defaults conda
RUN conda create --name torch python=3.10
RUN conda init bash
#RUN conda activate torch 
RUN conda install -n torch cmake ninja 

# Install pytorch
RUN python -m pip install numpy setuptools
RUN git clone --recursive --branch ${PYTORCH_VERSION} https://github.com/pytorch/pytorch
WORKDIR  /src/pytorch
RUN conda run -n torch pip install -r requirements.txt
RUN CMAKE_PREFIX_PATH=${CONDA_PREFIX:-"$(dirname $(which conda))/../"} \
    conda run -n torch python setup.py develop
RUN conda run -n torch python -m pip install jupyter lightning ray[tune] scikit-learn torchmetrics 

#https://github.com/pytorch/audio/issues/606
#RUN conda install -c pytorch torchaudio 

ARG PYTORCH_VISION_VERSION=v0.16.0
ARG PYTORCH_AUDIO_VERSION=v2.1.0
ENV PYTORCH_VERSION=2.1.0a0+git7bcf7da
WORKDIR /src
RUN git clone --branch ${PYTORCH_VISION_VERSION} https://github.com/pytorch/vision
ENV FORCE_CUDA=1
WORKDIR /src/vision
RUN CMAKE_PREFIX_PATH=${CONDA_PREFIX:-"$(dirname $(which conda))/../"} \
    conda run -n torch python setup.py install
RUN conda install -n torch -c anaconda libpng 
RUN conda install -n torch -c conda-forge libjpeg-turbo

# torchaudio doesnt compile -- cant find cuda.h
WORKDIR /src
RUN git clone --branch ${PYTORCH_AUDIO_VERSION} https://github.com/pytorch/audio
WORKDIR /src/audio
RUN conda run -n torch python setup.py install 

ARG PYTORCH_TEXT_VERSION=v0.16.0

# RUN conda install -n torch matplotlib
# torchtext  
#WORKDIR /src
#RUN git clone --branch ${PYTORCH_TEXT_VERSION} https://github.com/pytorch/text 
#WORKDIR /src/text
#RUN git submodule update --init --recursive
#RUN conda run -n torch python setup.py clean install

ARG JUPYTER_HOME=/root/.jupyter
ENV JUPYTER_HOME=$JUPYTER_HOME
COPY jupyter_notebook_config.py $JUPYTER_HOME/jupyter_notebook_config.py 
COPY jupyter_lab_config.py $JUPYTER_HOME/jupyter_lab_config.py 
COPY jupyter_server_config.json $JUPYTER_HOME/jupyter_server_config.json 
COPY jupyter_server_config.json $JUPYTER_HOME/jupyter_notebook_config.json 
COPY fullchain.pem /etc/ssl/certs/tonberry.pem
COPY privkey.pem /etc/ssl/private/tonberry.pem
WORKDIR /root/workspace
ENTRYPOINT ["conda", "run", "-n", "torch", "jupyter", "lab", "--allow-root"]
