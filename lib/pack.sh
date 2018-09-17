#!/usr/bin/env bash

input_path=$1
output_path=$2

cd $input_path
zip -r $output_path *
cd ..
rm -rf $input_path
