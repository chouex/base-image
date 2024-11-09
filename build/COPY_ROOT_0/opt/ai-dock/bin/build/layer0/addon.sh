#!/bin/bash

for line in ${CKPT//\\n/ } ; do 
   echo "+ \"$line\""
   wget -qnc --content-disposition --show-progress -e dotbytes="${3:-4M}" -P  "/workspace/storage/stable_diffusion/models/ckpt/" $line;
done
