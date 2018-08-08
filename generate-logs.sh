#!/bin/sh
# Written just for fun and to get random timings in logs of server!
# Dmitry Olshansky, August 2018
#

for r in `seq 1 1000` ; do
  # abuse awk to generate random double!
  RAND=`echo r | awk '{ print rand() }'`
  # sleep less then a second + time to run python (2 or 3?)
  python -c "import time; time.sleep($RAND)"
  # spawning curl each time adds its own delay - it gets interesting!
  curl "localhost:8000/?id=$RAND" > /dev/null
done

