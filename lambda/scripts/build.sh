#!/bin/bash
echo $(PWD)
rm -rf $(PWD)build/*
pip install -r $(PWD)/src/requirements.txt -t $(PWD)/build/
cp -r $(PWD)/src/* $(PWD)/build/
