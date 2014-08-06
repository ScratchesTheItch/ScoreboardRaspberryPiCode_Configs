#!/usr/bin/perl

$ENV{'QUERY_STRING'}=~/^msg=([^&]*)/;
$MESSAGE=$1;
$MESSAGE=~s/\+/ /g;

$HOME_DIRECTORY="/home/pi/gamechanger";
$COMMAND_FILE="$HOME_DIRECTORY/command.txt";

open (COMMAND, ">>", $COMMAND_FILE);

print COMMAND "message $MESSAGE\n";

close(COMMAND);

print "Content-type:text/html\r\n\r\n";
print '<html>';
print '<head>';
print '<title>Message Sent</title>';
print '<meta http-equiv="refresh" content="5; url=/">';
print '</head>';
print '<body>';
print '<h2>Message sent</h2>';
print '</body>';
print '</html>';
