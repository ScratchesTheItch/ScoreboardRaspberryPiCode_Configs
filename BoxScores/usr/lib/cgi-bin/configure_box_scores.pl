#!/usr/bin/perl

$CONFIG_FILE="/home/pi/BoxScores/sports.txt";

print "Content-type:text/html\r\n\r\n";
print '<html>';
print '<head>';
print '<title>Setup Box Scores</title>';
print '</head>';
print '<body>';
print "<h2>Configure Box Scores</h2>";

print '<form action="/cgi-bin/set_sports.pl"><table>';
print "<input type=checkbox name=\"ALL\" checked >All available sports<BR>\n";
print "<HR>\n";

open (CONFIG, "<$CONFIG_FILE");

while (<CONFIG>){
    ($Option, $Description) = split(/\t/);
    print "<input type=checkbox name=\"$Option\" checked >$Description<BR>\n";
}

#print "<input type=checkbox name=MLB checked >MLB Scores<BR>\n";
#print "<input type=checkbox name=NFL checked >NFL Scores <BR>\n";
print "<input type=submit value=\"Set Box Score Sports\"></form>";
close (LOGO); 

print "<HR>";

print "<form action=\"/cgi-bin/show_scores_now.pl\">";
print "<input type=submit value=\"Show Scores Now\">";
print "</form>";


print '</body>';
print '</html>';
