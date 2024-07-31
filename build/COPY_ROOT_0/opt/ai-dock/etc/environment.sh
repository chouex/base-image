# BUILDTIME INSTRUCTIONS
if [[ ! -f ~/.gitconfig ]]; then
    git config --global --add safe.directory "*"
fi

alias nv='watch -n 0.5 nvidia-smi'
