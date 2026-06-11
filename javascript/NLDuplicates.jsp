

        

function selectAllDupes()
{
    clearAllCheckBoxes();
	checkBoxes( 'd_', true );
}

function selectAllNotDupes()
{
    clearAllCheckBoxes();
	checkBoxes( 'n_', true );
}

function clearAllCheckBoxes()
{
	checkBoxes( 'all', false );
}

function checkBoxes( prefix, bValue )
{
	var frm  = document.forms[ 'body_actions' ];
	var bAll = (prefix == 'all' ? true : false);

	for (var i = 0; i < frm.elements.length; i++)
	{
		var elem = frm.elements[i];
        if (elem.type == 'checkbox' && elem.name.length > 0 && elem.name.indexOf('inpt_') != 0 && (bAll || elem.name.indexOf( prefix ) == 0) )
           setFormValue(elem, bValue);
    }
}

function isMasterBasedAction( opt )
{
    return opt == 'mim' || opt == 'kmdd' || opt == 'mmp';
}

function setMasterAction()
{
	var footerForm = document.forms['footer_actions_form'];
    var opt = getSelectValue( footerForm.elements['mopt'] );

	if (footerForm)
	{
        if ( !isMasterBasedAction( opt ))
            setFormValue( footerForm.elements['mopt'], 'mim' );
    }
}

function handleAction()
{
	var footerForm = document.forms['footer_actions_form'];
    var opt = getSelectValue( footerForm.elements['mopt'] );

	if (footerForm)
	{
		if ( !isMasterBasedAction( opt ) )
            checkBoxes( 'm_', false );
        if ( opt == 'and' )
            checkBoxes( 'd_', false );
    }
}

var errMsg = '';

// If option is blank, then must have >0 no dupes selected, all others not selected
// else
// If option requires master, then for every group, must have (one master + >0 dups)  or  (no master, no dups)
//                            else for every group, must have no master and >0 dups
function areOptionsValid ( bMass )
{
     var footerForm = document.forms['footer_actions_form'];
     var opt = getSelectValue( footerForm.elements['mopt'] );

     var frm = document.forms['body_actions'];
     var nNotADupCount = 0;

     if (opt == 'and')
     {
        // All not duplicates case. Must have >0 no dupes selected, all others not selected.
        for (var i = 0; i < frm.elements.length; i++)
        {
            var elem = frm.elements[i];
            if (elem.type == 'checkbox' && elem.name.length > 0 && elem.name.indexOf('inpt_') != 0 && elem.checked)
            {
                if (elem.name.indexOf('m_') == 0 || elem.name.indexOf('d_') == 0)
                {
                    errMsg = 'Please select no master or duplicate records for this operation.';
                    return false;
                }
                else if (elem.name.indexOf('n_') == 0)
                    nNotADupCount++;
            }
         }
         if (nNotADupCount == 0)
         {
            errMsg = 'Please mark at least one record as not-a-duplicate.'
            return false;
         }
         return true;
     }
     else if (isMasterBasedAction( opt ))
     {
        // Master case: every group must have (one master + >0 dups) or (no master, no dups)
        var curGroup = -1;
        var bMaster  = false;
        var nDupeCount = 0;
        var nTotalMasters = 0;

        for (var i = 0; i < frm.elements.length; i++)
        {
            elem = frm.elements[i];
            if (elem.name.length > 0 && elem.name.indexOf('inpt_') != 0)
            {
                if (elem.type == 'hidden' && elem.name.indexOf('g_') == 0)
                {
                    if (curGroup != elem.value)
                    {
                        if (curGroup != -1 && !checkGroupAtEnd( bMaster, nDupeCount, curGroup, bMass ))
                            return false;

                        curGroup = elem.value;
                        bMaster = false;
                        nDupeCount = 0;
                    }
                }
                else if (elem.type == 'checkbox' && elem.name.indexOf('m_') == 0 && elem.checked)
                {
                    bMaster = true;
                    nTotalMasters++;
                }
                else if (elem.type == 'checkbox' && elem.name.indexOf('d_') == 0 && elem.checked)
                    nDupeCount++;
            }
         }

         if (!checkGroupAtEnd( bMaster, nDupeCount, curGroup, bMass ))
            return false;

         if (nTotalMasters == 0)
         {
            errMsg = 'Please select a master record.';
            return false;
         }
         return true;
     }
     else
     {
        // Non master case: for every group, must have no master and >1 dups
        var curGroup = -1;
        var nDupeCount = 0;
        var nTotalDupes = 0;

        for (var i = 0; i < frm.elements.length; i++)
        {
            elem = frm.elements[i];
            if (elem.name.length > 0 && elem.name.indexOf('inpt_') != 0)
            {
                if (elem.type == 'hidden' && elem.name.indexOf('g_') == 0)
                {
                    if (curGroup != elem.value)
                    {
                        if (curGroup != -1)
                        {
                            if (nDupeCount == 1)
                            {
                                if ( bMass )
                                    errMsg = 'Please select at least two duplicates for Group #' + curGroup;
                                else
                                    errMsg = 'Please select at least two duplicates.';
                                return false;
                            }
                        }
                        curGroup = elem.value;
                        nDupeCount = 0;
                    }
                }
                else if (elem.type == 'checkbox' && elem.name.indexOf('d_') == 0 && elem.checked)
                {
                    nDupeCount++;
                    nTotalDupes++;
                }
                else if (elem.type == 'checkbox' && elem.name.indexOf('m_') == 0 && elem.checked)
                {
                    errMsg = 'Please select no master record for this operation.';
                    return false;
                }
            }
         }
         if (nTotalDupes <= 1)
         {
            errMsg = 'Please select at least two duplicates.';
            return false;
         }
         return true;
     }
}

function checkGroupAtEnd( bMaster, nDupeCount, curGroup, bMass)
{
    if (bMaster == false && nDupeCount > 0)
    {
        if ( bMass )
            errMsg = 'Please select a master record for Group #' + curGroup;
        else
            errMsg = 'Please select a master record.';
        return false;
    }
    else if (bMaster == true && nDupeCount == 0)
    {
        if ( bMass )
            errMsg = 'Please select at least one duplicate for Group #' + curGroup;
        else
            errMsg = 'Please select at least one duplicate';
        return false;
    }
    return true;
}

var bSubmitted = false;

function goMassSubmit(mass)
{
    if (bSubmitted)
    {
        alert('This page has already been submitted.');
    }
    else if (!areOptionsValid(mass))
    {
        alert(errMsg);
    }
    else
    {
        var footerForm = getFooterActionsForm();
        var bodyActionsForm = getBodyForm();
        var mergeType = getSelectValue(footerForm.elements['mopt']);

        if (mergeType == 'and' || mergeType == 'mmp'
                || confirm('Merge operations are irreversible and will merge or delete records flagged as duplicates. The operation itself may take a few minutes.\n\nPlease confirm you want to proceed.'))
        {
            var entitType = getSelectValue(footerForm.elements['etype']);

            bSubmitted = true;

            bodyActionsForm.action = '/app/common/entity/manageduplicates.nl?frame=be&submit=true&mopt=' + mergeType + '&etype=' + entitType;
            bodyActionsForm.submit();
        }
    }

    return false; // prevent default behaviour of submit button
}

function setFormValueForSingleElementOrArray(obj, value)
{
    if (obj.length === undefined)
    {
        setFormValue(obj, value);
    }
    else
    {
        for (var i = 0; i < obj.length; ++i)
        {
            setFormValue(obj[i], value);
        }
    }
}

function handleCheckboxesForEntity(obj)
{
    var value = obj.checked;
    var name = obj.name;
    var prefix = name.substring(0, 2);
    var key = name.substring(2, name.length);

    var formElements = document.forms['body_actions'].elements;

    // set same value in that column for all rows with the same entity
    var sameEntityElements = formElements[name];
    setFormValueForSingleElementOrArray(sameEntityElements, value);

    // uncheck all other columns for all rows with the same entity
    if (value)
    {
        var allPrefixes = ['m_', 'd_', 'n_'];
        for (var i = 0; i < allPrefixes.length; ++i)
        {
            var otherPrefix = allPrefixes[i];
            if (otherPrefix !== prefix)
            {
                var otherElements = formElements[otherPrefix + key];
                setFormValueForSingleElementOrArray(otherElements, false);
            }
        }
    }
}

function uncheckOtherMastersFromSameGroup(obj)
{
    var value = obj.checked;
    var name = obj.name;
    var key = name.substring(2, name.length);

    if (value)
    {
        var formElements = document.forms['body_actions'].elements;
        var dictionary = {};    // contains pairs [entity ID, group number]

        for (var i = 0; i < formElements.length; ++i)
        {
            var element = formElements[i];
            var elementName = element.name;

            if (element.tagName === 'INPUT' && elementName.indexOf('g_') === 0)
            {
            	// hidden input field containing group number
                var elementKey = elementName.substring(2, elementName.length);
                dictionary[elementKey] = element.value;
            }
        }

        var group = dictionary[key];

        // unchecking MASTER column for other entities with the same group
        for (var itemKey in dictionary)
        {
            if (dictionary.hasOwnProperty(itemKey) && itemKey !== key && dictionary[itemKey] === group)
            {
                setFormValueForSingleElementOrArray(formElements['m_' + itemKey], false);
            }
        }
    }
}