#!/usr/bin/perl

use strict;
use Compress::Zlib;
use Device::SerialPort;

#VARIABLE INITIALIZATION
my $ARDUINO_DEV = "/dev/ttyACM0";
my $CONFIG_FILE = "/tmp/arduino.conf";
my $READY_LINE  = "Enter command:";
my $GAMECHANGER_DIRECTORY        = "/home/pi/gamechanger";
my $INPUT_DIRECTORY              = "$GAMECHANGER_DIRECTORY/POSTS";
my $OUTPUT_DIRECTORY             = "$GAMECHANGER_DIRECTORY/scoreboard-complete";
my $First       = my $Second     = my $Third      = my $Balls    = "0";
my $Strikes     = my $Outs       = my $Half       = my $Home     = "0";
my $Visitor     = my $NewFirst   = my $NewSecond  = my $NewThird = "0";
my $NewHalf     = my $NewHome    = my $NewVisitor = my $NewBalls = "0";
my $NewStrikes  = my $NewOuts                                    = "0";
my $NewInning   = my $Inning     = my $ShowScores                = "1";
my $Buffer      = my $Decrypt                                    = "";
my $port;
my $LINE;
my $TeamID      = "";
my $TeamSide    = my $NewTeamSide = "Unknown";
my $TeamLogo    = "";
my $TeamLogoFile = "/home/pi/gamechanger/team_settings/logo.txt";
my $TeamIDFile   = "/home/pi/gamechanger/team_settings/team_id.txt";
my $CommandFile  = "/home/pi/gamechanger/command.txt";

#Clone serial port settings from the dev system (where this originally worked)
system ("stty -F $ARDUINO_DEV 9600 -icanon -isig -iexten -echo -icrnl -ixon -ixany -imaxbel -brkint -opost -onlcr cs8 -parenb ");

#Configure serial port for communications
my $port = Device::SerialPort->new("$ARDUINO_DEV");
serial_setup();

#If a team logo bitmap exists, load it into the scoreboard
if (-e $TeamLogoFile){
    $TeamLogo=parseTeamLogo();
    print ARDUINO "setMyLogo $TeamLogo\n\n\n\n";
    print "setMyLogo $TeamLogo\n";
}

#If a team ID file exists, load it into the program (works in conjunction 
#  with team logo above; when team ID is seen, the loaded logo is set to 
#  whichever side your team is playing-i.e., HOME or AWAY)
if (-e $TeamIDFile){
    $TeamID=parseTeamID();
}

#
until ($LINE=~/$READY_LINE/i){
    (my $count,$LINE)=$port->read(1024); # will read _up to_ 255 char
    print $LINE;
}

while (1) {

    if ($ShowScores == 1){
        open(SCORES, "/home/pi/BoxScores/generate_scores.sh|sed \'s/_/ /g\' |");
        
        while (<SCORES>){

            print ARDUINO $_;
            print; 
            sleep 2;
        }

        close (SCORES);
        $ShowScores=0;
    }
        
    if (-e $CommandFile){

        open (COMMANDS, "<", $CommandFile);

        while (<COMMANDS>){

            my $CMD_LINE=$_;

            if ($CMD_LINE=~/ShowScoresNow/){
                $ShowScores=1;
            }

            else {
                print ARDUINO $CMD_LINE;
                print $CMD_LINE;

                until ($LINE=~/$READY_LINE/i){
                    (my $count,$LINE)=$port->read(1024); # will read _up to_ 255 char
                    print $LINE;
                }
            }
        }
        close (COMMANDS);
        unlink ($CommandFile);

    }

    opendir (DIR, $INPUT_DIRECTORY) or die $!; 
      
    my @files = sort readdir(DIR);
      
    while ( my $file = shift @files ) {
        
        if ( $file =~/^post/){

            sleep 0.1;

            undef ($Buffer);

            open (INPUT, "<$INPUT_DIRECTORY/$file") or die ("Can't open $file");
      
            binmode(INPUT);
            
            while (<INPUT>) {
                
                $LINE=$_;
                if ($LINE=~/(\x78\x01.*)\x0d$/){
                    $Buffer=$1;
                    $Decrypt=uncompress($Buffer);
                    undef ($Buffer);
                }
                elsif ($LINE=~/(\x78\x01.*)$/){
                    $Buffer=$1;
                    if (substr($Buffer, length($Buffer),1) ne "\x0a"){
                        $Buffer.="\n";
                    }
                }
                elsif (defined($Buffer)){
                    if ($LINE=~/^(.*)\x0d\x0a$/){
                        $Buffer.=$1;
                        $Decrypt=uncompress($Buffer);
                        undef($Buffer);
                    }
                    else {
                        $Buffer.=$LINE;
                    }
                }
            }
            
            close (INPUT);
            
            rename "$INPUT_DIRECTORY/$file", "$OUTPUT_DIRECTORY/$file";
            
            if ($Decrypt ne ""){
                process_Buffer($Decrypt);
                $Decrypt="";
            }

            sleep 1;
        }
    }
}

sub process_Buffer {
    
    my $LINE=$_[0];
   
    if ($LINE=~/home_id.\s*:\s*.$TeamID/){
        $NewTeamSide="HOME";
    }
    if ($LINE=~/away_id.\s*:\s*.$TeamID"/){
        $NewTeamSide="AWAY";
    } 
    if ($LINE=~/.*"count":\s*{(.*?)}/){
        my $Count=$1;
        if ($Count=~/"outs"\s*:\s*(\d)/){ 
            $NewOuts=$1;
        }
        if ($Count=~/"strikes"\s*:\s*(\d)/){
            $NewStrikes=$1;
        }
        if ($Count=~/"balls"\s*:\s*(\d)/){
            $NewBalls=$1;
        }
    }
    
    if ($LINE=~/.*"score"\s*:\s*{(.*?)}/){
        my $Score=$1;
        if ($Score=~/"home"\s*:\s*(\d+)/){
            $NewHome = $1;
        }
        if ($Score=~/"away"\s*:\s*(\d+)/){
            $NewVisitor = $1;
        }
    }
    
    #if ($LINE=~/.*"situation"\s*:\s*{(.*?)}/){
    #    my $Situation=$1;
    if ($LINE=~/.*"inning"\s*:\s*(\d+)/){
        $NewInning=$1;
    }
    if ($LINE=~/.*"half"\s*:\s*([01])/){
        $NewHalf=$1;
    }
    #}
    
    if ($LINE=~/"bases"\s*:\s*\[(.+?)\],/){
        my $Bases=$1;
        
        if ($Bases=~/"base"\s*:\s*1/){
            $NewFirst="1";
        }
        else {
            $NewFirst="0";
        }
        if ($Bases=~/"base"\s*:\s*2/){
            $NewSecond="1";
        }
        else {
            $NewSecond="0";
        }
        if ($Bases=~/"base"\s*:\s*3/){
            $NewThird="1";
        }
        else {
            $NewThird="0";
        }
    }
     
    if(state_changed()){
        
        print ARDUINO "SGS $NewVisitor,$NewHome,$NewHalf,$NewInning,$NewFirst,$NewSecond,$NewThird,$NewBalls,$NewStrikes,$NewOuts\n";
        print "SGS $NewVisitor,$NewHome,$NewHalf,$NewInning,$NewFirst,$NewSecond,$NewThird,$NewBalls,$NewStrikes,$NewOuts\n";
        
        $First=$NewFirst;
        $Second=$NewSecond;
        $Third=$NewThird;
        $Half=$NewHalf;
        $Inning=$NewInning;
        $Home=$NewHome;
        $Visitor=$NewVisitor;
        $Balls=$NewBalls;
        $Strikes=$NewStrikes;
        $Outs=$NewOuts;
        
        until ($LINE=~/$READY_LINE/i){
            (my $count,$LINE)=$port->read(1024); # will read _up to_ 255 char
            print $LINE;
        }
        
    }

    if(is_side_changed()){
        print ARDUINO "setMySide $TeamSide\n";
        print "setMySide $TeamSide\n";

        until ($LINE=~/$READY_LINE/i){
            (my $count,$LINE)=$port->read(1024); # will read _up to_ 255 char
            print $LINE;
        }
    }

    
}

sub serial_setup(){
    
    my $LINE="";
    
    
    $port->databits(8);
    $port->baudrate(9600); # <-- match to arduino settings
    $port->parity("none");
    $port->stopbits(1);
    $port->dtr_active(0);
    $port->read_char_time(0);     # don't wait for each character
    $port->read_const_time(1000); # 1 second per unfulfilled "read" call
    $port->save($CONFIG_FILE);
    
    $port = tie( *ARDUINO, 'Device::SerialPort', $CONFIG_FILE) ||
        die "Cant open file handle to serial port";
    
    until ($LINE=~/$READY_LINE/i){
        (my $count,$LINE)=$port->read(255); # will read _up to_ 255 char
        print $LINE;
    }

}

sub is_side_changed(){

    #print "$TeamSide\t$NewTeamSide\n";

    if ($TeamSide ne $NewTeamSide){
    
        $TeamSide=$NewTeamSide;
        return 1;
    }
    return 0;
}
 
sub state_changed(){
    
    if ($Half ne $NewHalf){
        $ShowScores=1;
        return 1;
    }
    elsif ($Balls ne $NewBalls){
        return 1;
    }
    elsif ($Strikes ne $NewStrikes){
        return 1; 
    }
    elsif ($Outs ne $NewOuts){
        return 1; 
    }
    elsif ($First ne $NewFirst){
        return 1; 
    }
    elsif ($Second ne $NewSecond){
        return 1;
    }
    elsif ($Third ne $NewThird){
        return 1;
    }
    elsif ($Home ne $NewHome){
        return 1;
    }
    elsif ($Visitor ne $NewVisitor){
        return 1;
    }
    elsif ($Inning ne $NewInning){
        return 1;
    }
    else {
        return 0;
    }
    
}

sub parseTeamLogo(){

    open (LOGO, "<", $TeamLogoFile);

    my $Value=1;
    my @INT= (0,0,0,0,0,0);
    my $COMMAND="";

    for (my $i=0; $i<=7; $i++){
        my $LINE=<LOGO>;
        $LINE=~/^(.)(.)(.)(.)(.)(.)/;

        #print "$1 $2 $3 $4 $5 $6\n";

        if (($1 ne " ") and ($1 ne "")){
            $INT[0]+=$Value;
        }
        if (($2 ne " ") and ($2 ne "")){
            $INT[1]+=$Value;
        }
        if (($3 ne " ") and ($3 ne "")){
            $INT[2]+=$Value;
        }
        if (($4 ne " ") and ($4 ne "")){
            $INT[3]+=$Value;
        }
        if (($5 ne " ") and ($5 ne "")){
            $INT[4]+=$Value;
        }
        if (($6 ne " ") and ($6 ne "")){
            $INT[5]+=$Value;
        }

        $Value*=2;
    }

    for (my $j=0; $j<=4; $j++){
        $COMMAND.=$INT[$j] . ",";
    }
    
    $COMMAND.=$INT[5];
    #print $COMMAND . "\n";    
    close (LOGO);
    return $COMMAND;
}

sub parseTeamID(){
    
    open (TEAM, "<", $TeamIDFile);
    while (<TEAM>){
        if (/^TeamID=(\S*)/){
            close (TEAM);
            return $1;
        }
    }
    close (TEAM);
}

