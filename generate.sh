#!/bin/sh

BASEDIR=`dirname $0`
HTML=$BASEDIR/pagi.html
OUTDIR=$BASEDIR/target
mkdir -p $OUTDIR
OUTFILE=$OUTDIR/pagi.html
TEMPMD=$OUTDIR/pagi.tmp.md

cat $BASEDIR/web/header.htmlf > $OUTFILE

sed -e "/<<<<pagis.xsd>>>>/ {
	r $BASEDIR/resources/pagis.xsd
	d
}" -e "/<<<<pagif-xml.xsd>>>>/ {
	r $BASEDIR/resources/pagif-xml.xsd
	d
}" < $BASEDIR/pagi.md > $TEMPMD

markdown_py -x codehilite -x extra $TEMPMD >> $BASEDIR/$OUTFILE

cat $BASEDIR/web/footer.htmlf >> $OUTFILE

cp $BASEDIR/assets/* $OUTDIR

