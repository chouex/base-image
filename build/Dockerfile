ARG IMAGE_BASE="pytorch/pytorch:2.2.0-cuda12.1-cudnn8-devel"

# # Caddy build
# FROM ubuntu:22.04 as caddybuilder

# ENV PATH=/opt/go/bin:$PATH
# ENV GOROOT=/opt/go
# RUN apt-get update && \
#     apt-get install -y wget && \
#     wget https://dl.google.com/go/go1.22.4.linux-amd64.tar.gz && \
#     tar -xf go1.22.4.linux-amd64.tar.gz && \
#     mv ./go /opt && \ 
#     wget https://github.com/caddyserver/xcaddy/releases/download/v0.4.2/xcaddy_0.4.2_linux_amd64.deb && \
#     apt-get install ./xcaddy_0.4.2_linux_amd64.deb && \
#     xcaddy build \
#         --with github.com/caddyserver/replace-response && \
#     mkdir -p /opt/caddy/bin && \
#     mv ./caddy /opt/caddy/bin


# For build automation - Allows building from any Debian-based image

FROM ${IMAGE_BASE} AS main

# System libs are handled in /etc/ld.so.conf.d
# Python environments only to use this variable
ENV LD_LIBRARY_PATH=

# COPY --from=caddybuilder /opt/caddy/ /opt/caddy/

# Determines which scripts at /opt/ai-dock/bin/build/layerX will be run by init.sh
ARG XPU_TARGET="GPU_NVIDIA" # GPU_AMD, CPU
ENV XPU_TARGET=${XPU_TARGET}

ARG NODE_VERSION=v22.2.0
ENV NODE_VERSION=${NODE_VERSION}

LABEL org.opencontainers.image.source https://github.com/ai-dock/base-image

LABEL org.opencontainers.image.description "Base image for ai-dock."

LABEL maintainer="Rob Ballantyne <rob@dynamedia.uk>"

SHELL ["/bin/bash", "-c"]
# Set ENV variables
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV TZ=UTC
ENV SHELL="/bin/bash"
ENV USER_NAME=user
ENV USER_PASSWORD=password
ENV USER_GROUPS=users,ai-dock,adm,sudo,audio,video,tty,cdrom,dialout,dip,fax,floppy,lp,plugdev,ssl-cert,sudo,tape,voice
ENV DEBIAN_FRONTEND=noninteractive
ENV PATH=/opt/ai-dock/bin:/opt/caddy/bin:$PATH
ENV OPT_SYNC=
ENV PYTHONUNBUFFERED=true
ENV VENV_DIR=/opt/environments/python
ENV SERVICEPORTAL_VENV=${VENV_DIR}/serviceportal
ENV SERVICEPORTAL_VENV_PYTHON=${SERVICEPORTAL_VENV}/bin/python
ENV SERVICEPORTAL_VENV_PIP=${SERVICEPORTAL_VENV}/bin/pip

ENV APT_INSTALL="apt-get install -y --no-install-recommends"
ENV RCLONE_CONFIG="/etc/rclone/rclone.conf"
ENV IMAGE_SLUG="base-image"
# Copy early so we can use scripts in the build - Changes to these files will invalidate the cache and cause a rebuild.

RUN apt update && apt install -y supervisor

COPY --chown=0:1111 ./COPY_ROOT_0/ /

ARG CUDA_STRING
ARG ROCM_STRING

#FROM xxx as next

# Use build scripts to ensure we can build all targets from one Dockerfile in a single layer.
# Don't put anything heavy in here - We can use multi-stage building above if necessary.
RUN set -eo pipefail && /opt/ai-dock/bin/build/layer0/init.sh | tee /var/log/build.log



RUN useradd -m user && echo "user ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
RUN mkdir -p -m777  /workspace/kohya_ss/ /assets /output /workspace/storage/stable_diffusion/models/ckpt/ /home/user/.local/state/syncthing/

RUN git clone https://github.com/kohya-ss/sd-scripts --depth=1 /workspace/kohya_ss/sd-scripts/
RUN cd /workspace/kohya_ss/sd-scripts && pip install -r requirements.txt && if [ "$XPU_TARGET" = "GPU_NVIDIA" ]; then pip install xformers==0.0.24 torch==2.2.0 --index-url https://download.pytorch.org/whl/cu121; fi && pip cache purge
RUN git clone https://github.com/comfyanonymous/ComfyUI --depth=1 /workspace/ComfyUI/
RUN git clone https://github.com/pythongosssss/ComfyUI-Custom-Scripts --depth=1 /workspace/ComfyUI/custom_nodes/ComfyUI-Custom-Scripts
RUN git clone https://github.com/ltdrdata/ComfyUI-Manager --depth=1 /workspace/ComfyUI/custom_nodes/ComfyUI-Manager
RUN git clone https://github.com/ltdrdata/ComfyUI-Inspire-Pack --depth=1 /workspace/ComfyUI/custom_nodes/ComfyUI-Inspire-Pack && cd /workspace/ComfyUI/custom_nodes/ComfyUI-Inspire-Pack && pip install -r requirements.txt
RUN cd /workspace/ComfyUI/ && pip install -r requirements.txt && pip cache purge && rm -rf output && mkdir /output/comfy/ && ln -s /output/comfy/ output
RUN pip install pycryptodome rsa cryptography lycoris-lora flask && apt install aria2 -y

# Keep init.sh as-is and place additional logic in /opt/ai-dock/bin/preflight.d
CMD ["init.sh"]

FROM main AS addon
ARG CKPT
RUN wget -qnc --content-disposition --show-progress -e dotbytes="${3:-4M}" -P  "/workspace/storage/stable_diffusion/models/ckpt/" $CKPT

CMD ["init.sh"]
