#!/bin/bash
if [ ! -f "imm/ax6.config" ]; then
    cp "./ax6/.config" "imm/ax6.config"
fi
cd imm || exit
docker build -t sliamb/opbuilder:imm .
docker push sliamb/opbuilder:imm
