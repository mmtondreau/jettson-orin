#!/bin/bash -eu
#cp /nfs/home/mmtondreau/letsencrypt/live/tonberry.org/fullchain.pem .
#cp /nfs/home/mmtondreau/letsencrypt/live/tonberry.org/privkey.pem .  
IMAGE=registry.tonberry.org/tonberry/torch:1.0
#docker build -t $IMAGE -f Dockerfile . 
#rm fullchain.pem privkey.pem

MOUNT=/home/mmtondreau/workplace/LoanDefaultPredictor
sudo docker run -it --rm --runtime nvidia --network host -v ${MOUNT}:/root/workspace2 $IMAGE 


