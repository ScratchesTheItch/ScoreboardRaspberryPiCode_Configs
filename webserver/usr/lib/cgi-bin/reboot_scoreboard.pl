#!/usr/bin/perl

$REBOOT_BIN="/sbin/reboot";

system("sudo -u root $REBOOT_BIN");

print "Content-type:text/html\r\n\r\n";
print '<html>';
print '<head>';
print '<title>Scoreboard Reboot</title>';
print '<meta http-equiv="refresh" content="90; url=/">';
print '</head>';
print '<body>';
print '<h2>Scoreboard Rebooting.</h2>';
print 'This page will refresh automatically once scoreboard has rebooted (in approximately 90 seconds).';
print '</body>';
print '</html>';
