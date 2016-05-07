#!/usr/bin/perl
#!perl -w
use strict;
use Net::SMTP;
use Net::Telnet();
my $now_date = &now_date();
my $next_date = &next_date();
my $newpw = '';

genpw();

my $ip="wireless controller IP";
my $username="帳號";
my $password="密碼";
my $telnet = new Net::Telnet(Timeout => 10 , Prompt => '/[\$)#>]/');
$telnet->open($ip);
$telnet->login($username,$password);
my @line1=$telnet->cmd("config wireless network 2 wpa key value $newpw");
my @line2=$telnet->cmd("config wireless ap_profile 2 apply");
sleep(1);
my @line3=$telnet->cmd("y");
sleep(3);
my @line4=$telnet->cmd("save");
sleep(15);
print "@line1\n";
print "@line3\n"; 
mail();
sleep(2);
mailicd();
sub genpw
{
	my $newpw_len = 8;

	my @word = qw/! @ & 1 2 3 4 5 6 7 8 9 a b c d e f g h i j k l m n o p q r s t u v w x y z/ ;
    	for (my $i = 0; $i < $newpw_len; $i++) 
	{
     		if($i ==0 )
		{
      			$newpw .= $word[rand(3)];
     		}
		else
		{
      			$newpw .= $word[rand(38)];
        	}
 	}

	print $newpw;
}


sub next_date
{

	my @nDAY = localtime ( ( time +86400 * 6 ) );
	my $nD = $nDAY[3];
	my $nM = $nDAY[4] + 1;
	my $nY = $nDAY[5] + 1900;

	if ( $nM < 10 ){$nM = "0$nM";}
	if ( $nD < 10 ){$nD = "0$nD";}

	return ( "$nY/$nM/$nD" ) ;
}


sub now_date
{
	my @DAY = localtime (time);
	my $D = $DAY[3];
	my $M = $DAY[4] + 1;
	my $Y = $DAY[5] + 1900;

	if ( $M < 10 ){$M = "0$M";}
	if ( $D < 10 ){$D = "0$D";}

	return ("$Y/$M/$D") ;

}

sub mail
{
	my $mailhost = "smtp網址";
	my $mailfrom = '寄信mail位指';
	my $mailto1 = '目的mail位址';
	my $mailto2 = '目的mail位址';
	my $mailto3 = '目的mail位址';
	my $mailto4 = '目的mail位址';
	my $subject = "The Guest168 password of this week ($now_date - $next_date)";
	my $text = "Daer all,\n    The Guest168 password of this week ($now_date - $next_date) is $newpw\n\nPlease do not reply this email directly.\nIf you have any question, please contact $mailto1\nThanks a lot.\n";

	#my $smtp = Net::SMTP->new($mailhost, Debug => 1);
	my $smtp = Net::SMTP->new($mailhost);
	$smtp->mail($mailfrom);
	$smtp->to($mailto1,$mailto2,$mailto3,$mailto4);
	$smtp->data();
	$smtp->datasend("To: $mailto1,$mailto2,$mailto3,$mailto4\n");
	$smtp->datasend("From: $mailfrom\n");
	$smtp->datasend("Subject: $subject\n");
	$smtp->datasend("\n");
	$smtp->datasend("$text\n\n");
	$smtp->dataend();
	$smtp->quit;
}

sub mailicd
{
	my $mailhost = "smtp網址";
        my $mailfrom = '寄信mail位指';
        my $mailto1 = '目的mail位址';
        my $subject = "The Wireless Controller Logs";
        my $text = "Daer all,\n    The Wireless Controller Logs as below.\n\n----------------------------System Information----------------------------\n@line1\n@line3\n";

        #my $smtp = Net::SMTP->new($mailhost, Debug => 1);
        my $smtp = Net::SMTP->new($mailhost);
        $smtp->mail($mailfrom);
        $smtp->to($mailto1);
        $smtp->data();
        $smtp->datasend("To: $mailto1\n");
        $smtp->datasend("From: $mailfrom\n");
        $smtp->datasend("Subject: $subject\n");
        $smtp->datasend("\n");
        $smtp->datasend("$text\n\n");
        $smtp->dataend();
        $smtp->quit;
}
