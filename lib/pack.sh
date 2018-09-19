#!/usr/bin/env bash

input_path=$1
output_path=$2

cd $input_path
zip -r $output_path *
zip -d $output_path pack.yaml
cd ..
rm -rf $input_path
