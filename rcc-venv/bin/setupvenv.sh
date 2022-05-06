#!/bin/sh

mkdir tmp
rm -rf .venv
python -m venv .venv
cp .venv/bin/?ctivate* .venv/pyvenv.cfg tmp/
rm -rf .venv

ln -s $CONDA_PREFIX .venv
cp tmp/?ctivate* .venv/bin/
cp tmp/pyvenv.cfg .venv/
echo Python path: $(which python)
rm -rf tmp
