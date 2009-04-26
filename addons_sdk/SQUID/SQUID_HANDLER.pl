#!/usr/bin/perl

do "/frontview/lib/cgi-lib.pl";
do "/frontview/lib/addon.pl";

# initialize the %in hash
%in = ();
ReadParse();

my $operation      = $in{OPERATION};
my $command        = $in{command};
my $enabled        = $in{"CHECKBOX_SQUID_ENABLED"};

get_default_language_strings("SQUID");
 
my $xml_payload = "Content-type: text/xml; charset=utf-8\n\n"."<?xml version=\"1.0\" encoding=\"UTF-8\"?>";
 
if( $operation eq "get" )
{
  $xml_payload .= Show_SQUID_xml();
}
elsif( $operation eq "set" )
{
  if( $command eq "RemoveAddOn" )
  {
    # Remove_Service_xml() removes this add-on
    $xml_payload .= Remove_Service_xml("SQUID");
  }
  elsif ($command eq "ToggleService")
  {
    # Toggle_Service_xml() toggles the enabled state of the add-on
    $xml_payload .= Toggle_Service_xml("SQUID", $enabled);
  }
  elsif ($command eq "ModifyAddOnService")
  {
    # Modify_SQUID_xml() processes the input form changes
    $xml_payload .= Modify_SQUID_xml();
  }
}

print $xml_payload;
  

sub Show_SQUID_xml
{
  my $xml_payload = "<payload><content>" ;

  # check if service is running or not 
  my $enabled = GetServiceStatus("SQUID");

  my $enabled_disabled = "disabled";
     $enabled_disabled = "enabled" if( $enabled );

  # squid-specific vars
  my $allowed_hosts = GetValueFromServiceFile("SQUID_ALLOWED_HOSTS");
  if ($allowed_hosts eq "not_found" )
  {
    $allowed_hosts = "localnet";
  }
  $xml_payload .= "<SQUID_ALLOWED_HOSTS><value>$allowed_hosts</value><enable>$enabled_disabled</enable></SQUID_ALLOWED_HOSTS>";

  $xml_payload .= "</content><warning>No Warnings</warning><error>No Errors</error></payload>";
  
  return $xml_payload;
}


sub Modify_SQUID_xml 
{
  my $SPOOL;
  my $xml_payload;
  
  # Squid-specfic vars
  my $allowed_hosts = $in{"SQUID_ALLOWED_HOSTS"};
  $SPOOL .= "
if grep -q SQUID_ALLOWED_HOSTS /etc/default/services; then
  sed -i 's#SQUID_ALLOWED_HOSTS=.*#SQUID_ALLOWED_HOSTS=${allowed_hosts}#' /etc/default/services
else
  echo 'SQUID_ALLOWED_HOSTS=${allowed_hosts}' >> /etc/default/services
fi
";

  # this needs to stay aligned with what's in start.sh
  chomp($allowed_hosts);
  if ($allowed_hosts eq "") {
	$allowed_hosts = '10.0.0.0/8 172.16.0.0/12 192.168.0.0/16';
  }

  $SPOOL .= "
sed 's#ALLOWED_HOSTS#$allowed_hosts#' /opt/squid/etc/squid.conf.tmpl > /opt/squid/etc/squid.conf;
/opt/squid/sbin/squid -k reconfigure;
";
 
  if( $in{SWITCH} eq "YES" ) 
  {
    $xml_payload = Toggle_Service_xml("SQUID", $enabled);
  }
  else
  	{
    spool_file("${ORDER_SERVICE}_SQUID", $SPOOL);
    empty_spool();

    $xml_payload = _build_xml_set_payload_sync();
  }
  return $xml_payload;
}


1;
