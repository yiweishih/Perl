#!/usr/bin/perl

$total_hits=0;
   $dir="/tmp";
   $filename="201304.log";

=head

@match=qw(  /tem/images/sb1-ov.gif
            /tem/images/sb2-ov.gif
	    /tem/images/sb4-ov.gif );
=cut



@match = qw(academic.php
	    administrative.php
	    news.php\?type=1&id=2
	    user-student.php\?uid=1&mid=161 
	    news.php\?type=3
	    news.php\?type=1&id=7
	    news.php\?type=1&id=6
	    recruitment.php
	    news.php\?type=2
	    news.php\?type=1&id=4
	    /tem/images/sb1-ov.gif
	    introduction.php
	    news.php\?type=1&id=5
	    introduction.php\?mid=136
	    news.php\?type=1&id=1
	    news.php\?type=1&id=3
	    /tem/images/sb2-ov.gif
	    notice.php
	    /tem/images/sb4-ov.gif
	    continuing.php
	    user-student.php\?uid=2&mid=162
	    http://www.nchu.edu.tw/calendar/
	    telephone-directory-amy.php
	    farm.php
	    opinion.php
	    user-student.php\?uid=5&mid=165
	    development.php
	    user-student.php\?uid=4&mid=164
	    user-student.php\?uid=3&mid=163
	    user-student.php\?uid=6&mid=166
	    other.php);

@url = qw(  academic.php
	    administrative.php
	    news.php?type=1&id=2
	    user-student.php?uid=1&mid=161 
	    news.php?type=3
	    news.php?type=1&id=7
	    news.php?type=1&id=6
	    recruitment.php
	    news.php?type=2
	    news.php?type=1&id=4
	    https://nchu-am.nchu.edu.tw/nidp/idff/sso?id=3&sid=0&option=credential&sid=0
	    introduction.php
	    news.php?type=1&id=5
	    introduction.php?mid=136
	    news.php?type=1&id=1
	    news.php?type=1&id=3
	    http://webmail.nchu.edu.tw/ 
	    notice.php
	    http://www.lib.nchu.edu.tw/ 
	    continuing.php
	    user-student.php?uid=2&mid=162
	    http://www.nchu.edu.tw/calendar/
	    telephone-directory-amy.php
	    farm.php
	    opinion.php
	    user-student.php?uid=5&mid=165
	    development.php
	    user-student.php?uid=4&mid=164
	    user-student.php?uid=3&mid=163
	    user-student.php?uid=6&mid=166
	    other.php);

   for($i=0;$i<31;$i++){ 
   open(FILE,"$dir/$filename") or die "Can't open file!\n";
   while(<FILE>)
 
         {
	         chomp;
       	
		 $_=~ /^(.+?)\s.*?\[(.+?)\]\s"(.+?)"\s(.+?)\s(.+?)\s"(.+?)"\s"(.+?)"/;
	
		 if( $6 =~ /$match[$i]/ ||  $3 =~ /$match[$i]/){ $total_hits ++; }
         }
      	
=head
		 if ($total_hits==0)
  	       {
       			 open(FILE,"$dir/$filename") or die "Can't open file!\n";
         
			 while(<FILE>)
 
	     		   {
             			   chomp;
  	 	    	          
    				   $_=~ /^(.+?)\s.*?\[(.+?)\]\s"(.+?)"\s(.+?)\s(.+?)\s"(.+?)"\s"(.+?)"/;
               
				   if( $3 =~ /$match[$i]/ ){ $total_hits ++; }
        	           }        

              }	
=cut
      open (INPUT,">>./total_hits_analysis_04");	
      # print INPUT "$url[$i]\t\t$total_hits\n";
     
     print INPUT "$total_hits\n";
     $total_hits=0;
}

close(FILE);
