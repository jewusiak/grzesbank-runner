#!/bin/bash

if [[ " $@ " =~ " --clean "  ]]; then
    echo ">>> Cleaning tmp..."
    sudo rm -rf ./tmp
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

(
if [[ " $@ " =~ " --build "  ]]; then
  echo ">>> Compose with full rebuild..."
  docker compose up $DMN --build
else 
  echo ">>> Compose with optional rebuild..."
  docker compose up $DMN
fi
) || docker compose down