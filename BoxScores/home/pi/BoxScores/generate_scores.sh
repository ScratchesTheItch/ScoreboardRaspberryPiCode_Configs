#!/bin/bash
SCORE_BIN_DIR="/home/pi/BoxScores"
. $SCORE_BIN_DIR/sports.sh

$SCORE_BIN_DIR/all-in-one-scores.pl $SPORTS

echo cheer
