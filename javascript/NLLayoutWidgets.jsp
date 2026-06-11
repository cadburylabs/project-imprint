



function getLWobject(obj)
{
	
	var div = obj;
	if (typeof obj == "string")
		div = document.getElementById("div__"+obj);

	
	if (!div)
		return null;

	
	if (div.nlobj)
		return div.nlobj;

	
	if (!div.getAttribute("nltype"))
		return null;

	
	var nlobj = eval("new " + div.getAttribute("nltype") + "()");

	
	for (var k=0; k < div.attributes.length; k++)
	{
		var attr = div.attributes[k];
		if (/^nl/.test(attr.name))
		{
			var val = div.getAttribute(attr.name);
			nlobj[attr.name] = val;
		}
	}

	
	div["nlobj"] = nlobj;
	nlobj["nlelem"] = div;

	return nlobj;
}

function getHeightInRange(obj, nHeight)
{
	
	var minheight = obj.nlminh;
	var maxheight = obj.nlmaxh;

	
	minheight = (minheight == null) ? 0 : parseInt(minheight);
	maxheight = (maxheight == null) ? nHeight : parseInt(maxheight);

	
	if (nHeight > maxheight)
		nHeight = maxheight;
	if (nHeight < minheight)
		nHeight = minheight;

	return nHeight;
}

function getWidthInRange(obj, nWidth)
{
	
	var minwidth = obj.nlminw;
	var maxwidth = obj.nlmaxw;

	
	minwidth = (minwidth == null) ? 0 : parseInt(minwidth);
	maxwidth = (maxwidth == null) ? nWidth : parseInt(maxwidth);

	
	if (nWidth > maxwidth)
		nWidth = maxwidth;
	if (nWidth < minwidth)
		nWidth = minwidth;

	return nWidth;
}


NLContent = Class.create();
NLContent.prototype =
{
    initialize: function(sId)
    {
	},

	resize: function (nHeight, nWidth)
	{
		
		var contentDiv = this.nlelem;

		
		nHeight = getHeightInRange(this, nHeight);
		nWidth = getWidthInRange(this, nWidth);

		
		contentDiv.style.display = (nHeight == 0) ? "none" : "";
		contentDiv.style.height = nHeight;

        
        if (nHeight != contentDiv.offsetHeight)
        {
            if ((nHeight -= contentDiv.offsetHeight - nHeight) > 0)
                contentDiv.style.height = nHeight;
        }
	}
};


NLPanel = Class.create();
NLPanel.prototype =
{
    initialize: function(sId)
    {
	},

	resize: function(nHeight, nWidth)
	{
		
		var panelDiv = this.nlelem;

		
		nHeight = getHeightInRange(this, nHeight);
		nWidth = getWidthInRange(this, nWidth);

		
		nHeight -= panelDiv.childNodes[0].offsetHeight;
		if (nHeight < 0)
			nHeight = 0;

		
		var panelHeight = panelDiv.offsetHeight - panelDiv.childNodes[1].offsetHeight;
		var panelWidth = panelDiv.offsetWidth - panelDiv.childNodes[1].offsetWidth;

		
		var content = getLWobject(panelDiv.childNodes[1]);
		content.resize(nHeight, nWidth);

		
		nHeight = panelHeight + panelDiv.childNodes[1].offsetHeight;
		nWidth = panelWidth + panelDiv.childNodes[1].offsetWidth;

		panelDiv.style.display = (nHeight == 0) ? "none" : "";
		panelDiv.style.height = nHeight;

        
        if (nHeight != panelDiv.offsetHeight)
        {
            if ((nHeight -= panelDiv.offsetHeight - nHeight) > 0)
                panelDiv.style.height = nHeight;
        }
	},

	setButtonImage: function(nButtonNum, sButtonImg, sButtonAltText)
	{
		var btnimg = document.getElementById(this.nlid+"img"+nButtonNum);
		btnimg.src = sButtonImg;
//		btnimg.altText = sButtonAltText;
	}
};


NLAccordion = Class.create();
NLAccordion.prototype =
{
    initialize: function()
    {
	},

	resize: function(nHeight, nWidth)
	{
		
	},

	click: function(panelHeader)
	{
		if (!panelHeader)
			return;

		
		var panelDiv = panelHeader.parentNode;
		var accDiv = panelDiv.parentNode;
		var totalHeight = accDiv.offsetHeight;

		
		if (accDiv.childNodes[this.nlopenpanel] == panelDiv)
			return;

		
		
		var	p = getLWobject(accDiv.childNodes[this.nlopenpanel]);
		p.resize(0, panelDiv.offsetWidth);
		if (this.nlmaximg)
			p.setButtonImage(0, this.nlmaximg, this.nlmaxalt);

        
        var newPanelHeight = totalHeight - accDiv.offsetHeight;
        if (newPanelHeight == 0)
        {
            
            newPanelHeight = totalHeight - this.nlminh;
        }
        newPanelHeight += panelDiv.offsetHeight;

        
        p = getLWobject(panelDiv);
		p.resize(newPanelHeight, panelDiv.offsetWidth);
		if (this.nlminimg)
			p.setButtonImage(0, this.nlminimg, this.nlminalt);

		
		for (var j=0; j < accDiv.childNodes.length; j++)
		{
			if (accDiv.childNodes[j] == panelDiv)
				break;
		}

		this.nlopenpanel = j;

		
		while (accDiv.offsetHeight < totalHeight && panelDiv.nextSibling)
		{	
			panelDiv = panelDiv.nextSibling;
			p = getLWobject(panelDiv);
			if (p)
				p.resize(totalHeight - accDiv.offsetHeight + panelDiv.offsetHeight, panelDiv.offsetWidth);
		}

		
		panelDiv = panelHeader.parentNode;
		while (accDiv.offsetHeight < totalHeight && panelDiv.previousSibling)
		{	
			panelDiv = panelDiv.previousSibling;
			p = getLWobject(panelDiv);
			if (p)
				p.resize(totalHeight - accDiv.offsetHeight + panelDiv.offsetHeight, panelDiv.offsetWidth);
		}
	}
};
