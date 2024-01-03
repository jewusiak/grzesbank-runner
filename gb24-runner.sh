#!/bin/bash

BASE_PATH=$(pwd)

echo "$BASE_PATH bp"

if [[ " $@ " =~ " -h "  ]]; then
  echo "gb24-runner help:"
  echo "-----------------------"
  echo "--clean - clean tmp folder"
  echo "--pull - pull latest changes from git"
  echo "  -f - hard reset to HEAD before pull"
  echo "  -I <branch> - specify apI branch (default master)"
  echo "  -P <branch> - specify apP branch (default master)"
  echo "--gen-cert - generate 30-days self-signed SSL certificate"
  echo "--no-daemon - do not run docker compose with -d flag (daemon)"
  echo "--build - build all projects"
  exit 0
fi

if [[ " $@ " =~ " --clean "  ]]; then
    echo ">>> Cleaning tmp..."
    rm -rf ./tmp
fi

mkdir -p "tmp/docker_resources"

if [[ " $@ " =~ " --pull "  ]]; then
  BRANCH_APP="master"
  BRANCH_API="master"
  while getopts ":PI:" option; do
    case $option in
      P) #other branch apP
        BRANCH_APP=$OPTARG;;
      I) #other branch apI
        BRANCH_API=$OPTARG;;
    esac 
    
  done
  
  if [[ " $@ " =~ " -f "  ]]; then
    echo ">>> Resetting to HEAD..."
    cd tmp/grzesbank_app && 
    git reset --hard HEAD &&
    git clean -f -d
    cd $BASE_PATH
    cd tmp/grzesbank-api &&
    git reset --hard HEAD  &&
    git clean -f -d
    cd $BASE_PATH 
  fi
  
    echo ">>> Pulling from $BRANCH ..."
    cd tmp
    git clone -b $BRANCH_APP https://github.com/jewusiak/grzesbank_app || ( cd grzesbank_app && git pull && git checkout $BRANCH_APP && echo ">>> Pulled newest version of gb24-app" || echo ">>> Problem with gb24-app pull :(")
    git clone -b $BRANCH_API https://github.com/jewusiak/grzesbank-api || ( cd grzesbank-api && git pull && git checkout $BRANCH_API && echo ">>> Pulled newest version of gb24-api" || echo ">>> Problem with gb24-api pull :(")
    cd ..
fi

if [[ " $@ " =~ " --gen-cert "  ]]; then
  echo ">>> Generating certs..."
  openssl req -x509 -newkey rsa:4096 -nodes -keyout tmp/docker_resources/private.key -out tmp/docker_resources/cert.crt -sha256 -days 30 -subj "/C=PL/ST=Mazowieckie/L=Warsaw/O=Grzesbank/OU=Grzesbank24/CN=localhost"
fi

DMN="-d"

if [[ " $@ " =~ " --no-daemon "  ]]; then
  echo ">>> Disabling daemon..."
  DMN=""
fi


if [[ " $@ " =~ " --build "  ]]; then
  echo ">>> Compose with full rebuild..."
  docker compose up $DMN --build
else 
  echo ">>> Compose with optional rebuild..."
  docker compose up $DMN
fi