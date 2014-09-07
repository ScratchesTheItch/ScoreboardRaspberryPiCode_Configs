#!/usr/bin/perl

$URL="http://sports.espn.go.com/nfl/bottomline/scores";

%TeamMappings = ( "Arizona"       => "ARI",
                  "Atlanta"       => "ATL",
                  "Baltimore"     => "BAL",
                  "Buffalo"       => "BUF",
                  "Carolina"      => "CAR",
                  "Chicago"       => "CHI",
                  "Cincinnati"    => "CIN",
                  "Cleveland"     => "CLE",
                  "Dallas"        => "DAL",
                  "Denver"        => "DEN",
                  "Detroit"       => "DET",
                  "Green Bay"     => "GB",
                  "Houston"       => "HOU",
                  "Indianapolis"  => "IND",
                  "Jacksonville"  => "JAX",
                  "Kansas City"   => "KC",
                  "Miami"         => "MIA",
                  "Minnesota"     => "MIN",
                  "NY Giants"     => "NYG",
                  "NY Jets"       => "NYJ",
                  "New England"   => "NE",
                  "New Orleans"   => "NO",
                  "Oakland"       => "OAK",
                  "Philadelphia"  => "PHI",
                  "Pittsburgh"    => "PIT",
                  "San Diego"     => "SD",
                  "San Francisco" => "SF",
                  "Seattle"       => "SEA",
                  "St. Louis"     => "STL",
                  "Tampa Bay"     => "TB",
                  "Tennessee"     => "TEN",
                  "Washington"    => "WSH");

$FirstLine="YES";

open (SCORES, "curl $URL 2>/dev/null|");

while (<SCORES>){
    $LINE=$_;
    chomp $LINE;
    while ($LINE=~/nfl_s_left\d{1,2}=(.*?)&(.*)/){
         my $GAME_STRING=$1;
         $LINE=$2;
         $GAME_STRING=~s/%20/ /g;
         $GAME_STRING=~s/\^//g;
         if ($FirstLine eq "YES"){
             print "printScoreUpdate_NFL\n";
             $FirstLine="NO";
         }
         if ($GAME_STRING=~/(^.+?)\s+(\d+)\s+(.+?)\s+(\d+)\s+\((.+?)\)/){
             print "GameRecap_" .$TeamMappings{"$1"} . ",$2," . $TeamMappings{"$3"} . ",$4,"; 
             my $INNING_STRING=$5;
             if ($INNING_STRING=~/FINAL/){
                 print "F,-\n";
             }
             elsif ($INNING_STRING=~/HALF/){
                 print "H,-\n";
             }
             elsif ($INNING_STRING=~/\s(\d+)/){
                 print "$1,-\n";
             }
             else {
                 print "-,-\n";
             }
        }
    }
}
