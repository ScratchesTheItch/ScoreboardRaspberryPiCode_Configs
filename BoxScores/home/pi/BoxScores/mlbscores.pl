#!/usr/bin/perl

$URL="http://sports.espn.go.com/mlb/bottomline/scores";

%TeamMappings = ( "Atlanta"       => "ATL",   
                  "Arizona"       => "ARI",
                  "Baltimore"     => "BAL",
                  "Boston"        => "BOS",
                  "Chicago Cubs"  => "CHC",
                  "Chicago Sox"   => "CWS",
                  "Cincinnati"    => "CIN",
                  "Cleveland"     => "CLE",
                  "Colorado"      => "COL",
                  "Detroit"       => "DET",
                  "Houston"       => "HOU",
                  "Kansas City"   => "KC",
                  "LA Angels"     => "LAA",  
                  "LA Dodgers"    => "LAD",
                  "Miami"         => "MIA",
                  "Milwaukee"     => "MIL",
                  "Minnesota"     => "MIN",
                  "NY Mets"       => "NYM",
                  "NY Yankees"    => "NYY",
                  "Oakland"       => "OAK",
                  "Philadelphia"  => "PHI",
                  "Pittsburgh"    => "PIT",
                  "San Diego"     => "SD",
                  "San Francisco" => "SF",
                  "Seattle"       => "SEA",
                  "St. Louis"     => "STL",
                  "Tampa Bay"     => "TB",
                  "Texas"         => "TEX",
                  "Toronto"       => "TOR",
                  "Washington"    => "WSH" );
$FirstLine="YES";

open (SCORES, "curl $URL 2>/dev/null|");

while (<SCORES>){
    $LINE=$_;
    chomp $LINE;
    while ($LINE=~/mlb_s_left\d{1,2}=(.*?)&(.*)/){
        my $GAME_STRING=$1;
        $LINE=$2;
        $GAME_STRING=~s/%20/ /g;
        $GAME_STRING=~s/\^//g;
        if ($FirstLine eq "YES"){
            print "printScoreUpdate_MLB\n";
            $FirstLine="NO";
        }
        if ($GAME_STRING=~/(^.+?)\s+(\d+)\s+(.+?)\s+(\d+)\s+\((.+?)\)/){
            print "GameRecap_" .$TeamMappings{"$1"}. ",$2," . $TeamMappings{"$3"} . ",$4,"; 
            my $INNING_STRING=$5;
            if ($INNING_STRING=~/FINAL/){
                print "F,-\n";
            }
            elsif ($INNING_STRING=~/TOP.*?(\d+)/){
                print "$1,T\n";
            }
            elsif ($INNING_STRING=~/BOT.*?(\d+)/){
                print "$1,B\n";
            }
            else {
                print "-,-\n";
            }
       }
    }
}
