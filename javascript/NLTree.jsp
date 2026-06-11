





var nlTreeImages = NS.UI.Util.isRedwood ? {
	imageBaseUrl    : '/uiredwood/img/tree/',
	rootIcon        : 'folder.svg',
	rootOpenIcon    : 'folderopen.svg',
	folderIcon      : 'folder.svg',
	folderOpenIcon  : 'folderopen.svg',
	fileIcon        : 'file.svg',
	blankIcon       : 'blank.png',
	barIcon         : 'bar.gif',
	lIcon           : 'l.gif',
	tIcon           : 't.gif',
	minusIcon       : 'minus-square.svg',
	plusIcon        : 'plus-square.svg',
	lMinusIcon      : 'minus-square.svg',
	lPlusIcon       : 'plus-square.svg',
	tMinusIcon      : 'minus-square.svg',
	tPlusIcon       : 'plus-square.svg'
    } : {
    imageBaseUrl    : '/images/nav/tree/',
    rootIcon        : 'folder.gif',
    rootOpenIcon    : 'folderopen.gif',
    folderIcon      : 'folder.gif',
    folderOpenIcon  : 'folderopen.gif',
    fileIcon        : 'file.gif',
    blankIcon       : 'blank.png',
    barIcon         : 'bar.gif',
    lIcon           : 'l.gif',
    tIcon           : 't.gif',
    minusIcon       : 'minus.png',
    plusIcon        : 'plus.png',
    lMinusIcon      : 'minus.png',
    lPlusIcon       : 'plus.png',
    tMinusIcon      : 'minus.png',
    tPlusIcon       : 'plus.png'
};

// tree node fields expected
var NODE_ID = 0;
var NODE_TITLE = 1;
var NODE_FOLDER = 2;
var NODE_LAST = 3;
var NODE_PATH = 4;
var NODE_ACTION = 5;
var NODE_IMAGE = 6;
var NODE_IMAGE_OPEN = 7;
var NODE_SECONDARY_ID = 8;
var NODE_ALT_TITLE = 9;
var NODE_LINE_ACTION = 11;
var NODE_LINE_ACTION_TEXT = 12;
var NODE_LINE_ACTION_IMG = 13;
var NODE_INACTIVE = 10;

//node style content (node style is an array returned by nodestyleprovider for look and feel customization of each node
var NODE_STYLE_IMAGE = 0;
var NODE_STYLE_CSS = 1;
var NODE_STYLE_LABEL = 2;
var NODE_STYLE_ACTION = 3;

// status code for node content retrieval
var S_OK = 0;
var S_NODE_NOT_FOUND = 1;

// tree event
var E_INIT = 0;
var E_FOCUS = 1;
var E_DRAGDROP = 2;
var E_LOAD = 4;
var E_RELOAD = 6;
var E_EXPAND = 8;
var E_COLLAPSE = 9;

var E_RESPONSE_CANCEL = 0; // set event.status = 0 to prevent drag (on certan nodes)
TREE_NODE_TITLE_ID_POSTFIX = "_tnidtitle";
TREE_NODE_ROW_CSS_CLASS = "treeNodeRow"; // this is a dummy class name to help find the tree node div

/**
 * provide tree content using xml request object
 */
function nlTreeContentXMLReqProvider(url)
{
    if (url)
        this.url = url;
    else
        this.url = "/app/tree/tree.nl";
}

nlTreeContentXMLReqProvider.prototype.getNodeContent = function (id, callbackFunc)
{
	var querystring = "tnodeid=" + id;
	var async = false;
    callbackFunc = async ? callbackFunc : null;
    var url = this.url;
    url = addParamToURL(url, "tnodeid", id, false);
    url = addParamToURL(url, "taction", "tmloaddata", false);
    return nlXMLRequestURL( url, querystring, null, callbackFunc, async);
};

nlTreeContentXMLReqProvider.prototype.doHandleNodeContentResponse = function (response, content)
{
    content.reset();
    var sText = response.getBody();
	content.parse(sText);
    return content;
};

nlTreeContentXMLReqProvider.prototype.search = function (searchStr, callbackFunc)
{
	var querystring = "keyword=" + encodeURIComponent(searchStr);
	var async = false;
    var url = this.url;
    url = addParamToURL(url, "keyword", encodeURIComponent(searchStr), false);
    url = addParamToURL(url, "taction", "tmsrchnode", false);
    return nlXMLRequestURL( url, querystring, null, callbackFunc, async);
};

/**
 * represents a tree node content in xml format
 */
function nlTreeNodeXMLContent ()
{
    this.reset();
}

nlTreeNodeCSVContent.prototype.reset = function ()
{
    this.doc = null
};

nlTreeNodeXMLContent.prototype.parse = function (sText)
{
	this.doc = nlapiStringToXML (sText);
};

nlTreeNodeXMLContent.prototype.clear = function ()
{
	return doc.getElementsByTagName('status')[0].firstChild.nodeValue;
};

nlTreeNodeXMLContent.prototype.getStatus = function ()
{
	return doc.getElementsByTagName('status')[0].firstChild.nodeValue;
};

nlTreeNodeXMLContent.prototype.getTotal = function ()
{
	var total = doc.getElementsByTagName('total')[0].firstChild.nodeValue;
};

nlTreeNodeXMLContent.prototype.getNodes = function ()
{
	var nodes = [];
	var items = this.doc.getElementsByTagName('item');

	for(var i=0;i<items.length;i++)
	{
		var node = [];
		node[NODE_ID] = items[i].getElementsByTagName('id')[0].firstChild.nodeValue;
		node[NODE_TITLE] = items[i].getElementsByTagName('title')[0].firstChild.nodeValue;
		node[NODE_FOLDER] = items[i].getElementsByTagName('folder')[0].firstChild.nodeValue == "1"? true:false;
		nodes[nodes.length] = node;
	}
    if (nodes.length > 0)
        nodes[nodes.length-1][NODE_LAST] = true;
};

/**
 * represents a tree node content in csv format
 */
function nlTreeNodeCSVContent ()
{
    this.reset();
}

nlTreeNodeCSVContent.prototype.parse = function nlTreeNodeCSVContent_parse(sText)
{
    // grab only the tree data, which always ends with a char(5)
    sText = sText.split( String.fromCharCode(5) )[0];
    var lines = sText.split( String.fromCharCode(2) );
    if (lines.length == 0)
        return;

    var header = lines[0].split( String.fromCharCode(1) );
    this.status = header[0];
    this.total = [];

    var i;
    for (i=1; i<header.length; i++)
    {
        this.total[this.total.length] = header[i];
    }

    var numExpandedNodes = this.total.length;
    var numNodes = 0;
    for (var n=0; n<numExpandedNodes; n++)
    {
        this.nodes[n] = [];
        for (i=numNodes; i<numNodes + this.total[n]*1; i++)
        {
            var node = lines[i+1].split( String.fromCharCode(1) );
            this.nodes[n][this.nodes[n].length] = node;
        }
        numNodes += this.total[n] * 1;
    }
};

nlTreeNodeCSVContent.prototype.getStatus = function nlTreeNodeCSVContent_getStatus()
{
    return this.status;
};

nlTreeNodeCSVContent.prototype.getTotal = function nlTreeNodeCSVContent_getTotal(index)
{
	if (index == "undefined" || index == null)
        return this.total[0];

    return this.total[index];
};

nlTreeNodeCSVContent.prototype.getNodes = function nlTreeNodeCSVContent_getNodes(index)
{
    if (index == "undefined" || index == null)
        return this.nodes[0];

    return this.nodes[index];
};

nlTreeNodeCSVContent.prototype.reset = function nlTreeNodeCSVContent_reset()
{
    this.status = S_NODE_NOT_FOUND;
    this.nodes = [];
    this.total = [];
    this.total[0] = 0;

};

/**
 * Tree handler, handles tree operations such as expand and collapse
 */
function nlTreeHandler(tree)
{
	this.tree = tree;
}

nlTreeHandler.prototype.add = function nlTreeHandler_add (path)
{
	var that = this;
    this.expand(path);
    var response = this.tree.createNode(path, function(response){
	    that.addTreeNode(response, path);
    });
    if ( response)
        this.addTreeNode(response, path);
};

/**
 * add a new node to the tree node indicated by path
 * @param response The response object
 * @param path path to the expanded tree node
 */
nlTreeHandler.prototype.addTreeNode = function nlTreeHandler_addTreeNode (response, path)
{
    // get content
    var content = null;
    if (this.tree.getContentProvider()!= null)
        content =  this.tree.getContentProvider().doHandleNodeContentResponse (response, this.tree.content);
    if (content == null)
        return;

   //get the expanded node
    var expandedNode = this.tree.getExpandedNode(path);
    if (expandedNode == null)
        return;

    expandedNode.addChildNode(this.tree.doc, content.getNodes(0));
};

/**
 * Expand a tree node
 */
nlTreeHandler.prototype.expand = function expand(path)
{
	var parentNode = null;
	var parentPath = null;
	var nodeId = null;
	var index = -1;

    if (this.tree == null || path == null || path == "")
		return;

    //collapse leaf folder node
    if (this.tree.focusedNodePath!= null)
    {
        var focusedNode = this.tree.getExpandedNode(this.tree.focusedNodePath);
        if (focusedNode != null && focusedNode.directChildNodes.length == 0)
            this.collapse(this.tree.focusedNodePath);
    }


    //set focus if the node is already opened
    var w = path.lastIndexOf("_"), nodePath;
	if (w < 0 || isNaN(path.substring(w+1)))
		nodePath = path;
	else
		nodePath = path.substring(0, w);

	var expandedNode = this.tree.getDeepestExpandedNode(nodePath);
    var expandedNodePath = expandedNode==null? "" : expandedNode.getPath();

	// the node is already expanded
    if (expandedNodePath == nodePath)
        return;

    // the list of nodes to expand
    var subPath = expandedNodePath.length == 0 ? nodePath : nodePath.substr(expandedNodePath.length + 1);
	var that = this;

	var response = this.tree.getNodeContent(subPath, function(response) {
		that.expandTreeNode(response, expandedNodePath, subPath);
	});
    if ( response != null)
        this.expandTreeNode(response, expandedNodePath, subPath);
};

/**
 * Callback function to handle node expansion. Expand all the ndoes in the subPath
 * @param response The response object
 * @param parentNodePath The "root" node that the childe nodes attach to
 * @param subPath Dot seperated list of nodes to expand. The nodes in the path has parent child relationship
 */
nlTreeHandler.prototype.expandTreeNode = function expandTreeNode (response, parentNodePath, subPath)
{
    // get content
    var content = null;
    if (this.tree.getContentProvider()!= null)
        content =  this.tree.getContentProvider().doHandleNodeContentResponse (response, this.tree.content);
    if (content == null)

        return;

    var subPathArray=subPath.split(".");
    var startIndex = 0;

    //get the "root" node
    var expandedNode = this.tree.getDeepestExpandedNode(parentNodePath);
    if (expandedNode == null)
    {
        //check if the expanded node is a top level node
        if (parentNodePath!=null && parentNodePath!="")
            return;
        else if(subPathArray[0]=="ROOT")
        {
            this.tree.show(content.getNodes(0));
            startIndex = 1;
        }
    }
    else if(expandedNode.getPath() != parentNodePath)
        return;

    // expand the nodes in subpath
    var subPathArray=subPath.split(".");
    for (var i=startIndex; i<subPathArray.length; i++)
    {
        var childNodes = content.getNodes(i) || [];
		var id = subPathArray[i];

        // find the index of this node in it's parent
        var index = this.tree.getChildNodeIndex(expandedNode, id);
        if (index == -1)
        {
            return;
        }

        var node = this.tree.createExpandedNode(expandedNode.getDirectChildNode(id), id, index, childNodes);
	    expandedNode.addChild(node);
	    node.showExpanded();

        expandedNode = node;
    }
};

/**
 * Collapse a tree node
 */
nlTreeHandler.prototype.collapse = function collapse(path)
{
	var parentNode = null;
	var parentPath = null;
	var nodeId = null;
	var index = -1;

	if (this.tree == null || path == null || path == "")
		return;
	var v = path.lastIndexOf("_");
	if (v!=-1)
    	path = path.substring(0, v);

    var node = this.tree.getExpandedNode(path);
	if (node == null)
		return;

	node.opened = false;
	node.showCollapsed();

    this.tree.removeExpandedNode(node);
};

/**
 * focus on the node, expand if not
 */
nlTreeHandler.prototype.focus = function (path)
{
	this.expand(path);
    this.notify(path);
};

/**
 * notify tree node focus event
 */
nlTreeHandler.prototype.notify = function (path)
{
};

/**
 *  default tree event listener
 */
function nlTreeListener()
{
}

/**
 * default tree search handler that handles searching on the tree
 */
function nlTreeSearchHandler(tree)
{
	this.tree = tree;
}
nlTreeSearchHandler.prototype.handleSearchResults = function (response)
{
    // get content
    var content = null;
    if (this.tree.getContentProvider()!= null)
        content =  this.tree.getContentProvider().doHandleNodeContentResponse (response, this.tree.content);

    if (content != null)
        this.showSearchResults(content.getNodes(), content.status);
    else
        this.showSearchResults(null, this.tree.content.status);
};

nlTreeSearchHandler.prototype.search = function ()
{

    var searchStr = "";
    var input = document.getElementById(this.tree.id + "_si");
    if (input != null)
        searchStr = input.value;

    if (searchStr == null || searchStr == "")
    {
        this.showSearchResults(null, this.tree.content.status);
        return;
    }

    this.tree.searchNode(searchStr,  this.handleSearchResults.bind(this));
};

nlTreeSearchHandler.prototype.showSearchResults = function (nodes, status)
{
	var outputTable = document.getElementById(this.tree.id + "_stab");
	if (outputTable == null)
        return;

    var treeContentsDiv = document.getElementById("div__nav_tree");
    var startTableHeight = outputTable.parentNode.offsetHeight;
	var	startTotalHeight = startTableHeight + treeContentsDiv.offsetHeight;

	var	maxTableHeight = this.tree.maxSearchResultsHeight;
	var maxTreeHeight = this.tree.maxSearchTreeHeight;

	if (typeof(maxTableHeight)=="undefined")
		maxTableHeight = startTotalHeight;
	if (typeof(maxTreeHeight) =="undefined")
		maxTreeHeight = startTotalHeight;

	this.buildSearchTable(nodes, status, outputTable, maxTableHeight);

	if( this.tree.bGenerateForReportBuilder)
	{
		panemanager.showPaneElement("search");
	}
	else
	{
        // reset the tree DIV's height to ensure the left hand nav bar stays the same overall height
        treeContentsDiv.style.height = (startTotalHeight - outputTable.parentNode.offsetHeight) + "px";

        // Now limit the height of the tree
        if (treeContentsDiv.offsetHeight > maxTreeHeight)
            treeContentsDiv.style.height = maxTreeHeight + "px";

        // If the tree shrank, grow the results to compensate so the DIV stays the same height.
        if ((outputTable.parentNode.offsetHeight + treeContentsDiv.offsetHeight) != startTotalHeight)
            outputTable.parentNode.style.height = (startTotalHeight - treeContentsDiv.offsetHeight) + "px";

        // Just like above, check it again becuase Firefox sometimes gets the offsetHeight to large.
        if ((outputTable.parentNode.offsetHeight + treeContentsDiv.offsetHeight) != startTotalHeight)
            outputTable.parentNode.style.height = (startTotalHeight - (outputTable.parentNode.offsetHeight - startTotalHeight)) + "px";
	}
};

nlTreeSearchHandler.prototype.showSearchTable = function (nodes, status, maxTableHeight)
{
	var outputTable = document.getElementById(this.tree.id + "_stab");
	if (outputTable == null)
        return;

	maxTableHeight -= 26;

	this.buildSearchTable(nodes, status, outputTable, maxTableHeight);
};

nlTreeSearchHandler.prototype.buildSearchTable = function (nodes, status, outputTable, maxTableHeight)
{
    if( outputTable.firstElementChild )
        outputTable.removeChild( outputTable.firstElementChild );

    var tbody = document.createElement("TBODY");
    outputTable.appendChild(tbody);
	outputTable.parentNode.style.overflow = "auto";
	outputTable.parentNode.style.display = "";
	outputTable.parentNode.style.height = "";

    if( status == S_OK && nodes != null && nodes.length > 0 )
    {
        for (var i=0; i<nodes.length; i++)     //>
        {
            var tr = document.createElement("TR");
            tbody.appendChild(tr);
            var td = document.createElement("TD");
            tr.appendChild(td);
			var item = document.createElement("SPAN");
			item.classList.add("uir-tree-search-result-item");
			td.appendChild(item);

            var img = document.createElement("IMG");
			img.classList.add("uir-tree-search-result-item-icon")
	        item.appendChild(img);
            img.src = nlTreeImages.imageBaseUrl + nodes[i][NODE_IMAGE];

            var anchor = document.createElement("A");
            item.appendChild(anchor);
            var path = nodes[i][NODE_PATH];
			if( this.tree.bGenerateForReportBuilder)
			{
	            td.onmouseover = function(){ helpTimer = setTimeout(showComponentHelp.bind(null, path), 100)};
	            td.onmousedown = function () { return false; };
            }
            anchor.href = "javascript:void(0)";
            anchor.id = nodes[i][NODE_ID] + TREE_NODE_TITLE_ID_POSTFIX;
            anchor.classList.add("smalltextnolink", "uir-tree-search-result-item-label");
            anchor.setAttribute("tsrch_altid", nodes[i][NODE_SECONDARY_ID]);
            anchor.onclick = new Function(nodes[i][NODE_ACTION] + "; return false;");
            anchor.appendChild( document.createTextNode( nodes[i][NODE_TITLE] ) );

			if (!NS.UI.Util.isRedwood) {
				
				if (outputTable.parentNode.offsetHeight > maxTableHeight)
					outputTable.parentNode.style.height = maxTableHeight + "px";
				
				if (outputTable.parentNode.offsetHeight > maxTableHeight)
					outputTable.parentNode.style.height = (maxTableHeight - (outputTable.parentNode.offsetHeight - maxTableHeight)) + "px";
			}
		}
    }
    else
    {
        var tr = document.createElement("TR");
        tbody.appendChild(tr);
        var td = document.createElement("TD");
        tr.appendChild(td);
	    var item = document.createElement("SPAN");
	    item.classList.add("uir-tree-search-result-item", "uir-tree-search-result-item-not-found");
	    td.appendChild(item);

        var img = document.createElement("IMG");
	    img.classList.add("uir-tree-search-result-item-icon")
        img.src = NS.UI.Util.isRedwood ? "/uiredwood/icon/warning.svg" : "/images/reportbuilder/exclamation.gif";
	    item.appendChild(img);

        var label = document.createElement("SPAN");
		label.classList.add("textbold", "uir-tree-search-result-item-label");
	    label.innerHTML = "No results found";
	    item.appendChild(label);
    }
};

var hierarchyTO = 0;
var hierarchyDiv = null;
function showHierarchyDiv(td, path)
{
    var x = findPosX(td) + td.firstChild.offsetWidth + 5;
    var y = findPosY(td) - 2;
    var containerDiv = getParentElementByTag("DIV", td);
    if( containerDiv != null )
    {
        x+=containerDiv.scrollLeft;
        y-=containerDiv.scrollTop;
    }
    hierarchyTO = setTimeout("displayHierarchyDiv('"+path+"',"+x+","+y+")",750);
}

function displayHierarchyDiv(path, x, y)
{
    clearHierarchyDiv();
    hierarchyDiv = document.createElement( "DIV" );
    hierarchyDiv.style.position = "absolute";
    hierarchyDiv.style.borderStyle = "solid";
    hierarchyDiv.style.borderWidth = "1px";
    hierarchyDiv.style.borderColor = "#666666";
    hierarchyDiv.style.backgroundColor = "#EFEFEF";
    hierarchyDiv.style.padding = "4px";
    hierarchyDiv.innerHTML = "<font class='text'>"+path+"</font>";
    document.body.appendChild( hierarchyDiv );
    hierarchyDiv.style.top = y + "px";
    hierarchyDiv.style.left = x + "px";
}

function clearHierarchyDiv()
{
    clearTimeout(hierarchyTO);
    if( hierarchyDiv != null )
    {
        document.body.removeChild( hierarchyDiv );
        hierarchyDiv = null;
    }
}

/**
 * Drag and drop handler
 */
function nlTreeDragDropHandler(tree)
{
	this.tree = tree;
    this.clear();
    this.tree.addListener(E_INIT, this);
}

nlTreeDragDropHandler.prototype.initialize = function ()
{
    this.tree.getHtmlElem().dragdropHandler = this;
    document.dragdropHandler = this;
}

nlTreeDragDropHandler.prototype.clear = function ()
{
    this.mouseDown = false;
    this.eventSource = null;
    this.nodeId = null;
    this.dragContent = null;
    this.dragDiv = null;
};

nlTreeDragDropHandler.prototype.handleMouseDown = function (evnt)
{
    if (this.tree.getListeners(E_DRAGDROP) == null || this.tree.getListeners(E_DRAGDROP).length == 0)
        return true;

    var evnt = getEvent(evnt);

    this.eventSource = getEventTarget(evnt);
    this.mouseDown = true;
    return true;
 };

nlTreeDragDropHandler.prototype.handleMouseMove = function (evnt)
{
    if (!this.mouseDown)
        return true;

    var evnt = getEvent(evnt);
    if (this.dragDiv == null)
        evnt.initDragDrop = true;
    else
        evnt.initDragDrop = false;

    this.setupDragContent();
    evnt.dragContent = this.dragContent;

    if (this.dragContent != null && evnt.initDragDrop)
        this.tree.notify(E_DRAGDROP, evnt);

    if (this.dragContent == null || evnt.status == E_RESPONSE_CANCEL)
    {
        this.clear();
        evnt.cancelBubble = true;
        evnt.returnValue=false;
        return false;
    }

    this.setupDragDiv(evnt.dragDiv);
    positionDragDiv(this.dragDiv, evnt);
    this.tree.notify(E_DRAGDROP, evnt);

    evnt.cancelBubble = true;
    evnt.returnValue=false;
    return false;
};

nlTreeDragDropHandler.prototype.setupDragContent = function ()
{
    //setup drag content
    var treeNodeTitle = this.getTreeNodeTitle(this.eventSource);
    if (treeNodeTitle == null || treeNodeTitle.isfolder == "1")
    {
        // todo remove folder checking logic
        // folder cannot be dragged for report builder.
        return null;
    }
    var idx = treeNodeTitle.id.lastIndexOf(TREE_NODE_TITLE_ID_POSTFIX);
    var id = treeNodeTitle.id.substring(0, idx);
    var secondaryId = treeNodeTitle.getAttribute("tsrch_altid");
    this.dragContent = new nlTreeDragContent();
    var nodeStyle = this.tree.getNodeStyle(id);
    this.dragContent.setup(id, treeNodeTitle.innerHTML, secondaryId, nodeStyle);
    return this.dragContent;
};

nlTreeDragDropHandler.prototype.setupDragDiv = function (dragDiv)
{
    var treeNodeTitle = this.getTreeNodeTitle(this.eventSource);
    if (treeNodeTitle != null)
    {
        // folder cannot be dragged for report builder.
        if (treeNodeTitle.isfolder == "1")
            return null;

        if (this.dragDiv == null)
        {
            if (typeof dragDiv != "undefined" && dragDiv != null)
                this.dragDiv = dragDiv;
            else
                this.dragDiv = getDragDivIndicator(treeNodeTitle.innerHTML);
            document.body.appendChild(this.dragDiv);
        }
    }
    return this.dragDiv;
};

function positionDragDiv(treeDragDiv, evnt)
{
    if( (getMouseX(evnt) + treeDragDiv.offsetWidth) < (getDocumentWidth()-10) )
	    treeDragDiv.style["left"] = (getMouseX(evnt)+document.body.scrollLeft) + "px";
	treeDragDiv.style["top"] = (getMouseY(evnt) + document.body.scrollTop - treeDragDiv.offsetHeight - 3) + "px";
}

function getDragDivIndicator(label)
{
    var dragDiv = document.createElement("div");
    dragDiv.classList.add("dragbox", "uir-tree-drag-box");

    var leftArrow = document.createElement("span");
	leftArrow.classList.add('uir-tree-drag-box-arrow-left');
	dragDiv.appendChild(leftArrow);

    var labelSpan = document.createElement("span");
    labelSpan.classList.add('uir-tree-drag-box-label');
    labelSpan.appendChild(document.createTextNode(label));
    dragDiv.appendChild(labelSpan);

	var rightArrow = document.createElement("span");
	rightArrow.classList.add('uir-tree-drag-box-arrow-right');
	dragDiv.appendChild(rightArrow);

    return dragDiv;
}

nlTreeDragDropHandler.prototype.getTreeNodeTitle = function()
{
    if (this.eventSource == null)
        return;

    var elem = this.eventSource;
    var title = null;
    while(elem != null && elem != elem.parentNode)
    {
        if (elem.id != null && typeof(elem.id) == "string" /* make sure it is not a hidden field; sometimes we have hidden fields with id="id"*/)
        {
            var t = elem.id.lastIndexOf(TREE_NODE_TITLE_ID_POSTFIX);
            if (t != -1)
            {
                title = elem;
                this.nodeId = elem.id.substring(0, t);
                break;
            }
        }
        elem = elem.parentNode;
    }
    return title;
};

nlTreeDragDropHandler.prototype.handleMouseUp = function (evnt)
{
    if (!this.mouseDown)
        return true;

    var evnt = getEvent(evnt);

    if (this.dragDiv != null)
    {
        evnt.dragContent = this.dragContent;
        this.tree.notify(E_DRAGDROP, evnt);
        this.dragDiv.parentNode.removeChild(this.dragDiv);
    }
    this.clear();
    evnt.cancelBubble = true;
    evnt.returnValue=false;
    return false;
};

/**
 * listen to tree event
 */
nlTreeDragDropHandler.prototype.onEvent = function (eventId, eventObj)
{
    if (eventId == E_INIT)
        this.initialize();
};

/*
 * the exposed drag source content
 */
function nlTreeDragContent()
{
    this.nodeId = "";
    this.nodeTitle = "";
    this.secondaryId = "";
}

nlTreeDragContent.prototype.setup = function (nodeId, nodeTitle, secondaryId, nodeStyle)
{
    this.nodeId = nodeId;
    this.nodeTitle = nodeTitle;
    this.secondaryId = secondaryId;
    this.nodeStyle = nodeStyle;
};

function getTreeByName(treeName)
{
    return window[treeName];
}

/*
 * Tree class
 */
function nlTree(id)
{
    this.id = id;
    this.doc = null;
	this.rootNode = null;
    this.focusedExpandedNode = null;
    this.focusedNodePath = null;
    this.initContentElem = null;
    this.listeners = [];
    this.directChildNodes = [];
    this.total = 0;
    this.treeControlDoc = null;

    this.maxSearchResultsHeight = 90;
	this.maxSearchTreeHeight;

    this.treeImages = nlTreeImages;
    this.nodeStyleProvider = null;
    this.nodeHelpProvider = null;
    this.content = new nlTreeNodeCSVContent();
	this.contentProvider = new nlTreeContentXMLReqProvider();
    this.dragDropHandler = new nlTreeDragDropHandler(this);
    this.searchHandler = new nlTreeSearchHandler(this);
    this.treeHandler = new nlTreeHandler(this);

    // temp flag so that we do certain behavior only in the report builder
    this.bGenerateForReportBuilder = false;
    window[this.id] = this;

	this.sFocusedNodeClassName = "uir-tree-node-focused";
	this.bUseParentRefForLinks = true;
}

/**
 * Sets or removes a maximum height for the tree when showing search results.
 * Call with "false" sets a maximum height of zero so the tree doesn't show.
 * The maximum height of the tree overrides the maximum height of the results.
 * Call with "true" shows the tree by removing a maximum height restriction
 * and the maximum height of the search results is used.
 */
nlTree.prototype.showTreeOnSearch = function (bShow)
{
	if (bShow)
		delete this.maxSearchTreeHeight;
	else
		this.maxSearchTreeHeight = 0;
};

/**
 * add a child expanded node to its parent node
 */
nlTree.prototype.createExpandedNode = function (node, id, index, directChildNodes)
{
	return new nlExpandedTreeNode(node, id, index, this, directChildNodes, this.bGenerateForReportBuilder, this.bUseParentRefForLinks);
};

/**
 * add a listener of a certain event type
 * @param eventId the event to listen to
 * @param listener the listener object
 */
nlTree.prototype.addListener = function (eventId, listener)
{
    if (this.listeners[eventId] == null)
        this.listeners[eventId] = [];

    var len = this.listeners[eventId].length;
    for (var i=0; i<len; i++)
    {
        if (this.listeners[eventId][i] == listener)
            break;
    }
    if (i==len)
        this.listeners[eventId][i] = listener;
};

/**
 * get all listeners of a certain event type
 * @param eventId the event to listen to
 */
nlTree.prototype.getListeners = function (eventId)
{
    return this.listeners[eventId];
};

/**
 * create a new node
 * @param path the parent node of the new node
 * @param callbackFunc
 */
nlTree.prototype.createNode = function (path, callbackFunc)
{
	if (this.contentProvider == null)
		return null;

	this.contentProvider.createNode(path, callbackFunc);
};

/**
 * collapse an expanded node. If the node is the parent node of the focused node,
 * then change the focused node to this node.
 */
nlTree.prototype.collapse = function (path)
{
	if (this.treeHandler == null)
        return;

    this.treeHandler.collapse(path);

    var indexOffset = path.lastIndexOf('_');
    var nodePath = path.substring(0, indexOffset);
    if (this.focusedNodePath != null && this.focusedNodePath.indexOf(nodePath) != -1)
        this.setFocusedNode(nodePath);
    this.notify(E_COLLAPSE, this, path);
};

/**
 * expand the node
 */
nlTree.prototype.expand = function (path)
{
	if (this.treeHandler == null)
		return;

	this.treeHandler.expand(path);
    this.notify(E_EXPAND, this, path);
};

/**
 * expand this node and focus on it
 * this is the behavior when the user clicks on the title of the node
 * @param path the path of the node a.b.c_i( a, b, c is the path, i is the index of this node among siblings
 * @param bExpand do not expand if it is leaf node
 */
nlTree.prototype.focus = function (path, bExpand)
{
    if (bExpand == true)
        this.expand(path);

	var indexOffset = path.lastIndexOf('_');
    var nodePath = indexOffset==-1? path : path.substring(0, indexOffset);
    this.setFocusedNode(nodePath);
};

/**
 * find the index of a certain child node in a given expanded node;
 * @param node expanded node
 * @param childNodeId the Id of the child node
 */
nlTree.prototype.getChildNodeIndex = function (node, childNodeId)
{
    var numChildNodes = node.directChildNodes.length;
    var index = -1;

    for(var i=0; i<numChildNodes; i++)
    {
        if (document.getElementById(childNodeId + TREE_NODE_TITLE_ID_POSTFIX))
        {
            index = i;
            break;
        }
    }

    return index;
};

nlTree.prototype.getContentProvider = function ()
{
    return this.contentProvider;
};

/**
 * find the expanded node for the path given,
 * return null if not found
 * return the tree it self if the path is empty
 */
nlTree.prototype.getExpandedNode = function getExpandedNode(path)
{
	if (path == null)
		return null;

	var node = null;
	var pathArray = path.split(".");
	var match = false;

	var expandedNodes = this.rootNode.expandedNodes;
	for (var i=0; i<pathArray.length; i++)
	{
		match = false;
		for (var j=0; j<expandedNodes.length; j++)
		{
			if (expandedNodes[j].id == pathArray[i])
			{
				match = true;
				break;
			}
		}
		if (match && i<pathArray.length-1)
			expandedNodes = expandedNodes[j].expandedNodes;
		else
			break;
	}
	if (match)
		node = expandedNodes[j];
	if (pathArray.length == 0)
		node = this;

	return node;
};

/**
 * find the deepest expanded node along the path given,
 * return null if not found
 * return the tree it self if the path is empty
 */
nlTree.prototype.getDeepestExpandedNode = function getDeepestExpandedNode(path)
{
    if (path == null)
        return null;

	var node = this.rootNode;
	var pathArray = path.split(".");
	var match = false;

    var expandedNodes = this.rootNode.expandedNodes;
	for (var i=0; i<pathArray.length; i++)
	{
		match = false;
		for (var j=0; j<expandedNodes.length; j++)
		{
			if (expandedNodes[j].id == pathArray[i])
			{
				match = true;
				break;
			}
		}
		if (match)
        {
            node = expandedNodes[j];
            expandedNodes = expandedNodes[j].expandedNodes;
        }
        if( !match || expandedNodes == null)
			break;
	}

	return node;
};

nlTree.prototype.getDragIndicatorFromListener = function (nodeId)
{
    var nodeStyle = this.getNodeStyle(nodeId);
    var dragDivHtml = null;
    for (i=0; i<this.listeners[E_DRAGDROP].length; i++)
    {
        var listener = this.listeners[E_DRAGDROP][i];
        if (typeof listener.getDragIndicator != "undefined")
            dragDivHtml = listener.getDragIndicator(nodeId, nodeStyle)

        return;
    }
};

nlTree.prototype.getHtmlElem = function ()
{
    return this.doc.getElementById(this.id + "_b");
};

/**
 * get the child nodes of the node with given id
 */
nlTree.prototype.getNodeContent = function (id, callbackFunc)
{
	if (this.contentProvider == null)
		return null;

	return this.contentProvider.getNodeContent(id, callbackFunc);
};

nlTree.prototype.getTreeHandler = function ()
{
    return this.treeHandler;
};

nlTree.prototype.getSearchHandler = function ()
{
    return this.searchHandler;
};

nlTree.prototype.init = function (doc)
{
    this.doc = doc;
	this.initContentElem = doc.getElementById(this.id+"_i");

	var treeElem = this.getHtmlElem();
    var dragDropHandler = this.dragDropHandler;
	var that = this;

    attachEventHandler("mousedown", treeElem, function(evnt){ return dragDropHandler.handleMouseDown(evnt);});
    attachEventHandler("mousemove", treeElem, function(evnt){ return dragDropHandler.handleMouseMove(evnt);});
    attachEventHandler("mousemove", document, function(evnt){ return dragDropHandler.handleMouseMove(evnt);});
    attachEventHandler("mouseup", document, function(evnt){ return dragDropHandler.handleMouseUp(evnt);});
    attachEventHandler("load", window, function(){ setTimeout(function() { return that.load(); }, 0); }, true);
    this.notify(E_INIT, this);
};

nlTree.prototype.hasNode = function (nodeId)
{
    return document.getElementById(nodeId + TREE_NODE_TITLE_ID_POSTFIX) != null;
};

nlTree.prototype.setOnloadAction = function(s)
{
	this.fOnloadAction = new Function(s);
};

nlTree.prototype.refresh = function()
{
	this.load();
};

nlTree.prototype.load = function()
{
	this.show();
	if (this.fOnloadAction)
		this.fOnloadAction();
    this.notify(E_LOAD, this);
};

nlTree.prototype.notify = function (eventId, eventObj, params)
{
    if (this.listeners[eventId] == null)
        return;

    for (var i=0; i<this.listeners[eventId].length; i++)
        this.listeners[eventId][i].onEvent(eventId, eventObj, params);
};

nlTree.prototype.reload = function(path)
{
    if (typeof path == "undefined" || path == null || path.length ==0)
        path = "";
    if (path.indexOf("ROOT") !=0)
        path = "ROOT" + (path.length ==0 ? "" : "." + path);

    var response = this.getNodeContent(path, null);

    if ( response != null)
    {
        var expandedNodes = this.rootNode.expandedNodes;
        var focusedNodePath = this.focusedNodePath;
	    this.rootNode.expandedNodes = [];
        this.focusedNodePath = null;
        this.treeHandler.expandTreeNode(response, null, path);
        this.restoreExpandedNodes(expandedNodes);
        this.setFocusedNode(focusedNodePath);
    }

    if (this.fOnloadAction)
        this.fOnloadAction();
    this.notify(E_RELOAD, this);
};

// This method is used to restore a tree after reload.
// It expand the tree based on the previous expanded nodes structure, and tries to reduces the number of requests to server
// by expanding the only the leave nodes.
nlTree.prototype.restoreExpandedNodes = function(expandedNodes)
{
    for (var i=0; i < expandedNodes.length; i++)
    {
        var expandedNode = expandedNodes[i];
        if (expandedNode.expandedNodes.length == 0)
            this.expand(expandedNode.getPath());
        else
            this.restoreExpandedNodes (expandedNode.expandedNodes);
    }
};


/**
 * remove an expanded node from the tree
 */
nlTree.prototype.removeExpandedNode = function (node)
{
    if (node == null)
        return;

    var expandedNodes = node.parent.expandedNodes;

	for (var i=0; i<expandedNodes.length; i++)
	{
		if (expandedNodes[i] == node)
		{
			expandedNodes.splice(i, 1);
			return;
		}
	}
};

nlTree.prototype.removeListener = function (event, listener)
{
    if (this.listeners[event] == null)
       return;

    var len = this.listeners[event].length;
    for (var i=0; i<len; i++)
    {
        if (this.listeners[event][i] == listener)
            break;
    }
    if (i<len)
        this.listeners[event].splice(i, 1);
};

nlTree.prototype.search = function ()
{
    if (this.searchHandler != null)
        this.searchHandler.search();
};


nlTree.prototype.searchNode = function (searchStr, callbackFunc)
{
	if (this.contentProvider == null)
		return null;

    return this.contentProvider.search(searchStr, callbackFunc);
};

nlTree.prototype.setContentProviderUrl = function (url)
{
    if (this.contentProvider != null)
        this.contentProvider.url = url;
};

nlTree.prototype.setGenerateForReportBuilder = function (b)
{
    this.bGenerateForReportBuilder = b;
};

nlTree.prototype.setFocusedExpandedNode = function (node)
{
	this.focusedExpandedNode = node;
};

/**
 * Set the focused node Id and highlight the node focused on UI
 * The node can be a leaf node, i.e. node without children. Therefore cannot
 * use expandedNode functions.
 * @param path the path of the node in the format of a.b.c
 */
nlTree.prototype.setFocusedNode = function (path)
{
    if (path == null || path == this.focusedNodePath)
        return;

    var node = this.getNodeByPath(path);
    var currentlyFocusedNode = this.focusedNodePath ? this.getNodeByPath(this.focusedNodePath) : null;

    // sometimes nodes are the same even if nodePaths are different (sometimes nodePath doesn't contain parent)
    if (node === currentlyFocusedNode) {
        return;
    }

    if (node != null)
    {
		node.classList.add(this.sFocusedNodeClassName);
        jQuery(node).parent().addClass('uir-tree-node-parent-focused');

        node.scrollIntoView();
    }

    this.unselectFocusedNode();

    this.focusedNodePath = path;
};

/**
 * Unselects the currently selected tree node (the one specified in this.focusedNodePath).
 * If no node is selected, nothing happens
 */
nlTree.prototype.unselectFocusedNode = function ()
{
    if (this.focusedNodePath == null)
    {
        return;
    }

    var node = this.getNodeByPath(this.focusedNodePath);
    jQuery(node).parent().removeClass('uir-tree-node-parent-focused');

    if (node != null)
    {
		node.classList.remove(this.sFocusedNodeClassName);
    }
};

/**
 * Finds the node in the tree which points to the given path
 */
nlTree.prototype.getNodeByPath = function (path)
{
    var pathArray = path.split(".");
    var nodeId = pathArray[pathArray.length - 1];
    var node = document.getElementById(nodeId + TREE_NODE_TITLE_ID_POSTFIX);

    return node;
};

/**
 * set the the inital top level nodes
 */
nlTree.prototype.setInitContent = function (content)
{
    this.initContentElem.innerHTML = content;
    this.directChildNodes = [];
};

/**
 * show the top level nodes
 */
nlTree.prototype.show = function(directChildNodes)
{
    if (directChildNodes)
        this.directChildNodes = directChildNodes;
    else if (this.directChildNodes.length == 0)
    {
        if (this.initContentElem)
        {
            var sText = this.initContentElem.innerHTML;
            var content = new nlTreeNodeCSVContent();
            content.parse (sText);
            this.directChildNodes = content.getNodes();
        }
        else if (this.contentProvider)
        {
            var content = this.contentProvider.getNodeContent("ROOT");
            this.directChildNodes = content.getNodes();
        }
    }
    if (!this.directChildNodes) {
	    this.directChildNodes = [];
    }

	this.rootNode = this.createExpandedNode(null,'',0,this.directChildNodes);
	this.rootNode.showChildren(this.doc, this.directChildNodes);
};

nlTree.prototype.updateNodeStyle = function (nodeId, nodeStyle, bClearSavedClassName)
{
	var nodeIconElem = this.doc.getElementById(nodeId + "_i");
    if (nodeIconElem != null && nodeStyle[NODE_STYLE_IMAGE] != null)
        nodeIconElem.src = nodeStyle[NODE_STYLE_IMAGE];

    var nodeLabelElem = this.doc.getElementById(nodeId + TREE_NODE_TITLE_ID_POSTFIX );
    if (nodeLabelElem != null)
    {
        if(nodeStyle[NODE_STYLE_CSS] != null)
        {
            nodeLabelElem.className = nodeStyle[NODE_STYLE_CSS];
            if (bClearSavedClassName && nodeLabelElem.origClassName)
                nodeLabelElem.origClassName = null;
        }
        var tooltipAttrName = this.nodeHelpProvider ? this.nodeHelpProvider.getTooltipAttributeName() : "title" ;
        if(nodeStyle[NODE_STYLE_LABEL] != null)
        {
            nodeLabelElem.innerHTML = nodeStyle[NODE_STYLE_LABEL];
            nodeLabelElem[tooltipAttrName] = nodeStyle[NODE_STYLE_LABEL];
            nodeLabelElem.altText = nodeStyle[NODE_STYLE_LABEL];
        }
        if(nodeStyle[NODE_ALT_TITLE] != null)
            nodeLabelElem[tooltipAttrName] = nodeStyle[NODE_ALT_TITLE];
    }

    if (nodeStyle[NODE_STYLE_ACTION] != null)
        window["tnaction_" + nodeId] = nodeStyle[NODE_STYLE_ACTION];
};

nlTree.prototype.getNodeStyle = function (nodeId)
{
    var nodeStyle = {};

    var nodeIconElem = this.doc.getElementById(nodeId + "_i");
	if (nodeIconElem != null)
        nodeStyle[NODE_STYLE_IMAGE] = nodeIconElem.src;
    var nodeLabelElem = this.doc.getElementById(nodeId + TREE_NODE_TITLE_ID_POSTFIX );
    if (nodeLabelElem != null)
    {
        nodeStyle[NODE_STYLE_CSS] = nodeLabelElem.className
        nodeStyle[NODE_STYLE_LABEL] = nodeLabelElem.innerHTML;
    }
    return nodeStyle;
};


nlTree.prototype.updateNodeLineActionStyle = function (nodeId, actionId, nodeLineActionStyle)
{
    var actionId = "tnlineaction_" + nodeId + "_" + actionId;
    var actionElem = document.getElementById(actionId);
    if (nodeLineActionStyle[NODE_LINE_ACTION] == null)
    {
        actionElem.style.display = "none";
    }
    else
    {
        var label = nodeLineActionStyle[NODE_LINE_ACTION_TEXT];
        actionElem.title = (label != null && label.length>0) ? escapeHTMLAttr(label) : "";
        var image = nodeLineActionStyle[NODE_LINE_ACTION_IMG];
        if(image)
            actionElem.innerHTML = "<img src=\"" + image + "\" style='vertical-align:top;' />";
        else
            actionElem.innerHTML = label;
    }
};

// get the element that contains the all the node pieces ( the line )
nlTree.prototype.getNodeLine = function nlTree_getNodeLine(nodeId)
{
    var nodeLineElem = this.doc.getElementById(nodeId + "_l");
    return nodeLineElem;
};

nlTree.prototype.getNodeChildElem = function nlTree_getNodeChildElem(nodeId)
{
    var nodeChildElem = this.doc.getElementById(nodeId + "_c");
    return nodeChildElem;
};


nlTree.prototype.setDefaultImage = function (imageType, image)
{
    if (this.treeImages == nlTreeImages)
        this.treeImages = clone(nlTreeImages);
    this.treeImages[imageType]=image;
};

nlTree.prototype.setFocusedNodeClassName = function (sClassName)
{
	this.sFocusedNodeClassName = sClassName;
};

nlTree.prototype.setUseParentRefForLinks = function (bUseParentRefs)
{
	this.bUseParentRefForLinks = bUseParentRefs;
};

nlTree.prototype.showNodeHelp = function nlTree_showNodeHelp(evnt, node, hierarchy)
{
    if(!this.nodeHelpProvider)
        return;

    if (this.nodeHelpProvider.showHelp)
        this.nodeHelpProvider.showHelp(evnt, node, hierarchy);
    else
    {
        var htmlStr = nodeHelpProvider.getHelpHtml(hierarchy);
        var helpElemId = nodeHelpProvider.getHelpElemId(hierarchy);
        clearTimeout(helpTimer);
        var helpElem = document.getElementById(helpElemId);
        if(!helpElem)
            return;

        helpElem.innerHTML = htmlStr;
    }
};

nlTree.prototype.hideNodeHelp = function nlTree_showNodeHelp(evnt, node, hierarchy)
{
    if(!this.nodeHelpProvider)
        return;

    if (this.nodeHelpProvider.hideHelp)
        this.nodeHelpProvider.hideHelp(evnt, node, hierarchy);

    // does not handle the case when the help is shown in help panel
};

/*
 * TreeNode class
 */
function nlExpandedTreeNode(node, id, index, tree, directChildNodes, generateForReportBuilder, useParentRefForLinks)
{
	this.node = node;
    this.expandedNodes = [];
    this.id = id;
    this.tree = tree;
    this.index = index;
    this.parent = null;
    this.lastChildId = null;
    this.opened = true;
    this.level = -1;
    this.htmlElem = null;
    this.titleElem = null;
    this.stateElem = null;
    this.childElem = null;
    this.htmlId = null;
	this.directChildNodes = directChildNodes;
    this.bGenerateForReportBuilder = generateForReportBuilder;
	this.bUseParentRefForLinks = useParentRefForLinks;
}

nlExpandedTreeNode.prototype.getDirectChildNode = function(id) {
	for (var i = 0; i < this.directChildNodes.length; i++) {
		if (this.directChildNodes[i][NODE_ID] === id) {
			return this.directChildNodes[i];
        }
    }
}

nlExpandedTreeNode.prototype.addChild = function (node)
{
	node.parent = this;
	node.level = this.level + 1;

    this.expandedNodes.splice(this.findNewNodePosition(node.index), 0, node);
};

nlExpandedTreeNode.prototype.findNewNodePosition = function (index)
{
	var expandedNodes = this.expandedNodes;
	for (var i=0; i<expandedNodes.length; i++)
	{
		if (expandedNodes[i].index > index)
			return i;
	}
	return expandedNodes.length;
};

nlExpandedTreeNode.prototype.getChildElem = function (doc)
{
    return doc.getElementById(this.getHtmlId() + "_c");
};

nlExpandedTreeNode.prototype.getExpandedChildNode = function (id)
{
	for (var i = 0; i < this.expandedNodes.length; i ++)
    {
        if (this.expandedNodes[i].id == id)
            return this.expandedNodes[i];
    }
    return null;
};

nlExpandedTreeNode.prototype.getHtmlElem = function (doc)
{
	return doc.getElementById(this.getHtmlId());
};

nlExpandedTreeNode.prototype.getStateElem = function (doc)
{
	return doc.getElementById(this.getHtmlId() + "_s");
};

nlExpandedTreeNode.prototype.getIconElem = function (doc)
{
	return doc.getElementById(this.getHtmlId() + "_i");
};

nlExpandedTreeNode.prototype.getStateLinkElem = function (doc)
{
	return doc.getElementById(this.getHtmlId() + "_sl");
};

nlExpandedTreeNode.prototype.getTitleElem = function (doc)
{
	return doc.getElementById(this.getHtmlId() + TREE_NODE_TITLE_ID_POSTFIX);
};

/**
 * get path of the ndoe
 */
nlExpandedTreeNode.prototype.getPath = function ()
{
    //handle the virtaul node when show the top level ndoes
    if (this.level < 0)
        return "";

    var path = this.id;
    var node = this.parent;
    while (node.level >= 0)
	{
		path = node.id + "." + path;
        node = node.parent;
    }
	return path;
};

/**
 * get html id of the ndoe
 */
nlExpandedTreeNode.prototype.getHtmlId = function ()
{
    //handle the virtual node when show the top level nodes
    return (this.level < 0) ? this.tree.id + "_b" : this.id;
};

nlExpandedTreeNode.prototype.addChildNode = function nlExpandedTreeNode_addChildNode(doc, childNode)
{
    var childHtmlElem = this.getChildElem(doc);
    var lastChildInfo = this.getLastChildInfo();
    var nlTreeImages = this.tree.treeImages;
    if (childNode.length > 0)
    {
        var imgUrl = "";
        var lastChildId = childHtmlElem.lastChild.id;
        var stateImageNode = doc.getElementById(lastChildId + "_ti");
        var expandedChildNode = this.getExpandedChildNode(lastChildId);
        if (expandedChildNode != null)
        {
            imgUrl = nlTreeImages.tMinusIcon;

            var childElem = expandedChildNode.getChildElem(doc);
            lastChildInfo[lastChildInfo.length] = false;
            for (var k = 0; k < childElem.childNodes.length; k++)
            {
                lastChildInfo[lastChildInfo.length - 1] = k < (childElem.childNodes.length -1);
                var hierarchyElem = doc.getElementById(childElem.childNodes[k].id + "_h");
                hierarchyElem.innerHTML = expandedChildNode.renderHierarchy(lastChildInfo);
            }
            lastChildInfo.splice(lastChildInfo.length - 1, 1);
        }
        else
        {
            if (stateImageNode.src.indexOf(nlTreeImages.imageBaseUrl + nlTreeImages.lPlusIcon) >= 0)
                imgUrl = nlTreeImages.tPlusIcon;
            else if (stateImageNode.src.indexOf(nlTreeImages.imageBaseUrl + nlTreeImages.lIcon) >= 0)
                imgUrl = nlTreeImages.tIcon;
        }
        stateImageNode.src = nlTreeImages.imageBaseUrl + imgUrl;
    }
    lastChildInfo[this.level + 1] = true;
	this.directChildNodes.push(childNode);
    childHtmlElem.innerHTML += this.renderChild(this.directChildNodes.length - 1, childNode, lastChildInfo);
    this.lastChildId = childNode[NODE_ID];
};

nlExpandedTreeNode.prototype.showCollapsed = function ()
{
	var doc = this.tree.doc;
	this.showUpdatedNode(doc);
	this.showChildren(doc, []);
};

nlExpandedTreeNode.prototype.showExpanded = function ()
{
	var doc = this.tree.doc;
	this.showUpdatedNode(doc);
	this.showChildren(doc, this.directChildNodes);
};

nlExpandedTreeNode.prototype.showChildren = function (doc, childNodes)
{
	if (doc == null) return;

	var htmlStr = [];
	var lastChildInfo = this.getLastChildInfo();

	lastChildInfo[lastChildInfo.length] = false;
	htmlStr[htmlStr.length] = "";
	for (var i=0; i<childNodes.length; i++)
	{
		if (i == childNodes.length-1)
		{
			lastChildInfo[lastChildInfo.length-1] = true;
			this.lastChildId = childNodes[i][NODE_ID];
		}
		htmlStr[htmlStr.length] = this.renderChild(i, childNodes[i], lastChildInfo);
	}

	var childHtmlElem= this.getChildElem(doc);
	if (childHtmlElem == null)
	{
		htmlStr[0] = "<span id=\"" + this.getHtmlId()+ "_c\" >";
		htmlStr[htmlStr.length] = "</span>";
		this.getHtmlElem(doc).innerHTML += htmlStr.join("");
	}
	else
	{
        childHtmlElem.innerHTML = htmlStr.join("");
	    childHtmlElem.style.display = (childNodes.length > 0 ? "" : "none");
    }
};

/**
 * Show the state of the node, i.e. +/- sign, open/closed folder icon.
 */
nlExpandedTreeNode.prototype.showUpdatedNode = function (doc)
{
	var stateElem = this.getStateElem(doc);
	if (stateElem)
		stateElem.innerHTML = this.renderNodeState(this.getPath(), this.id, this.index, this.level, this.parent.lastChildId == this.id, this.node[NODE_FOLDER], this.opened, "1" == this.node[NODE_INACTIVE]);

    var iconElem = this.getIconElem(doc);
    if (iconElem)
	    iconElem.src = this.opened ? iconElem.dataset.openIcon : iconElem.dataset.icon;
};

nlExpandedTreeNode.prototype.renderChild = function (index, childNode, lastChildInfo)
{
	var htmlStr = [];

    var path = this.getPath();
    if (path != "")
        path += ".";
    var path = path + childNode[NODE_ID];
    var htmlId = childNode[NODE_ID];
    htmlStr[htmlStr.length] = "<span id=\"" + htmlId + "\">";
    htmlStr[htmlStr.length] = "<div id=\"" + htmlId + "_l\" nowrap style=\"white-space: nowrap;\" class ='" + TREE_NODE_ROW_CSS_CLASS +"'>";
    htmlStr[htmlStr.length] = "<span id=\"" + htmlId + "_h" + "\">";
    htmlStr[htmlStr.length] = this.renderHierarchy(lastChildInfo);
    htmlStr[htmlStr.length] = "</span>";
    htmlStr[htmlStr.length] = "<span id=\"" + htmlId + "_s" + "\">";
    htmlStr[htmlStr.length] = this.renderNodeState(path, htmlId, index, lastChildInfo.length-1, lastChildInfo[lastChildInfo.length-1], childNode[NODE_FOLDER], false, "1" == childNode[NODE_INACTIVE]);
    htmlStr[htmlStr.length] = "</span>";
    htmlStr[htmlStr.length] = this.renderTitle(path, htmlId, index, childNode[NODE_TITLE], childNode[NODE_ALT_TITLE], childNode[NODE_ACTION], childNode[NODE_SECONDARY_ID], childNode[NODE_FOLDER], false, childNode[NODE_IMAGE], childNode[NODE_IMAGE_OPEN],childNode[NODE_PATH], childNode[NODE_INACTIVE]);
    if (childNode[NODE_LINE_ACTION])
        htmlStr[htmlStr.length] = this.renderLineAction(path, htmlId, 0 /*may have more in the future*/, childNode[NODE_LINE_ACTION], childNode[NODE_LINE_ACTION_TEXT], childNode[NODE_LINE_ACTION_IMG]);
    htmlStr[htmlStr.length] = "</div>";

    htmlStr[htmlStr.length] = "</span>"
    return htmlStr.join("");
};

nlExpandedTreeNode.prototype.renderHierarchy = function (lastChildInfo)
{
	//show indent
    var nlTreeImages = this.tree.treeImages;
    var htmlStr = [];
	for (var i=0; i<lastChildInfo.length-1; i++)
	{
		if (lastChildInfo[i])
			htmlStr[htmlStr.length] = "<img src=\"" + nlTreeImages.imageBaseUrl + nlTreeImages.blankIcon + "\" border=\"0\" style=\"vertical-align:top;\" />";
		else
			htmlStr[htmlStr.length] = "<img src=\"" + nlTreeImages.imageBaseUrl + nlTreeImages.barIcon + "\" border=\"0\" style=\"vertical-align:top;\" />";
	}

	return htmlStr.join("");
};

nlExpandedTreeNode.prototype.renderNodeState = function (path, id, index, level, isLastChild, isFolder, isOpen, isInactive)
{
    var nlTreeImages = this.tree.treeImages;
    var htmlStr = [];
    var toggleUrl = (this.bUseParentRefForLinks ? "parent." : "") +  this.tree.id;
	var toggleIcon = null;
    isFolder = (isFolder==1);

    var toggleIconStyle = "vertical-align:top;";

    if (this.tree.nodeStyleProvider != null && this.tree.nodeStyleProvider.getNodeStateStyle != null)
    {
        var nodeStateStyle = this.tree.nodeStyleProvider.getNodeStateStyle(id, toggleIconStyle);
        if (nodeStateStyle != null)
        {
            toggleIcon = nodeStateStyle[NODE_STYLE_IMAGE];
            toggleIconStyle = nodeStateStyle[NODE_STYLE_CSS];
        }
    }

    if (!toggleIcon)
    {
        if (isFolder)
        {
            if (this.directChildNodes.length>0) {
	            if (isOpen) {
		            if (level == 0)
			            toggleIcon = nlTreeImages.minusIcon;
		            else {
			            if (isLastChild)
				            toggleIcon = nlTreeImages.lMinusIcon;
			            else
				            toggleIcon = nlTreeImages.tMinusIcon;
		            }
		            toggleUrl += ".collapse('" + path + "_" + index + "')";
	            } else {
		            if (level == 0)
			            toggleIcon = nlTreeImages.plusIcon;
		            else {
			            if (isLastChild)
				            toggleIcon = nlTreeImages.lPlusIcon;
			            else
				            toggleIcon = nlTreeImages.tPlusIcon;
		            }
		            toggleUrl += ".expand('" + path + "_" + index + "')";
	            }
            } else {
	            toggleIcon = nlTreeImages.blankIcon;
            }
        }
        else if (this.id == id)  //logical folder, not tree foder (i.e. will never contain child expanded nodes
        {
            if (level == 0)
                toggleIcon = nlTreeImages.blankIcon;
            else
            {
                if (isLastChild)
                    toggleIcon = nlTreeImages.lIcon;
                else
                    toggleIcon = nlTreeImages.tIcon;
            }
        }
        else
        {
            if (level == 0)
                toggleIcon = nlTreeImages.blankIcon;
            else
            {
                if (isLastChild)
                    toggleIcon = nlTreeImages.lIcon;
                else
                    toggleIcon = nlTreeImages.tIcon;
            }
        }
     }

     if(isFolder)
        htmlStr[htmlStr.length] = "<a class='smalltextnolink' id=\"" + id + "_sl\" href=\"javascript:void(0);\" onclick=\"" + toggleUrl + "; return false;\">";
     htmlStr[htmlStr.length] = "<img id='" + id + "_ti' src=\"" + nlTreeImages.imageBaseUrl + toggleIcon + "\" border=\"0\" style=\""+ toggleIconStyle +  "\" />";
     if(isFolder)
        htmlStr[htmlStr.length] = "</a>";

    return htmlStr.join("");
};

nlExpandedTreeNode.prototype.getNodeIcon = function (id, isFolder, isOpen)
{
    var nodeIcon;
    var nlTreeImages = this.tree.treeImages;
    var nodeIconElem = this.tree.doc.getElementById(id + "_i");

    /*
     * if the node has open iamge and the state is open then use it
     * else if the node has close iamge then use it for both open or close state
     * otherwise use the default icon
     */
    if (nodeIconElem != null)
    {
        if (isOpen && typeof nodeIconElem.openIcon != "undefined" && nodeIconElem.openIcon != null && nodeIconElem.openIcon != "")
            return nlTreeImages.imageBaseUrl + nodeIconElem.openIcon;
        else if (typeof nodeIconElem.closeIcon != "undefined" && nodeIconElem.closeIcon != null && nodeIconElem.closeIcon != "")
            return nlTreeImages.imageBaseUrl + nodeIconElem.closeIcon;
    }

    if (isFolder == 1)
	{
		if (isOpen)
            nodeIcon = nlTreeImages.folderOpenIcon;
        else
            nodeIcon = nlTreeImages.folderIcon;
    }
    else
        nodeIcon = nlTreeImages.fileIcon;

    return nlTreeImages.imageBaseUrl + nodeIcon;
};

nlExpandedTreeNode.prototype.renderNodeIcon = function (id, isFolder, isOpen, nodeImage, nodeImageOpen, nodeUrl, alttitle, mouseHandlers)
{
    var nodeIconStyle = null;
    var nodeStyle = "cursor:pointer;";

    if (this.tree.nodeStyleProvider != null && this.tree.nodeStyleProvider.getNodeIconStyle != null)
    {
        nodeIconStyle = this.tree.nodeStyleProvider.getNodeIconStyle(id, nodeStyle);
        if (nodeIconStyle != null)
        {
	        nodeImage = nodeImageOpen = nodeIconStyle[NODE_STYLE_IMAGE];
            nodeStyle = nodeIconStyle[NODE_STYLE_CSS];
        }
    }

    if (!nodeImage)
	    nodeImage = this.getNodeIcon(id, isFolder, false);
	if (!nodeImageOpen)
		nodeImageOpen = this.getNodeIcon(id, isFolder, true);

    var tooltipAttrName = this.tree.nodeHelpProvider ? this.tree.nodeHelpProvider.getTooltipAttributeName() : "title" ;
    return "<img id=\"" + id + "_i\" class=\"uir-tree-node-icon\"" +(alttitle != null && alttitle.length>0 ? tooltipAttrName + "='"+escapeHTMLAttr(alttitle)+"' " : "")+"onclick=\"" + nodeUrl + "\" src=\"" + (isOpen?nodeImageOpen:nodeImage) + "\" style='" + nodeStyle + "' border=\"0\" style=\"vertical-align:top;\" data-open-icon=\"" + nodeImageOpen + "\" data-icon=\"" + nodeImage + "\"" + mouseHandlers + " />";
};

nlExpandedTreeNode.prototype.renderTitle = function (path, id, index, title, alttitle, action, secondaryId, isFolder, isOpen, nodeImage, nodeImageOpen, hierarchy, isInactive)
{
    var htmlStr = [];
	var nodeUrl = "";
    var defaultAction = "";
    var nlTreeImages = this.tree.treeImages;

    if (isFolder == 1)
        defaultAction = (this.bUseParentRefForLinks ? "parent." : "") + this.tree.id + ".focus('" + path  + "_" + index + "', true);";
    else
        defaultAction = (this.bUseParentRefForLinks ? "parent." : "") + this.tree.id + ".focus('" + path  + "_" + index + "', false);";

    var actionId = "tnaction_" + id;
    if (action != "undefined" && action != null && action != "")
    {
        window[actionId] = action;
        nodeUrl = "if (eval(window['" + actionId + "']) != false) ";
    }

    nodeUrl += '{' + defaultAction + '; }; event.stopPropagation(); return false;';

	var mouseHandlers;
    if (this.bGenerateForReportBuilder && isFolder==0)
        mouseHandlers = "onmouseover=\"showComponentHelp('"+escapeHTMLAttr(hierarchy)+"');\"";
    else if (this.tree.nodeHelpProvider)
    {
        mouseHandlers = "onmouseover=\"window['" + this.tree.id + "'].showNodeHelp(event, this, '"+escapeHTMLAttr(hierarchy)+"'); return true;\"";
        mouseHandlers += " onmouseout=\"window['" + this.tree.id + "'].hideNodeHelp(event, this, '"+escapeHTMLAttr(hierarchy)+"'); return true;\"";
    }
    mouseHandlers += " onmousedown=\"return false;\"";

    var nodeStyle = null;
    if (this.tree.nodeStyleProvider != null)
        nodeStyle = this.tree.nodeStyleProvider.getNodeStyle(id);

    var imageBaseUrl = nlTreeImages.imageBaseUrl;
	if (nodeImage) {
		nodeImage = imageBaseUrl+nodeImage;
    }
	if (nodeImageOpen) {
		nodeImageOpen = imageBaseUrl+nodeImageOpen;
	} else {
		nodeImageOpen = nodeImage;
    }
    if (nodeStyle != null)
    {
        if (nodeStyle[NODE_STYLE_IMAGE] != null)
        {
	        nodeImageOpen = nodeImage = nodeStyle[NODE_STYLE_IMAGE];
        }
        if (nodeStyle[NODE_STYLE_ACTION] != null)
            window[actionId] = nodeStyle[NODE_STYLE_ACTION];
        if (nodeStyle[NODE_STYLE_LABEL] != null)
            title = nodeStyle[NODE_STYLE_LABEL];
    }

    // only keep the tooltip text if the tooltip is not shown as ballon popup
    if (!this.tree.nodeHelpProvider && alttitle)
        alttitle = alttitle.split(String.fromCharCode(6))[0];
    var tooltipAttrName = this.tree.nodeHelpProvider ? this.tree.nodeHelpProvider.getTooltipAttributeName() : "title" ;

    htmlStr[htmlStr.length] = this.renderNodeIcon(id, isFolder, isOpen, nodeImage, nodeImageOpen, nodeUrl, alttitle, mouseHandlers);

    var style;
    if (nodeStyle != null && nodeStyle[NODE_STYLE_CSS] != null)
        style = nodeStyle[NODE_STYLE_CSS];
    else
        style = "smalltextnolink uir-tree-node";

    if ("1" === isInactive) {
        style += " uir-tree-node-inactive";
    }

    htmlStr[htmlStr.length] = "<span "+(alttitle != null && alttitle.length>0 ? tooltipAttrName + "='"+escapeHTMLAttr(alttitle)+"' " : "")+"style='vertical-align:top; cursor:pointer; margin-right:5px; ' class='" + style + "' id=\"" + id + TREE_NODE_TITLE_ID_POSTFIX + "\" onclick=\"" + nodeUrl + "\" altText=\"" + escapeHTMLAttr(title) + "\" isfolder=\"" + isFolder + "\" "+mouseHandlers+" tsrch_altid=\"" + secondaryId + "\">";
    htmlStr[htmlStr.length] = title;
    htmlStr[htmlStr.length] = "</span>";
    return htmlStr.join("");
};

nlExpandedTreeNode.prototype.renderLineAction = function (path, id, actionIdx, action, label, image)
{
    var htmlStr = [];
	var nodeUrl = "";

    var actionId = "tnlineaction_" + id + "_" + actionIdx ;
    window[actionId] = action;
    nodeUrl = "return eval(window['" + actionId + "'])";

    // can apply node style from node style provider in the future if needed
    htmlStr[htmlStr.length] = "<span "+(label != null && label.length>0 ? "title='"+escapeHTMLAttr(label)+"' " : "")+" style='padding-left:5px; vertical-align:top; cursor:pointer;'  class='smalltextnolink' id='" + actionId + "' onclick=\"" + nodeUrl + "\">";
    if(image)
    {
        htmlStr[htmlStr.length] = "<img src=\"" + image + "\" style='vertical-align:top;' />";
    }
    else
        htmlStr[htmlStr.length] = label;
    htmlStr[htmlStr.length] = "</span>";
    return htmlStr.join("");
};

nlExpandedTreeNode.prototype.getLastChildInfo = function ()
{
	var lastChild = [];
	var node = this;

    // handle the virtaul node when show the top level ndoes
    if (node.level < 0)
        return lastChild;

    while(node != null)
	{
		if (node.parent==null || node.parent.lastChildId == node.id)
			lastChild[node.level] = true;
        else
            lastChild[node.level] = false;
        node = node.parent;
    }

	return lastChild;
};

/**
 * This is the default help content provider and help renderer
 */
function nlTreeNodeHelpProvider ()
{
    this.title = null;
    this.icon = null;
    this.details = null;
    this.tooltipAttrName = 'tooltip';
    this.tooltipPopup = null;
    this.timer = null;
}

/**
 * Set a timer to Show node help as a ballon pupup with 1 second delay
 * @param node The html element for tree node title
 * @param hierarchy The string that identifies the hierarchy of the node
 */
nlTreeNodeHelpProvider.prototype.showHelp = function nlTreeNodeHelpProvider_showHelp (evnt, node, hierarcy)
{
    if (this.timer)
        clearTimeout(this.timer);

    this.mouseX = getMouseX(evnt);
    this.mouseY = getMouseY(evnt);
    this.node = node;
    this.hierarcy = hierarcy;
    this.timer = setTimeout( function ()
                            {
                                this.doShowHelp(this.mouseX, this.mouseY, this.node, this.hierarchy);
                            }.bind(this), 300);
};

nlTreeNodeHelpProvider.prototype.doShowHelp = function nlTreeNodeHelpProvider_showHelp (mouseX, mouseY, node, hierarcy)
{

    var tooltipInfo = this.getTooltipInfo(node, hierarcy);
    if (tooltipInfo && tooltipInfo.length > 0)
        this.tooltipPopup = nlShowTooltip (mouseX, mouseY, null, tooltipInfo[0], tooltipInfo[1], tooltipInfo[2]);

};

/*
 * hide balloon node help
 */
nlTreeNodeHelpProvider.prototype.hideHelp = function nlTreeNodeHelpProvider_showHelp ()
{
    if (this.timer)
        clearTimeout(this.timer);
    if (this.tooltipPopup)
        this.tooltipPopup.close();

};

nlTreeNodeHelpProvider.prototype.getTooltipAttributeName = function nlTreeNodeHelpProvider_getTooltipAttributeName ()
{
    return this.tooltipAttrName;
}

nlTreeNodeHelpProvider.prototype.getTooltipInfo = function nlTreeNodeHelpProvider_getTooltipInfo (node, hierarcy)
{
    var tooltipInfo = null;
    var tooltip = node[this.tooltipAttrName];
    if (tooltip && tooltip.length > 0)
        tooltipInfo = tooltip.split(String.fromCharCode(6));
    return tooltipInfo;
};

// dashboard related manipulation








var NODE_ACTIVE = 12;
var NODE_PORTLETKEY = 14;
var NODE_COLUMN = 15;
var NODE_LOCK = 13;

//dashboard customization
function nlCustomizeDashboard (treeObj)
{
    var dashboardDiv = document.getElementById("nav_pane");
    if (dashboardDiv.parentNode.style.display == "")
        return;
    else
        dashboardDiv.waitForTree = true;
    if (treeObj)
    {
        treeObj.reload();
        treeObj.expand("standardcontent");
    }
    window.editDashboard = true;
}

function nlShowDashboardCustPane ()
{
    var dashboardDiv = document.getElementById("nav_pane");
    if (dashboardDiv== null || !dashboardDiv.waitForTree)
        return;

    dashboardDiv.parentNode.style.display = "";

    setDashboardCustPaneSize();

    attachEventHandler("resize", window, resizeDashboardCustPane);

    clearTimeout(chartResizingTimeout);
    chartResizingTimeout = setTimeout(reflowAllCharts, 300); //once the CustPane is opened the all the HC need to be redrawed. Issue 221984

    dashboardDiv.waitForTree = false;
}

function resizeDashboardCustPane()
{
    var dashboardDiv = document.getElementById("nav_pane");
    if(dashboardDiv.resizeTimer)
    	clearTimeout(dashboardDiv.resizeTimer);
	dashboardDiv.resizeTimer = setTimeout(setDashboardCustPaneSize,500);
}

function setDashboardCustPaneSize ()
{
    var treeDiv = document.getElementById("div__nav_tree");
    treeDiv.style.height = Number(getDocumentClientHeight()) - Number(findPosY(document.getElementById("div__nav_tree"))) + "px";
}

function closeDashboardCustPane ()
{
    var dashboardDiv = document.getElementById("nav_pane");
    if (dashboardDiv)
    {
        dashboardDiv.parentNode.style.display = "none";
        dashboardDiv.waitForTree = false;
    }

    if(window.detachEvent)
        window.detachEvent("onresize", resizeDashboardCustPane);
    else if(window.addEventListener)
        window.removeEventListener("resize", resizeDashboardCustPane, false);

    clearTimeout(chartResizingTimeout);
    chartResizingTimeout = setTimeout(reflowAllCharts, 300); //once the CustPane is closed the all the HC need to be redrawed. Issue 221984

    window.editDashboard = false;
    return false;
}

function updatePortletTree(tree, nodeId, bHide, portletKey, portletShellTempId, portletDivId)
{
    var nodeInfo = nodeId.split("_");
    if (nodeInfo.length < 2)
        return null;

    enablePortletTreeNode(tree, nodeId, bHide);
    var tr = document.getElementById(portletShellTempId);
    var sectionId = getParameter("sc", document);
    if(!bHide)
    {
        if (!tr)
            return;
        tr.id = "handle_portlet_" + portletKey;
        var div = tr.getElementsByTagName("div")[0];
        div.id = portletDivId + "_splits";
        var iframe = tr.getElementsByTagName("iframe")[0];
        iframe.id = portletDivId + "_frame";

        //portlet is visible, add hide portlet link
        var linkElem = div.getElementsByTagName("A")[0];
        linkElem.href = "javascript:hidePortlet(" + sectionId + "," + portletKey + ", 'portlet_" + portletKey + "');";

        if(tr.bDelete)
        {
            // user wants to delete the portlet while waiting for response
            hidePortlet(sectionId, portletKey, div.id);
            tr.bDelete = false;
        }
    }

    // update the num of available portlets of parent category
    var contentSrcName = tree.id + "_data";
    if (isReportPortlet(nodeInfo[0]))
    {
        var nodeId = "reportcontent";
        window[contentSrcName][nodeId].availablePortlets = getAvailablePortlets(nodeId);
        tree.updateNodeStyle(nodeId, tree.nodeStyleProvider.getNodeStyle(nodeId));
    }
    else if (isTrendPortlet(nodeInfo[0]))
    {
        var nodeId = "trendcontent";
        window[contentSrcName][nodeId].availablePortlets = getAvailablePortlets(nodeId);
        tree.updateNodeStyle(nodeId, tree.nodeStyleProvider.getNodeStyle(nodeId));
    }
}

function removeShellPortlet(trId, bDefer, portletNodeId)
{
    var portletShell = document.getElementById(trId) ;
    if(bDefer)
        portletShell.bDelete = true;
    else
    {
        // cannot add portlet on server, restore ui
        if (portletShell.parentNode)
            portletShell.parentNode.removeChild(portletShell);

        enablePortletTreeNode(tree_portlet, portletNodeId, true);
    }
}

function isReportPortlet(type)
{
    return (type == "enhancedcontent" ||
            type == "customcontent" ||
            type == "smpcontent");
}

function isTrendPortlet(type)
{
    return (type == "trendcontent");
}

function getAvailablePortlets(type)
{
    var availablePortlets = Number.MAX_VALUE;
    var categories = null;
    if (type == "enhancedcontent" ||
        type == "customcontent" ||
        type == "smpcontent")
        type = "reportcontent";
    
    if (type == "reportcontent")
    {
        categories = ["enhancedcontent", "customcontent", "smpcontent"];
        availablePortlets = 10;
    }
    else if (type == "trendcontent")
    {
        categories = ["trendcontent"];
        availablePortlets = 5;

    }
    if (categories)
    {
        for (var i=0; i < categories.length; i++)
        {
            var contentSrcName = "tree_portlet" + "_data";
            if (!window[contentSrcName][categories[i]])
                continue;
            for (var j=0; j < window[contentSrcName][categories[i]].length; j++)
            {
                var node = window[contentSrcName][categories[i]][j];
                if (node[NODE_ACTIVE])
                    --availablePortlets;
            }
        }
    }
    return availablePortlets;
}

//allow adding the given portlet to dashboard
function enablePortletTreeNode(tree, nodeId, bEnable)
{
    var contentSrcName = tree.id + "_data";
    var nodeInfo = nodeId.split("_");
    var node = window[contentSrcName][nodeInfo[0]][nodeInfo[1]];
    node[NODE_ACTIVE] = bEnable ? false : true;
    var tree = getTreeByName('tree_portlet');
    tree.updateNodeStyle(nodeId, tree.nodeStyleProvider.getNodeStyle(nodeId), bEnable);
}

function NLDashboardCustInitListener ()  {}

NLDashboardCustInitListener.prototype.onEvent = function (evntId, tree)
{
    if (evntId == E_INIT)
    {
        tree.contentProvider = new NLDashboardTreeContentProvider(tree);
        tree.content = tree.contentProvider.content;
        tree.nodeStyleProvider = new NLDashboardTreeNodeStyleProvider(tree);
        tree.nodeHelpProvider = new nlDashBoardTreeNodeHelpProvider();
    }
}

function NLDashboardTreeContentProvider(tree)
{
    this.base = nlTreeContentXMLReqProvider;
    this.base(tree.contentProvider.url);
    this.contentSrcName = tree.id + "_data";
    this.content =  new NLDashboardTreeContent();
}

NLDashboardTreeContentProvider.prototype.getNodeContent = function (path, callbackFunc)
{
    var response = this.base.prototype.getNodeContent.call(this, path, callbackFunc);
    eval_js(response.body);

    return this.doGetNodeContent(path, callbackFunc);
};

NLDashboardTreeContentProvider.prototype.doGetNodeContent = function (path, callbackFunc)
{
    var contentSrc = window[this.contentSrcName];
    var response = [];
    // the dashboard tree data is flat, just just need to use folder name, sch as reportcontent, customcontent, etc
    var pathInfo = path.split(".");
    for (var i=0; i<pathInfo.length; i++)
        response[i] = contentSrc[pathInfo[i]];
    this.callbackFunc = callbackFunc;
    return response;
}

NLDashboardTreeContentProvider.prototype.doHandleNodeContentResponse = function (response, content)
{
    content.nodes = response;
    return content;
}

function NLDashboardTreeContent (treeId) { }


NLDashboardTreeContent.prototype.getNodes = function NLDashboardTreeContent_getNodes(i)
{
    return this.nodes[i];
}

// NLDashboardTreeNodeStyleProvider serves as both style and help provider
function NLDashboardTreeNodeStyleProvider (tree)
{
    this.tree = tree;
}

NLDashboardTreeNodeStyleProvider.prototype.getNodeStyle = function (nodeId)
{
    nodeStyle = [];
    nodeStyle[NODE_STYLE_IMAGE] = null;
    nodeStyle[NODE_STYLE_CSS] = null;
    nodeStyle[NODE_STYLE_LABEL] = null;
    nodeStyle[NODE_STYLE_ACTION] = null;

    var nodeInfo = nodeId.split("_");
    var contentSrcName = this.tree.id + "_data";
    if (!window[contentSrcName])
        return null;
    if (nodeInfo.length == 1) // portlet category node, such as standard, report, trend etc
    {
        var node = window[contentSrcName][nodeInfo[0]];
        if (!node)
            return null;

        var label = "";
        var availablePortlets = 0;
        var availabilityStr = "{1} available";

        if (nodeInfo[0] == "reportcontent" || nodeInfo[0] == "trendcontent")
        {
            if (nodeInfo[0] == "reportcontent")
            {
                node.availablePortlets = getAvailablePortlets(nodeInfo[0]);
               label = "Report Snapshots";
            }
            else if (nodeInfo[0] == "trendcontent")
            {
                node.availablePortlets = getAvailablePortlets(nodeInfo[0]);
                label =  "Trend Graphs";
            }
            nodeStyle[NODE_STYLE_LABEL] = label + " (" + availabilityStr.replace("{1}", node.availablePortlets) + ")";
        }
        else
            return null;
    }
    else if (nodeInfo.length == 2) // portlet node
    {
        var node = window[contentSrcName][nodeInfo[0]][nodeInfo[1]];
        if (!node)
            return null;


        if(node[NODE_ACTIVE])
        {
            nodeStyle[NODE_STYLE_IMAGE] = "/images/icons/dashboard/addcontentpanel/tree_dashboard_portlet_used.gif";
            nodeStyle[NODE_STYLE_CSS] = "smalltextb";
            nodeStyle[NODE_STYLE_ACTION] = "highlightPortlet('" + node[NODE_PORTLETKEY]+ "')";
        }
        else
        {
            nodeStyle[NODE_STYLE_IMAGE] = "/images/icons/dashboard/addcontentpanel/tree_dashboard_portlet.gif";
            nodeStyle[NODE_STYLE_CSS] = "smalltextnolink";
            nodeStyle[NODE_STYLE_ACTION] = "addPortletToDashboard('" + nodeId + "', " +  node[NODE_COLUMN] + ", '" + escapeHTMLAttr(node[NODE_TITLE]) + "', 0)";
        }
    }

    return nodeStyle;
}

NLDashboardTreeNodeStyleProvider.prototype.showHelp = function NLDashboardTreeNodeStyleProvider_showHelp(hierarchy)
{
    var helpPane = document.getElementById("help_pane");
    if(!helpPane)
        return;

    if (!helpPane.defaultHelp)
        helpPane.defaultHelp = helpPane.innerHTML;

    if(hierarchy)
    {
        var hierarchyInfo = hierarchy.split(".");
        var nodeId = hierarchyInfo[hierarchyInfo.length - 1];
        var nodeInfo = nodeId.split("_");
        if(nodeInfo.length == 1) // folder
        {
            if (helpPane.defaultHelp)
                helpPane.innerHTML = helpPane.defaultHelp;
        }
        else
        {
            var contentSrcName = this.tree.id + "_data";
            var node = window[contentSrcName][nodeInfo[0]][nodeInfo[1]];
            if (!node)
                return;
            var text = node[NODE_HELP];
            if (text)
                document.getElementById("portlet_help").innerHTML = text;
        }
    }

    setObjectOpacity(0, helpPane);
    fadeObjectOpacity(helpPane, 0,100,350);
}

function highlightPortlet(portletId)
{
    var dashboardDiv = document.getElementById("nav_pane");
    if (dashboardDiv.highlightPortlet)
        stopHighlightPortlet(dashboardDiv.highlightPortlet);

    var portletTitleElem = document.getElementById("portlet_" + portletId);
    if(!portletTitleElem)
        return;

    var portletTableElem =  getParentElementByTag("table", portletTitleElem);

    if(!portletTableElem)
        return;

    var x = findPosX(portletTableElem);
    var y = findPosY(portletTableElem);
    if( x<window.scrollLeft || y<window.scrollTop ||
        (x + portletTableElem.offsetWidth) > getDocumentClientWidth() ||
        (y + portletTableElem.offsetHeight) > getDocumentClientHeight() )
        portletTableElem.scrollIntoView(false);

    portletTableElem.origBorderColor = portletTableElem.style.borderColor;
    portletTableElem.origBorderStyle = portletTableElem.style.borderStyle;
    portletTableElem.origBorderWidth = portletTableElem.style.borderWidth;
    portletTableElem.style.borderColor ="#0000FF";
    portletTableElem.style.borderStyle = "solid";
    portletTableElem.style.borderWidth = "1px";
    portletTableElem.highlightTimer = setTimeout(stopHighlightPortlet.bind(portletTableElem), 1000);
    dashboardDiv.highlightPortlet = portletTableElem;
}

function stopHighlightPortlet(portletTableElem)
{
    if (!portletTableElem)
        portletTableElem = this;

    if(portletTableElem.highlightTimer)
        clearTimeout(portletTableElem.highlightTimer);

    portletTableElem.style.borderColor = portletTableElem.origBorderColor;
    portletTableElem.style.borderStyle = portletTableElem.origBorderStyle;
    portletTableElem.style.borderWidth = portletTableElem.origBorderWidth;

    var dashboardDiv = document.getElementById("nav_pane");
    if (dashboardDiv.highlightPortlet == portletTableElem)
        dashboardDiv.highlightPortlet = null;
}

var portletTemplateTrId = "handle_" + "servercontent0";

/**
 * dashboard addcontent listener for drag and drop drop event
 */
function nlDashboardCustDragdropListener ()
{
    this.dragDiv = null;
    this.dropBarDiv = null;
    this.moveColumn = false;
    this.moveRow = -1;
    this.templateTrId = portletTemplateTrId;
}

nlDashboardCustDragdropListener.prototype.onEvent = function (eventId, evnt)
{
    if (evnt.type == "mousemove" )
        this.mouseMove(evnt);
    else if (evnt.type == "mouseup")
        this.mouseUp(evnt);
}

nlDashboardCustDragdropListener.prototype.mouseMove = function nlDashboardCustDragdropListener_mouseMove(evnt)
{
    evnt = getEvent(evnt);

    if (evnt.initDragDrop)
    {
        if (canAddPortletToDashboard(evnt.dragContent.nodeId))
            this.setupDrag(evnt);
        else
            evnt.status = E_RESPONSE_CANCEL;
    }
    else
        portletDraggerOnMouseMove(evnt);
    return;
}

nlDashboardCustDragdropListener.prototype.mouseUp = function (evnt)
{
    var tree = getTreeByName('tree_portlet');
    var nodeStyle = tree.getNodeStyle(evnt.dragContent.nodeId);
    this.trToBeMoved = this.getPortletLayout(nodeStyle[NODE_STYLE_LABEL], evnt.dragContent.nodeId);

    if (this.trToBeMoved && currentPortlet)
    {
        // update server portlet layout
        // has to call it this way - somehow ff and safari complain that NLPortletDragger_putDownPortlet is undefined
        NLPortletDragger.prototype.putDownPortlet.call(this);

        // disable portlet tree node
        enablePortletTreeNode(tree_portlet, this.portletID, false);

        this.trToBeMoved = null;
        dragger = null;
        this.portletID = null;
    }
}

nlDashboardCustDragdropListener.prototype.setupDrag = function nlDashboardCustDragdropListener_setupDrag(evnt)
{
    var nodeStyle = evnt.dragContent.nodeStyle;

    this.divContainer = this.setupDragIndicator(evnt);
    this.originalContainer = this.divContainer.parentNode; // adaptor to portlet drag/drop mechanism, originalContainer is not really needed here
    this.widthPlaceHolder = null;
    this.originalColumn = -1;
    this.portletID = evnt.dragContent.nodeId;
    dragger = this; //hookup to portlet drag/drop mechanism.
};

function nlDashboardCustDragdropListener_createPortletLayout(label, nodeId)
{
    var tr = document.createElement("tr");
    tr.className = "portletHandle";
    tr.id = "handle_serverconent_temp_" + new Date().getTime();
    tr.bPortletAdded = false;
    var td = document.createElement("td");
    tr.appendChild(td);
    var content = document.getElementById(portletTemplateTrId).getElementsByTagName("div")[0].parentNode.innerHTML;

    if(label)
        content = content.replace("_PORTLET_TITLE_", label);

    var sectionId = getParameter("sc", document);
    var contentSrcName = "tree_portlet" + "_data";
    var nodeInfo = nodeId.split("_");
    var node = window[contentSrcName][nodeInfo[0]][nodeInfo[1]];
    td.innerHTML = content.replace("hidePortlet(" + sectionId + ",0,'portlet_0');", "removeShellPortlet('" + tr.id + "', true);");
    return tr;
}
nlDashboardCustDragdropListener.prototype.getPortletLayout = nlDashboardCustDragdropListener_createPortletLayout;

nlDashboardCustDragdropListener.prototype.setupDragIndicator = function nlDashboardCustDragdropListener_setupDragIndicator(evnt)
{
    evnt = getEvent(evnt);

    //todo move to nltree.jsp, this should be the default drag indicator
    var nodeStyle = evnt.dragContent.nodeStyle;

    var dragDiv = document.createElement("div");
    // dummy class used only to identify the div
    dragDiv.className = "dragbox";
    dragDiv.style.position = "absolute";
    dragDiv.style.backgroundColor = "#EFEFEF";
    dragDiv.style.zIndex = 1000;
    dragDiv.style.padding = "1px";

    var innerDiv = document.createElement("div");
    innerDiv.style.borderColor = "#FFFFFF #999999 #999999 #FFFFFF";
    innerDiv.style.borderWidth = "1px";
    innerDiv.style.borderStyle = "solid";
    innerDiv.style.backgroundColor = "#EFEFEF";
    innerDiv.className = "rptpreviewrawtext";
    innerDiv.style.padding = "1px 2px 1px 2px";
    dragDiv.appendChild( innerDiv );

    var sHtml = "<table border=0><tr><td><img border=0 src='" + nodeStyle[NODE_STYLE_IMAGE] + "'></td><td class=rptpreviewrawtext>" + nodeStyle[NODE_STYLE_LABEL] + "</td></tr></table>";
    innerDiv.innerHTML = sHtml;
    evnt.dragDiv = dragDiv;
    return dragDiv;
};


nlDashboardCustDragdropListener.prototype.putDownPortlet = function nlDashboardCustDragdropListener_putDownPortlet()
{
    // this is a place holder just to ignore the global mouseup event from document object
    // real handling of drop will be started when the event is fired from the portlet tree
};

function nlDashboardCustDragdropListener_updateLayoutInDatabase(moving, pushedDown, newColumn, oldColumn, portletId)
{
    var sUrl = "/app/center/setup/dashboard.nl?movedid=" + moving + "&replacedid=" + pushedDown + "&newcolumn=" + newColumn;
    sUrl += "&method=addportlet" + "&shellid=" + portletId;
    var sectionId = getParameter("sc", document);
    if(sectionId)
        sUrl += "&sectionid=" + sectionId;
    var entityId = getParameter("entityid", document);
    if(entityId)
        sUrl += "&entityid=" + entityId;
    var projectId = getParameter("project", document);
    if (projectId)
        sUrl += "&project=" + projectId;
    sendRequestToFrame(sUrl, "server_commands");
}
nlDashboardCustDragdropListener.prototype.updateLayoutInDatabase = nlDashboardCustDragdropListener_updateLayoutInDatabase;

function canAddPortletToDashboard(portletId)
{
    var nodeInfo = portletId.split("_");
    if (nodeInfo.length < 2)
        return false;  // cannot drag the node
    var contentSrcName = "tree_portlet" + "_data";
    var node = window[contentSrcName][nodeInfo[0]][nodeInfo[1]];
    if(!node || node[NODE_ACTIVE])
        return false;  // cannot drag the node
    else if (isReportPortlet(nodeInfo[0]))
    {
        window[contentSrcName]["reportcontent"].availablePortlets = getAvailablePortlets(nodeInfo[0]);
        return (window[contentSrcName]["reportcontent"].availablePortlets > 0);
    }
    else if (isTrendPortlet(nodeInfo[0]))
    {
        window[contentSrcName]["trendcontent"].availablePortlets = getAvailablePortlets(nodeInfo[0]);
        return (window[contentSrcName]["trendcontent"].availablePortlets > 0);
    }
    return true;
}

/**
 *  Add portlet to dashboard, invoked for tree node click.
 *  @param portletId the id of the portlet (it is the tree node id, not the db portlet id as the portlet id for enhsnapshot will be
 *                   assigned by server when added to the dashboard
 *  @param nColumn the column to add the portlet, 1 based.
 *  @param label   the portlet label, it will be shown on the skeletion portlet
 *  @param nRow    the row to add the portlet, 1 based, default to 1,
 *  @param docu    the document object for the dashboard
 */
function addPortletToDashboard(portletId, nColumn, label, nRow, doc)
{
    if (!nRow)
        nRow = 1;
    if(!doc)
        doc = document;

    if (!canAddPortletToDashboard(portletId))
        return;

    // hide tree node tooltip if any
    var tree = getTreeByName('tree_portlet');
    if (tree)
        tree.hideNodeHelp();

    var portletShellTr = nlDashboardCustDragdropListener_createPortletLayout(label, portletId);

    // template portlet (a tr representing portlet skeleton) is always the last portlet on column 0, and
    // is used to locate the containing table column and rows here
    var templatePortletTr = doc.getElementById(portletTemplateTrId);
    var table = getParentElementByTag("table", templatePortletTr.parentNode);
    var mainTable = getParentElementByTag("table", table.parentNode);

    var destMainTableColElem = mainTable.rows[0].cells[nColumn-1];
    var destTableElem = destMainTableColElem.getElementsByTagName("table")[0];
    var targetPortletTr = destTableElem.rows[nRow - 1];

    targetPortletTr.parentNode.insertBefore(portletShellTr, targetPortletTr);

    nlDashboardCustDragdropListener_updateLayoutInDatabase(portletId, getPortletId(targetPortletTr.id), nColumn, -1, portletShellTr.id);

    // disable portlet tree node
    enablePortletTreeNode(tree_portlet, portletId, false);
}

/*
 * This is the dhelp content provider and help renderer for dashboard tree
 */
function nlDashBoardTreeNodeHelpProvider ()
{
    this.base = nlTreeNodeHelpProvider;
}

nlDashBoardTreeNodeHelpProvider.prototype = new nlTreeNodeHelpProvider;

var dashboardTooltipIcons = {
        "0": "/images/icons/dashboard/addcontentpanel/dl_tn_generic.gif",
        "1": "/images/icons/dashboard/addcontentpanel/dl_tn_report.gif",
        "2": "/images/icons/dashboard/addcontentpanel/dl_tn_graph.gif",
        "3": "/images/icons/dashboard/addcontentpanel/dl_tn_links.gif",
        "4": "/images/icons/dashboard/addcontentpanel/dl_tn_list.gif",
        "5": "/images/icons/dashboard/addcontentpanel/dl_tn_kpimeter.gif",
        "6": "/images/icons/dashboard/addcontentpanel/dl_tn_kpi.gif"
};

/*
 * Get tooltip data
 * @param node The html element for the tree node
 * @param hierarchy The string that identifies the hierarchy of the node
 */
nlDashBoardTreeNodeHelpProvider.prototype.getTooltipInfo = function nlDashBoardTreeNodeHelpProvider_getTooltipInfo (node, hierarchy)
{
    var nodeInfo = node.id.split("_");

    if (!nodeInfo
        || ((nodeInfo[0] == "enhancedcontent"
              || nodeInfo[0] == "customcontent"
              || nodeInfo[0] == "smpcontent")
              && nodeInfo.length == 2 ))
        return null;

    var tooltipInfo = this.base.prototype.getTooltipInfo.call(this, node, hierarchy);

    var contentSrcName = "tree_portlet" + "_data";
    if (!window[contentSrcName])
        return null;

    var label = "";
    var availablePortlets = 0;
    var availabilityStr = "{1} available";

    var title = "<div class=smalltext>";
    if (nodeInfo[0] == "standardcontent")
        title += "Standard Content";
    else if (nodeInfo[0] == "trendcontent")
        title += "Trend Graphs";
    else
        title += "Report Snapshots";

    if (nodeInfo.length == 3 )
    {
        if (nodeInfo[0] == "enhancedcontent"
                || nodeInfo[0] == "customcontent"
                || nodeInfo[0] == "smpcontent")
        {
            title += " ("
            if (nodeInfo[0] == "enhancedcontent")
                title += "Standard";
            else if (nodeInfo[0] == "smpcontent")
                title += "Sales Management Report Snapshots";
            else
                title += "Custom";
            title += " )"
        }
        var portletTitle = "";
        if (nodeInfo[2] == 'i')  // this is the icon node
            portletTitle = node.nextSibling.innerHTML;
        else
            portletTitle = node.innerHTML;

        title += "<br /><b>" + portletTitle + "</b>";
    }
    title += "</div>";


    // get help icon
    var iconUrl = "";
    if (nodeInfo[0] == "standardcontent")
    {
        var node = null;
        if (nodeInfo.length == 3)
            node = window[contentSrcName][nodeInfo[0]][nodeInfo[1]];
        if (node && node[16])
            iconUrl += dashboardTooltipIcons[node[16]];
        else
            iconUrl += dashboardTooltipIcons["0"];
    }
    else if (nodeInfo[0] == "trendcontent")
        iconUrl += dashboardTooltipIcons["2"];
    else
        iconUrl += dashboardTooltipIcons["1"];

    // get detail help info
    var detail = "<div class=smalltext>";
    var bFull = false;
    var node = window[contentSrcName][nodeInfo[0]];
    if (!node)
        return null;
    if(!node.availablePortlets)
        node.availablePortlets = getAvailablePortlets(nodeInfo[0]);
    var max = Number.MAX_VALUE;
    if((nodeInfo[0] == "enhancedcontent"
              || nodeInfo[0] == "customcontent"
              || nodeInfo[0] == "smpcontent") && nodeInfo.length == 3
        || nodeInfo[0] == "reportcontent")
        max = 10;
    else if (nodeInfo[0] == "trendcontent")
        max = 5;
    if (max != Number.MAX_VALUE && node.availablePortlets <= 0)
        bFull = true;

    if (nodeInfo.length == 2)
    {
        var node = window[contentSrcName][nodeInfo[0]];
        if (!node)
            return null;
        if(!node.availablePortlets)
            node.availablePortlets = getAvailablePortlets(nodeInfo[0]);

        detail += "Click or drag and drop content below to add it to your dashboard.<br />";

        if (nodeInfo[0] == "reportcontent"
                || nodeInfo[0] == "trendcontent" )
        {
            detail += "You can add up to {1: number} portlets in this category.".replace("{1}", max);
            detail += "<br />Currently {1: number of portlets} have been added, {2: number of portlets} are available".replace("{1}", max - node.availablePortlets).replace("{2}", node.availablePortlets);
        }
    }
    else if (nodeInfo.length == 3)   
    {
        if (tooltipInfo && tooltipInfo[0])
            detail += tooltipInfo[0] + "<br />";

        var node = window[contentSrcName][nodeInfo[0]][nodeInfo[1]];
        if (!node)
            return null;

        detail += "<div style='padding-top:5px;font-style:italic'>";
        if (node[NODE_ACTIVE])
        {
            if (node[NODE_LOCK])
                detail += "<img src='/images/icons/dashboard/addcontentpanel/dl_icon_checkmark.gif' />" + " Cannot be removed from dashboard.";
            else
                detail += "<img src='/images/icons/dashboard/addcontentpanel/dl_icon_checkmark.gif' />" + " Currently displayed on dashboard.";
        }
        else
        {
            if (!bFull)
                detail += "Click or drag and drop to add to dashboard.";
            else
                detail += "<img src='/images/icons/dashboard/addcontentpanel/dl_icon_exclamation.gif' />" + " This portlet cannot be added because you already have the maximum number allowed ({1}) in this category.".replace("{1}", max);
        }
        detail += "</div>";
    }
    detail += "</div>";

    if (!tooltipInfo)
        tooltipInfo = [];
    tooltipInfo[0] = title;
    tooltipInfo[1] = "<img src='" + iconUrl + "'/>";
    tooltipInfo[2] = detail;
    return tooltipInfo;
};
