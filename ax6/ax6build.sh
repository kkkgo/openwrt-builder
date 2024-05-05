#!/bin/bash
cd ax6 || exit
docker build -t sliamb/opbuilder:ax6 .
docker push sliamb/opbuilder:ax6
