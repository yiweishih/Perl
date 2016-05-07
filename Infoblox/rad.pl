#!/usr/bin/perl

my $filename="logfile";

open (LOGFILE, $filename) or die "can't open logfile";

my $job = "";
my $mac = "";
my $i=0;

while(<LOGFILE>)
{
}

for(;;)
{
    while(<LOGFILE>)
    {
        if($_ =~ /Acct-Status-Type = Start/)
        {
            $job = "registermac";
        }
        if($_ =~ /Acct-Status-Type = Stop/)
        {
            $job = "removemac";
        }
        if($_ =~ /Calling-Station-Id =/)
        {
            $mac = substr $_, 23, -2;
        }
        if($_ =~ /Timestamp/)
        {
            $job = "";
            $mac = "";
        }
        if($job && $mac)
        {
            my $mac2 = substr($mac,0,2) . ":" . substr($mac,2,2) . ":" . substr($mac,4,2) . ":" . substr($mac,6,2) . ":" . substr($mac,8,2) . ":" . substr($mac,10,2);
            print $job . " " . $mac . " " . $mac2 . "\n";
            my $cmd = "perl /root/infobloxCmd6.pl 10.10.10.20 admin infoblox " . $job . " " . $mac2 . " itw_user";
            print $cmd . "\n";
            system($cmd);
            $job = "";
            $mac = "";
        }
    }
    sleep 1;
    seek(LOGFILE, 0, 1);
}
