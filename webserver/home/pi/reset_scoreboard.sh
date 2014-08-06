#!/bin/sh

kill $(pidof perl)
sleep 1
/home/pi/gamechanger/bin/read_set_scoreboard.pl > /dev/null&

