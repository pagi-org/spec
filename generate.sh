#!/bin/sh

BASEDIR=`dirname $0`
HTML=$BASEDIR/pagi.html
OUTDIR=$BASEDIR/target
mkdir -p $OUTDIR
OUTFILE=$OUTDIR/pagi.html

cat $BASEDIR/header.htmlf > $OUTFILE

markdown_py -x codehilite -x extra $BASEDIR/pagi.md >> $BASEDIR/$OUTFILE

cat $BASEDIR/footer.htmlf >> $OUTFILE

