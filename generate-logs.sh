#!/bin/sh
# Written just for fun and to get random timings in logs of server!
# Dmitry Olshansky, August 2018
#
LONGEST=10.0 # seconds of delay
FIXED=0.5 # minimum of delay, fixed portion
for r in `seq 1 1000` ; do
  # abuse awk to generate random double!
  RAND=`echo r | awk '{ print rand() }'`
  echo "$FIXED + $RAND * $LONGEST"
  # sleep less then 3 seconds + time to run python2 or python3?
  python -c "import time; time.sleep($FIXED + $LONGEST * $RAND)"
  # spawning curl each time adds its own delay - it gets interesting!
  curl "localhost:8000/?id=$RAND" > /dev/null
done

