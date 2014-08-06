#!/usr/bin/perl

$RESET_BIN="/home/pi/reset_scoreboard.sh";
$HOME_DIRECTORY="/home/pi/gamechanger/team_settings";
$ID_FILE="$HOME_DIRECTORY/team_id.txt";

$ENV{'QUERY_STRING'}=~/TeamID=([a-z0-9]*)/;
$TeamID=$1;

open (TEAMID, ">", $ID_FILE);
print TEAMID "TeamID=$TeamID\n";
close (TEAMID);

system("sudo -u root $RESET_BIN &");

print "Content-type:text/html\r\n\r\n";
print '<html>';
print '<head>';
print '<title>Team ID Changed</title>';
print '<meta http-equiv="refresh" content="5; url=/">';
print '</head>';
print '<body>';
print '<h2>Team ID Changed</h2>';
print '</body>';
print '</html>';
