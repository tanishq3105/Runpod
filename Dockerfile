FROM alpine/git:2.36.2 AS download

COPY clone.sh /clone.sh

RUN . /clone.sh stable-diffusion-webui-assets https://github.com/AUTOMATIC1111/stable-diffusion-webui-assets.git 6f7db241d2f8ba7457bac5ca9753331f0c266917

RUN . /clone.sh stable-diffusion-stability-ai https://github.com/Stability-AI/stablediffusion.git cf1d67a6fd5ea1aa600c4df58e5b47da45f6bdbf \
  && rm -rf assets data/**/*.png data/**/*.jpg data/**/*.gif

RUN . /clone.sh BLIP https://github.com/salesforce/BLIP.git 48211a1594f1321b00f14c9f7a5b4813144b2fb9
RUN . /clone.sh k-diffusion https://github.com/crowsonkb/k-diffusion.git ab527a9a6d347f364e3d185ba6d714e22d80cb3c
RUN . /clone.sh clip-interrogator https://github.com/pharmapsychotic/clip-interrogator 2cf03aaf6e704197fd0dae7c7f96aa59cf1b11c9
RUN . /clone.sh generative-models https://github.com/Stability-AI/generative-models 45c443b316737a4ab6e40413d7794a7f5657c19f
RUN . /clone.sh stable-diffusion-webui-assets https://github.com/AUTOMATIC1111/stable-diffusion-webui-assets 6f7db241d2f8ba7457bac5ca9753331f0c266917

#add the model stored locally
ADD model.safetensors /

# Add all files from the controlnet folder to the root directory in the current stage
ADD controlnet/control_v11e_sd15_ip2p.pth /
ADD controlnet/control_v11e_sd15_ip2p.yaml /
ADD controlnet/control_v11e_sd15_shuffle.pth /
ADD controlnet/control_v11e_sd15_shuffle.yaml /
ADD controlnet/control_v11f1e_sd15_tile.pth /
ADD controlnet/control_v11f1e_sd15_tile.yaml /
ADD controlnet/control_v11f1p_sd15_depth.pth /
ADD controlnet/control_v11f1p_sd15_depth.yaml /
ADD controlnet/control_v11p_sd15_canny.pth /
ADD controlnet/control_v11p_sd15_canny.yaml /
ADD controlnet/control_v11p_sd15_inpaint.pth /
ADD controlnet/control_v11p_sd15_inpaint.yaml /
ADD controlnet/control_v11p_sd15_lineart.pth /
ADD controlnet/control_v11p_sd15_lineart.yaml /
ADD controlnet/control_v11p_sd15_mlsd.pth /
ADD controlnet/control_v11p_sd15_mlsd.yaml /
ADD controlnet/control_v11p_sd15_normalbae.pth /
ADD controlnet/control_v11p_sd15_normalbae.yaml /
ADD controlnet/control_v11p_sd15_openpose.pth /
ADD controlnet/control_v11p_sd15_openpose.yaml /
ADD controlnet/control_v11p_sd15_scribble.pth /
ADD controlnet/control_v11p_sd15_scribble.yaml /
ADD controlnet/control_v11p_sd15_seg.pth /
ADD controlnet/control_v11p_sd15_seg.yaml /
ADD controlnet/control_v11p_sd15_softedge.pth /
ADD controlnet/control_v11p_sd15_softedge.yaml /
ADD controlnet/control_v11p_sd15s2_lineart_anime.pth /
ADD controlnet/control_v11p_sd15s2_lineart_anime.yaml /
ADD sam_vit_b_01ec64.pth /
ADD sam_vit_h_4b8939.pth /

ADD groundingdino_swint_ogc.pth /

FROM pytorch/pytorch:2.3.0-cuda12.1-cudnn8-runtime



ENV DEBIAN_FRONTEND=noninteractive PIP_PREFER_BINARY=1

RUN --mount=type=cache,target=/var/cache/apt \
  apt-get update && \
  # we need those
  apt-get install -y fonts-dejavu-core rsync git jq moreutils aria2 \
  # extensions needs those
  ffmpeg libglfw3-dev libgles2-mesa-dev pkg-config libcairo2 libcairo2-dev build-essential


WORKDIR /
RUN --mount=type=cache,target=/root/.cache/pip \
  git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git && \
  cd stable-diffusion-webui && \
  git reset --hard v1.9.4 && \
  pip install -r requirements_versions.txt

RUN cd stable-diffusion-webui/extensions && \
  git clone https://github.com/Mikubill/sd-webui-controlnet.git && \
  git clone https://github.com/Bing-su/adetailer && \
  git clone https://github.com/continue-revolution/sd-webui-segment-anything && \
  git clone https://github.com/huchenlei/sd-webui-openpose-editor.git

ENV ROOT=/stable-diffusion-webui

COPY --from=download /model.safetensors ${ROOT}/models/Stable-diffusion/

COPY --from=download /control_v11e_sd15_ip2p.pth ${ROOT}/extensions/sd-webui-controlnet/models/
COPY --from=download /control_v11e_sd15_ip2p.yaml ${ROOT}/extensions/sd-webui-controlnet/models/
COPY --from=download /control_v11e_sd15_shuffle.pth ${ROOT}/extensions/sd-webui-controlnet/models/
COPY --from=download /control_v11e_sd15_shuffle.yaml ${ROOT}/extensions/sd-webui-controlnet/models/
COPY --from=download /control_v11f1e_sd15_tile.pth ${ROOT}/extensions/sd-webui-controlnet/models/
COPY --from=download /control_v11f1e_sd15_tile.yaml ${ROOT}/extensions/sd-webui-controlnet/models/
COPY --from=download /control_v11f1p_sd15_depth.pth ${ROOT}/extensions/sd-webui-controlnet/models/
COPY --from=download /control_v11f1p_sd15_depth.yaml ${ROOT}/extensions/sd-webui-controlnet/models/
COPY --from=download /control_v11p_sd15_canny.pth ${ROOT}/extensions/sd-webui-controlnet/models/
COPY --from=download /control_v11p_sd15_canny.yaml ${ROOT}/extensions/sd-webui-controlnet/models/
COPY --from=download /control_v11p_sd15_inpaint.pth ${ROOT}/extensions/sd-webui-controlnet/models/
COPY --from=download /control_v11p_sd15_inpaint.yaml ${ROOT}/extensions/sd-webui-controlnet/models/
COPY --from=download /control_v11p_sd15_lineart.pth ${ROOT}/extensions/sd-webui-controlnet/models/
COPY --from=download /control_v11p_sd15_lineart.yaml ${ROOT}/extensions/sd-webui-controlnet/models/
COPY --from=download /control_v11p_sd15_mlsd.pth ${ROOT}/extensions/sd-webui-controlnet/models/
COPY --from=download /control_v11p_sd15_mlsd.yaml ${ROOT}/extensions/sd-webui-controlnet/models/
COPY --from=download /control_v11p_sd15_normalbae.pth ${ROOT}/extensions/sd-webui-controlnet/models/
COPY --from=download /control_v11p_sd15_normalbae.yaml ${ROOT}/extensions/sd-webui-controlnet/models/
COPY --from=download /control_v11p_sd15_openpose.pth ${ROOT}/extensions/sd-webui-controlnet/models/
COPY --from=download /control_v11p_sd15_openpose.yaml ${ROOT}/extensions/sd-webui-controlnet/models/
COPY --from=download /control_v11p_sd15_scribble.pth ${ROOT}/extensions/sd-webui-controlnet/models/
COPY --from=download /control_v11p_sd15_scribble.yaml ${ROOT}/extensions/sd-webui-controlnet/models/
COPY --from=download /control_v11p_sd15_seg.pth ${ROOT}/extensions/sd-webui-controlnet/models/
COPY --from=download /control_v11p_sd15_seg.yaml ${ROOT}/extensions/sd-webui-controlnet/models/
COPY --from=download /control_v11p_sd15_softedge.pth ${ROOT}/extensions/sd-webui-controlnet/models/
COPY --from=download /control_v11p_sd15_softedge.yaml ${ROOT}/extensions/sd-webui-controlnet/models/
COPY --from=download /control_v11p_sd15s2_lineart_anime.pth ${ROOT}/extensions/sd-webui-controlnet/models/
COPY --from=download /control_v11p_sd15s2_lineart_anime.yaml ${ROOT}/extensions/sd-webui-controlnet/models/

COPY --from=download /sam_vit_b_01ec64.pth ${ROOT}/extensions/sd-webui-segment-anything/models/sam/
COPY --from=download /sam_vit_h_4b8939.pth ${ROOT}/extensions/sd-webui-segment-anything/models/sam/

COPY --from=download /groundingdino_swint_ogc.pth ${ROOT}/extensions/sd-webui-segment-anything/models/grounding-dino/

COPY --from=download /repositories/ ${ROOT}/repositories/
RUN mkdir ${ROOT}/interrogate && cp ${ROOT}/repositories/clip-interrogator/clip_interrogator/data/* ${ROOT}/interrogate

COPY requirements.txt ./

RUN --mount=type=cache,target=/root/.cache/pip \
  pip install pyngrok xformers==0.0.26.post1 \
  git+https://github.com/TencentARC/GFPGAN.git@8d2447a2d918f8eba5a4a01463fd48e45126a379 \
  git+https://github.com/openai/CLIP.git@d50d76daa670286dd6cacf3bcd80b5e4823fc8e1 \
  git+https://github.com/mlfoundations/open_clip.git@v2.20.0

# there seems to be a memory leak (or maybe just memory not being freed fast enough) that is fixed by this version of malloc
# maybe move this up to the dependencies list.
RUN apt-get -y install libgoogle-perftools-dev && apt-get clean
ENV LD_PRELOAD=libtcmalloc.so

RUN --mount=type=cache,target=/root/.cache/pip \
   pip uninstall -y typing_extensions && \
   pip install typing_extensions==4.11.0

RUN pip install -r requirements.txt

COPY controlnet/ip-adapter-plus_sd15.pth ${ROOT}/extensions/sd-webui-controlnet/models/


COPY . /docker

RUN \
  # mv ${ROOT}/style.css ${ROOT}/user.css && \
  # one of the ugliest hacks I ever wrote \
  sed -i 's/in_app_dir = .*/in_app_dir = True/g' /opt/conda/lib/python3.10/site-packages/gradio/routes.py && \
  git config --global --add safe.directory '*'

WORKDIR ${ROOT}
ENV NVIDIA_VISIBLE_DEVICES=all
ENV CLI_ARGS=""
EXPOSE 7860
ENTRYPOINT ["/docker/entrypoint.sh"]
CMD python -u webui.py --listen --no-download-sd-model --port 7860 ${CLI_ARGS}
