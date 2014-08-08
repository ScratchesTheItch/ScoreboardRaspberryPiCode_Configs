#!/usr/bin/perl

use strict;
use Compress::Zlib;

#VARIABLE INITIALIZATION
my $GAMECHANGER_DIRECTORY        = "/home/pi/gamechanger";
my $INPUT_DIRECTORY              = "$GAMECHANGER_DIRECTORY/output";
my $OUTPUT_DIRECTORY             = "$GAMECHANGER_DIRECTORY/done";
my $Buffer      = my $Decrypt                                    = "";
my $port;
my $LINE;



while (1) {

    opendir (DIR, $INPUT_DIRECTORY) or die $!; 
      
    my @files = sort readdir(DIR);
      
    while ( my $file = shift @files ) {
        
        if ( -f "$INPUT_DIRECTORY/$file"){

            sleep 1;
 
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

                open (OUTPUT, ">$OUTPUT_DIRECTORY/decrypt-$file");
                print OUTPUT $Decrypt;
                close (OUTPUT);

                $Decrypt="";
            }
        }
    }
}
