




        

var footerFormName = 'footerform';




function NLReport_refresh(formName)
{
    if (!NS.form.isValid())
    {
        return;
    }

    var form = document.forms[formName];
    form.method ='POST';
    form.submit();
    disableField(document.getElementById("refresh"), true);
	disableField(document.getElementById("customize"), true);
}

function NLReport_email(formName)
{
    if (!NS.form.isValid())
    {
        return;
    }

	// this data is already escaped out, do not escape it again.
	var sDescription = document.forms[formName].elements['reportdescription'].value;
    var sDefinitionId = document.forms[formName].elements['cr'].value;
	var sExecutionId  = document.forms[formName].elements['id'].value;
    var colDimensionValue = NLReport_getColumnDimension(formName);

	nlOpenWindow("/app/reporting/emailreport.nl?l=T"
				 + "&defaultsubject=" + sDescription
				 + "&defid=" + sDefinitionId
                 + "&emailnow=T"
				 + "&range=" + colDimensionValue
				 + "&executionid=" + sExecutionId,
                 "emailreport", 740, 500, null, false);
}

function NLReport_schedule(formName)
{
    if (!NS.form.isValid())
    {
        return;
    }

	// this data is already escaped out, do not escape it again.
	var sDescription = document.forms[formName].elements['reportdescription'].value;
    var sDefinitionId = document.forms[formName].elements['cr'].value;
	var sExecutionId  = document.forms[formName].elements['id'].value;
	var colDimensionValue = NLReport_getColumnDimension(formName);

	nlOpenWindow("/app/reporting/emailreport.nl?l=T&frequency=NONE"
				 + "&defaultsubject=" + sDescription
				 + "&defid=" + sDefinitionId
				 + "&range=" + colDimensionValue
				 + "&executionid=" + sExecutionId,
                 "emailreport", 800, 700, null, true);
}

function NLReport_getColumnDimension(formName)
{
	var colDimension = document.forms[formName].elements['range'];
	var colDimensionValue = "none";
	if( colDimension != null )
		colDimensionValue = colDimension.value;
	return colDimensionValue;
}



function getIndentX(nIndent)
{
    return 4 + (nIndent+1) * 20 - 15;
}




var NLReport_bubble = null;
var NLReport_sBubbleText = "";
var NLReport_iBubbleTimerID = 0;
var NLReport_iBubbleHideTimerID = 0;


function NLReport_getBubbleString(sHref)
{
    var sDrill = null;

    
	if(sHref.indexOf("item/item.nl") != -1 )
	{
		sDrill = "Item Record";
	}
	else if(sHref.indexOf("entity/entity.nl") != -1 )
	{
		sDrill = "Entity Record";
	}
	else if(sHref.indexOf("departmenttype.nl") != -1 )
	{
		sDrill = "Department Record";
	}
	else if(sHref.indexOf("classtype.nl") != -1 )
	{
		sDrill = "Class Record";
	}
	else if(sHref.indexOf("locationtype.nl") != -1 )
	{
		sDrill = "Location Record";
	}
	else if(sHref.indexOf("item.nl") != -1 )
	{
		sDrill = "Item Record";
	}
	else if(sHref.indexOf("custrecordlist.nl") != -1 )
	{
		sDrill = "Custom Record";
	}
	else if(sHref.indexOf("entity/employee.nl") != -1 )
	{
		sDrill = "Employee Record";
	}
	else if(sHref.indexOf("account.nl") != -1 )
	{
		sDrill = "Account Definition";
	}
	else if(sHref.indexOf("/custjob.nl") != -1 )
	{
		sDrill = "Customer Record";
	}
	else if(sHref.indexOf("/transactions/") != -1 )
	{
		sDrill = "Transaction Record";
	}
	else if(sHref.indexOf("quickreportdrilldown") != -1 )
	{
		
		sDrill = "Detail Report";
	}
	else if(sHref.indexOf("CHILDRENOF") != -1 || sHref.indexOf("isDrilldown") != -1)
	{
		
		sDrill = "Detail Report";
	}
	else
	{
		return null;
	}

    return "View " + sDrill;
    
}


function NLReport_scheduleBubble(ndElement)
{
    
    if(ndElement && ndElement.onclick && ndElement.className == "H")
    {
		var bShowBubble = (document.forms[footerFormName].elements['SHOW_DRILLDOWN_BALLOON'].checked);

		if( bShowBubble )
		{
            if( !ndElement.bTriggered )
            {
                ndElement.bTriggered = false; //set it to false in case the value is null                                
                ndElement.onclick();
                ndElement.bTriggered = true;                                
            }

			
			var sBubbleText = NLReport_getBubbleString(ndElement.href);

			if(sBubbleText)
			{
				NLReport_sBubbleText = sBubbleText;
				
				NLReport_startBubbleTimer(NLReport_sBubbleText);
			}
		}
	}
    else
    {
        NLReport_hideBubble();
    }
}

function NLReport_startBubbleTimer(sBubbleText, bNoAutoHide, xPos, yPos, msBeforeBubbleAppears)
{
    if(NLReport_iBubbleTimerID)
    {
        clearTimeout(NLReport_iBubbleTimerID);
        NLReport_iBubbleTimerID = 0;
    }

    if (msBeforeBubbleAppears == null)
    msBeforeBubbleAppears = 1000;

    NLReport_iBubbleTimerID = setTimeout(function(){NLReport_showBubble(sBubbleText, bNoAutoHide, xPos, yPos);}, msBeforeBubbleAppears);
}


function NLReport_showBubble(sBubbleText, bNoAutoHide, xPos, yPos)
{
    
    if (xPos == null) xPos = mouseX;
    if (yPos == null) yPos = mouseY+document.body.scrollTop;

    NLReport_createBubble( xPos, yPos, sBubbleText, bNoAutoHide);
}


function NLReport_hideBubble()
{
   if( NLReport_iBubbleTimerID )
   {
       clearTimeout( NLReport_iBubbleTimerID );
       NLReport_iBubbleTimerID = 0;
   }

   if( NLReport_iBubbleHideTimerID )
   {
        clearTimeout( NLReport_iBubbleHideTimerID );
        NLReport_iBubbleHideTimerID = 0;
   }

   if(NLReport_bubble)
   {
        NLReport_bubble.style.display = "none";
   }
}


function NLReport_createBubble(left, top, sText, bNoAutoHide)
{
    if(!NLReport_bubble)
    {
		var span = document.createElement("span");
		span.id = "rptbubbletext";
		span.innerHTML = sText;

        var div = document.createElement("div");
		div.classList.add("rptbubble");
        div.appendChild(span);

        document.body.appendChild(div);

        NLReport_bubble = div;
    }

    
    var ndText = document.getElementById('rptbubbletext');
    ndText.innerHTML = sText;

    
    NLReport_bubble.style.visibility = "hidden";
    NLReport_bubble.style.display = "block";

    
    var iDocWidth  = getDocumentWidth();
    var iDivWidth  = parseInt(NLReport_bubble.offsetWidth);
    var iDivHeight = parseInt(NLReport_bubble.offsetHeight);

	if ( (left + iDivWidth) > iDocWidth )
    {
		left = iDocWidth - iDivWidth;
    }

    NLReport_bubble.style.top = top - iDivHeight - 8 + 'px';
    NLReport_bubble.style.left = left - 25 + 'px';

    NLReport_bubble.style.visibility = "";

    
    if (!bNoAutoHide)
        NLReport_iBubbleHideTimerID = setTimeout(function(){NLReport_hideBubble();}, 5000);
}
// </script>
