#!/bin/bash

arg_dockerfile=Dockerfile
arg_imagename=model
arg_help=0
arg_ssh_pub=0
args_git_branch=master

while [[ "$#" -gt 0 ]]; do case $1 in
    --file) arg_dockerfile="$2"; shift;;
    --tag) arg_imagename="$2"; shift;;
    --arg_git_branch) arg_git_branch="$2"; shift;;
    --arg_ssh_pub) arg_ssh_pub=1; shift;;
    -h|--help) arg_help=1;;
    *) echo "Unknown parameters passed: $1"; echo "For help type: $0 --help"; exit 1;
esac; shift; done


if [ "$arg_help" -eq "1" ]; then
    echo "Usage: $0 [options]"
    echo "  --help or -h          : Print this help menu."
    echo "  --file <dockerfile>   : Docker file to use for build."
    echo "  --tag <imagename>     : Image name for the generated container."
    echo "  --arg_git_branch      : git specific branch."
    echo "  --arg_ssh_pub         : Whether add ssh pub for some private repository."
    exit;
fi

echo "Building container"

# add ssh pub
if [[ "$arg_ssh_pub" -eq "1" ]]; then
    echo "> add .ssh"
    mkdir -p ssh
    cp $HOME/.ssh/{id_rsa,id_rsa.pub} ssh/
    arg_ssh_pub=ssh
fi


docker_args="-f $arg_dockerfile \\
            --build-arg SSH_DIR=$arg_ssh_pub \\
            --build-arg GIT_BRANCH=$git_branch \\
            --tag=$arg_imagename ."

echo "> docker build $docker_args"

docker build $docker_args

if [ -d $arg_ssh_pub ]; then
    rm -rf $arg_ssh_pub
fi

