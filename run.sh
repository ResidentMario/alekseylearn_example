#!/bin/bash
if [[ "$1" = train ]]
then
    source activate runenv
    python train.py
fi