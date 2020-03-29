#!/usr/bin/env bash
set -x
source /etc/lsb-release

export DEBIAN_FRONTEND="noninteractive"

sudo apt-get update -y

sudo apt-get install python-pip jq software-properties-common -y

        