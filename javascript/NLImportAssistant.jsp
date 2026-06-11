














	

var LABEL_FIELD_NAME = "label";
var FILE_NAME_FIELD_NAME = "filename";
var ERROR_FIELD_NAME = "error";
var PARENT_FILE_NAME = "parent";


var STYLE_SMALL_TEXT_NOLINK = "smalltextnolink";

var PRIMARY_FILE_STR = "Primary File - ";
var LINKED_FILE_STR = "Linked File (Optional) - ";
var SELECT_STR = "Select...";
var REMOVE_STR = "REMOVE";
var ERROR_STR =  "Error";
var XLS_NOT_SUPPORTED_ERROR_STR = "xls format is not supported, please select a csv file to upload.";



var FILE_TYPE_FIELD_NAME = "filetype";

var FILE_MISSING_TITLE =  "File Missing";
var FILE_MISSING= "Please provide a valid file to upload";
var PRIMARY_FILE_MISSING= "Please provide at least the primary file to upload";
var FILE_UPLOAD_PROGRESS_TITLE = "Processing Your File(s) ...";
var IMPORT_NAME_MISSING= "Import Map Name can not be empty.";
var MISSING_PARENT_FILE_ERROR_STR = "Missing parent file _PARENT_FILE_NAME_ necessary for subrecord file _SUBRECORD_FILE_NAME_.";
var FIELD_MAPPING_SINGLE_JE_WARNING= "You have not mapped a field to be a unique transaction identifier, so this file’s data will be imported as a single journal entry.  If this is incorrect, please go back and correct your mapping and data file.  You can choose the Entry No., External ID, or Internal ID field as a unique identifier.";
var FIELD_MAPPING_NAME_LOOKUP_FORBIDDEN = "To update this record you must map either the Internal ID or the External ID field.";

function showUploadProgress()
{
    nlShowProgress("", FILE_UPLOAD_PROGRESS_TITLE, "document.location='/app/setup/assistants/nsimport/importassistant.nl'; closePopup();");
    setObjectOpacity(20, document.getElementById("div__scrollbody"));
    setDisabledState("next", false);     // disable next button
    disableField(document.getElementById("next"));
}

function NLImportFileUpload_getMappableFileGroups(fileUploadObjId, recType, subRecType)
{
	//var recType = getSelectValue(selectInpt);
    var queryString = "/app/setup/assistants/nsimport/importassistant.nl?importmethod=filegroups&rectype=" + recType;
    if (subRecType)
        queryString += "&recsubtype=" + subRecType;
    var async = false;

    nlXMLRequestURL( queryString, null, null, new Function ("response", "window." + fileUploadObjId + ".updateFileUploadInfo(response);"), async);
}

function NLImportFileUpload(id, fileInfo, bSingleFile, recordType)
{
    this.htmlId = id;
    window[id] = this;
	this.htmlElem = document.getElementById(id+"_div");
    this.recordTypeFileInfo = fileInfo;
    this.bSingleFile = true;

    var formElem = isInsideElemByTagName("FORM", this.htmlElem);
    if (formElem != null)
        formElem.onsubmit = new Function("return window." + this.htmlId + ".validateFiles();");

    this.init(this.recordTypeFileInfo[recordType], bSingleFile);
}

NLImportFileUpload.prototype.init = function(data, bSingleFile)
{
    if (typeof data == "undefined" || data == null)
        this.data = [];
    else
        this.data = data;

    if (typeof bSingleFile != "undefined" && bSingleFile != null)
        this.bSingleFile = bSingleFile;

    if (this.data.length < 2)
        this.bSingleFile = true;
};

NLImportFileUpload.prototype.updateFileUploadInfo = function (response)
{
    var sText = response.getBody();
    var array = sText.split(String.fromCharCode(5));
    var subTypes = array[0].length==0 ? [] : array[0].split(String.fromCharCode(1));
    var subType = array[1];
    this.setSubTypes(subTypes, subType);
    var fileGroupLabels = array[2].length==0 ? [] : array[2].split(String.fromCharCode(1));
    var parentGroups = array[3].length==0 ? [] : array[3].split(String.fromCharCode(1));
    this.setFileGroups(fileGroupLabels, parentGroups);
};

NLImportFileUpload.prototype.setSubTypes = function (subTypes, subType)
{
    var subTypeSlct = document.getElementsByName("recordsubtype")[0];
    deleteAllSelectOptions(subTypeSlct);
    var selected = false;
    if (subTypes.length > 0)
    {
        for (var i = 0; i < subTypes.length; i++)
            addSelectOption(document, subTypeSlct, subTypes[i++], subTypes[i]);
        setSelectValue (subTypeSlct, subType);
    }

    disableSelect (subTypeSlct, subTypes.length==0);
};

NLImportFileUpload.prototype.setFileGroups = function (fileGroupLabels, parentFiles)
{
    var data = [];

	for (var i = 0; i < fileGroupLabels.length; i++)
	{
        data[i] = {};
        data[i][LABEL_FIELD_NAME] = fileGroupLabels[i];
        data[i][FILE_NAME_FIELD_NAME] = "";
        data[i][ERROR_FIELD_NAME] = "";
        data[i][PARENT_FILE_NAME] = parentFiles[i];
	}

	this.init(data, data.length>1);
	this.show();

};

NLImportFileUpload.prototype.show = function()
{
    if (typeof this.htmlElem == "undefined" || this.htmlElem == null)
        return;

    this.updateFileTypeChoices();

    if (this.data.length == 0)
        return;

    var htmlStr = new StringBuffer();

    htmlStr.append("<table class='" + STYLE_SMALL_TEXT_NOLINK + "'> \n");

    for (var i=0; i < this.data.length; i++)
    {
        htmlStr.append("<tr id='" + this.getFileUploadRowElemId(i) + "' ");
        if (this.bSingleFile && i > 0)
            htmlStr.append(" style='display:none'");
        htmlStr.append(">");
        htmlStr.append(this.renderFileUploadLine(i, this.data[i]));
        htmlStr.append("</tr>");
    }
    htmlStr.append("</table> \n");

    this.htmlElem.innerHTML = htmlStr.toString();

};


NLImportFileUpload.prototype.refresh = function(recordType, bSingleFile)
{
    this.init(this.recordTypeFileInfo[recordType], bSingleFile);
    this.show();
};

NLImportFileUpload.prototype.validateFiles = function ()
{
    var primaryFileName = document.getElementById(this.getFileUploadFullNameElemId(0)).value;

    if ( primaryFileName == "undefined" || primaryFileName == null || primaryFileName == "")
    {
        if (this.bSingleFile)
            nlShowMessage (FILE_MISSING, FILE_MISSING_TITLE, MSG_STYLE_INFO);
        else
            nlShowMessage (PRIMARY_FILE_MISSING, FILE_MISSING_TITLE, MSG_STYLE_INFO);

        return false;
    }

    var listMissingParentFiles = "";
    for (var i = 0; i < this.data.length; i++)
    {
        var parentName = this.data[i][PARENT_FILE_NAME];
        if (this.data[i][FILE_NAME_FIELD_NAME] != "undefined" && this.data[i][FILE_NAME_FIELD_NAME] != null && this.data[i][FILE_NAME_FIELD_NAME] != "")
        {
            if (this.isFileMissing(parentName))
            {
                listMissingParentFiles += MISSING_PARENT_FILE_ERROR_STR.replace("_PARENT_FILE_NAME_", parentName).replace("_SUBRECORD_FILE_NAME_", this.data[i][LABEL_FIELD_NAME]) + "<p>\r\n";
            }
        }
    }
    if (listMissingParentFiles != "")
    {
        nlShowMessage (listMissingParentFiles, FILE_MISSING_TITLE, MSG_STYLE_INFO);
        return false;
    }
    showUploadProgress();
    return true;
};

NLImportFileUpload.prototype.updateFileTypeChoices = function()
{
    var elems = document.getElementsByName (FILE_TYPE_FIELD_NAME);

    for (var i=0; i<elems.length; i++)
    {
        var elem = elems.item(i);
        if (elem!=null)
        {
            if (elem.value == "s" && this.bSingleFile )
                elem.checked = true;
            if (elem.value == "m")
                elem.disabled = this.data.length < 2;
        }
    }
};

NLImportFileUpload.prototype.isFileMissing = function(fileName)
{
    if (fileName == null || fileName == "undefined" || fileName =="")
        return false;

    for (var i = 0; i < this.data.length; i++)
    {
        if (this.data[i][LABEL_FIELD_NAME] == fileName && this.data[i][FILE_NAME_FIELD_NAME] != null && this.data[i][FILE_NAME_FIELD_NAME] != "undefined" && this.data[i][FILE_NAME_FIELD_NAME] != "")
            return false;
    }

    return true;
}

NLImportFileUpload.prototype.renderFileUploadLine = function(index, data)
{
    var htmlStr = new StringBuffer();
    var bError = (data[ERROR_FIELD_NAME] != null && data[ERROR_FIELD_NAME] !== "");

    htmlStr.append("<td id='" + this.getFileLabelElemId(index) + "' style='white-space:nowrap;'>");
    htmlStr.append(this.renderLabel(index, data));
    htmlStr.append("</td>");
    htmlStr.append("<td>");
    htmlStr.append("<div class='uir-assistant-file-input-wrapper'>");
    htmlStr.append("<table><tr>");
    var buttonElem = document.getElementById("button_html_elem");
    htmlStr.append(buttonElem.innerHTML);
    htmlStr.append("</tr></table>");
    htmlStr.append("<span>");
    htmlStr.append(this.renderFileUploadControl(index,data[FILE_NAME_FIELD_NAME]));
    htmlStr.append("</span>");
    htmlStr.append("</div>");
    htmlStr.append("</td>");

    htmlStr.append("<td id=\"" +  this.getFileNameElemId(index) + "\"> ");
    htmlStr.append (this.renderFileName(index, data));
    htmlStr.append("</td>");

    htmlStr.append("<td id=\"" +  this.getActionElemId(index) + "\">");
    htmlStr.append(this.renderAction(index,data));
    htmlStr.append("</td>");
    htmlStr.append("<td>");
    var value = bError ? "" : data[FILE_NAME_FIELD_NAME];
    htmlStr.append("<input type=\"hidden\" name=\"" + this.getFileUploadFullNameElemId(index) + "\" id=\"" + this.getFileUploadFullNameElemId(index) + "\" value=\"" + data[FILE_NAME_FIELD_NAME] + "\"/>");
    htmlStr.append("</td>");

    return htmlStr.toString();
};

NLImportFileUpload.prototype.renderFileUploadControl = function(index, value)
{
    return "<input tabindex='-1' type=\"file\" name=\"" + this.getFileUploadElemId(index) + "\" id=\"" + this.getFileUploadElemId(index) + "\" class='uir-assistant-file-input-overlay' value=\"" + value + "\" onchange=\"window." + this.htmlId + ".addFile(" + index + ");\" />";
};


NLImportFileUpload.prototype.updateFileUploadLine = function(index, data)
{
    var elem = document.getElementById(this.getFileLabelElemId(index));
    if (typeof elem != "undefined" && elem != null)
        elem.innerHTML = this.renderLabel(index, data);

    elem = document.getElementById(this.getFileNameElemId(index));
    if (typeof elem != "undefined" && elem != null)
        elem.innerHTML = this.renderFileName(index, data);

    elem = document.getElementById(this.getActionElemId(index));
    if (typeof elem != "undefined" && elem != null)
        elem.innerHTML = this.renderAction(index, data);

    this.updateFilePath(index, data);
};


NLImportFileUpload.prototype.renderLabel = function(index, data)
{
    if (this.bSingleFile)
        return "&nbsp;";
    else
    {
        if (index == 0)
            return PRIMARY_FILE_STR + data[LABEL_FIELD_NAME];
        else
            return LINKED_FILE_STR + data[LABEL_FIELD_NAME];
    }
};

NLImportFileUpload.prototype.renderFileName = function(index, data)
{
    var bError = (data[ERROR_FIELD_NAME] != null && data[ERROR_FIELD_NAME] !== "");
    var htmlStr = "<span class='uir-assistant-file-name' data-error='" + bError + "'>";
	htmlStr += this.getFileName(data[FILE_NAME_FIELD_NAME]);
	htmlStr += "</span>";
    return htmlStr;
};

NLImportFileUpload.prototype.renderAction = function(index, data)
{
    var bError = (data[ERROR_FIELD_NAME] != null && data[ERROR_FIELD_NAME] !== "");
	var htmlStr = "<span class='uir-assistant-file-action' data-error='" + bError + "'>";
	var fileName = data[FILE_NAME_FIELD_NAME];

    if (!bError && fileName != null && data[FILE_NAME_FIELD_NAME] != "")
    {
        htmlStr += "<a href=\"javascript:void(0);\" onclick=\"window." + this.htmlId + ".removeFile(" + index + ");\">" + REMOVE_STR + "</a>";
    }

	htmlStr += "</span>";

    return htmlStr;
};

NLImportFileUpload.prototype.updateFilePath = function(index, data)
{
    var bError = (data[ERROR_FIELD_NAME] != null && data[ERROR_FIELD_NAME] !== "");
    var htmlStr = new StringBuffer();

    var elem = document.getElementById(this.getFileUploadElemId(index));

    if (typeof elem =="undefined" || elem == null)
        return;

    elem.vlaue = data[FILE_NAME_FIELD_NAME];
};

NLImportFileUpload.prototype.setFileName = function(index, data)
{
    if (this.bSingle && index == 0)
        return "&nbsp;";
    else
        return PRIMARY_FILE_STR + data[LABEL_FIELD_NAME];
};

NLImportFileUpload.prototype.selectFile = function (index)
{
    var elem = document.getElementById(this.getFileUploadElemId(index));
    if (typeof elem != "undefined" && elem != null)
        elem.click();
};

NLImportFileUpload.prototype.addFile = function (index)
{
    var elem = document.getElementById(this.getFileUploadElemId(index));
    if (typeof elem == "undefined" || elem == null)
        return;

    if (elem.value.indexOf('.xls') >= 0)
    {
        nlShowMessage (XLS_NOT_SUPPORTED_ERROR_STR, ERROR_STR, MSG_STYLE_WARNING);
        this.removeFile (index);
        NS.form.setChanged(false);
        return false;
    }

    this.data[index][FILE_NAME_FIELD_NAME] = elem.value;
    this.data[index][ERROR_FIELD_NAME] = "";

    elem = document.getElementById(this.getFileUploadRowElemId (index));
    if (typeof elem == "undefined" || elem == null)
        return;

    elem = document.getElementById(this.getFileUploadFullNameElemId (index));
    elem.value = this.data[index][FILE_NAME_FIELD_NAME];

    this.updateFileUploadLine(index, this.data[index]);

    NS.form.setChanged(false);
};

NLImportFileUpload.prototype.removeFile = function (index)
{
     this.data[index][FILE_NAME_FIELD_NAME] = "";

    var elem = document.getElementById(this.getFileUploadElemId(index));
    if (typeof elem != "undefined" && elem != null)
    {
        var parentNode = elem.parentNode;
        parentNode.removeChild(elem);
        parentNode.innerHTML = this.renderFileUploadControl(index, "");
    }

    elem = document.getElementById(this.getFileUploadFullNameElemId(index));
    if (typeof elem != "undefined" && elem != null)
        elem.value = "";

    elem = document.getElementById(this.getFileNameElemId(index));
    if (typeof elem != "undefined" && elem != null)
    {
        elem.innerHTML = "";
    }

    elem = document.getElementById(this.getActionElemId(index));
    if (typeof elem != "undefined" && elem != null)
    {
        elem.innerHTML = "";
    }

    NS.form.setChanged(false);
};


NLImportFileUpload.prototype.toggleFileType = function (bSingle)
{
    this.bSingleFile = bSingle;

    for (var i=0; i < this.data.length; i++)
    {
        var elem = document.getElementById(this.getFileLabelElemId(i));
        if (typeof elem != "undefined" && elem != null)
            elem.innerHTML = this.renderLabel(i, this.data[i]);

        if (i > 0)
        {
            elem = document.getElementById(this.getFileUploadRowElemId(i));
            if (typeof elem != "undefined" && elem != null)
                 elem.style.display = bSingle ? "none" : "";
        }
    }
};

NLImportFileUpload.prototype.getFileUploadRowElemId = function (index)
{
    return this.htmlId + "_flr_" + index;
};


NLImportFileUpload.prototype.getFileLabelElemId = function (index)
{
    return this.htmlId + "_flbl_" + index;
};

NLImportFileUpload.prototype.getFileUploadElemId = function (index)
{
    return this.htmlId + index;
};

NLImportFileUpload.prototype.getFileUploadFullNameElemId = function (index)
{
    return this.htmlId + "_ffn_" + index;
};

NLImportFileUpload.prototype.getFileNameElemId = function (index)
{
    return this.htmlId + "_fn_" + index;
};

NLImportFileUpload.prototype.getActionElemId = function (index)
{
    return this.htmlId + "_ac_" + index;
}

NLImportFileUpload.prototype.getFileName = function (fileName)
{
    if (typeof fileName == "undefined" || fileName == null)
        return "";

    var lastSlash = fileName.lastIndexOf("/");
    if (lastSlash == -1)
        lastSlash = fileName.lastIndexOf("\\");
    if (lastSlash >= 0)
        fileName  = fileName.substring(lastSlash +1);

    return fileName;
};



function isInsideElemByName (name, element)
{
    var elem = element;

    while(elem != null && elem != elem.parentNode)
    {
        if (elem.name == name)
            return elem;
        elem = elem.parentNode;
    }
    return null;
}

function isInsideElemByTagName (tagName, element)
{
    var elem = element;

    while(elem != null && elem != elem.parentNode)
    {
        if (elem.tagName == tagName)
            return elem;
        elem = elem.parentNode;
    }
    return null;
}

function attachFileMappingValidation(primeFileKeyCol, linkedFileKeyCol, numLinkedFiles)
{
    var formElem = isInsideElemByTagName("FORM", $$(primeFileKeyCol));
    if (formElem != null)
        formElem.onsubmit = new Function("return validateFileMapping(\""+ primeFileKeyCol + "\", \"" + linkedFileKeyCol + "\"," + numLinkedFiles + ");");
}

var FILE_MAPPING_ERROR_POPUP_TITLE = "File Mapping Error";
var FILE_MAPPING_ERROR_POPUP_MESSAGE = "You must select a key column for each file in order to proceed.";

function validateFileMapping(primeFileKeyCol, linkedFileKeyCol, numLinkedFiles)
{
    //todo add the following validations
    //foreign key != primary key
    //each file linked to parent -- todo -- not here, at the very first page of wizzard

    var bValid = true;
    var keyCol = getSelectValue($$(primeFileKeyCol));
    if(keyCol == "")
    {
        markFileColumnSelect(primeFileKeyCol, true);
        bValid = false;
    }
    else
        markFileColumnSelect(primeFileKeyCol, false);

    for (var i = 1; i <= numLinkedFiles; i ++)
    {
        var elemName = linkedFileKeyCol + i;
        keyCol = getSelectValue($$(elemName));

        if(keyCol == "")
        {
            markFileColumnSelect(elemName, true);
            bValid = false;
        }
        else
            markFileColumnSelect(elemName, false);
    }

    if (!bValid)
        nlShowMessage(FILE_MAPPING_ERROR_POPUP_MESSAGE, FILE_MAPPING_ERROR_POPUP_TITLE, MSG_STYLE_WARNING);

    return bValid;
}

function markFileColumnSelect(keyColName, bMark)
{
    var spanId = keyColName + "_e";

    var span = document.getElementById(spanId);
    if (span != null)
    {
        span.style.display = bMark ? "" : "none";
    }
    else if (bMark)
    {
        var elem = document.getElementsByName(keyColName)[0];
        if (elem == null)
            return;

        span = document.createElement("span");
        span.id = spanId;
		span.classList.add('uir-assistant-select-error');
        elem.parentNode.insertBefore(span, elem);
    }
}

function NLDragDropListener () {}

NLDragDropListener.prototype.dropDestName = "";

NLDragDropListener.prototype.onEvent = function (evntId, evnt)
{
    if (evnt.type == "mousemove" )
        this.mouseMove(evnt);
    else if (evnt.type == "mouseup")
        this.mouseUp(evnt);
};

NLDragDropListener.prototype.setupDropIndicator = function (evnt)
{
    evnt = getEvent(evnt);
    var target = getEventTarget(evnt);
    var dropDest = isInsideElemByName(this.dropDestName, target);
    if ( dropDest == null)
        return;

    if (this.dropDest != null)
        window[IMPORT_MAPPER_ID].highlightCell(this.dropDest, false);

    this.dropDest = dropDest;
    window[IMPORT_MAPPER_ID].highlightCell(this.dropDest, true);

};

NLDragDropListener.prototype.setupDragIndicator = function (evnt)
{
    evnt = getEvent(evnt);

    //todo move to nltree.jsp, this should be the default drag indicator
    var nodeStyle = evnt.dragContent.nodeStyle;

    var dragDiv = document.createElement("div");
    dragDiv.classList.add("dragbox", "uir-tree-drag-box");

	var img = document.createElement("img");
	img.classList.add('uir-assistant-import-drag-img');
	img.src = nodeStyle[NODE_STYLE_IMAGE];

	var label = document.createElement("span");
	label.classList.add("uir-tree-drag-box-label");
	label.textContent = nodeStyle[NODE_STYLE_LABEL];

	dragDiv.appendChild(img);
	dragDiv.appendChild(label);

    evnt.dragDiv = dragDiv;
};

NLDragDropListener.prototype.mouseMove = function (evnt)
{
    if (evnt.initDragDrop)
        this.setupDragIndicator(evnt);

    this.setupDropIndicator(evnt);
};

NLDragDropListener.prototype.mouseUp = function (evnt)
{
};


function NLColDragDropListener ()
{
    this.dropDestName = FLG_COL_DROP_DEST;
}
NLColDragDropListener.prototype = new NLDragDropListener;

NLColDragDropListener.prototype.mouseUp = function (evnt)
{
    evnt = getEvent(evnt);
    var target = getEventTarget(evnt);

    if (this.dropDest != null)
        window[IMPORT_MAPPER_ID].highlightCell(this.dropDest, false);
    this.dropDest = null;

    var dropDest = isInsideElemByName(this.dropDestName, target);
    if ( dropDest == null)
        return;

    var ids = evnt.dragContent.nodeId.split(String.fromCharCode(8));
    var rowElem = isInsideElemByTagName("TR", target);
    var index = rowElem.rowIndex;
    window[IMPORT_MAPPER_ID].updateMappingRow (window[IMPORT_MAPPER_ID].colTree.id, index, ids[0], ids[1]);
};

function NLFldDragDropListener ()
{
    this.dropDestName = FLG_FLD_DROP_DEST;
}
NLFldDragDropListener.prototype = new NLDragDropListener;

NLFldDragDropListener.prototype.mouseMove = function (evnt)
{
    evnt = getEvent(evnt);

    if (evnt.initDragDrop)
    {
        var ids = evnt.dragContent.nodeId.split(String.fromCharCode(8));

        if (window[IMPORT_MAPPER_ID].isFieldMapped(ids[0], ids[1]))
            evnt.status = E_RESPONSE_CANCEL;  // cannot drag the node
        else
            this.setupDragIndicator(evnt);
    }
    else
        this.setupDropIndicator(evnt);
};

NLFldDragDropListener.prototype.mouseUp = function (evnt)
{
    evnt = getEvent(evnt);
    var target = getEventTarget(evnt);

    if (this.dropDest != null)
        window[IMPORT_MAPPER_ID].highlightCell(this.dropDest, false);
    this.dropDest = null;

    var dropDest = isInsideElemByName(this.dropDestName, target);
    if ( dropDest == null)
        return;

    var ids = evnt.dragContent.nodeId.split(String.fromCharCode(8));
    var rowElem = isInsideElemByTagName("TR", target);
    var index = rowElem.rowIndex;
    var errMsg = window[IMPORT_MAPPER_ID].setField (evnt.dragContent.nodeId, index);
};


function NLColInitListener (){}

NLColInitListener.prototype.onEvent = function (evntId, tree)
{
    tree.contentProvider = new NLImportTreeContentProvider(tree.id);
    tree.content = tree.contentProvider.content;
    tree.nodeStyleProvider = new NLNodeStyleProvider(tree.id);
};


function NLFldInitListener ()  {}

NLFldInitListener.prototype.onEvent = function (evntId, tree)
{
    tree.contentProvider = new NLImportFieldTreeContentProvider(tree.id);
    tree.content = tree.contentProvider.content;
    tree.nodeStyleProvider = new NLNodeStyleProvider(tree.id);
};


function NLImportTreeContentProvider (treeId)
{
    this.contentSrcName = treeId + "_data";
    this.content =  new NLImportTreeContent();
}

NLImportTreeContentProvider.prototype.getNodeContent = function (id, callbackFunc)
{
    this.doGetNodeContent(id, callbackFunc);
};

NLImportTreeContentProvider.prototype.doGetNodeContent = function (id, callbackFunc)
{
    var response = [];

    var contentSrc = window[this.contentSrcName];

    var ids = id.split(".");

    var node = contentSrc[ids[0]];

    response[0] = node[NODE_FIELDS];

    this.callbackFunc = callbackFunc;
    eval( "this.callbackFunc( response )" );
};

NLImportTreeContentProvider.prototype.doHandleNodeContentResponse = function (response, content)
{
    content.nodes = response;
    return content;
};

function NLImportFieldTreeContentProvider (treeId)
{
    this.base = NLImportTreeContentProvider;
    this.base(treeId);
}

NLImportFieldTreeContentProvider.prototype = new NLImportTreeContentProvider;

NLImportFieldTreeContentProvider.prototype.getNodeContent = function (id, callbackFunc)
{
    var response = [];

    var contentSrc = window[this.contentSrcName];

    var nodeInfo = id.split(String.fromCharCode(8));
    if (nodeInfo.length == 2)
    {
        var node = contentSrc[id];
        if (node[NODE_DENORMALIZED] != "T")
            return this.doGetNodeContent(id, callbackFunc);
        else
        {
            // prepare folder nodes for denorma fields;
            //prepare a seconde level of nodes such as address 1, address 2 ... address 5
            var lineNodes = [];
            for (var i = 0; i < node[NODE_NUM_LINES]; i++)
            {
                var lineNode = [];
                for (var j = 0; j <= NODE_SECONDARY_ID; j++)
                    lineNode[j] = node[j];

                lineNode[NODE_ID] += String.fromCharCode(8) + parseInt(i);        //A*fld*0
                lineNode[NODE_TITLE] += " " + parseInt(i+1);
                lineNode[NODE_PATH] = lineNode[NODE_PATH] + "." + lineNode[NODE_ID];
                lineNodes[i] = lineNode;
            }
            response[0] = lineNodes;
        }
    }
    else
    {
        lineNodes = [];
        var lineNum = parseInt(nodeInfo[nodeInfo.length - 1]);

        node = contentSrc[nodeInfo[0] + String.fromCharCode(8) + nodeInfo[1]];
        var allNodes = node[NODE_FIELDS];

        for (i = 0; i < allNodes.length/node[NODE_NUM_LINES]; i++)
        {
            lineNodes[i] = allNodes[lineNum + i*node[NODE_NUM_LINES]];
            var nodePath = lineNodes[i][NODE_PATH].split(".");
            lineNodes[i][NODE_PATH] = nodePath[0] + "." + id + "." + nodePath[1];
        }
        response[0] = lineNodes;
    }
    this.callbackFunc = callbackFunc;
    eval( "this.callbackFunc( response )" );
};

NLImportFieldTreeContentProvider.prototype.createNode = function (path, callbackFunc)
{
    var response = [];

    var contentSrc = window[this.contentSrcName];

    var hierarchy = path.split(".");
    var id = hierarchy[hierarchy.length -1];
    var nodeInfo = id.split(String.fromCharCode(8));
    if (nodeInfo.length == 2)
    {
        var node = contentSrc[id];
        if (node[NODE_NUM_LINES] >=99)
        {
            nlShowMessage("You can only add up to 99 nodes for a given sublist.",
                          "WARNING",
                          MSG_STYLE_WARNING);
            return;
        }
        if (node[NODE_DENORMALIZED] == "T")
        {

            var numLines = node[NODE_NUM_LINES];
            var numFields = node[NODE_FIELDS].length / numLines;

            // insert a new line
            for (var i = numFields - 1; i >= 0; i--)
            {
                var field = node[NODE_FIELDS][i*numLines + numLines - 1]; //last line of the field
                var newLineField = new Array();
                
                for (var j = 0; j < field.length; j++)
                {
                    var ids = field[NODE_ID].split("");
                    var idx = ids[1].split(":");
                    idx[idx.length - 1] = numLines;
                    ids[1] = idx.join(":");
                    id = ids.join("");

                    if ( j == NODE_ID || j == NODE_PATH || j == NODE_ACTION)
                        newLineField[j] = field[j].replace(field[NODE_ID], id);
                    else
                        newLineField[j] = field[j];
                }
                node[NODE_FIELDS].splice(i*numLines + numLines, 0, newLineField);
            }

            // prepare folder nodes for denorma fields;
            node[NODE_NUM_LINES]++;

            var lineNode = [];
            for (var j = 0; j <= NODE_SECONDARY_ID; j++)
                lineNode[j] = node[j];

            lineNode[NODE_ID] += String.fromCharCode(8) + (parseInt(node[NODE_NUM_LINES]) - 1);        //A*fld*0
            lineNode[NODE_TITLE] += " " + parseInt(node[NODE_NUM_LINES]);
            lineNode[NODE_LAST] = "1";
            lineNode[NODE_PATH] = lineNode[NODE_PATH] + "." + lineNode[NODE_ID];

            response[0] = lineNode;
        }
    }
    this.callbackFunc = callbackFunc;
    eval( "this.callbackFunc( response )" );
};


function NLImportTreeContent (treeId) { }


NLImportTreeContent.prototype.getNodes = function NLImportTreeContent_getNodes(i)
{
    return this.nodes[i];
};

function NLNodeStyleProvider (treeId)
{
    this.treeId = treeId;
}

NLNodeStyleProvider.prototype.getNodeStyle = function (nodeId)
{
    if (typeof window[IMPORT_MAPPER_ID] == "undefined" || window[IMPORT_MAPPER_ID] == null)
        return;

    return window[IMPORT_MAPPER_ID].getNodeStyle(this.treeId, nodeId);
};


// addtional info for each cat node (file/list def)
var NODE_FIELDS = 8;

// addtional info for each ns field cat node (list def)
var NODE_DENORMALIZED = 9; // if the fields are denormalized (has name_1, name_2, name_3, addr_1, addr_2, addr_3 etc)
var NODE_NUM_LINES = 10; // the number of lines if the field is denormalized

// additional info for each tree leaf node  (col/field def)
var NODE_REQUIRED = 8;
var NODE_CANNOT_DELETE_IF_REQUIRED = 9;
//var NODE_REFERENCE_TYPE = 9
var NODE_DEFATULT = 10;
var NODE_SELECT = 11;
var NODE_CUSTOMFIELD = 12;

var DEFAULT_NUM_ROWS = 11;
var ROW_HEIGHT = 30;

// column index in the mapper table
var COL_LEFT_MARGIN = 0;
var COL_EDIT_ICON = 1;
var COL_COLUMN = 2;
var COL_ARROW = 3;
var COL_FIELD = 4;
var COL_DELETE = 5;
var COL_RIGHT_MARGIN = 6;

var MAPPING_STATUS_NORMAL = 0;
var MAPPING_STATUS_EMPTY = 1;
var MAPPING_STATUS_ERROR = 2;


var FLG_COL_DROP_DEST = "col_drop_dest";
var FLG_FLD_DROP_DEST = "fld_drop_dest";

var HIGHLIGHT_CELL_BG_COLOR = "#dddddd";

var IMPORT_MAPPER_ID = "mapperpane" + "_obj";

var SUB_LIST_LINE_NUM_SEPERAROR = ":";

var FIELD_MAPPING_ERROR_POPUP_TITLE = "Field Mapping Error";
var FIELD_MAPPING_ERROR_POPUP_MESSAGE = "<p>One or more of your fields or the NetSuite fields have not been mapped on the mapping panel.</p> <p>Required NetSuite fields must be mapped in order to proceed with import.</p><p>Other fields must either be mapped or be removed from the mapping panel.</p>";
var FIELD_MAPPING_TXN_ERROR_POPUP_MESSAGE = "You must map one of the following NetSuite fields to a column in your CSV file to be a unique identifier:  External ID, Internal ID, or a document number field such as Order # or Invoice #.";
var FIELD_MAPPING_NONE_MAPPED_POPUP_MESSAGE  = "You must map at least one NetSuite field for import.";

var REMOVE_SUBLIST_FIELDS_MSG = "When you remove the required field _FIELD_NAME_ for sublist _LIST_NAME_, all fields mapping for that sublist will also be removed.";
var ADD_REQUIRED_SUBLIST_FIELDS_MSG = "When you map field _FIELD_NAME_ for sublist _LIST_NAME_, you must map all required fields for the sublist.";
var CANNOT_REPLACE_SUBLIST_FIELD = "You cannot replace the mapping of required field _FIELD_NAME_ on sublist _LIST_NAME_ with a mapping to the non-required field _FIELD_NAME2_ from that sublist. You must add the non-required field _FIELD_NAME2_ as a separate field mapping.";

function CreateMapperLayout (id, machine, colData, fldData, colTree, listTree, readOnly)
{
    window[IMPORT_MAPPER_ID]= new NLImportFieldMapper(id, machine, colData, fldData, colTree, listTree);
    if (readOnly == true)
        window[IMPORT_MAPPER_ID].readOnly = readOnly;
    window[IMPORT_MAPPER_ID].show();
}


function NLImportFieldMapper (id, machine, colData, fldData, colTree, listTree)
{
    this.htmlId = id;
    this.id = id + "_obj";
    window[id] = this;
    this.machine = machine;
    this.colData = colData;
    this.fldData = fldData;
    this.colTree = colTree;
    this.listTree = listTree;
    this.rowMachineMap = [];     // map UI rows to machine lines

    this.mappedCols = {};
    this.mappedFlds = {};

    var linearray = getLineArray(this.machine.name);
    if (linearray.length == 0)
        this.addRequiredFieldsToMachine();
    else
        this.setupMapping ();

    this.setActiveLine(-1);

    
    this.arrowLeft = document.createElement("img");
    this.arrowLeft.src = "/images/icons/import/arrow_l.gif";
    this.arrowLeft.border = 0;
    this.arrowLeft.style.display = "none";
    this.arrowRight = document.createElement("img");
    this.arrowRight.src = "/images/icons/import/arrow_r.gif";
    this.arrowRight.border = 0;
    this.arrowRight.style.display = "none";
    this.readOnly = false;
}

NLImportFieldMapper.prototype.reset = function()
{
    if (confirm("Are you sure you want to restore the saved mapping or recover auto mapped fields?"))
        window.location.reload();
};


NLImportFieldMapper.prototype.show = function()
{
    var containerElem = document.getElementById(this.htmlId);
    if (containerElem == null)
        return;

    var divElem = document.createElement('div');
    containerElem.appendChild (divElem);

    var tableElem = document.createElement('table');
    tableElem.cellPadding = 0;
    tableElem.cellSpacing = 0;
    tableElem.style.width = "100%";
    tableElem.id = this.getTableElemId();
    divElem.appendChild(tableElem);

    var linearray = getLineArray(this.machine.name);
    var rows = this.readOnly ? linearray.length : (Math.max(linearray.length + 1, DEFAULT_NUM_ROWS));
    for(var i=0; i<rows; i++)
    {
        var linedata = null;
        if (i < linearray.length)
            linedata = splitIntoCells( linearray[i] );

        this.renderMappingLine(i, linedata, tableElem);
    }

    this.setActiveLine(linearray.length, true);
};

NLImportFieldMapper.prototype.renderMappingLine = function (index, linedata, tableElem)
{
    var file = null;
    var col = null;
    var list = null;
    var field = null;
    var defaultVal = null;
    var refType = null;
    if (linedata != null)
    {
        file = this.getFieldValue(linedata, 'mf_file');
        col = this.getFieldValue(linedata, 'mf_col');
        list = this.getFieldValue(linedata, 'mf_list');
        field = this.getFieldValue(linedata, 'mf_fld');
        defaultVal = this.getFieldValue(linedata, 'mf_default_label');
        refType = this.getFieldValue(linedata, 'mf_ref');
        if (typeof defaultVal == "undefined" || defaultVal == null || defaultVal == "")
            defaultVal = this.getFieldValue(linedata, 'mf_default');
    }

    if (!tableElem)
        tableElem = document.getElementById (this.getTableElemId());

    var rowElem = null;
    if (index >= tableElem.rows.length)
    {
        rowElem = tableElem.insertRow(tableElem.rows.length);         //create row
        rowElem.style.borderBottom='solid 1px #999999';
        rowElem.style.height= ROW_HEIGHT + 'px';
        rowElem.className = "bg";

        rowElem.onclick = function () { window[IMPORT_MAPPER_ID].setActiveLine(this.rowIndex, true); };
        //add left padding cell
        var cellElem = document.createElement("td");
        cellElem.style.width = '10px';
        cellElem.style.border = '0px';
        rowElem.appendChild(cellElem);

        //add edit control cell
        cellElem = document.createElement("td");
        cellElem.style.borderBottom='solid 1px #999999';
        if(!this.readOnly)
            cellElem.style.width = '20px';
        else
            cellElem.style.width = '0px';
        cellElem.align = 'center';
        rowElem.appendChild(cellElem);

        //add column header cell
        cellElem = document.createElement("td");
        cellElem.style.width = '35%';
        cellElem.style.borderBottom='solid 1px #999999';
        cellElem.style.padding = "3px";
        cellElem.className='text';
        rowElem.appendChild(cellElem);
        //add arrow cell
        cellElem = document.createElement("td");
        cellElem.style.borderBottom='solid 1px #999999';
        cellElem.style.width = '30px';
        cellElem.align = 'center';
        var arrowElem = document.createElement("span");
        arrowElem.classList.add('uir-assistant-import-arrow');
		arrowElem.setAttribute('data-status', 'normal');
        cellElem.appendChild(arrowElem);
        rowElem.appendChild(cellElem);
        //add field name cell
        cellElem = document.createElement("td");
        cellElem.style.width = '35%';
        cellElem.style.borderBottom='solid 1px #999999';
        cellElem.style.padding = "3px";
        cellElem.className='text';
        rowElem.appendChild(cellElem);
        //add delete control cell
        cellElem = document.createElement("td");
        cellElem.style.borderBottom='solid 1px #999999';
        if(!this.readOnly)
            cellElem.style.width = '20px';
        else
            cellElem.style.width = '0px';
        cellElem.align = 'center';
        rowElem.appendChild(cellElem);
        //add right padding cell
        cellElem = document.createElement("td");
		cellElem.setAttribute("align", "right");
        cellElem.style.width = '10px';
        cellElem.style.border = '0px';
        rowElem.appendChild(cellElem);

        var id = new Date().getTime();
        rowElem.id = id;
        this.rowMachineMap[rowElem.rowIndex] = id;
    }
    else
        rowElem = tableElem.getElementsByTagName('tbody')[0].getElementsByTagName('tr')[index];

    if (!this.readOnly)
        this.renderEditColumn(rowElem.rowIndex, rowElem.getElementsByTagName('td')[COL_EDIT_ICON], file, col, list, field);

    this.renderColName(rowElem.rowIndex, rowElem.getElementsByTagName('td')[COL_COLUMN], file, col, defaultVal, refType);

    this.renderMappingRowStatus(rowElem.rowIndex, linedata==null?MAPPING_STATUS_EMPTY : MAPPING_STATUS_NORMAL);

    this.renderFieldName(rowElem.rowIndex, rowElem.getElementsByTagName('td')[COL_FIELD], list, field);

    if (!this.readOnly)
        this.renderDeleteColumn(rowElem.getElementsByTagName('td')[COL_DELETE], file, col, list, field);
};

NLImportFieldMapper.prototype.updateCurrentMappingLine = function ()
{
    var linearray = getLineArray(this.machine.name);
    var linedata = splitIntoCells( linearray[this.activeLine] );
    this.renderMappingLine (this.activeLine, linedata);
};


NLImportFieldMapper.prototype.renderEditColumn = function (rowIndex, tdElem, file, col, list, field)
{
    var bLink = false;
    if(typeof list != "undefined" && typeof field != "undefined" && list != null && field != null &&  list != "" && field != "")
        bLink = true;

    var htmlStr = new StringBuffer();
    if (bLink)
    {
        htmlStr.append("<a href='javascript:void(0)' onclick=\"javascript:window."+ this.id + ".editField(this," + rowIndex + ", '"+ file + "', '" + col + "', '" + list + "', '" + field + "');\">");
        htmlStr.append("<span class='uir-assistant-import-edit' data-enabled='true' title='" + "Edit" + "'></span>");
        htmlStr.append("</a>");
    }
    else
        htmlStr.append("<span class='uir-assistant-import-edit' data-enabled='false'  title='" + "Edit" + "'></span>");

    tdElem.innerHTML = htmlStr.toString();
};

NLImportFieldMapper.prototype.renderColName = function (rowIndex, tdElem, file, col, defaultVal, refType)
{
    tdElem.name = FLG_COL_DROP_DEST;
    if (typeof defaultVal != "undefined" && defaultVal != null && defaultVal != "")
    {
        tdElem.innerHTML = "<i>" + escapeHTML(defaultVal) + "</i>";
        return;
    }

    if (typeof col == "undefined" || col == null || col == "")
        col = "&nbsp;";
    else
    {
        var keyName = this.getDataSourceKeyNames(this.colTree.id, file, col)[0];
        if (!this.readOnly)
            col = this.renderLabelWithToolTip (this.colData[keyName][NODE_TITLE], col, true);
        else
        {
            var title = "";
            if (typeof refType == "string")
            {
                var refTypeLabel = "";
                if (refType == "name")
                    refTypeLabel = "Names";
                else if (refType == "internalId")
                    refTypeLabel = "Internal ID";
                else if (refType == "externalId")
                    refTypeLabel = "External ID";

                if (refTypeLabel != "")
                    title = "Choose Reference Type" + ": " + refTypeLabel;
            }
            col = "<span title='" + title + "'>" + escapeHTML(col) + "</span>";
        }
    }

    tdElem.innerHTML = col;
};


NLImportFieldMapper.prototype.renderMappingRowStatus = function (rowIndex, status)
{
    var tableElem = document.getElementById (this.getTableElemId());
    var rowElem =  tableElem.rows[rowIndex];

    var statusElem = rowElem.getElementsByTagName('td')[COL_ARROW];
    var arrowElem = statusElem.querySelector('.uir-assistant-import-arrow');

    if (status == MAPPING_STATUS_NORMAL)
	    arrowElem.setAttribute('data-status', 'normal');
    else if (status == MAPPING_STATUS_EMPTY)
	    arrowElem.setAttribute('data-status', 'empty');
    else if (status == MAPPING_STATUS_ERROR)
	    arrowElem.setAttribute('data-status', 'error');
};



NLImportFieldMapper.prototype.renderFieldName = function (rowIndex, tdElem, list, field)
{
    var label;
    var bCanDrop = true;

    var listFieldDef = this.getListFieldDef(list,field);
    var listDef = listFieldDef[0];
    var fieldDef = listFieldDef[1];

    if (typeof fieldDef != "undefined" && fieldDef != null && fieldDef != "")
    {
        bCanDrop = this.isFieldRequired(field, fieldDef) ? false : true;
        var title = listDef[5];
        if (listDef[NODE_DENORMALIZED] == "T")
        {
            var fileInfo = fieldDef[NODE_ID].split(String.fromCharCode(8));
            var lineNum = fileInfo[1].split(SUB_LIST_LINE_NUM_SEPERAROR)[1];
            title += " " + parseInt(lineNum*1+1);
        }
        label = this.renderLabelWithToolTip (title, fieldDef[NODE_TITLE],false);

        
        tdElem.fldId = this.getDataSourceKeyNames (this.listTree.id, list, field)[1];
    }
    else
    {
        //if (rowIndex <= this.machine.getMaxIndex())
        //    bCanDrop = true;
        label = "&nbsp;";
    }

    tdElem.name = bCanDrop ? FLG_FLD_DROP_DEST : "";


    tdElem.innerHTML = label;
};

NLImportFieldMapper.prototype.renderDeleteColumn = function (tdElem, file, col, list, field)
{
    var bLink = true;

    if( file == null && col == null && list == null && field == null)
        bLink = false;
    else
    {
        var listFieldInfo = this.getListFieldDef (list, field);
        var listDef = listFieldInfo[0];
        var fieldDef = listFieldInfo[1];
        if (fieldDef != null && this.isFieldRequired(field, fieldDef) && !this.isOpportunityItemSingleFile(file, list, field))
            bLink = false;
    }

    var htmlStr = new StringBuffer();
    if (bLink)
    {
        htmlStr.append("<a href='javascript:void(0)' onclick=\"javascript:window."+ this.id + ".deleteMappingRow(this, '"+ file + "', '" + col + "', '" + list + "', '" + field + "');\">");
        htmlStr.append("<span class='uir-assistant-import-delete' data-enabled='true' title='" + "Delete" + "'></span>");
        htmlStr.append("</a>");
    }
    else
        htmlStr.append("<span class='uir-assistant-import-delete' data-enabled='false' title='" + "Delete" + "'></span>");

    tdElem.innerHTML = htmlStr.toString();
};


NLImportFieldMapper.prototype.renderLabelWithToolTip  = function (val1, val2,isCol)
{
    if (isCol)
        return "<span title='" + val1 + ": " + val2 + "'>" + escapeHTML(val2) + "</span>";
	var fldName = val1 == null || val1 == "" ? val2 : val1 + " : " + val2;
	return "<span title='" + fldName + "'>" + escapeHTML(fldName) + "</span>";
};

NLImportFieldMapper.prototype.renderActiveLineIndicator  = function ()
{
    var tableElem = document.getElementById (this.getTableElemId());
    var rows = tableElem.getElementsByTagName('tbody')[0].getElementsByTagName('tr');
    var bEnable = false;
    if (this.activeLine >=0 && this.activeLine < rows.length)
    {
        var rowElem = rows[this.activeLine];
        if (this.arrowLeft.parentNode != null)
            this.arrowLeft.parentNode.removeChild(this.arrowLeft);
        rowElem.getElementsByTagName('td')[COL_LEFT_MARGIN].appendChild(this.arrowLeft);
        if (this.arrowRight.parentNode != null)
            this.arrowRight.parentNode.removeChild(this.arrowRight);
        rowElem.getElementsByTagName('td')[COL_RIGHT_MARGIN].appendChild(this.arrowRight);
        bEnable = true;
    }
    this.arrowLeft.style.display = bEnable ? "" : "none";
    this.arrowRight.style.display = bEnable ? "" : "none";
};

NLImportFieldMapper.prototype.highlightCell = function (cellElem, bHighLight)
{
    if (bHighLight)
        cellElem.style.backgroundColor = HIGHLIGHT_CELL_BG_COLOR;
    else
        cellElem.style.backgroundColor = "";
};


NLImportFieldMapper.prototype.setActiveLine = function (index, bRender)
{
    var oldActiveLine = -1;
    if (this.activeLine != index)
    {
        var linearray = getLineArray(this.machine.name);

        if (index >= 0 && index <= linearray.length)
        {
            oldActiveLine = this.activeLine;

            this.activeLine = index;
            this.machine.setMachineIndex(index + 1);
        }
    }

    if (bRender)
    {
        this.renderActiveLineIndicator();

        var tableElem = document.getElementById(this.getTableElemId());
        var rowElem;
        if (oldActiveLine >= 0 && oldActiveLine < tableElem.rows.length)
        {
            rowElem  = tableElem.rows[oldActiveLine];
            rowElem.className = "bg";
        }
        if (this.activeLine >= 0 && this.activeLine < tableElem.rows.length)
        {
            rowElem = tableElem.rows[this.activeLine];
            rowElem.className = "bglt";
        }

        
        var rowOffset = index * ROW_HEIGHT;  
        var containerElem = document.getElementById(this.htmlId);

        if (rowOffset < containerElem.scrollTop)
            containerElem.scrollTop = rowOffset;
        else if (rowOffset + ROW_HEIGHT > containerElem.scrollTop + containerElem.clientHeight)
            containerElem.scrollTop += rowOffset + ROW_HEIGHT - containerElem.scrollTop - containerElem.clientHeight;
    }
};

NLImportFieldMapper.prototype.setColumn = function (colId)
{
    var nodeInfo = colId.split(String.fromCharCode(8));
    this.updateMappingRow (this.colTree.id, this.activeLine, nodeInfo[0], nodeInfo[1]);
};

NLImportFieldMapper.prototype.setField = function (fldId, tableRowIdx)
{
    var nodeInfo = fldId.split(String.fromCharCode(8));

    var bCanDrop = true;
    var oldList = "";
    var oldListDef = null;
    var oldFieldDef = null;
    var oldSubListRowIdx = -1;
    var lisFieldtDefs = this.getListFieldDef(nodeInfo[0], nodeInfo[1]);
    var newListDef = lisFieldtDefs[0];
    var newFieldDef = lisFieldtDefs[1];
    var newSubListRowIdx =(newListDef[NODE_DENORMALIZED] == "T") ? nodeInfo[1].split(SUB_LIST_LINE_NUM_SEPERAROR)[1] : -1;
    var lineLoaded = false;

    if(typeof tableRowIdx == "undefined" || tableRowIdx == null)
        tableRowIdx = this.activeLine;

    var linearray = getLineArray(this.machine.name);
    if (tableRowIdx < 0 || tableRowIdx > linearray.length)
        return;

    if (tableRowIdx < linearray.length) 
    {
        
        this.machine.loadline(tableRowIdx + 1);
        lineLoaded = true; 
        oldList = this.getCurrentLineFieldValue('mf_list');
        var field = this.getCurrentLineFieldValue('mf_fld');
        if (oldList != null && oldList.length != 0 )  
        {
            var listFieldDefs = this.getListFieldDef(oldList, field);
            oldListDef = listFieldDefs[0];
            oldFieldDef = listFieldDefs[1];
            if (oldListDef[NODE_DENORMALIZED] == "T")
                oldSubListRowIdx = field.split(SUB_LIST_LINE_NUM_SEPERAROR)[1];
            bCanDrop = !(this.isFieldRequired(oldFieldDef[NODE_ID].split(String.fromCharCode(8))[1], oldFieldDef));
        }
    }
    if (newListDef[NODE_DENORMALIZED] == "T" || (oldListDef != null && oldListDef[NODE_DENORMALIZED] == "T"))
    {
        if (oldListDef == newListDef && newSubListRowIdx == oldSubListRowIdx && oldFieldDef[NODE_REQUIRED] == "T")
        {
            
            alert(CANNOT_REPLACE_SUBLIST_FIELD.replace("_FIELD_NAME_", oldFieldDef[NODE_TITLE]).replace("_LIST_NAME_", oldListDef[NODE_TITLE] + " " + (parseInt(oldSubListRowIdx)+1)).replace(/_FIELD_NAME2_/g, newFieldDef[NODE_TITLE]));
            if (lineLoaded)
                this.machine.updateLineData();
            return;
        }
    }

    if (!bCanDrop)
    {
        var linearray = getLineArray(this.machine.name);
        if (lineLoaded)
            this.machine.updateLineData();
        this.setActiveLine(linearray.length, true);
        return;
    }
    var msg = "";
    if ( this.isMachineList(oldListDef) && oldFieldDef[NODE_REQUIRED] == "T")
    {
        var listLabel = oldListDef[NODE_TITLE] + (oldSubListRowIdx != -1 ? (" " + (parseInt(oldSubListRowIdx)+1)) : "");
        msg += REMOVE_SUBLIST_FIELDS_MSG.replace("_LIST_NAME_", listLabel).replace("_FIELD_NAME_", oldFieldDef[NODE_TITLE]) + "\n";
    }
    if ( this.isMachineList(newListDef) && this.canMapRequiredSubListFields(nodeInfo[0], newSubListRowIdx) && (newFieldDef[NODE_REQUIRED] == "T" ? this.getNumOfdRequiredFieldsInList(newListDef)>1 :true))
    {
        var listLabel = newListDef[NODE_TITLE] + (newSubListRowIdx != -1 ? (" " + (parseInt(newSubListRowIdx)+1)) : "");
        msg += ADD_REQUIRED_SUBLIST_FIELDS_MSG.replace("_LIST_NAME_", listLabel).replace("_FIELD_NAME_", newFieldDef[NODE_TITLE]) + "\n";
    }
    if (msg.length > 0)
    {
        msg += "Do you want to continue?" + "\n";
        if (!confirm(msg))
        {
            if (lineLoaded)
                this.machine.updateLineData();
            return;
        }
    }

    if (tableRowIdx != this.activeLine)
        this.setActiveLine(tableRowIdx, true);

    this.updateMappingRow (this.listTree.id, this.activeLine, nodeInfo[0], nodeInfo[1]);

    if(this.isMachineList(oldListDef) && oldFieldDef[NODE_REQUIRED] == "T")
        this.deleteSubListFields(oldList, oldSubListRowIdx);
    if(this.isMachineList(newListDef) && this.canMapRequiredSubListFields(nodeInfo[0], newSubListRowIdx))
        this.addRequiredSubListFields(nodeInfo[0], newSubListRowIdx);
};


NLImportFieldMapper.prototype.deleteSubListFields = function NLImportFieldMapper_deleteMachineFields(list, subListRowIdx)
{
    var listDef = this.getListFieldDef(list,"")[0];
    var bDenormalized = listDef[NODE_DENORMALIZED] == "T";
    if (!(this.isMachineList(listDef) || list == "OPPORTUNITY:item"))
        return;

    this.bSkipDeleteSubListFields = true;
    var tableElem = document.getElementById (this.getTableElemId());
    for (var rowIndex = tableElem.rows.length - 1; rowIndex >= 0; rowIndex--)
    {
        var rowElem = tableElem.rows[rowIndex];
        var fldId = rowElem.getElementsByTagName('td')[COL_FIELD].fldId;
        if (typeof fldId != "undefined" && fldId != null)
        {
            var nodeInfo = fldId.split(String.fromCharCode(8));
            if (list == nodeInfo[0] && (!bDenormalized || nodeInfo[1].split(SUB_LIST_LINE_NUM_SEPERAROR)[1] == subListRowIdx))
                rowElem.getElementsByTagName('td')[COL_DELETE].firstChild.onclick();
        }
    }
    this.bSkipDeleteSubListFields = false;
};


NLImportFieldMapper.prototype.addRequiredSubListFields = function NLImportFieldMapper_addRequiredSubListFields(list, subListRowIdx)
{
    var listDef = this.getListFieldDef(list,"")[0];
    var bDenormalized = listDef[NODE_DENORMALIZED] == "T";
    if (!this.isMachineList(listDef) || (bDenormalized && subListRowIdx >= listDef[NODE_NUM_LINES]))
        return;

    var fieldDefs = listDef[NODE_FIELDS], rowIndex;
    var insertRowIdx = getLineArray(this.machine.name).length;
    var tableElem = document.getElementById (this.getTableElemId());
    var numRows =  tableElem.rows.length;
    var numSubListFields = bDenormalized ? fieldDefs.length/listDef[NODE_NUM_LINES] : fieldDefs.length;
    for (var i=0; i < numSubListFields; i++)
    {
        var fieldIdx = bDenormalized ? (i*listDef[NODE_NUM_LINES] + parseInt(subListRowIdx)) : i;
        if (fieldDefs[fieldIdx][NODE_REQUIRED] == "T" )
        {
            for (rowIndex = 0; rowIndex < numRows; rowIndex++)
            {
                var rowElem = tableElem.rows[rowIndex];
                if (fieldDefs[fieldIdx][NODE_ID] == rowElem.getElementsByTagName('td')[COL_FIELD].fldId)
                    break; 
            }
            if (rowIndex == numRows)
            {
                var nodeInfo =  fieldDefs[fieldIdx][NODE_ID].split(String.fromCharCode(8));
                this.updateMappingRow (this.listTree.id, insertRowIdx++, nodeInfo[0], nodeInfo[1]);
                this.updateTreeNodeStyle(this.listTree.id, nodeInfo[0], nodeInfo[1]);
            }
        }
    }
};


NLImportFieldMapper.prototype.canMapRequiredSubListFields = function NLImportFieldMapper_canMapRequiredSubListFields(list, subListRowIdx)
{
    var listDef = this.getListFieldDef(list,"")[0];
    var bDenormalized = listDef[NODE_DENORMALIZED] == "T";
    if (!this.isMachineList(listDef) || (bDenormalized && subListRowIdx >= listDef[NODE_NUM_LINES]))
        return false;

    var fieldDefs = listDef[NODE_FIELDS], rowIndex;
    var insertRowIdx = getLineArray(this.machine.name).length;
    var tableElem = document.getElementById (this.getTableElemId());
    var numRows =  tableElem.rows.length;
    var numSubListFields = bDenormalized ? fieldDefs.length/listDef[NODE_NUM_LINES] : fieldDefs.length;
    for (var i=0; i < numSubListFields; i++)
    {
        var fieldIdx = bDenormalized ? (i*listDef[NODE_NUM_LINES] + parseInt(subListRowIdx)) : i;
        if (fieldDefs[fieldIdx][NODE_REQUIRED] == "T" )
        {
            for (rowIndex = 0; rowIndex < numRows; rowIndex++)
            {
                var rowElem = tableElem.rows[rowIndex];
                if (fieldDefs[fieldIdx][NODE_ID] == rowElem.getElementsByTagName('td')[COL_FIELD].fldId)
                    break; 
            }
            if (rowIndex == numRows)
                return true;
        }
    }
    return false;
};



NLImportFieldMapper.prototype.isFieldRequired = function NLImportFieldMapper_isFieldRequired(field, fieldDef)
{
    return fieldDef.bCannotDelete;
};

NLImportFieldMapper.prototype.getNumOfdRequiredFieldsInList = function NLImportFieldMapper_getNumOfdRequiredFieldsInList(listDef)
{
    var num = 0;
    var fieldDefs = listDef[NODE_FIELDS];
    for (var i=0; i < fieldDefs.length; i++)
    {
        if (fieldDefs[i][NODE_REQUIRED] == "T")
            num++;
    }
    return num;
};

NLImportFieldMapper.prototype.isMachineList = function NLImportFieldMapper_isMachineList(listDef)
{
    
    return (listDef && listDef[NODE_ID].indexOf(":") > 0 );
};



NLImportFieldMapper.prototype.isOpportunityItemSingleFile = function NLImportFieldMapper_isOpportunityItemSingleFile(file, list, field)
{
    
    return ((file == null || file == "") && list == "OPPORTUNITY:item" && field == "item");

};
NLImportFieldMapper.prototype.isMachineLineField = function NLImportFieldMapper_isMachineLineField(field)
{
    return (field.split(SUB_LIST_LINE_NUM_SEPERAROR).length > 1);
};



NLImportFieldMapper.prototype.focusMappingLine = function (fldId)
{
    var rowIndex;
    var tableElem = document.getElementById (this.getTableElemId());
    for (rowIndex = 0; rowIndex < tableElem.rows.length; rowIndex ++)
    {
        if (tableElem.rows[rowIndex].getElementsByTagName('td')[COL_FIELD].fldId == fldId)
            break;
    }
    if(rowIndex < tableElem.rows.length)
        this.setActiveLine(rowIndex, true);
};

NLImportFieldMapper.prototype.hlighlightMafppingLine = function (fldId)
{
    var nodeInfo = fldId.split(String.fromCharCode(8));
    this.updateMappingRow (this.listTree.id, this.activeLine, nodeInfo[0], nodeInfo[1]);
};



NLImportFieldMapper.prototype.deleteMappingRow = function (spanElem, file, col, list, field)
{
    var subListRowIdx = -1;
    var bDeleteSubListField = false;
    if (list != null && list != "" && !this.bSkipDeleteSubListFields)
    {
        var lisFieldtDefs = this.getListFieldDef(list, field);
        var listDef = lisFieldtDefs[0];
        var fieldDef = lisFieldtDefs[1];
        if ((this.isMachineList(listDef) && fieldDef[NODE_REQUIRED] == "T") || this.isOpportunityItemSingleFile(file, list, field) )
        {
            var listLabel = listDef[NODE_TITLE];
            if (listDef[NODE_DENORMALIZED] == "T")
            {
                subListRowIdx = field.split(SUB_LIST_LINE_NUM_SEPERAROR)[1];
                listLabel += " " + (parseInt(subListRowIdx)+1);
            }
            var msg = REMOVE_SUBLIST_FIELDS_MSG.replace("_LIST_NAME_", listLabel).replace("_FIELD_NAME_", fieldDef[NODE_TITLE]);
            msg += "Do you want to continue?" + "\n";
            if (!confirm(msg))
                return;
            bDeleteSubListField = true;
        }
    }

    var rowElem = isInsideElemByTagName ("TR", spanElem);
    if (rowElem == -1)
        return;

    var index = rowElem.rowIndex;

    if (index != this.activeLine)
        this.setActiveLine(index, true);

    this.deleteline(index);

    this.removeMappedColumn(file, col);
    this.removeMappedField(list, field);

    var tableElem = document.getElementById(this.getTableElemId());
    tableElem.deleteRow(index);

    if (tableElem.rows.length < DEFAULT_NUM_ROWS)
        this.renderMappingLine (tableElem.rows.length, null);

    var machineIndex = this.machine.getMaxIndex() - 2;
    this.setActiveLine(index > machineIndex ? machineIndex + 1 : index, true);

    this.updateTreeNodeStyle(this.colTree.id, file, col);
    this.updateTreeNodeStyle(this.listTree.id, list, field);

    if(bDeleteSubListField)
        this.deleteSubListFields(list, subListRowIdx);
};


NLImportFieldMapper.prototype.updateMappingRow = function (treeId, lineIdx, val1, val2)
{
    var linearray = getLineArray(this.machine.name);

    var rows = Math.max(linearray.length, DEFAULT_NUM_ROWS);

    if (lineIdx >= linearray.length)
    {
        this.machine.setMachineIndex( linearray.length + 1);
        lineIdx = linearray.length;
        this.insertline();
    }

    this.machine.setMachineIndex( lineIdx + 1 );

    this.machine.loadline(lineIdx + 1);

    var oldVal1, oldVal2;
    if (treeId == this.listTree.id)
    {
        oldVal1 = this.getCurrentLineFieldValue('mf_list');
        oldVal2 = this.getCurrentLineFieldValue('mf_fld');
        this.setMappingLineFieldData(val1, val2);
        this.machine.updateLineData();
        this.removeMappedField(oldVal1, oldVal2);
        this.addMappedField(val1, val2);
    }
    else
    {
        oldVal1 = this.getCurrentLineFieldValue('mf_file');
        oldVal2 = this.getCurrentLineFieldValue('mf_col');
        this.setMappingLineColumnData(val1, val2);
        this.machine.updateLineData();
        this.removeMappedColumn(oldVal1, oldVal2);
        this.addMappedColumn(val1, val2);
    }

    linearray = getLineArray(this.machine.name);
    var linedata = splitIntoCells( linearray[lineIdx] );

    this.renderMappingLine (lineIdx, linedata);

    this.setActiveLine (lineIdx, true);

    // add one additional line on ui
    if (lineIdx == linearray.length - 1)
    {
        this.renderMappingLine (lineIdx + 1, new Array(this.machine.countFormElements()));
        if ( this.getCurrentLineFieldValue('mf_list') != null &&
             this.getCurrentLineFieldValue('mf_fld') != null &&
             this.getCurrentLineFieldValue('mf_file') != null &&
             this.getCurrentLineFieldValue('mf_col') != null)
	   	     this.setActiveLine (lineIdx + 1, true);
    }


    if (treeId == this.listTree.id)
    {
        this.updateTreeNodeStyle(this.listTree.id, oldVal1, oldVal2);
        this.updateTreeNodeStyle(this.listTree.id, val1, val2);
    }
    else
    {
        this.updateTreeNodeStyle(this.colTree.id, oldVal1, oldVal2);
        this.updateTreeNodeStyle(this.colTree.id, val1, val2);
    }

    this.renderMappingRowStatus(this.activeLine, MAPPING_STATUS_NORMAL);
};

NLImportFieldMapper.prototype.editField = function (editElem, rowIndex, file, col, list, fld)
{
    var fieldDef = this.getListFieldDef(list, fld)[1];

    var linearray = getLineArray(this.machine.name);
    var linedata = splitIntoCells( linearray[rowIndex] );

    var refType = this.getFieldValue(linedata, 'mf_ref');
    var defaultVal = this.getFieldValue(linedata, 'mf_default');

    var url = new StringBuffer();            
    url.append(document.URL);
    if(document.URL.indexOf("?") < 0)
        url.append("?");
    else
        url.append("&");
    url.append ("importmethod=").append("fieldvalue");
    url.append ("&list=").append(list);
    url.append ("&fld=").append(fld);
    if(typeof file != "undefined" && file!= null && file!= "")
        url.append ("&file=").append(file);
    if(typeof col != "undefined" && col != null && col != "")
        url.append ("&col=").append(col);
    if(typeof refType != "undefined" && refType != null && refType != "")
        url.append ("&reftype=").append(refType);
    if(typeof defaultVal != "undefined" && defaultVal != null && defaultVal != "")
        url.append ("&default=").append(encodeURIComponent(defaultVal));

    this.setActiveLine(rowIndex, true);

    nlOpenPopup(window, "nlpopuplite", url.toString(), null, false, 500, 500);
};


NLImportFieldMapper.prototype.SetFieldProperty = function(val, type, label)
{
    var file;
    var col;

    this.machine.loadline(this.activeLine + 1);

    if (type == "D" || type == "N") // default value or null value
    {
        file = this.getCurrentLineFieldValue('mf_file');
        col = this.getCurrentLineFieldValue('mf_col');
        this.removeMappedColumn(file, col);
    }
    this.setMappingFieldProperty (val, type, label);

    this.machine.updateLineData();

    this.updateCurrentMappingLine();

    if (type == "D") // default value, remove used file/col
        this.updateTreeNodeStyle(this.colTree.id, file, col);

    this.renderMappingRowStatus(this.activeLine, MAPPING_STATUS_NORMAL);
};

NLImportFieldMapper.prototype.getTableElemId = function ()
{
    return this.id + "_table";
};

NLImportFieldMapper.prototype.getColumnNameElemId = function (file, col)
{
    return file + "_" + col + "_col";
};

NLImportFieldMapper.prototype.getListFieldDef = function(list, field)
{
    var i;

    if (list == null || list == "")
        return [null, null];

    var key = this.getDataSourceKeyNames (this.listTree.id, list, field);

    var listDef = this.fldData[key[0]];

    if (field == null || field == "")
        return [listDef, null];

    var fieldDefs = listDef[NODE_FIELDS];
    for (i=0; i < fieldDefs.length; i++)
    {
        if (fieldDefs[i][NODE_ID] == key[1])
            break;
    }
    if (i == fieldDefs.length)
        return [listDef, null];

    return [listDef, fieldDefs[i]];
};

NLImportFieldMapper.prototype.getFieldValue = function (linedata, fieldname )
{
	var nPos = this.machine.getArrayPosition( fieldname );
	if ( nPos == -1 )
		return false;
	return linedata != null && linedata.length > nPos ? linedata[ nPos ] : null ;
};

NLImportFieldMapper.prototype.getCurrentLineFieldValue = function (fieldname )
{
	var nPos = this.machine.getArrayPosition( fieldname );
	if ( nPos == -1 )
		return "";
	return this.machine.getFormElement(nPos).value;
};



NLImportFieldMapper.prototype.getDataSourceKeyNames = function (treeId, val1, val2)
{
    var postFix = (treeId == this.colTree.id) ? "_col" : "_fld";

    if (val2.indexOf(String.fromCharCode(8)) == -1)
        val2 = val1 + String.fromCharCode(8) + val2 + String.fromCharCode(8) + postFix;

    if (val1.indexOf(String.fromCharCode(8)) == -1)
        val1 = val1 + String.fromCharCode(8) + postFix;

    return [val1, val2];
};


NLImportFieldMapper.prototype.getMappedKeyName = function (a, b)
{
    return a + String.fromCharCode(8) + b;
};


NLImportFieldMapper.prototype.addMappedColumn = function (file, col)
{
    var key = this.getMappedKeyName(file, col);
    if (typeof this.mappedCols[key] == "undefined" || this.mappedCols[key] == null)
        this.mappedCols[key] = 1;
    else
        this.mappedCols[key] += 1;
};

NLImportFieldMapper.prototype.removeMappedColumn = function (file, col)
{
    var key = this.getMappedKeyName(file, col);
    if (typeof this.mappedCols[key] == "undefined" || this.mappedCols[key] == null)
        return;

    this.mappedCols[key] -= 1;
    if (this.mappedCols[key] <= 0)
        this.mappedCols[key] = null;
};


NLImportFieldMapper.prototype.addMappedField = function (list, field)
{
    var key = this.getMappedKeyName(list, field);
    this.mappedFlds[key] = 1;
};

NLImportFieldMapper.prototype.removeMappedField = function (list, field)
{
    var key = this.getMappedKeyName(list, field);
    if (typeof this.mappedFlds[key] == "undefined" || this.mappedFlds[key] == null)
        return;

    this.mappedFlds[key] = null;
};


NLImportFieldMapper.prototype.isFieldMapped = function (list, field)
 {
     var key = this.getMappedKeyName(list, field);
     if (typeof this.mappedFlds[key] == "undefined" || this.mappedFlds[key] == null)
        return false;

     return true;
 };


NLImportFieldMapper.prototype.addRequiredFieldsToMachine = function ()
{
    var listName;
    for (listName in this.fldData)
    {
        var listDef = this.fldData[listName];

        
        if (this.isMachineList(listDef))
            continue;

        var fieldDefs = listDef[NODE_FIELDS];
        for (var i=0; i < fieldDefs.length; i++)
        {
            if (fieldDefs[i][NODE_REQUIRED] == "T")
            {
                var ids = fieldDefs[i][NODE_ID].split(String.fromCharCode(8));
                if (this.isFieldRequired(ids[1], fieldDefs[i]))
                {
                    this.insertline();
                    this.setMappingLineFieldData (ids[0], ids[1]);
                    this.machine.updateLineData();
                    this.addMappedField(ids[0], ids[1]);
                    if(fieldDefs[i][NODE_CANNOT_DELETE_IF_REQUIRED]=="T")
                        fieldDefs[i].bCannotDelete = true;
                }
            }
        }
    }
};


NLImportFieldMapper.prototype.setupMapping = function ()
{
    var linearray = getLineArray( this.machine.name );
    for(var i=0; i<linearray.length; i++)
    {
        var linedata = splitIntoCells( linearray[i] );

        var file = this.getFieldValue(linedata, 'mf_file');
        var col = this.getFieldValue(linedata, 'mf_col');
        var list = this.getFieldValue(linedata, 'mf_list');
        var field = this.getFieldValue(linedata, 'mf_fld');

        this.addMappedField(list, field);
        
        var listFieldDef = this.getListFieldDef(list, field);
        if (listFieldDef && listFieldDef[1][NODE_REQUIRED] == "T" && listFieldDef[1][NODE_CANNOT_DELETE_IF_REQUIRED]=="T")
            listFieldDef[1].bCannotDelete = true;

        if(typeof file != "undefined" && file != null && file !="" &&
           typeof col != "undefined" && col != null && col !="")
            this.addMappedColumn(file, col);

    }
};


NLImportFieldMapper.prototype.insertline = function()
{
	var linenum = this.machine.getMachineIndex() - 1;
	var linedata = new Array(this.machine.countFormElements());
    var linearray = getLineArray( this.machine.name );
	linearray = (linearray.slice(0,linenum).concat(linedata.join(String.fromCharCode(1)))).concat(linearray.slice(linenum));

	this.machine.setLineArray( linearray );

	this.machine.incrementIndex() ;
	var oldidx = linenum+1;
	this.machine.setMachineIndex( oldidx );
};

NLImportFieldMapper.prototype.deleteline = function(index)
{
    var linearray = getLineArray( this.machine.name );

    linearray = linearray.slice(0,index).concat(linearray.slice( (index+1) ));

    this.machine.setLineArray( linearray );

    this.machine.decrementIndex( );

    if( this.machine.getMachineIndex() > this.machine.getNextIndex())
        this.machine.setMachineIndex( this.machine.getNextIndex() -1 );
};


NLImportFieldMapper.prototype.setMappingLineColumnData = function(file, col)
{
    if(typeof file != "undefined" && typeof col!= "undefined" && file!= null && col!= null)
    {
        var nPos = this.machine.getArrayPosition( "mf_file" );
        var curElement = this.machine.getFormElement(nPos );
        curElement.value = file;

        nPos = this.machine.getArrayPosition( "mf_col" );
        curElement = this.machine.getFormElement(nPos );
        curElement.value = col;

        nPos = this.machine.getArrayPosition( "mf_ref" );
        curElement = this.machine.getFormElement(nPos );
        curElement.value = "";

        nPos = this.machine.getArrayPosition( "mf_default" );
        curElement = this.machine.getFormElement(nPos );
        curElement.value = "";

        nPos = this.machine.getArrayPosition( "mf_default_label" );
        curElement = this.machine.getFormElement(nPos );
        curElement.value = "";
    }
};


NLImportFieldMapper.prototype.setMappingLineFieldData = function (list, field)
{
    if(typeof list != "undefined" && typeof field!= "undefined" && list!= null && field!= null)
    {
        var nPos = this.machine.getArrayPosition( "mf_list" );
        var curElement = this.machine.getFormElement(nPos );
        curElement.value = list;

        nPos = this.machine.getArrayPosition( "mf_fld" );
        curElement = this.machine.getFormElement(nPos );
        curElement.value = field;

        nPos = this.machine.getArrayPosition( "mf_default" );
        curElement = this.machine.getFormElement(nPos );
        curElement.value = "";
    }
};


NLImportFieldMapper.prototype.setMappingFieldProperty = function (value, type, label)
{
    var nPos;
    var curElement;

    if (type == "D" || type == "N" )  // default value or null value
    {
        nPos = this.machine.getArrayPosition( "mf_default" );
        curElement =this.machine.getFormElement(nPos );
        curElement.value = value;

        nPos = this.machine.getArrayPosition( "mf_default_label" );
        curElement =this.machine.getFormElement(nPos );
        if (typeof label != "undefined" && label != null)
            curElement.value = label;
        else
            curElement.value = "";

        nPos = this.machine.getArrayPosition( "mf_file" );
        curElement = this.machine.getFormElement(nPos );
        curElement.value = "";

        nPos = this.machine.getArrayPosition( "mf_col" );
        curElement = this.machine.getFormElement(nPos );
        curElement.value = "";

        nPos = this.machine.getArrayPosition( "mf_ref" );
        curElement =this.machine.getFormElement(nPos );
        curElement.value = "";

    }
    else    // reference type
    {
        nPos = this.machine.getArrayPosition( "mf_ref" );
        curElement =this.machine.getFormElement(nPos );
        curElement.value = value;

        nPos = this.machine.getArrayPosition( "mf_default" );
        curElement =this.machine.getFormElement(nPos );
        curElement.value = "";

        nPos = this.machine.getArrayPosition( "mf_default_label" );
        curElement =this.machine.getFormElement(nPos );
        curElement.value = "";
     }
};


NLImportFieldMapper.prototype.getMachineLineNum = function (file, col, list, field)
{
    var linearray = getLineArray(this.machine.name);

    var rows = Math.max(linearray.length, DEFAULT_NUM_ROWS);
    for(var i=0; i<linearray.length; i++)
    {
        var linedata = splitIntoCells( linearray[i] );

        if (file == this.getFieldValue(linedata, 'mf_file') &&
            col == this.getFieldValue(linedata, 'mf_col') &&
            list == this.getFieldValue(linedata, 'mf_list') &&
            field == this.getFieldValue(linedata, 'mf_fld'))
            break;
    }

    return i==linearray.length ? -1 : i;
};


NLImportFieldMapper.prototype.validateFieldMapping = function (importRecordType, isSingleFileTXN, nameLookupForbidden)
{
    var requredFieldErrors = [];
    var otherErrors = [];

    var errors = [];
    var linearray = getLineArray(this.machine.name);

    var rows = Math.max(linearray.length, DEFAULT_NUM_ROWS);
	var anyIdMapped = false;
	var intOrExtIdMapped = false;

	if (linearray.length == 0)
	{
	    nlShowMessage (FIELD_MAPPING_NONE_MAPPED_POPUP_MESSAGE, FIELD_MAPPING_ERROR_POPUP_TITLE, MSG_STYLE_WARNING);
		return false;
	}

    // hack - there must be at least one field mapped, so see iff it contains "JOURNALENTRY", if so, it is a JE or ICJE
    var isJE = importRecordType == 'JOURNALENTRY' || importRecordType == 'INTERCOMPANYJOURNALENTRY';

    for(var i=0; i<linearray.length; i++)
    {
        var linedata = splitIntoCells( linearray[i] );

        var file = this.getFieldValue(linedata, 'mf_file');
        var col = this.getFieldValue(linedata, 'mf_col');
        var list = this.getFieldValue(linedata, 'mf_list');
        var field = this.getFieldValue(linedata, 'mf_fld');
        var defaultVal = this.getFieldValue(linedata, 'mf_default');

        if (field == "id" || field == "externalid" || field == "tranid")
        {
			anyIdMapped = true;
			if (field == "externalid" || field == "id")
			   intOrExtIdMapped= true;

			if (defaultVal != null && defaultVal != "")
			{
			    // can not map id, externalId or tranid to a default value. Does not make sense.
			    if (isJE && isSingleFileTXN && field == "tranid")
			    	anyIdMapped = false;
			    else
 					errors[errors.length] = i;
 			}
		}

		if (list != null && field != null && list != "" && field != "" )
        {
            if ((file == null || col == null || file == "" || col == "") && (defaultVal == null || defaultVal == "") )
                //if (this.div.scrollTop = this.currentCell.offsetTop;
                errors[errors.length] = i;
        }
        else if (file != null && col != null && file != "" && col != "" )
        {
            if (list == null || field == null || list == "" || field == "")
                errors[errors.length] = i;
        }
    }

	if (isSingleFileTXN && !anyIdMapped)
    {
        if (isJE)
 		{
 		 	if (!confirm( FIELD_MAPPING_SINGLE_JE_WARNING ))
 		 		return false;
 		}
		else
		{
			nlShowMessage (FIELD_MAPPING_TXN_ERROR_POPUP_MESSAGE, FIELD_MAPPING_ERROR_POPUP_TITLE, MSG_STYLE_WARNING);
    		return false;
    	}
	}

   if (nameLookupForbidden && !intOrExtIdMapped)
   {
       nlShowMessage(FIELD_MAPPING_NAME_LOOKUP_FORBIDDEN , FIELD_MAPPING_ERROR_POPUP_TITLE, MSG_STYLE_WARNING);
       return false;
   }

	if (errors.length == 0)
        return true;

    var tableElem = document.getElementById (this.getTableElemId());

    for( var i = 0; i < errors.length; i++ )
    {
        var rowIndex  = errors[i];
        this.renderMappingRowStatus(rowIndex, MAPPING_STATUS_ERROR);
    }

    nlShowMessage (FIELD_MAPPING_ERROR_POPUP_MESSAGE, FIELD_MAPPING_ERROR_POPUP_TITLE, MSG_STYLE_WARNING);

    return false;
};

NLImportFieldMapper.prototype.updateTreeNodeStyle = function(treeId, val1, val2)
{
    if (typeof val1 == "undefined" || val1 == null || val1 == "")
        return;

    var tree = (treeId == this.colTree.id) ? this.colTree : this.listTree;

    var nodeId;
    var nodeIds = this.getDataSourceKeyNames (treeId, val1, val2);
    if (typeof val2 == "undefined" || val2 == null)
        nodeId = nodeIds[0];
    else
        nodeId = nodeIds[1];

    var nodeStyle = this.getNodeStyle(treeId, nodeId);

    tree.updateNodeStyle(nodeId, nodeStyle);
};

NLImportFieldMapper.prototype.getNodeStyle = function(treeId, nodeId, keyName)
{
	var isRedwood = NS.UI.Util.isRedwood;
    var nodeInfo = nodeId.split(String.fromCharCode(8));

    var nodeStyle = [];
    nodeStyle[NODE_STYLE_IMAGE] = null;
    nodeStyle[NODE_STYLE_CSS] = null;
    nodeStyle[NODE_STYLE_LABEL] = null;
    nodeStyle[NODE_STYLE_ACTION] = null;

    if (nodeInfo.length == 2 ||
        (nodeInfo.length == 3 &&
         nodeInfo[nodeInfo.length -1] != "_col" &&
         nodeInfo[nodeInfo.length -1] !="_fld")) // list type
    {
        nodeStyle[NODE_STYLE_CSS] = "textboldnolink uir-import-parent-node";
        return nodeStyle;
    }

    if (typeof keyName == "undefined" || keyName == null)
        keyName = this.getMappedKeyName(nodeInfo[0], nodeInfo[1]);

    if( treeId == this.colTree.id)
    {
        if (typeof this.mappedCols[keyName] != "undefined" && this.mappedCols[keyName] != null)
        {
            nodeStyle[NODE_STYLE_IMAGE] = isRedwood ? "/uiredwood/icon/check.svg" : "/images/icons/import/item_checked.gif";
            nodeStyle[NODE_STYLE_CSS] = "uir-tree-node-with-icon uir-import-fm-itemchecked";
        }
        else
        {
            nodeStyle[NODE_STYLE_IMAGE] = isRedwood ? "/uiredwood/icon/box.svg" : "/images/icons/import/treefield.gif";
            nodeStyle[NODE_STYLE_CSS] = "uir-tree-node-with-icon uir-import-fm-treefield";
        }

        return nodeStyle;
    }
    else if (treeId == this.listTree.id)
    {

        var listFieldDef = this.getListFieldDef(nodeInfo[0],nodeInfo[1]);
        var fieldDef = listFieldDef[1];
        var bCustomField = fieldDef[NODE_CUSTOMFIELD] == "T";
        var bKeyField = fieldDef[NODE_CUSTOMFIELD] == "K";
        nodeStyle[NODE_STYLE_CSS] = "uir-tree-node-with-icon ";

		var imgField = isRedwood ? "/uiredwood/icon/box.svg" : "/images/icons/import/ns.gif";
		var imgKey = isRedwood ? "/uiredwood/icon/key.svg" : "/images/icons/import/ns_key.gif";
		var imgCustom = isRedwood ? "/uiredwood/icon/box-settings.svg" : "/images/icons/import/ns_custom.gif";

	    nodeStyle[NODE_STYLE_IMAGE] = bCustomField ? imgCustom : (bKeyField ? imgKey : imgField);
        if (typeof this.mappedFlds[keyName] != "undefined" && this.mappedFlds[keyName] != null)
        {
            nodeStyle[NODE_STYLE_CSS] += bCustomField ? "uir-import-fm-nscustomg" : (bKeyField ? "uir-import-fm-nskeyg" : "uir-import-fm-uir-import-fm-nsg");
            nodeStyle[NODE_STYLE_ACTION] = "window." + "mapperpane" + ".focusMappingLine(\"" + nodeId + "\");";
        }
        else
        {
            nodeStyle[NODE_STYLE_CSS] += bCustomField ? "uir-import-fm-nscustom" : (bKeyField ? "uir-import-fm-nskey" : "uir-import-fm-ns");
            nodeStyle[NODE_STYLE_ACTION] = "window." + "mapperpane" + ".setField(\"" + nodeId + "\");";
        }

        return nodeStyle;
    }
    return null;
};

function validateImportName(bttnElem, nameElemId, id)
{
    var action = bttnElem.name;

    if (document.getElementById(nameElemId).value == "" && action != 'finish')
    {
        nlShowMessage(IMPORT_NAME_MISSING, "", MSG_STYLE_INFO);
        return false;
    }
    else
    {

        if (id !='' &&
            (action == 'saveandexecute' ||
             action == 'save'))
            return confirm ("Do you want to overwrite this saved import?");
        else if (action == 'finish')
            return confirm ("Data you entered on this page has not been saved and will be lost. Press OK to proceed.");

    }

    return true;
};


function NLImportAssistant_resizeObjectPanes()
{
    var mapper = document.querySelector('.uir-assistant-field-mapper-container');
	if (mapper)
    {
	    var contentWrapper = document.querySelector('.uir-rightpane-content-top');
	    var newHeight = contentWrapper.offsetHeight - (NS.UI.Util.isRedwood ? 120 : 100);
	    mapper.style.height = newHeight + "px";
    }
}
