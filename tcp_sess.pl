#!/usr/bin/perl -w
######################################################### Simple TCP traffic generator#####################################################################
#---------Author  saib10@bth.se 2014.

use LWP::UserAgent;
use Time::HiRes qw(usleep gettimeofday tv_interval );
use Socket;
use IO::Socket;
use Sys::Hostname;
use Switch;
use Getopt::Long;
use Log::Log4perl qw(:easy);

my $content = "";
my $shaping_params = "";
my $settings_params = "";
my $tcp_congestion_control = "";
my $logger;
my $default_server_rmem = "";
my $default_server_wmem = "";
my $default_client_rmem = "";
my $default_client_wmem = "";
my $default_server_congestion_control = "";
my $default_client_congestion_control = "";
my $pid_server = "";
my $pid_client = "";
my $probe;
my $expid;
my $runid;

my $device_string=`uname -a`;
if ($device_string =~ m/jun-test-client-xps/i) {
	printf "Supported platform.\n";
} else {
	printf "No support for $device_string. \n";
	printf "FAILIURE.\n";
	exit(0);
}

my $startTime=Time::HiRes::time;

#Fetch the command line arguments#
GetOptions ('url=s' => \$content, 'shaping=s' => \$shaping_params, 'server-settings=s'=>\$server_settings, 'client-settings=s'=>\$client_settings, 'probe'=>\$probe) or die('ERROR');

if($ENV{'EXPID'} and $ENV{'RUNID'}){
    $expid = $ENV{'EXPID'};
    $runid = $ENV{'RUNID'};
    printf "Expid= " . $ENV{'EXPID'} . " Runid= " .$ENV{'RUNID'} . "\n";
}else{
    $expid = int(rand(1000));
    $runid = int(rand(10));
}

Log::Log4perl::init('/etc/log4perl.conf');
$logger = Log::Log4perl->get_logger('tcp_sess');
$logger->info('Experiment started');
$logger->info('Experiment ID: '.$expid.' Run ID: '.$runid);


if($shaping_params){
%shaping_inputs = $shaping_params =~ m[(\S+)\s*:\s*(\S+)]g;
applyKaunetShaping(\%shaping_inputs);
}


if($server_settings){
%settings_input = $server_settings =~ m[(\S+)\s*:\s*(\S+)]g;
getServerSettings();
changeServerSettings(\%settings_input);
}

   
if($client_settings){
%client_settings_input = $client_settings =~ m[(\S+)\s*:\s*(\S+)]g;
getClientSettings();
changeClientSettings(\%client_settings_input);
}

if($probe){
loadTCPProbe();
}

#downloadFile();
startTCPSession();

resetShaper();
restoreServerSettings();
restoreClientSettings();

if($probe){
backupTCPProbe();
}

print "SUCCESS\n";
exit(0);

#Server default TCP settings#
sub getServerSettings{
     my $device_string=`ssh server "uname -a"`;
    if ($device_string =~ m/jun-server/i) {
	printf "Supported platform.\n";
    } else {
	printf "No support for $device_string. \n";
	printf "FAILIURE.\n";
	exit(0);
    }
    $default_server_rmem = `ssh server "sysctl -n net.ipv4.tcp_rmem"`;
    $default_server_wmem = `ssh server "sysctl -n net.ipv4.tcp_wmem"`;
    $default_server_congestion_control = `ssh server "sysctl -n net.ipv4.tcp_congestion_control"`;
    $logger->info("Default server TCP configuration\n"."default server rmem=".$default_server_rmem."\t"."default server wmem=".$default_server_wmem."\t"."default server congestion=".$default_server_congestion_control);
    print "Default server TCP configuration\n"."default server rmem=".$default_server_rmem."\n"."default server wmem=".$default_server_wmem."\n"."default server congestion=".$default_server_congestion_control."\n";
}

#Apply new TCP settings#
sub changeServerSettings{
   
    my %settings_params = %{shift()};
    my $server_wmem = $settings_params{'wmem'};
    my $server_rmem = $settings_params{'rmem'};
    my $server_congestion = $settings_params{'congestion'};
    $server_wmem =~ s/,/\t/g;
    $server_rmem =~ s/,/\t/g;
    my $response =  `ssh server "sysctl -w net.ipv4.tcp_rmem=\'$server_rmem\'"`;
    $response = $response."\n";
    $response .= `ssh server "sysctl -w net.ipv4.tcp_wmem=\'$server_wmem\'"`; 
    $response = $response."\n";
    $response .= `ssh server "sysctl -w net.ipv4.tcp_congestion_control=\'$server_congestion\'"`; 
    $logger->info("Appying new server settings: ".$response);
    print "Appying new server settings: ".$response."\n";
}

#Restore default server TCP settings#
sub restoreServerSettings{
    my $response =  `ssh server "sysctl -w net.ipv4.tcp_rmem=\'$default_server_rmem\'"`;
    $response = $response."\n";
    $response .=  `ssh server "sysctl -w net.ipv4.tcp_wmem=\'$default_server_wmem\'"`;
    $response = $response."\n";
    $response .=  `ssh server "sysctl -w net.ipv4.tcp_congestion_control=\'$default_server_congestion_control\'"`;
    $logger->info("Restoring old server settings: ".$response);
    print "Restoring old server settings: ".$response."\n";
}

#Client default TCP settings#
sub getClientSettings{
 
    $default_client_rmem =`sudo sysctl -n net.ipv4.tcp_rmem`;
    $default_client_wmem =`sudo sysctl -n net.ipv4.tcp_wmem`;
    $default_client_congestion_control =`sudo sysctl -n net.ipv4.tcp_congestion_control`;
    $logger->info("Default Client TCP configuration\t"."default Client rmem=".$default_client_rmem."\t"."default Client wmem=".$default_client_wmem."\t"."default Client congestion=".$default_client_congestion_control);
    print "Default Client TCP configuration\n"."default Client rmem=".$default_client_rmem."\n"."default Client wmem=".$default_client_wmem."\n"."default Client congestion=".$default_client_congestion_control."\n";
   }
 
#Apply new TCP settings #
sub changeClientSettings{
    my %client_settings_params = %{shift()};
    my $client_wmem = $client_settings_params{'wmem'};
    my $client_rmem = $client_settings_params{'rmem'};
    my $client_congestion = $client_settings_params{'congestion'};
    $client_wmem =~ s/,/\t/g;
    $client_rmem =~ s/,/\t/g;
    my $response =  `sudo sysctl -w net.ipv4.tcp_rmem=\'$client_rmem\'`;
    $response = $response."\n";
    $response .= `sudo sysctl -w net.ipv4.tcp_wmem=\'$client_wmem\'`; 
    $response = $response."\n";
    $response .= `sudo sysctl -w net.ipv4.tcp_congestion_control=\'$client_congestion\'`;
    $logger->info("Appying new client settings: ".$response);
    print "Appying new client settings: "."\n".$response."\n";
}

#Restore default server TCP settings#
sub restoreClientSettings{
    my $response =  `sudo sysctl -w net.ipv4.tcp_rmem=\'$default_client_rmem\'`;
    $response = $response."\n";
    $response .=  `sudo sysctl -w net.ipv4.tcp_wmem=\'$default_client_wmem\'`;
    $response = $response."\n";
    $response .=  `sudo sysctl -w net.ipv4.tcp_congestion_control=\'$default_client_congestion_control\'`;
    $logger->info("Restoring old client settings: ".$response);
    print "Restoring old client settings: ".$response."\n";
}


#Apply kaunet shaping based on mathematical model#
sub applyKaunetShaping{
    my $device_string=`ssh shaper "uname -a"`;
    if ($device_string =~ m/jun-kau-frbsd/i) {
	printf "Supported platform.\n";
    } else {
	printf "No support for $device_string. \n";
	printf "FAILIURE.\n";
	exit(0);
    }
    my %kaunet_params = %{shift()};
    my $seed = $kaunet_params{'seed'};
    print (Time::HiRes::time);
    print ": Generating rendom time varying delay secuence using $seed as seed distribution $kaunet_params{'dist'}  avg. ontime $kaunet_params{'on'} avg. offtime $kaunet_params{'off'} duration $kaunet_params{'duration'} mode  $kaunet_params{'mode'}\n";
    $logger->info( ": Generating rendom time varying delay secuence using $seed as seed distribution $kaunet_params{'dist'}  avg. ontime $kaunet_params{'on'} avg. offtime $kaunet_params{'off'} duration $kaunet_params{'duration'} mode  $kaunet_params{'mode'}");
    my $duration = $kaunet_params{'duration'}*1000;
    my $mode =  $kaunet_params{'mode'};
    my $response = '';
    if( $mode =~ 'time'){
	$response = `ssh shaper "~/experiment_automation/shaper/ON-OFF-gen -d $kaunet_params{'dist'} -s $seed -o $kaunet_params{'on'} -f $kaunet_params{'off'} -t $kaunet_params{'duration'} -m $kaunet_params{'mode'}"`;
    print $response."\n";
    }else{
	$response = `ssh shaper "~/experiment_automation/shaper/ON-OFF-gen -d $kaunet_params{'dist'} -s $seed -o $kaunet_params{'on'} -f $kaunet_params{'off'} -t $kaunet_params{'duration'} -a $kaunet_params{'iat'} -m $kaunet_params{'mode'}"`;
    }
  
    my $shaping_pattern_file = `ssh shaper "ls *.txt"`;
    if($shaping_pattern_file =~ m/.*\.txt/i){
	my ($patt_file,$type);
	($patt_file,$type) = split(/\.txt/,$shaping_pattern_file);
	if($kaunet_params{'dist'} =~ m/GEOMETRIC/i){
	my $sec_file = `ssh shaper "ls *.csv"`;
	my $on_off_sec = `ssh shaper "cat $sec_file"`;
	$logger->info("Generated on off secuences: ".$on_off_sec);
	$response = `ssh shaper "rm -rf $sec_file"`;
	}
	
	$patt_file = $patt_file.".dcp";
	$response = `ssh shaper "patt_gen -del -pos $patt_file $mode  $duration -f $shaping_pattern_file"`;
	my $delete_pattern_file = `ssh shaper "rm -rf $shaping_pattern_file"`;
	$response = `ssh shaper "sudo ipfw -f pipe flush && sudo ipfw -f flush"`;
	$response = `ssh shaper "sudo ipfw 1001 add pipe 1 ip from any to any via xl1 out"`;
	$response = `ssh shaper "sudo ipfw pipe 1 config delay 0ms bw 100Mbit/s pattern $patt_file"`;
	print $response."\n";
	$logger->info('Shaping applied properly');

    }else{
	$logger->error('Kaunet Shaping failed.');
	print "ERROR\n failed to generate shaping secuence.\n";
	exit(1);
    }
}

#Clear shaping rules and remove pattern file#
sub resetShaper{
    $response = `ssh shaper "sudo ipfw -f pipe flush && sudo ipfw -f flush"`;
    $logger->info('All shaping rule flushed.');
    my $patt_file = `ssh shaper "ls *.dcp"`;
    if($patt_file){
    $response = `ssh shaper "rm $patt_file"`;
    }
}

#Enable  TCP probe on both side#
sub loadTCPProbe{
    my $response = `modprobe -r tcp_probe`;
    $response = `modprobe tcp_probe port=80`;
    $response = `cat /proc/net/tcpprobe > /tmp/tcpprobe.out &`;
    $pid_client = `$!`;
    $response = `ssh server "modprobe -r tcp_probe"`;
    $response = `ssh server "modprobe tcp_probe port=80"`;
    $response = `ssh server "cat /proc/net/tcpprobe > /tmp/tcpprobe.out &"`;
    $pid_server = `ssh server $!`;
    $logger->info('TCP probe enabled.');
   
}

sub backupTCPProbe{
    my $response = `mkdir -p tcptrace`;
    $response = `kill $pid_client`;
    $response = `mv /tmp/tcpprobe.out tcptrace/tcpprobe_client.txt`; 
    $response = `ssh server "kill $pid_server"`;
    $response = `scp server:/tmp/tcpprobe.out tcptrace/tcpprobe_server.txt`;
    $logger->info('Saving TCP probe log.');
}
#Download sample file#

sub downloadFile{
    my $ua=LWP::UserAgent->new();
    $ua->timeout(10);
    $file="$content";
    $tStarts=Time::HiRes::time;  #Grab a timestamp, before the download starts
    $logger->info('Downloading sample file from server: '.$file);
    $contents = $ua->get($file);				#Retreive the file.
    $tEnd=Time::HiRes::time;			#Grab a timestamp, after the download ends

    { 
	use bytes;
	$B=length($contents->content); 
    }


    if(($tEnd-$tStarts)>0 && $B>285){		
        #Make sure that we got something ($B>0), and that it actually took some time (tE-tS)>0
	print "$file\t$B [byte] \t" . ($tEnd-$tStarts) . " [s] \t"  . (8*($B/($tEnd-$tStarts))) ." [bps]\n";	
        # Log the url, rep, bytes received, download time and estimated bitrate. 
    } else {
	$logger->error('Download failed. Check server running or file available.');
	print "$file\t$B [byte] \t" . ($tEnd-$tStarts) . " [s] \tFAIL \n";  
        #Log the url, rep bytes and download time, not bitrate as something was wrong here.
	resetShaper();
	restoreServerSettings();
	restoreClientSettings();
	exit 1;
    }

    my $endTime=Time::HiRes::time;
    $logger->info("ExpRuntime: " . ($endTime - $startTime) . " [s] Content: $file\t Size: $B [byte] \t DLtime: " . ($tEnd - $tStarts) . " [s] \t bitrate: "  . (8*($B/($tEnd - $tStarts))) ." [bps]");
    print "ExpRuntime: " . ($endTime - $startTime) . " [s] Content: $file\t Size: $B [byte] \t DLtime: " . ($tEnd - $tStarts) . " [s] \t bitrate: "  . (8*($B/($tEnd - $tStarts))) ." [bps] \n";	# Log the url, rep, bytes 

}


sub startTCPSession{
    #my $daemon = `ps -xj | grep tcpsnoop`;
    my $response;
    my $set_exp_marker = "Experiment ID: ".$expid."-----------------------------------------------"."Run ID: ".$runid;
    $response = `echo $set_exp_marker >> ./tcpcwnd/tcpsnoop_receiver.log`;
    $response = `ssh TCP 'echo $set_exp_marker >> ./tcpcwnd/tcpshoot_sender.log'`;
    $response = `./tcpcwnd/tcpsnoop -d -f ./tcpcwnd/tcpsnoop_receiver.log -p 12345 -b 4096`;
    $tStarts=Time::HiRes::time;  #Grab a timestamp, before the download starts
    my $sender_response = `ssh TCP './tcpcwnd/tcpshoot -b 4096 -c 1024000000 -d ~/$content -f ./tcpcwnd/tcpshoot_sender.log -p 12345 -s 192.168.186.148'`;
    $tEnd=Time::HiRes::time;
    print "Download time: ".($tEnd - $tStarts)."\nSUCCESS";
    $logger->info("Download time: ".($tEnd - $tStarts));

}
