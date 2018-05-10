#!/bin/bash

mkdir -p raw_data
aws s3 sync s3://olgabot-antibody/h1n1_memory_bcells/ raw_data/

mv