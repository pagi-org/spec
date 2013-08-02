#!/bin/sh

BASEDIR=`dirname $0`

markdown_py -x extra $BASEDIR/pagi.md > $BASEDIR/pagi.html
