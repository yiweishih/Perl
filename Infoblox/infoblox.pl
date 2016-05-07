#!/usr/bin/perl

$file = "/tmp/infoblox/position";

	if (-e $file){

		open ABC,"/tmp/infoblox/position"; #or die "Can't open file!\n";

		$position = <ABC>;
	
		     }

	else {$position = 0};

open LOG,"/tmp/infoblox/log";

seek (LOG,$position,0);

while (<LOG>){
	 
open INPUT,">>/tmp/infoblox/analysis";

print INPUT if (/Calling/);
   
             }

$position = tell(LOG);
        
open  POSITION,">/tmp/infoblox/position";
       
print POSITION $position;
    
close (POSITION);
	
close (LOG);	        

open Analysis,"/tmp/infoblox/analysis";

while(<Analysis>){
         
    	 $_ =~/"(.+?)"/;
         $1=~/(\w{2})(\w{2})(\w{2})(\w{2})(\w{2})(\w{2})/;
         @mac=($1,$2,$3,$4,$5,$6);
	 $mac2= join(":",@mac);
 
	 print $mac2,"\n";  

   		      # print $1,"\n";
		      #	$_=~/(.+*)\s=\s"(.+*)"/;
		      #	print $1;
                }	
     
	 close (Analysis);
       



