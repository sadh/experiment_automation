#!/usr/bin/perl -w

use Switch;
use Getopt::Long;
use strict; 
use warnings;


my $log_file;
my $exp_id;
my $run_id;

#Fetch the command line arguments
GetOptions ('file=s' => \$log_file,'exp_id=s'=>\$exp_id,'run_id=s'=>\$run_id) or die('ERROR');

open (DATA, "<$log_file") or die ("Unable to open log file");
open(EXTRACT,">".$exp_id."_"."$run_id");
my $search_string = "Experiment ID: ".$exp_id."-+Run ID: ".$run_id;
my $escape_string = "Experiment ID: \\d+-+Run ID: \\d+";
my @lines = <DATA>;
close DATA or die('Error closing log file.');
my $index = 0;
++$index until $lines[$index] =~ /$search_string/ or $index > $#lines;
$index++;

for(my $i = $index+1;$i<$#lines;$i++){
    if( $lines[$i] =~ /$escape_string/) {
	last;  
    }
    print EXTRACT $lines[$i]."\n";
}

close EXTRACT or die('Error closing output file');
