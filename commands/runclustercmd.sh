#!/usr/bin/env bash
if [ -z "$1" -o -z "$2" ]; then 
        echo "usage: $0 <jobscript> <numjobs>"
        exit
fi

qsub -t 1-$2 -cwd -m e -M `whoami`@lmb.internal -notify $1
