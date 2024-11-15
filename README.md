# GoPro Max 360° Video Processing with FFmpeg in Docker

This Dockerfile provides a streamlined way to process 360° videos from a GoPro Max camera using FFmpeg, adapted from a solution by David G. found at [Trek View](https://www.trekview.org/blog/using-ffmpeg-process-gopro-max-360/).

## Motivation

Compiling FFmpeg with the necessary options for processing GoPro Max videos proved challenging on my local machine and with newer Ubuntu Docker images. To simplify the process, this Dockerfile leverages an Ubuntu 20.04 image with NVIDIA CUDA, which includes the necessary NVIDIA drivers and CUDA libraries.

## Features

- Uses `nvidia/cuda:12.2.0-base-ubuntu20.04` as the base image.
- Installs dependencies required to compile FFmpeg with OpenCL, OpenGL, libx264, and libx265 support.
- Clones the `goproMax-ffmpeg-v5` repository from GitHub.
- Compiles FFmpeg with the following options: `--enable-opencl`, `--enable-opengl`, `--enable-sdl2`, `--enable-libx264`, `--enable-gpl`, `--disable-x86asm`, and `--enable-libx265`.
- Sets the entrypoint to the compiled `ffmpeg` executable.

(not sure if need everything here, but works... !)

## How to Use

### Build the Docker Image

```bash
docker build -t gopro-ffmpeg .
```

### Run the Container

```bash
docker run --gpus device=0 -v /path/to/input/files/:/input -v /path/to/output/files/:/output \
gopro-ffmpeg -hwaccel opencl -v verbose -filter_complex '[0:0]format=yuv420p,hwupload[a] , [0:5]format=yuv420p,hwupload[b], [a][b]gopromax_opencl, hwdownload,format=yuv420p' \ 
-i /input/input_movie.360 -c:v libx264 -pix_fmt yuv420p -map_metadata 0 -map 0:a -map 0:3 /output/output_movie.mp4
```

Replace `/path/to/input/files/` and `/path/to/output/files/` with the actual path to your video files (or use only one directory)

## Notes

- Ensure you have Docker and the NVIDIA Container Toolkit installed on your machine.
- The `--gpus all` option in the `docker run` command allows the container to access all available GPUs.
- Adjust the `ffmpeg` command according to your needs.
- This WILL NOT automatically inject the appropriate metadata to make the video being recognized by YouTube/Facebook/VLC. To do this, check this you will need an environment (I use miniconda) with a python 2.7 version installed and git clone https://github.com/google/spatial-media. Then, from the main directory run something like `python spatialmedia -i ../equirretangular_nometadata.mp4 ../equirretangular_withmetadata.mp4`

## Acknowledgments

- David G. for the original tutorial.
- The FFmpeg community for developing this powerful tool.