#!/bin/sh

BASEDIR=`dirname $0`
HTML=$BASEDIR/pagi.html

cat $BASEDIR/header.htmlf > pagi.html

markdown_py -x codehilite -x extra $BASEDIR/pagi.md >> $BASEDIR/pagi.html

cat $BASEDIR/footer.htmlf >> pagi.html

