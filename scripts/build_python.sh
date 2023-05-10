#!/bin/bash

rm -rf venv

python3.11 -m venv venv
source venv/bin/activate
python3.11 -m pip install --upgrade pip
python3.11 -m pip install -r requirements.txt
