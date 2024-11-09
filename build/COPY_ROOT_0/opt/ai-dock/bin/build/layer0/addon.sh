IFS=$'\n' 
for line in $CKPT; do 
  wget -qnc --content-disposition --show-progress -e dotbytes="${3:-4M}" -P  "/workspace/storage/stable_diffusion/models/ckpt/" $line;
done
