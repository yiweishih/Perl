use Infoblox;
use Class::Date qw(date);
use POSIX;
use Time::HiRes;


my $IB_MAC_FILTER_GUEST="Authorized_Guest";
my $IB_MAC_FILTER_USER="Authorized_User";

#my $tmp_datetime = prettydate();
#my $unixtime = date($tmp_datetime)->epoch;

#	my $Global_Expire_Time_User = (1 * 86400) + $unixtime;
#	my $user_expire_timestamp_user = localtime($Global_Expire_Time_User);
#	print "$Global_Expire_Time_User\n";
#	print "$user_expire_timestamp_user\n";
#	exit(0);

if ($#ARGV < 4) {
 print "$#ARGV\n";
 print "usage: infobloxCmd infobloxip username password function parameter[]\n";
 exit;
}

#my $infobloxip = "10.1.1.246";
#my $username = "admin";
#my $password = "infoblox";
my $infobloxip = $ARGV[0];
my $username = $ARGV[1];
my $password = $ARGV[2];
my $function = $ARGV[3];
my $clientip = $ARGV[4];
my $macaddress = $ARGV[4];
my $assignUsername = $ARGV[5];
my $filterName = $ARGV[6];
my $expiration_time = $ARGV[7];



if ($function eq "search") {
   my $session = &openSession($infobloxip, $username, $password);
   my $clientmac = &get_dhcp_lease($session, $clientip);

   print "status=true,mac=$clientmac\n";
}

if ($function eq "filtersearch") {
   my $session = &openSession($infobloxip, $username, $password);
   my $mac = &get_dhcp_lease($session, $clientip);

   if (&search_dhcp_mac_filter($session, $mac, $filterName)) {
      print "fileter $filter found ip:$ip already registered";
   }
}

if ($function eq "register") {
   my $session = &openSession($infobloxip, $username, $password);
   my $mac = &get_dhcp_lease($session, $clientip);

   if (&search_dhcp_mac_filter($session, $mac, $filterName) == 0) {

      &add_dhcp_mac_filter($session, $mac, $filterName, $assignUsername, $expiration_time);
   }else {
      print "status=fasle, $mac already register to $filterName filter!";
   }
}

if ($function eq "update") {
   my $session = &openSession($infobloxip, $username, $password);
   
   if (&search_dhcp_mac_filter($session, $mac, $filterName) == 0) {
      &remove_macaddress($session, $macaddress, $filterName);
      &add_dhcp_mac_filter($session, $mac, $filterName, $assignUsername, $expiration_time);
   }else {
      print "status=fasle, $mac already register to $filterName filter!";
   }
}

if ($function eq "removemac") {
   my $session = &openSession($infobloxip, $username, $password);
   $filterName = $ARGV[5];
   remove_macaddress($session, $macaddress, $filterName);
}

if ($function eq "registermac") {
   my $session = &openSession($infobloxip, $username, $password);
   
   remove_macaddress($session, $macaddress, $filterName);

   if (&search_dhcp_mac_filter($session, $macaddress, $filterName) == 0) {

      &add_dhcp_mac_filter($session, $macaddress, $filterName, $assignUsername, $expiration_time);
   }else {
      print "status=fasle, $macaddress already register to $filterName filter!";
   }
}

if ($function eq "removefreemac") {
    my $session = &openSession($infobloxip, $username, $password);
	$filterName = $ARGV[4];

	&remove_lease_mac($session, $filterName);
}

if ($function eq "searchremovemac") {
    my $session = &openSession($infobloxip, $username, $password);
	
	$filterName = $ARGV[5];
	&search_remove_mac($session, $macaddress, $filterName);
}

exit(0);
 
 
 sub openSession {
 	 my ($ip, $username, $password) = @_;
 	 
   my $session  = Infoblox::Session->new(
    				    master => $ip,
  			            username => $username,
  			            password => $password,
  					    timeout  => "3600",
  		   );
  unless ($session->status_code == 0) {
   		print "connection to Infoblox Server Error device ip" . $ip . "account:" . $username . "error code:" . $session->status_code . "error detail:" . $session->status_detail() . "\n";
      exit(0);
  }   		   
  return $session;

}


#------------------------------------------------------
# get_dhcp_lease                                
#   目的: 用 IP 到 Infoblox 取得 IP 配發的狀況，傳回 MAC Addr
#------------------------------------------------------
sub get_dhcp_lease {                            
    my ($session, $ip) =  @_;                                                                          
                                         
    # search for some leases                    
    my @leases = $session->get(object => 'Infoblox::DHCP::Lease',
				ipv4addr => $ip);                                          
    # XXX multiple leases case?                 
    if (@leases) {                              
	     my $lease = shift @leases;              
	     my $mac = $lease->mac();                
	     return $mac;                            
    } else {                           
	     print "status=false / IP address:$ip can't found dhcp assign record now\n";
	     return '';                              
    }                                           
}

#------------------------------------------------------
# search_dhcp_mac_filter                        
#   目的: Check If MAC Exist In the Specific Filter
#   Return:                                     
#           0: Not Exist                        
#           1: Exist                            
#------------------------------------------------------
sub search_dhcp_mac_filter {
    my ($session, $mac, $filter) = @_;

    my @retrieved_objs = $session->search(
       object => "Infoblox::DHCP::MAC",
       mac    => "$mac",
       filter => $filter
    );
    my $retrieved_objs = @retrieved_objs[0];
    if ($retrieved_objs) {
    	return 1;
    }else {
    	return 0;
    }
}

#------------------------------------------------------
#   search_legal_mac_filter                        
#   目的: 讀取合法區的DHCP IP Range
#   Return:                                     
#           合法區IP物件             
#------------------------------------------------------

sub search_legal_mac_filter {
   my ($session, $filter) = @_;

   my @retrieved_objs = $session->search(
     object => "Infoblox::DHCP::MAC",
     mac    => ".*",
     filter => "$filter"
 	);
	
	return @retrieved_objs;
}

#------------------------------------------------------
#   search_remove_mac                        
#   目的: 搜尋已經在Infoblox不存在的macaddress       
#------------------------------------------------------
sub search_remove_mac() {
   my ($session, $macstr, $filter) = @_;
   my @mac_array = split(/%20/, $macstr);
   
   $i = 0;
   @remove_macaddress = ("");
   while($i <= $#mac_array){
		my $mac = $mac_array[$i];
		unless (search_dhcp_mac_filter($session, $mac, $filter)) {
		   push(@remove_macaddress, $mac);
		}
		$i++;
	}
	if ($#remove_macaddress >= 1) {
	   print "not exists macaddress:";
	}
	for($i=0; $i<=$#remove_macaddress; $i++) {
        print "$remove_macaddress[$i]\t";
    }
	if ($#remove_macaddress >= 1) {
	   print "\n";
	}   
	return 1;
}



#------------------------------------------------------
#   remove_lease_mac                        
#   目的: 移除已經在Infoblox失效的macaddress       
#------------------------------------------------------
sub remove_lease_mac() {
   my ($session,$filter) = @_;
   
   @macaddress = &search_legal_mac_filter($session,$filter);
   $i = 0;
   @lease_macaddress = ("");
   
   my $tempsess;
   while($i <= $#macaddress){
		my $get_mac = $macaddress[$i];
		my $mac = $get_mac->mac();

		my @leases = $session->search(
					    object => 'Infoblox::DHCP::Lease',
	      			    mac => $mac);
	    $c = 0;
	    $d = 0;
	    while ($c <= $#leases) {
	      	my $status = $leases[$c];
	      	my $binding_state = $status->binding_state();
	      	if ($binding_state eq "free") {
	      		$d++;
	      	}
	  		$c++;
	  	}
	  	if ($c == $d) {
		    if ($i % 15 == 0)  {
		       $tempsess = &openSession($infobloxip, $username, $password);
		    }
			
		    my $flag = "true";
			if ($i < 15) {
			   $flag = &remove_macaddress($session, $mac, $filter);
			}else {
			   $flag = &remove_macaddress($tempsess, $mac, $filter);
			}   
			
			if ($flag eq "true") {
			   push(@lease_macaddress, $mac);
			}
	  	}
	  	$i++;
 	}
	if ($#lease_macaddress >= 1) {
	   print "remove lease macaddress:";
	}
	for($i=0; $i<=$#lease_macaddress; $i++) {
        print "$lease_macaddress[$i]\t";
    }
	if ($#lease_macaddress >= 1) {
	   print "\n";
	}   
	return 1;
}
					

#------------------------------------------------------
# add_dhcp_mac_filter                           
#   目的: 將 MAC 註冊到 MAC Address Filter 清單中，變成註冊合法機器
#------------------------------------------------------
sub add_dhcp_mac_filter {
    my ($session, $mac, $filter, $userid, $expiration_time) = @_;

    my $expire_dt;
    if ($expiration_time =~ /(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})/) {
       $expire_dt = unixtime_converter(0,$5,$4,$3,$2,$1);
    }else {
    	 $expire_dt = $expiration_time;
    }
	my $mac2 = Infoblox::DHCP::MAC->new(

                      "mac"                         => "$mac",

                      "filter"                      => "$filter",

                      "comment"                     => "",

                      "expiration_time"             => "$expire_dt",

                      "username"                    => "$userid",

                      "authentication_time"         => "0",

                      "reserved_for_infoblox" => "Modify By Docutek's authServer Program"

        );

    unless($mac2) {
	     my $code = $session->status_code();
	     my $detail = $session->status_detail(); 
	     if ($detail eq "The specified object was not found") {
		      $mac = "not found source mac address, please confirm this is infoblox assign ip";
	     }
	     print "error code:$code" . "error description:$detail" . "<B>issue:$mac。" . "\n";
	     return 0;

    }

    unless ($session->add($mac2)) {
	     my $code = $session->status_code();
	     my $detail = $session->status_detail();
	     if ($code == 1001) {
		      print "MAC:[$mac] format error, please varify mac address format.";
	     }
	     return 0;
    }
    return 1;
}

#------------------------------------------------------
# unixtime_converter
#   目的: 將一般時間欄位轉換為unixtime
#------------------------------------------------------
sub unixtime_converter {
	my ($sec, $min, $hour, $rday, $rmon, $ryear) = @_;
	my $day  = $rday;
	my $mon  = $rmon - 1;
	my $year = $ryear - 1900;
	my $wday = 0;
	my $yday = 0;
	my $unixtime_convert = mktime ($sec, $min, $hour, $day, $mon, $year, $wday, $yday);
	return $unixtime_convert;
}

sub remove_macaddress {
	my ($session, $mac, $filter) = @_;
	
	my @retrieved_objs = $session->search(
                 object => "Infoblox::DHCP::MAC",
                 mac => $mac,
                 filter => $filter
                 );

   if(@retrieved_objs) {
      my $retrieved_obj = @retrieved_objs[0];
      #my $expired = $retrieved_obj->expired();
      my $response = $session->remove( $retrieved_obj );
      #print "$response\n";
	  return 'true';
   } else {
      print "status=false / MAC address:$mac can't remove now\n";
	    return 'false';                              	
   }
}