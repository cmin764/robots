#!/bin/sh

rm -rf tmp venv
mkdir tmp
python -m venv venv
cp venv/bin/?ctivate* tmp/
cp venv/pyvenv.cfg tmp
rm -rf venv
ln -s $CONDA_PREFIX venv
cp tmp/?ctivate* venv/bin/
cp tmp/pyvenv.cfg venv/

