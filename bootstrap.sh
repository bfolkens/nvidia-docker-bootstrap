#!/bin/bash

echo "$(date): Copying the NVidia drivers from the host."

NV_LIBS=" \
  libnvidia-ml.so \
  libcuda.so \
  libnvidia-ptxjitcompiler.so \
  libnvidia-fatbinaryloader.so \
  libnvidia-opencl.so \
  libnvidia-compiler.so \
  libnvidia-cfg.so \
  libvdpau.so \
  libvdpau_trace.so \
  libvdpau_nvidia.so \
  libnvidia-encode.so \
  libnvcuvid.so \
  libnvidia-fbc.so \
  libnvidia-ifr.so \
  libnvidia-wfb.so \
  libwfb.so \
  libGL.so \
  libGLX.so \
  libglx.so \
  libOpenGL.so \
  libOpenCL.so \
  libGLESv1_CM.so \
  libGLESv2.so \
  libEGL.so \
  libGLdispatch.so \
  libGLX_nvidia.so \
  libEGL_nvidia.so \
  libGLESv2_nvidia.so \
  libGLESv1_CM_nvidia.so \
  libnvidia-eglcore.so \
  libnvidia-egl-wayland.so \
  libnvidia-glcore.so \
  libnvidia-tls.so \
  libnvidia-glsi.so \
  nvidia_drv.so"

new_library_paths=""

prefix=usr
librarylist=$(mktemp)
trap "rm ${librarylist}" EXIT
find /host${prefix} > ${librarylist}

for filename in $NV_LIBS; do
  while read path; do
    newpath="/${prefix}${path#/host${prefix}}"

    if [ -f $path ]; then
      mkdir -p `dirname $newpath` && \
        cp -a $path $newpath

      if [[ $newpath == */lib/* || $newpath == */lib32/* || \
            $newpath == */lib64/* ]]; then
        libpath=$(dirname $newpath)
        new_library_paths="${libpath} ${new_library_paths}"
      fi
    fi
  done < <(grep "${filename}*" ${librarylist})
done


echo "$(date): Reconfiguring ldcache."

echo "${new_library_paths}" | tr ' ' '\n' | sort -u > /etc/ld.so.conf.d/nvidia.conf
ldconfig
