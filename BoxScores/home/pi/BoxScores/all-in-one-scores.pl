#!/usr/bin/perl

($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
$mon++;
$DATE_STRING="$mon/$mday";
#$DATE_STRING="9/4";

$SUMMARY_URL="http://scores.nbcsports.com/ticker/data/sports.js.asp?jsonp=true&order";
# Full URL should be http://scores.nbcsports.com/ticker/data/sports.js.asp?jsonp=true&order=cfb%7cnfl%7cmlb

$SCORE_URL="http://scores.nbcsports.com/ticker/data/gamesNEW.js.asp?jsonp=true";
# Full URL should be http://scores.nbcsports.com/ticker/data/gamesNEW.js.asp?jsonp=true&sport=CFB&period=2

$COMMAND=lc(join("%7c",@ARGV));

open (SPORTS_SUMMARY, "wget -O - \'$SUMMARY_URL=$COMMAND\' 2>/dev/null|");

while (<SPORTS_SUMMARY>){
   
    my $LINE=$_;
    #print $LINE;
    chomp $LINE;

    if ($LINE=~/{"sport": "([A-Z]*)".*{"period": "([^"]*)".*?"isdefault": true.*$/){
        $SPORT=$1;
        $PERIOD=$2;

        open (SPORTS_SCORES, "wget -O - \'$SCORE_URL&sport=$SPORT&period=$PERIOD\' 2>/dev/null|");
        #open (SPORTS_SCORES, "<" . lc($SPORT) . "testdata.txt");

        @SCORE_CMDS=();
        while (<SPORTS_SCORES>){

            my $SLINE=$_;
            #print $SLINE;
            chomp ($SLINE);

            if ($SLINE=~/visiting-team.*?alias=\\"([^\\]*)\\".*?score=\\"(\d*)\\".*?home-team.*?alias=\\"([^\\]*)\\.*?score=\\"(\d*)\\"(.*gamedate=\\"$DATE_STRING\\".*)$/){
           
                $VTEAM=uc($1);
                $VSCORE=$2; 
                $HTEAM=uc($3);
                $HSCORE=$4;
                $REMAINDER=$5;

                if ($SPORT eq "CFB"){
                    $VTEAM=~/^\S*?\s*?(\S*)$/;
                    $VTEAM=substr($1,0,4);
                    $HTEAM=~/^\S*?\s*?(\S*)$/;
                    $HTEAM=substr($1,0,4);
                }
                else {
                    $VTEAM=substr($VTEAM,0,3);
                    $HTEAM=substr($HTEAM,0,3);
                }

                if ($REMAINDER=~/gamestate status=\\"Final\\"/){
                    push @SCORE_CMDS, 
                      "GameRecap_$VTEAM,$VSCORE,$HTEAM,$HSCORE,F,-\n";
                }
                elsif ($REMAINDER=~/gamestate status=\\"In-Progress\\".*?display_status1=\\"([TB])[^\\]*\\".*?display_status2=\\"(\d*)/){
                    $INNING=$2;
                    $HALF=$1;
                    unshift @SCORE_CMDS, "GameRecap_$VTEAM,$VSCORE," .
                      "$HTEAM,$HSCORE,$INNING,$HALF\n"; 
                }
                elsif ($REMAINDER=~/gamestate status=\\"In-Progress\\".*?display_status1=\\"[^\\]*\\".*?display_status2=\\"(\d+)/){
                    $QUARTER=$1;
                    unshift @SCORE_CMDS, "GameRecap_$VTEAM,$VSCORE," .
                      "$HTEAM,$HSCORE,$QUARTER,-\n";
                }
                elsif ($REMAINDER=~/gamestate status=\\"In-Progress\\".*?display_status1=\\"Half\\"/){
                    unshift @SCORE_CMDS, "GameRecap_$VTEAM,$VSCORE," .
                      "$HTEAM,$HSCORE,H,-\n";
                }
            }
        }
        
        close (SPORTS_SCORES);
        if (@SCORE_CMDS > 0) {
             print "printScoreUpdate_$SPORT\n";
             foreach (@SCORE_CMDS){
                 print;
             }
        }
    } 
}

close (SPORTS_SUMMARY);
