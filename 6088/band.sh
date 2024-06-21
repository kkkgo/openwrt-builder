#!/bin/sh
echo "BAND_NAME=${{ github.event.inputs.BAND_NAME }}" > band.txt
echo "BAND_NAME_ADDMAC=${{ github.event.inputs.BAND_NAME_ADDMAC }}" >> band.txt
echo "BAND_SSID=${{ github.event.inputs.BAND_SSID }}" >> band.txt
echo "BAND_ROOT_PASS=${{ github.event.inputs.BAND_ROOT_PASS }}" >> band.txt
echo "BAND_WLAN_PASS=${{ github.event.inputs.BAND_WLAN_PASS }}" >> band.txt
echo "PASS_PUBKEY=${{ github.event.inputs.PASS_PUBKEY }}" >> band.txt
echo "BAND_CIDR=${{ github.event.inputs.BAND_CIDR }}" >> band.txt