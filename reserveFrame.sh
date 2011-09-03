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

HOST="http://host/reserveFrameComplete";
SHARED_DIR="/home/project/shared";
DURATION=643; # maksymalna ilość klatek filmu

if [ -n "$1" ]; then

  FRAME_ID=$1;

  LOOP_ID=$((FRAME_ID / DURATION));
  LOOP_ID=${LOOP_ID/.*}; # Zaokrąglenie w dół (floor)

  MODULO=$((FRAME_ID % DURATION));

  cp $SHARED_DIR/frames/$MODULO.jpg $SHARED_DIR/drafts/$FRAME_ID.jpg;

  curl --data "frameId=$FRAME_ID" $HOST > /dev/null 2>&1;

fi;