#!/usr/bin/env bash

# mmds: multi-monitor display standby

# copyright 2022, P. Lutus https://arachnoid.com
# released under the GPL

# must install:
#  xprintidle
#  x11-server-utils (normally installed)

# to kill any current invocation:

# $ mmds.sh -k

# don't run as root

[[ $UID -eq 0 ]] && exit

# don't run without X access

[[ -z $DISPLAY ]] && exit

set +m # try to suppress kill messages

# allow only one instance to run

path=$(dirname $0)

pidfile=$path/mmd.pid

[[ -f $pidfile ]] && {
  # kill prior invocation
  kill $(<$pidfile) > /dev/null 2>&1
  # remove flag file
  rm $pidfile > /dev/null 2>&1
}

# exit now if -k argument given

[[ $1 == "-k" ]] && exit

# otherwise run this script

# create new pidfile

echo "$$" > $pidfile

dtime=600 # delay time: 600 seconds (10 minutes) before monitors off

#dtime=10 # for testing: 10 seconds before monitors off

ptime=8 # pause time between first power-off and rapid repeat sequence

# sum of ptime and dtime

dptime=$((dtime+ptime))

activity_threshold=200 # activity threshold for user activity, units ms

# debug=true : print lots of debugging information

debug=false

debug_print() {
  if $debug; then
    echo "$(date): $1"
  fi
}

time=0
phase=0
reset=false

while true; do
  # test for user activity
  activity_ms=$(xprintidle)
  debug_print "phase $phase: time: $time, activity: $activity_ms :: threshold: $activity_threshold"
  # if activity within activity_threshold interval
  if $reset || [[ $activity_ms -lt $activity_threshold ]]; then
    debug_print "user activity reset in phase $phase"
    time=0
    phase=0
    reset=false
  else
    ((time++))
  fi
  # test for end of delay time
  if [[ $time -eq $dtime ]]; then
    ((phase++))
    debug_print "start single force-off phase $phase"
    xset dpms force off
  fi
  # test for end of pause time
  if [[ $time -eq $dptime ]]; then
    ((phase++))
    debug_print "start rapid force-off sequence phase $phase"
    # rapid, repeated force-off command
    # to prevent monitor restarts
    for ((x = 0;x < 100;x++)); do
      # every 20 ms
      sleep 0.02
      xset dpms force off
      # test for user activity
      activity_ms=$(xprintidle)
      debug_print "force-off count = $x, activity: $activity_ms"
      # break if user activity detected
      if [[ $activity_ms -lt $activity_threshold ]]; then
        reset=true
        break
      fi
    done
  fi
  sleep 1
done
