#!/usr/bin/perl

$COMMAND_FILE ="/home/pi/gamechanger/command.txt";
$COMMAND = "ShowScoresNow";

system("echo $COMMAND >> $COMMAND_FILE");

print "Content-type:text/html\r\n\r\n";
print '<html>';
print '<head>';
print '<title>Show Scores Now</title>';
print '<meta http-equiv="refresh" content="5; url=/">';
print '</head>';
print '<body>';
print '<h2>Show Scores Now</h2>';
print 'This page will refresh automatically (in approximately 5 seconds).';
print '</body>';
print '</html>';
