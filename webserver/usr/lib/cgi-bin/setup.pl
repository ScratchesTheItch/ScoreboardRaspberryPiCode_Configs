#!/usr/bin/perl

$HOME_DIRECTORY="/home/pi/gamechanger/team_settings";
$LOGO_FILE="$HOME_DIRECTORY/logo.txt";
$ID_FILE="$HOME_DIRECTORY/team_id.txt";

open(TEAM_ID_FILE, "<", $ID_FILE);
while (<TEAM_ID_FILE>){
    if (/TeamID=(\S*)/){
        $TeamID=$1;
    }
}
close(TEAM_ID_FILE);

print "Content-type:text/html\r\n\r\n";
print '<html>';
print '<head>';
print '<title>Setup Scoreboard</title>';
print '</head>';
print '<body>';
print "<h2>Team Logo</h2>";

print '<form action="/cgi-bin/set_logo.pl"><table>';

open (LOGO, "<", $LOGO_FILE);
for ($i=0; $i<8; $i++){

    print '<tr>';
    $INPUT=<LOGO>;
    $INPUT=~/^(.)(.)(.)(.)(.)(.)/;
   @LINE=($1,$2,$3,$4,$5,$6);

   for ($j=0;$j<6; $j++){
      
       print "<td><input type=checkbox name=Cell$i$j "; 
       unless ($LINE[$j] eq " "){
           print ' checked';
       }
       print "></td>";
   }
   print "</tr>";
}
print "</table><BR><input type=submit value=\"Change Logo\"></form>";
close (LOGO); 

print "<HR>";

print "<form action=\"/cgi-bin/set_team_id.pl\">";
print "<H2>Team's Gamechanger ID</H2>";
print "<i>NOTE: Your team's Gamechanger ID can be found by navigating to their gamechanger home page and copying the last part of the home page's URL (the random string part)</i><br>";
print "<input type=text value=\"$TeamID\" name=TeamID size=32>";
print "<input type=submit value=\"Change Team ID\">";
print "</form>";


print '</body>';
print '</html>';
