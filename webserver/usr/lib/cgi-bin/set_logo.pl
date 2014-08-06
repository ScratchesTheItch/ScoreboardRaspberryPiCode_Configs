#!/usr/bin/perl

$HOME_DIRECTORY="/home/pi/gamechanger";
$LOGO_FILE="$HOME_DIRECTORY/team_settings/logo.txt";
$COMMAND_FILE="$HOME_DIRECTORY/command.txt";

print "Content-type:text/html\r\n\r\n";
print '<html>';
print '<head>';
print '<title>Logo changed</title>';
print '<meta http-equiv="refresh" content="5; url=/">';
print '</head>';
print '<body>';
print '<h2>Logo changed</h2>';

@VALUE=(0,0,0,0,0,0);
open(LOGO, ">", $LOGO_FILE);
$VAL=1;
for ($i=0; $i<8; $i++){
    for ($j=0; $j<6; $j++){
        if ($ENV{'QUERY_STRING'}=~/Cell$i$j=on/){
            print LOGO "#";
            $VALUE[$j]+=$VAL;
        }
        else {
            print LOGO " ";
        }
    }
    $VAL*=2;
    print LOGO "\n";
}

close (LOGO);

print '</body>';
print '</html>';

open (COMMAND, ">", $COMMAND_FILE);
print COMMAND "setMyLogo $VALUE[0],$VALUE[1],$VALUE[2],$VALUE[3],$VALUE[4],$VALUE[5]\n";
close (COMMAND);


