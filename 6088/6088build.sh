#!/bin/bash
cd 6088 || exit
docker build -t sliamb/opbuilder:6088 .
docker push sliamb/opbuilder:6088
