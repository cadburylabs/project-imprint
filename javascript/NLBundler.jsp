










var sTYPE_SUBTYPE_DELIM = String.fromCharCode(3);
var sTYPE_COMP_KEY_DELIM = String.fromCharCode(1);
var sTYPE_COMP_KEY_VALUE_DELIM = String.fromCharCode(5);


var BASE_CHECKBOX_NAME = "chkbox"+sTYPE_SUBTYPE_DELIM;
var BASE_CHECKBOX_NAME_ALT = "chkboxalt"+sTYPE_SUBTYPE_DELIM;


var currentFocusTr = null;
var currentParentFocusTr = null;
var currentFocusChildTd = null;
var runningTotals = new Array();


function populateCurrentItems()
{
	var sHiddenFieldValue = document.forms[0].elements[getHiddenFieldName()].value;
	if(sHiddenFieldValue != null && sHiddenFieldValue.length>0)
	{
		var currentVals = sHiddenFieldValue.split( sTYPE_COMP_KEY_DELIM );
		for(var i=0; i<currentVals.length; i++)
		{
			var dataPieces = currentVals[i].split( sTYPE_COMP_KEY_VALUE_DELIM );
			var chkboxid = dataPieces[0] + sTYPE_COMP_KEY_VALUE_DELIM + dataPieces[1] + sTYPE_COMP_KEY_VALUE_DELIM + dataPieces[2];
			setFormValue(document.forms[0].elements[ BASE_CHECKBOX_NAME + chkboxid ], true);

			var altchkbox = document.forms[0].elements[ BASE_CHECKBOX_NAME_ALT + chkboxid ];
			if (altchkbox != null)
            {
				disableField(altchkbox, false);
				setFormValue(altchkbox,(dataPieces.length >= 5 && dataPieces[4] == "T"));
			}
		}
	}
}


function getRunningBundleObjectTotal()
{
	var iCount = 0;
	for(var i in runningTotals)
	{
	    if ( i.substring(0, 3) == "cmp" )
		    iCount += Number(runningTotals[i]);
    }
	return iCount;
}


function markCurrentItems(bCheckAll, bMark)
{
    var sOldHiddenFieldValue = document.forms[0].elements[ getHiddenFieldName() ].value;
	var sNewHiddenFieldValue = "";
	var iCount = 0;
	var elements = document.forms[0].elements;
	for(var i=0; i<elements.length; i++)
	{
		if(elements[i].type == "checkbox" && elements[i].name != null && elements[i].name.indexOf(BASE_CHECKBOX_NAME)==0)
		{
            var sCurFieldValue = "";
			if( bCheckAll && bMark || !bCheckAll && elements[i].checked)
			{
 				sCurFieldValue += getFieldPrimaryKeyFromName( elements[i].name );
				iCount++;
			}
            if ( bCheckAll )
                setFormValue(elements[i], bMark);

            
			var bIncludeData = "F";
			var altCheckBox = elements[ BASE_CHECKBOX_NAME_ALT + getFieldPrimaryKeyFromName(elements[i].name) ];
			if (altCheckBox != null)
			{
				disableField(altCheckBox, !elements[i].checked);
				if (elements[i].checked == false)
					setFormValue(altCheckBox, false);
				if (altCheckBox.checked)
					bIncludeData = "T";
			}

			
			if ( sCurFieldValue.length > 0 )
            {
                
                var bLocked = "F";
                var sInstallationPref = "";
				var lockedIdx = sOldHiddenFieldValue.indexOf( sCurFieldValue )+1;
	            if ( lockedIdx > 0 )
	            {
	                bLocked = (sOldHiddenFieldValue.substring( lockedIdx + sCurFieldValue.length, lockedIdx + sCurFieldValue.length + 1 ) == "T") ? "T" : "F";
                    var sObjectProperties = sOldHiddenFieldValue.substring( lockedIdx - 1 ).split( sTYPE_COMP_KEY_DELIM )[0];
                    sInstallationPref = sObjectProperties.split( sTYPE_COMP_KEY_VALUE_DELIM )[6];
	            }

                if ( sNewHiddenFieldValue.length > 0 )
	                sNewHiddenFieldValue += sTYPE_COMP_KEY_DELIM;
			    sNewHiddenFieldValue += sCurFieldValue + sTYPE_COMP_KEY_VALUE_DELIM + bLocked + sTYPE_COMP_KEY_VALUE_DELIM + bIncludeData + sTYPE_COMP_KEY_VALUE_DELIM + sTYPE_COMP_KEY_VALUE_DELIM + sInstallationPref;
			}
		}
	}

	document.forms[0].elements[ getHiddenFieldName() ].value = sNewHiddenFieldValue;
	runningTotals[ getHiddenFieldName() ] = iCount;
	document.forms[0].elements[ getParentHiddenFieldName() ].value = iCount;

	populateComponentSummary( currentFocusTr, sNewHiddenFieldValue, true );
}


function getHiddenFieldName()
{
	return "cmp" + sTYPE_SUBTYPE_DELIM + getCurrentType() + sTYPE_SUBTYPE_DELIM + getCurrentSubType();
}

function getParentHiddenFieldName()
{
	return "cmp" + sTYPE_SUBTYPE_DELIM + getCurrentType() + sTYPE_SUBTYPE_DELIM + "PARENT";
}


function getCurrentType()
{
	return document.forms[0].elements["fld_currenttype"].value
}


function getCurrentSubType()
{
	return document.forms[0].elements["fld_currentsubtype"].value
}


function syncComponentSummary()
{
	var bData = true;
	if(currentFocusChildTd != null)
	{
		if(currentFocusChildTd.getAttribute("nodata") == "T")
		{
			currentFocusChildTd.parentNode.style.display = "none";
			currentFocusChildTd.innerHTML = "";
			bData = false;
		}
		currentFocusChildTd.style.backgroundColor = "";
		currentFocusChildTd = null;
	}
	if(currentFocusTr != null)
	{
		currentFocusTr.cells[0].style.backgroundColor = "";
		if(!bData)
			currentFocusTr.style.display = "none";
		var parentCount = Number(document.getElementById(currentParentFocusTr.getAttribute("parentHiddenFieldName")).value);
		currentParentFocusTr.style.display = parentCount > 0 ? "" : "none";
		currentFocusTr = null;
		currentParentFocusTr = null;
	}
	var sHiddenFieldName = getHiddenFieldName();
	var parentHiddenFieldName = getParentHiddenFieldName();
	currentFocusTr = document.getElementById(sHiddenFieldName+"_tr");
	currentParentFocusTr = document.getElementById(parentHiddenFieldName+"_tr");
	currentFocusTr.style.display = "";
	currentParentFocusTr.style.display = "";
	currentParentFocusTr.setAttribute("parentHiddenFieldName",parentHiddenFieldName);
	currentFocusTr.nextSibling.style.display = "";
	currentFocusTr.cells[0].style.backgroundColor = "#EEEEEE";

	populateComponentSummary(currentFocusTr, document.getElementById(sHiddenFieldName).value, true, true);
	manageNoDataMessage();
}


function focusComponentTd()
{
	if(currentFocusTr != null)
		currentFocusTr.cells[0].focus();
}

function focusChildTd()
{
	if(currentFocusChildTd != null)
		currentFocusChildTd.focus();
}


function populateComponentSummary(currentTr, vals, bSetCurrent, bFocus)
{
	var td = currentTr.nextSibling.cells[0];
	var iCount = 0;
	if(vals == null || vals.length==0)
	{
		if(bSetCurrent)
		{
			td.innerHTML = "<i>No objects selected</i>";
			td.style.paddingBottom = "2";
			td.style.display = "";
			td.style.backgroundColor = "#EEEEEE";
			td.className = "smallgraytext";
			td.setAttribute("nodata","T");
		}
	}
	else
	{
		var sb = new StringBuffer();
		sb.append("<table cellpadding=0 cellspacing=0 width='100%' border=0>");
		var sDescription = null;
		var compKeys = vals.split(sTYPE_COMP_KEY_DELIM);
		iCount = compKeys.length;
		for(var i=0; i<compKeys.length; i++)
		{
			sDescription = compKeys[i].split(sTYPE_COMP_KEY_VALUE_DELIM)[1];
			sb.append("<tr><td nowrap class=text><span class='uir-bundlebuilder-content-item'>");
			sb.append(escapeHTML(sDescription));
			sb.append("</span></td></tr>");
		}
		sb.append("</table>");
		td.innerHTML = sb.toString();
		td.style.display = "";
		currentTr.nextSibling.style.display = "";
		td.style.backgroundColor = bSetCurrent ? "#EEEEEE" : "#FFFFFF";
		td.className = "text";
		td.setAttribute("nodata","F");
	}
	if(bFocus)
	{
		currentFocusChildTd = td;
		if(vals == null || vals.length==0)
			focusComponentTd();
		else
			focusChildTd();
	}
	var sHiddenFieldName = currentTr.id.substring(0, currentTr.id.length-3);
	runningTotals[sHiddenFieldName] = iCount;
	manageNoDataMessage();
}


function syncFullSummary()
{
	var elems = document.forms[0].elements;
	for(var i=0; i<elems.length; i++)
	{
		if(elems[i].type == "hidden" && elems[i].name != null && elems[i].name.indexOf("cmp"+sTYPE_SUBTYPE_DELIM)==0)
		{
			var trr = document.getElementById(elems[i].name+"_tr");
			if(elems[i].name.indexOf(sTYPE_SUBTYPE_DELIM+"PARENT")>1)
			{
				var iCount = Number(elems[i].value);
				if( iCount > 0 )
					trr.style.display = "";
			}
			else
			{
				populateComponentSummary(trr, elems[i].value, false);
			}
		}
	}
	manageNoDataMessage()
}


function manageNoDataMessage(bForceHidden)
{
	document.getElementById("nodata_tr").style.display = (getRunningBundleObjectTotal()>0 || bForceHidden ? "none" : "");
}


function getFieldPrimaryKeyFromName(name)
{
	return name.substring(name.lastIndexOf(sTYPE_SUBTYPE_DELIM)+1);
}


function positionArrow()
{
	var div = document.createElement("DIV");
	div.style.position = "absolute";
	var span = document.createElement("SPAN");
	span.classList.add('uir-bundlebuilder-arrow');
	div.appendChild(span);
	var container = document.getElementById("arrowholder1").parentNode;
	container.appendChild(div);
	var div2 = div.cloneNode(true);
	container = document.getElementById("arrowholder2").parentNode;
	container.appendChild(div2);
}


function navigateToStep(iStep)
{
	var form = document.forms['main_form'];
	var iCurrentStep = form.elements['curstep'].value;
	form.elements['navigateto'].value = iStep;
    form.elements['_button'].value = iCurrentStep < iStep ? "next" : "back";
    if (!form.onsubmit || form.onsubmit())
        form.submit();
    return false;
}



function NLBundler_resizeObjectPanes()
{
	var contentWrapper = document.querySelector('.uir-rightpane-content-top');
	var newHeight = Math.max(305, contentWrapper.offsetHeight - 115) + 'px';
	var panes = document.querySelectorAll('.uir-bundlebuilder-inner-table');
	panes.forEach(function (pane) {
		pane.style.height = newHeight;
    });
}
