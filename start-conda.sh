#!/bin/bash -eu
cp /nfs/home/mmtondreau/letsencrypt/live/tonberry.org/fullchain.pem .
cp /nfs/home/mmtondreau/letsencrypt/live/tonberry.org/privkey.pem .  
docker build -t conda -f Dockerfile.conda . 
rm fullchain.pem privkey.pem

MOUNT=/home/mmtondreau/workplace/LoanDefaultPredictor
sudo docker run -it --rm --runtime nvidia --network host -v ${MOUNT}:/root/workspace  conda:latest 


