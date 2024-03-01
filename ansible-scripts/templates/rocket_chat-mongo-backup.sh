#!/bin/bash
sudo docker exec -i rocket_chat_mongo_1 /usr/bin/mongodump -o /dump
sudo docker cp rocket_chat_mongo_1:/dump ./db-dumps

GZIP=-9 tar czvf "./db-dumps/dump.tar.gz" -C "./db-dumps" "dump"


aws s3 cp "./db-dumps/dump.tar.gz" "s3://{{ s3_name }}/"
/usr/bin/find ./db-dumps -name "*.tar.gz" -type f -delete