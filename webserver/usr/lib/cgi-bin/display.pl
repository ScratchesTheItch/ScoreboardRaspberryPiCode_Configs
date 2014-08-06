#!/usr/bin/perl

$HOME_DIRECTORY="/home/pi/gamechanger";
$COMMAND_FILE="$HOME_DIRECTORY/command.txt";
$HScore=0;
$VScore=0;
$Inning=1;
$Half=0;
$Balls=0;
$Strikes=0;
$Outs=0;
$First=0;
$Second=0;
$Third=0;

$ENV{'QUERY_STRING'}=~/HScore=(\d+)/;
    $HScore=$1;
$ENV{'QUERY_STRING'}=~/VScore=(\d+)/;
    $VScore=$1;

$ENV{'QUERY_STRING'}=~/Inning=(\d+)/;
    $Inning=$1;
if ($ENV{'QUERY_STRING'}=~/half=bottom/i){
    $Half=1;
}

$ENV{'QUERY_STRING'}=~/Balls=(\d+)/;
    $Balls=$1;
$ENV{'QUERY_STRING'}=~/Strikes=(\d+)/;
    $Strikes=$1;
$ENV{'QUERY_STRING'}=~/Outs=(\d+)/;
    $Outs=$1;

if ($ENV{'QUERY_STRING'}=~/First=on/){
    $First=1;
}
if ($ENV{'QUERY_STRING'}=~/Second=on/){
    $Second=1;
}
if ($ENV{'QUERY_STRING'}=~/Third=on/){
    $Third=1;
}

if ($ENV{'QUERY_STRING'}=~/Side=Away/){
    $Side=AWAY;
}
elsif ($ENV{'QUERY_STRING'}=~/Side=Home/){
    $Side=HOME;
}

open (COMMAND, ">>", $COMMAND_FILE);

if (defined $Side){
    print COMMAND "SGS $VScore,$HScore,$Half,$Inning,$First,$Second,$Third,$Balls,$Strikes,$Outs\n";
    print COMMAND "setMySide $Side\n";
}
else{
    print COMMAND "SGS $VScore,$HScore,$Half,$Inning,$First,$Second,$Third,$Balls,$Strikes,$Outs\n";
}

close(COMMAND);

print "Content-type:text/html\r\n\r\n";
print '<html>';
print '<head>';
print '<title>Change Sent</title>';
print '<meta http-equiv="refresh" content="5; url=/">';
print '</head>';
print '<body>';
print '<h2>Change sent</h2>';
print '</body>';
print '</html>';
