#!/usr/bin/env bash
qsub -t 1-$2 -cwd -m e -M `whoami`@lmb.internal -notify $1
