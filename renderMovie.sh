#!/bin/bash

# This file is part of the Odtwarzanie poklatkowe Project.
# http://lab.180hb.com/2011/08/odtwarzanie-poklatkowe/
#
# Copyright (c) 2011 LAB^180 (http://lab.180hb.com).
#
# @author Szymon P. Peplinski (speplinski@180hb.com)
# @author Marek Brach (mbrach@180hb.com)
#
# This code is licensed to you under the terms of the Creative Commons 
# Attribution–Share Alike 3.0 Unported license ("CC BY-SA 3.0").
# An explanation of CC BY-SA 3.0 is available at 
# http://creativecommons.org/licenses/by-sa/3.0/.
#
# The original authors of this document, and LAB^180, 
# designate this project as the "Attribution Party" 
# for purposes of CC BY-SA 3.0.
#
# In accordance with CC BY-SA 3.0, if you distribute this document 
# or an adaptation of it, you must provide the URL 
# for the original version.

HOST="http://host/makeMovieComplete"
DRAFT_DIR="/home/project/shared/drafts"
STREAMS_DIR="/home/project/shared/streams"
KEYFRAME=50
DURATION=643

if [ -n "$3" ]
then

  FRAME_HASH=$3

  if [ -n "$1" ] && [ -n "$2" ]
  then

    FRAME_ID=$1
    TOTAL_LOOPS=$2

    LOOP_ID=$(( FRAME_ID / DURATION ))
    LOOP_ID=${LOOP_ID/.*} # floor

    LOOP_MODULO=$(( FRAME_ID % DURATION ))

    KEYFRAME_ID=$(( FRAME_ID / KEYFRAME ))
    KEYFRAME_ID=${KEYFRAME_ID/.*} # floor

    KEYFRAME_MODULO=$(( FRAME_ID % KEYFRAME ))

    START_FRAME=$(( DURATION + LOOP_MODULO - KEYFRAME_MODULO ))
    START_FRAME=$(( START_FRAME % DURATION ))

    if [ $KEYFRAME_ID -lt $TOTAL_LOOPS ]
    then
      KEYFRAME_LENGTH=$(( KEYFRAME - 1 ))
    else
      KEYFRAME_LENGTH=$KEYFRAME_MODULO
    fi

    START_FRAME=$(( DURATION + LOOP_MODULO - KEYFRAME_MODULO ))
    START_FRAME=$(( START_FRAME % DURATION ))

    TEMP_DIR=$(mktemp -d /tmp/ffmpeg_XXXXXXXXXXXXXXXXXXXXXXXX) || { 
      echo "Failed to create temp file"
      exit 1
    }

    KEYFRAME_INDEX=0 

    while [ $KEYFRAME_INDEX -le $KEYFRAME_LENGTH ]
    do
        FILE=$(( START_FRAME + KEYFRAME_INDEX ))
        FILE=$(( FILE % DURATION ))

        if [ ! -f $DRAFT_DIR/$FILE.jpg  ]
        then
          break
        else
          cp $DRAFT_DIR/$FILE.jpg $TEMP_DIR/$KEYFRAME_INDEX.jpg
        fi

        KEYFRAME_INDEX=$(( KEYFRAME_INDEX + 1 ))
    done

    #ffmpeg bug: fps 24 drop frames!
    ffmpeg -y -i $TEMP_DIR/%d.jpg -r 25 -s 640x360 -b 1536k -an -vcodec flv -f avm2 $STREAMS_DIR/$KEYFRAME_ID.swf #1>/dev/null 2>/dev/null

    rm -rf $TEMP_DIR

    curl --data "frameHash=$FRAME_HASH" $HOST #> /dev/null 2>&1

  fi

fi