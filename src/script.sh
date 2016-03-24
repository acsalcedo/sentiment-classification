#!/bin/bash

while true;
do
    now=$(date +"%T")
    echo "Current time : $now"
    python review.py
    sleep 600
done