#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <timestamp-image-file> <gpx-file>"
    exit 1
fi


TIMESTAMP_IMG=$1
GPX=$2

if [ ! -f "$TIMESTAMP_IMG" ]; then
    echo "$TIMESTAMP_IMG does not exist."
    exit 1
fi
if ! file "$TIMESTAMP_IMG" | grep -q 'JPEG image'; then
    echo "$TIMESTAMP_IMG must be a JPEG image file."
    exit 1
fi

if [ ! -f "$GPX" ]; then
    echo "$GPX does not exist."
    exit 1
fi
if ! grep -iq '<gpx' $GPX; then
    echo "$GPX is not a GPX file."
    exit 1
fi

GPS_DATE=$(zbarimg -q $TIMESTAMP_IMG | sed 's/QR-Code://')
CAMERA_DATE=$(exiftool -EXIF:CreateDate $TIMESTAMP_IMG | sed -r 's/^.*([0-9]{4}):([0-9]{2}):([0-9]{2}) /\1-\2-\3T/')

if [ ! $GPS_DATE ]; then
    echo "Can't extract GPS date from $TIMESTAMP_IMG - Make sure QR code is clear on the picture."
    exit 1
fi
if [ ! $GPS_DATE ]; then
    echo "Can't extract picture date and time date from $TIMESTAMP_IMG."
    exit 1
fi

GPS_TIME=$(gdate -d"$GPS_DATE" +%s)
CAMERA_TIME=$(gdate -d"$CAMERA_DATE" +%s)                                                                         

exiftool -geosync=$(expr $GPS_TIME - $CAMERA_TIME) -geotag $GPX *.JPG *.CR2
