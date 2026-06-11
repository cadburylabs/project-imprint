




	


function getQueryParameter(param)
{
  var idx = document.URL.indexOf(param+"=");
  if (idx != -1)
  {
    var sidx = idx+param.length+1;
    var len = document.URL.substring(sidx).indexOf("&");
    if (len == -1)
      return document.URL.substring(sidx);
    else
      return document.URL.substring(sidx, sidx+len)
  }
  else
    return null;
}
function HandleReferralInfo()
{
  var affiliateid = getQueryParameter("affiliateid");
  if (affiliateid != null)
    document.cookie = "ai="+affiliateid+"; path=/; domain=.netsuite.com;";
  var sourceid = getQueryParameter("sourceid");
  var expires = new Date();
  expires.setTime(expires.getTime()+31536000);
  if (sourceid == null)
    sourceid = "0000000000000000";
  else
    document.cookie = "lsi="+sourceid+"; path=/; domain=.netsuite.com; expires="+expires.toGMTString();
  if (document.cookie.indexOf("osi=") == -1)
    document.cookie = "osi="+sourceid+"; path=/; domain=.netsuite.com; expires="+expires.toGMTString();
  document.cookie = "csi="+sourceid+"; path=/; domain=.netsuite.com;";
}
function selectAndGo(newLoc)
{
    var newPage = newLoc.options[newLoc.selectedIndex].value;
    if(newPage != "")
        window.location.href = newPage;
}
function openTourWindow()
{
  var tour = window.open('/portal/popuptour.nl','Tour','scrollbars=yes,resizable=yes,width=820,height=508');
  tour.focus();
}
function closeAndGoTo(url)
{
  opener.location = url;
  window.close();
}
function fieldHelp(sHelptext)
{
	var body = "<html> <head> <title>Help</title><meta http-equiv='Content-Type' content='text/html; charset=utf-8'>"+
			   "<link rel='stylesheet' href='/core/styles/pagestyles.nl?ct=-2&bglt=F2F4F6&bgmd=EDF1F7&bgdk=737A82&bgon=5C7499&bgoff=AFB5BF&bgbar=5C7499&tasktitletext=E4EAF4&crumbtext=C4C8CF&headertext=B5C1D5&ontab=FFFFFF&offtab=000000&text=000000&link=000000&bgbody=FFFFFF&bghead=FFFFFF&portlet=C0CAD9&portletlabel=000000&bgbutton=FFE599&bgrequiredfld=FFFFE5&font=Verdana%2CHelvetica%2Csans-serif&size_site_content=9pt&size_site_title=9pt&size=1.0&nlinputstyles=T&accessibility=F&appOnly=F&NS_VER=2026.1&minver=14'>"+
			   "</head>"+
			   "<body bgcolor='#FFFFFF' link='#000000' vlink='#000000' alink='#000000' text='#000000'  class='bglt' topmargin='2' marginheight='1' leftmargin='2' marginwidth='1' onblur='window.close()'>"+
			   "<table border='0' cellspacing='0' cellpadding='2' width='100%'>"+
			   "<tr> <td class='text'><p>"+
			   sHelptext+
			   "</p></td> </tr> </table> </body> </html>";
    var fieldhelp = window.open('','fieldhelpwin','scrollbars=no,width=350,height=205');
    fieldhelp.document.write(body);
    fieldhelp.focus();
}
function setLoginCookie(createCookie)
{
	if(createCookie)
	{
		var expireDate = new Date();
		expireDate.setMonth(expireDate.getMonth()+24);
		var userName = document.forms[0].elements['email'].value;
		document.cookie = "OSBuserName="+userName+"; path=/; domain=.4434917-sb1.app.netsuite.com; expires="+expireDate.toGMTString();
	}
	else
	{
		if (document.cookie.indexOf("OSBuserName=") > -1)
		{
			expireDate = new Date();
			expireDate.setDate(expireDate.getDate()-1);
			document.cookie = "OSBuserName=blah; path=/; domain=.4434917-sb1.app.netsuite.com; expires="+expireDate.toGMTString();
		}
	}
	document.cookie = "ScreenWidth="+screen.width+"; path=/; domain=.4434917-sb1.app.netsuite.com";
	document.cookie = "ScreenHeight="+screen.height+"; path=/; domain=.4434917-sb1.app.netsuite.com";
}

function populateEmailFromCookie()
{
	var cookieVal = "";
	if (document.cookie.indexOf("OSBuserName=") > -1)
	{
		var thisCookie = document.cookie.split("; ");
		for(var i=0; i<thisCookie.length; i++)
		{
			if("OSBuserName" == thisCookie[i].split("=")[0])
			{
				cookieVal = thisCookie[i].split("=")[1];
				document.forms[0].elements['email'].value = cookieVal;
				document.forms[0].elements['rememberme'].checked = "T";
				document.forms[0].elements['password'].focus();
				return;
			}
		}
	}
	else
	{
		document.forms[0].elements['email'].focus();
	}
}

function populateEmailFromCookieNoFocus()
{
    var cookieVal = "";
    if (document.cookie.indexOf("OSBuserName=") > -1)
    {
        var thisCookie = document.cookie.split("; ");
        for(var i=0; i<thisCookie.length; i++)
        {
            if("OSBuserName" == thisCookie[i].split("=")[0])
            {
                cookieVal = thisCookie[i].split("=")[1];
                document.forms[0].elements['email'].value = cookieVal;
                document.forms[0].elements['rememberme'].checked = "T";
                document.forms[0].elements['password'].focus();
                return;
            }
        }
    }
}
function hasFlash()
{
    if ((navigator.appName == "Microsoft Internet Explorer" &&
                navigator.appVersion.indexOf("Mac") == -1 &&
                navigator.appVersion.indexOf("3.1") == -1) ||
                (navigator.plugins && navigator.plugins["Shockwave Flash"])
                || navigator.plugins["Shockwave Flash 2.0"])
    {
        
        return true;
    }
    else
    {
        
        return false;
    }
}

