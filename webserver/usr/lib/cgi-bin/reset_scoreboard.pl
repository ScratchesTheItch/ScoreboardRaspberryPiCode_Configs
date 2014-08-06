#!/usr/bin/perl

$RESET_BIN="/home/pi/reset_scoreboard.sh";

system("sudo -u root $RESET_BIN &");

print "Content-type:text/html\r\n\r\n";
print '<html>';
print '<head>';
print '<title>Scoreboard Reset</title>';
print '<meta http-equiv="refresh" content="5; url=/">';
print '</head>';
print '<body>';
print '<h2>Scoreboard Reset</h2>';
print '</body>';
print '</html>';
