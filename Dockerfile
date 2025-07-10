# Define build arguments (use CUDA 11.3.1 by default)
ARG UBUNTU_VERSION=20.04
ARG CUDA_VERSION=11.7.1
ARG CUDNN_VERSION=8

# Use the *devel* image (includes CUDA toolkit + nvcc)
FROM nvidia/cuda:${CUDA_VERSION}-cudnn${CUDNN_VERSION}-devel-ubuntu${UBUNTU_VERSION}

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV CUDA_HOME=/usr/local/cuda
ENV TORCH_CUDA_ARCH_LIST="6.0 6.1 6.2 7.0 7.2 7.5 8.0 8.6" 
ENV TORCH_NVCC_FLAGS="-Xfatbin -compress-all"
ENV MAX_JOBS=4

# Install system dependencies
RUN apt-get update && apt-get install -y \
    python3.8 \
    python3.8-dev \
    python3-pip \
    git \
    cmake \
    build-essential \
    libopenblas-dev \
    && rm -rf /var/lib/apt/lists/*

# Make Python 3.8 the default
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.8 1

# Install PyTorch with matching CUDA
ARG PYTORCH_VERSION=1.13.1
ARG PYTORCH_CUDA=cu117
RUN pip install --no-cache-dir \
    numpy==1.21.6 \
    ninja \
    torch==${PYTORCH_VERSION}+${PYTORCH_CUDA} \
    torchvision==0.14.1+${PYTORCH_CUDA} \
    torchaudio==0.13.1 \
    --extra-index-url https://download.pytorch.org/whl/${PYTORCH_CUDA}

# Clone and install Minkowski Engine
RUN git clone https://github.com/zzhangje/MinkowskiEngine-community.git && \
    cd MinkowskiEngine-community && \
    python setup.py install --blas_include_dirs=/usr/include/openblas --force_cuda

# Install additional Python packages
RUN apt-get update && apt-get install -y \
    libsuitesparse-dev \
    ffmpeg \
    libgl1 \
    libegl1 \
    libxrender1 \
    libglib2.0-0 \
    python3.8-tk \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements file and install Python dependencies
COPY requirements.txt /workspace/requirements.txt
RUN pip install --no-cache-dir -r /workspace/requirements.txt

ENV PYOPENGL_PLATFORM=egl
WORKDIR /workspace
