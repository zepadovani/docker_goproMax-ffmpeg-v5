# Use the NVIDIA CUDA base image with Ubuntu 20.04
FROM nvidia/cuda:12.2.0-base-ubuntu20.04

# Set environment variables for timezone and non-interactive installation
ENV TZ=US \
    DEBIAN_FRONTEND=noninteractive

# Update package list and install necessary packages
RUN apt-get update -qq && \
    apt-get -y install \
    apt-utils \
    unzip \
    tar \
    curl \
    xz-utils \
    ocl-icd-libopencl1 \
    opencl-headers \
    clinfo \
    autoconf \
    automake \
    build-essential \
    cmake \
    git-core \
    libass-dev \
    libfreetype6-dev \
    libgnutls28-dev \
    libmp3lame-dev \
    libsdl2-dev \
    libtool \
    libva-dev \
    libvdpau-dev \
    libvorbis-dev \
    libxcb1-dev \
    libxcb-shm0-dev \
    libxcb-xfixes0-dev \
    meson \
    ninja-build \
    pkg-config \
    texinfo \
    wget \
    yasm \
    zlib1g-dev

# Install additional packages required for OpenCL and video encoding
RUN apt-get -y install \
    ocl-icd-opencl-dev \
    libx264-dev \
    libx265-dev \
    libsdl2-dev \
    gcc \
    gnupg2

# Remove old NVIDIA key if it exists
RUN apt-key del 7fa2af80 || true

# Add the new NVIDIA package signing key
RUN apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/3bf863cc.pub

# Update package list again after adding new key
RUN apt-get update

# Create directory for OpenCL vendor and add NVIDIA OpenCL ICD
RUN mkdir -p /etc/OpenCL/vendors && \
    echo "libnvidia-opencl.so.1" > /etc/OpenCL/vendors/nvidia.icd

# Set environment variables for NVIDIA runtime
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility

# Clone the GoProMax-ffmpeg repository from GitHub
RUN git clone https://github.com/zepadovani/goproMax-ffmpeg-v5.git

# Set the working directory to the cloned repository
WORKDIR /goproMax-ffmpeg-v5

# Configure the build with specific options
RUN ./configure --enable-opencl --enable-opengl --enable-sdl2 --enable-libx264 --enable-gpl --disable-x86asm --enable-libx265

# Print a message indicating the start of the compilation process
RUN echo "compiling using make -j$(nproc)"

# Compile the project using all available CPU cores
RUN make -j$(nproc)

# Install the compiled binaries
RUN make install

# Set the entrypoint to the compiled ffmpeg binary
ENTRYPOINT ["/goproMax-ffmpeg-v5/ffmpeg"]