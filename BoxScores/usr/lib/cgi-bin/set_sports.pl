#!/usr/bin/perl

$HOME_DIRECTORY="/home/pi/BoxScores";
$COMMAND_FILE ="$HOME_DIRECTORY/sports.sh";
$PATTERN = "SPORTS=";
$SPORT_STRING="";

unless ($ENV{'QUERY_STRING'}=~/ALL=on/){
    $SETTINGS=$ENV{'QUERY_STRING'};

    while ($SETTINGS=~/^(.*?)=on[\&]*(.*)$/){

        $SPORT_STRING.="$1 ";
        $SETTINGS=$2;
    }
}

open (SPORT_FILE, ">$COMMAND_FILE");
    print SPORT_FILE "$PATTERN\"$SPORT_STRING\"\n";
close (SPORT_FILE);

print "Content-type:text/html\r\n\r\n";
print '<html>';
print '<head>';
print '<title>Configure Box Scores</title>';
print '<meta http-equiv="refresh" content="5; url=/">';
print '</head>';
print '<body>';
print "<h2>Configure Box Scores</h2>";
print 'This page will refresh automatically (in approximately 5 seconds).';
print '</body>';
print '</html>';
