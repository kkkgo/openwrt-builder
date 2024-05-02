#!/bin/bash
if [ ! -f "imm/6088.config" ]; then
    cp "./6088/.config" "imm/6088.config"
fi

if [ ! -f "imm/ax6.config" ]; then
    cp "./ax6/.config" "imm/ax6.config"
fi
docker build -t sliamb/opbuilder:imm ./imm
docker push sliamb/opbuilder:imm
