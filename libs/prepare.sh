#!/bin/sh 

if [ ! "$(ls -A ../Shock)" ]; then
    cd ..
    git submodule init
    git submodule update
    cd -
fi

