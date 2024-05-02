#!/bin/bash
if [ ! -f "imm/ax6.config" ]; then
    cp "./ax6/.config" "imm/ax6.config"
fi
docker build -t sliamb/opbuilder:imm ./imm
docker push sliamb/opbuilder:imm
