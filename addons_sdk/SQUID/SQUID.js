self.SQUID_preaction = function()
{
}

self.SQUID_onloadaction = function()
{
}

self.SQUID_enable = function()
{
  document.getElementById('BUTTON_SQUID_APPLY').disabled = false;
  var allowed_hosts = document.getElementById('SQUID_ALLOWED_HOSTS');
  if (allowed_hosts)
  {
    allowed_hosts.disabled = false;
  }
}

self.SQUID_remove = function()
{
  if( !confirm(S['CONFIRM_REMOVE_ADDON']) )
  {
    return;
  }

  var set_url = NasState.otherAddOnHash['SQUID'].DisplayAtom.set_url
                + '?OPERATION=set&command=RemoveAddOn';

  applyChangesAsynch(set_url,  SQUID_handle_remove_response);
}

self.SQUID_handle_remove_response = function()
{
  if ( httpAsyncRequestObject && 
      httpAsyncRequestObject.readyState && 
      httpAsyncRequestObject.readyState == 4 ) 
  {
    if ( httpAsyncRequestObject.responseText.indexOf('<payload>') != -1 )
    {
       showProgressBar('default');
       xmlPayLoad  = httpAsyncRequestObject.responseXML;
       var status = xmlPayLoad.getElementsByTagName('status').item(0);
       if (!status || !status.firstChild)
       {
          return;
       }

       if ( status.firstChild.data == 'success')
       {
         display_messages(xmlPayLoad);
         updateAddOn('SQUID');
         if (!NasState.otherAddOnHash['SQUID'])
         {
            remove_element('SQUID');
            if (getNumAddOns() == 0 )
            {
               document.getElementById('no_addons').className = 'visible';
            }
         }
         else
         {
           hide_element('SQUID_LINK');
         }
       }
       else if (status.firstChild.data == 'failure')
       {
         display_error_messages(xmlPayLoad);
       }
    }
    httpAsyncRequestObject = null;
  }
}

self.SQUID_page_change = function()
{
  var id_array = new Array( 'SQUID_ALLOWED_HOSTS' );
  for (var ix = 0; ix < id_array.length; ix++ )
  {
     NasState.otherAddOnHash['SQUID'].DisplayAtom.fieldHash[id_array[ix]].value = 
     document.getElementById(id_array[ix]).value;
     NasState.otherAddOnHash['SQUID'].DisplayAtom.fieldHash[id_array[ix]].modified = true;
  }
}


self.SQUID_enable_save_button = function()
{
  document.getElementById('BUTTON_SQUID_APPLY').disabled = false;
}

self.SQUID_apply = function()
{

   var page_changed = false;
   var set_url = NasState.otherAddOnHash['SQUID'].DisplayAtom.set_url;
   var allowedHosts = document.getElementById('SQUID_ALLOWED_HOSTS');
   if (allowedHosts)
   {
     var id_array = new Array ('SQUID_ALLOWED_HOSTS');
     for (var ix = 0; ix < id_array.length ; ix ++)
     {
       if (  NasState.otherAddOnHash['SQUID'].DisplayAtom.fieldHash[id_array[ix]].modified )
       {
          page_changed = true;
          break;
       }
     }
   }
   var enabled = document.getElementById('CHECKBOX_SQUID_ENABLED').checked ? 'checked' :  'unchecked';
   var current_status  = NasState.otherAddOnHash['SQUID'].Status;
   if ( page_changed )
   {
      set_url += '?command=ModifyAddOnService&OPERATION=set&' + 
                  NasState.otherAddOnHash['SQUID'].DisplayAtom.getApplicablePagePostStringNoQuest('modify') +
                  '&CHECKBOX_SQUID_ENABLED=' +  enabled;
      if ( enabled == 'checked' && current_status == 'on' ) 
      {
        set_url += "&SWITCH=NO";
      }
      else
      {
         set_url += "&SWITCH=YES";
      }
   }
   else
   {
      set_url += '?command=ToggleService&OPERATION=set&CHECKBOX_SQUID_ENABLED=' + enabled;
   }
   applyChangesAsynch(set_url, SQUID_handle_apply_response);
}

self.SQUID_handle_apply_response = function()
{
  if ( httpAsyncRequestObject &&
       httpAsyncRequestObject.readyState &&
       httpAsyncRequestObject.readyState == 4 )
  {
    if ( httpAsyncRequestObject.responseText.indexOf('<payload>') != -1 )
    {
      showProgressBar('default');
      xmlPayLoad = httpAsyncRequestObject.responseXML;
      var status = xmlPayLoad.getElementsByTagName('status').item(0);
      if ( !status || !status.firstChild )
      {
        return;
      }

      if ( status.firstChild.data == 'success' )
      {
        var log_alert_payload = xmlPayLoad.getElementsByTagName('normal_alerts').item(0);
        if ( log_alert_payload )
	{
	  var messages = grabMessagePayLoad(log_alert_payload);
	  if ( messages && messages.length > 0 )
	  {
	      if ( messages != 'NO_ALERTS' )
	      {
	        alert (messages);
	      }
	      var success_message_start = AS['SUCCESS_ADDON_START'];
		  success_message_start = success_message_start.replace('%ADDON_NAME%', NasState.otherAddOnHash['SQUID'].FriendlyName);
	      var success_message_stop  = AS['SUCCESS_ADDON_STOP'];
		  success_message_stop = success_message_stop.replace('%ADDON_NAME%', NasState.otherAddOnHash['SQUID'].FriendlyName);

	      if ( NasState.otherAddOnHash['SQUID'].Status == 'off' )
	      {
	        NasState.otherAddOnHash['SQUID'].Status = 'on';
	        NasState.otherAddOnHash['SQUID'].RunStatus = 'OK';
	        refresh_applicable_pages();
	      }
	      else
	      {
	        NasState.otherAddOnHash['SQUID'].Status = 'off';
	        NasState.otherAddOnHash['SQUID'].RunStatus = 'not_present';
	        refresh_applicable_pages();
	      }
	    }
        }
      }
      else if (status.firstChild.data == 'failure')
      {
        display_error_messages(xmlPayLoad);
      }
    }
    httpAsyncRequestObject = null;
  }
}

self.SQUID_handle_apply_toggle_response = function()
{
  if (httpAsyncRequestObject &&
      httpAsyncRequestObject.readyState &&
      httpAsyncRequestObject.readyState == 4 )
  {
    if ( httpAsyncRequestObject.responseText.indexOf('<payload>') != -1 )
    {
      showProgressBar('default');
      xmlPayLoad = httpAsyncRequestObject.responseXML;
      var status = xmlPayLoad.getElementsByTagName('status').item(0);
      if (!status || !status.firstChild)
      {
        return;
      }
      if ( status.firstChild.data == 'success' )
      {
        display_messages(xmlPayLoad);
      }
      else
      {
        display_error_messages(xmlPayLoad);
      }
    }
  }
}

self.SQUID_service_toggle = function()
{
  
  var addon_enabled = document.getElementById('CHECKBOX_SQUID_ENABLED').checked ? 'checked' :  'unchecked';
  var set_url    = NasState.otherAddOnHash['SQUID'].DisplayAtom.set_url
                   + '?OPERATION=set&command=ToggleService&CHECKBOX_SQUID_ENABLED='
                   + addon_enabled;
  
  var xmlSyncPayLoad = getXmlFromUrl(set_url);
  var syncStatus = xmlSyncPayLoad.getElementsByTagName('status').item(0);
  if (!syncStatus || !syncStatus.firstChild)
  {
     return ret_val;
  }

  if ( syncStatus.firstChild.data == 'success' )
  {
    display_messages(xmlSyncPayLoad);
    //if SQUID is enabled
    NasState.otherAddOnHash['SQUID'].Status = 'on';                                             
    NasState.otherAddOnHash['SQUID'].RunStatus = 'OK';                                            
    refresh_applicable_pages();  
    //else if SQUID is disabled
    NasState.otherAddOnHash['SQUID'].Status = 'off';                    
    NasState.otherAddOnHash['SQUID'].RunStatus = 'not_present';         
    refresh_applicable_pages(); 
  }
  else
  {
    display_error_messages(xmlSyncPayLoad);
  }
}

