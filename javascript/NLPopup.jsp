



	



/**
 * adjust the layout of the popup and display
 * @param style The style of the popup, none - no style, default - square angle/blue background
 * @param block Show the gray layer or not behind the popup
 */
nlPopupLite.prototype.adjustPopupSize = function nlPopupLite_adjustPopupSize(bDynamic, style, bPosition)
{
    if (typeof style == "undefined")
        style = this.style;

    var width = Math.max(this.nativeContentObject.body.scrollWidth, this.width);
    if (width == 0)
    {
        width = this.defaultWidth;
    }

    var height = Math.max(this.nativeContentObject.body.scrollHeight, this.height);
    if (height == 0)
    {
        height = this.defaultHeight;
    }

    if (style == POPUP_LAYOUT_STYLE_DEFAULT)
    {
        this.nativeTopObject.style.border = "0";
        this.nativeContentObject.body.style.border = "0";
    }

    if(this.dynamicSize)
    {
        while (height/width > .75)
        {
            width += 50;
            this.nativeTopObject.style.width = width + 'px';
            if (height == this.nativeContentObject.body.scrollHeight)
                break;
            width = this.nativeContentObject.body.scrollWidth;
            height = this.nativeContentObject.body.scrollHeight;
        }
    }

    if (document.all)
    {
        this.nativeTopObject.style.width = (width + getRuntimeSize(this.nativeTopObject, "borderLeftWidth") + getRuntimeSize(this.nativeTopObject, "borderRightWidth") + 2) + 'px';
        this.nativeTopObject.style.height = (height + getRuntimeSize(this.nativeTopObject, "borderTopWidth") + getRuntimeSize(this.nativeTopObject, "borderBottomWidth") + 2) + 'px';
    }
    else
    {
        width += getRuntimeSize(this.nativeContentObject.body, "borderLeftWidth") +  getRuntimeSize(this.nativeContentObject.body, "borderLeftWidth") + getRuntimeSize(this.nativeContentObject.body, "marginLeft") +  getRuntimeSize(this.nativeContentObject.body, "marginRight");
        
            width +=15;    //compensate for the vertical scroll bar - to be further investigated
        
        height += getRuntimeSize(this.nativeContentObject.body, "borderTopWidth") +  getRuntimeSize(this.nativeContentObject.body, "borderBottomWidth") + getRuntimeSize(this.nativeContentObject.body, "marginTop") +  getRuntimeSize(this.nativeContentObject.body, "marginBottom") + 10;
        this.nativeTopObject.style.width = (width - getRuntimeSize(this.nativeTopObject, "paddingLeft") - getRuntimeSize(this.nativeTopObject, "paddingRight")) + 'px';
        this.nativeTopObject.style.height = (height - getRuntimeSize(this.nativeTopObject, "paddingTop") - getRuntimeSize(this.nativeTopObject, "paddingBottom")) + 'px';

    }

    if (bPosition != false)
        this.setPosition();

    
    this.nativeTopObject.style.visibility = "visible";
    
};

nlMessageContent.prototype.getContent = function(contentTemplate)
{
    var content = contentTemplate;
    if (!content)
        content = MSG_POPUP_SHELL;

    if (typeof this.message != "undefined" && this.message != null)
        content = content.replace("<messagecontent/>", this.message);
    if (typeof this.title != "undefined" && this.title != null)
        content = content.replace("<messagetitle/>", this.title);
    if (typeof this.style != "undefined" && this.style != null)
    {
		var type = this.style === 1 ? 'info' : (this.style === 2 ? 'warning' : 'error');
        var img = "<span class='uir-popup-icon' data-type='" + type + "'></span>";
        content = content.replace("<messageicon/>", img);
    }

    return content;
};

nlConfirmContent.prototype = new nlMessageContent;
nlConfirmContent.prototype.getContent = function()
{
    var content = this.constructor.prototype.getContent.call(this,CONFIRM_POPUP_SHELL);
    if (!this.okAction)
        this.okAction = "";
    content = content.replace("${okaction}", this.okAction);
    if (!this.cancelAction)
        this.cancelAction = "";
    content = content.replace("${cancelaction}", this.cancelAction);

    return content;
};

nlProgressContent.prototype.getContent = function()
{
    var content = PROGRESS_POPUP_SHELL;
    if (typeof this.message != "undefined" && this.message != null)
        content = content.replace("<messagecontent/>", this.message);
    if (typeof this.title != "undefined" && this.title != null)
        content = content.replace("<messagetitle/>", this.title);

    var img = "<img src=\"/images/icons/progress/progress_waitBar.gif\" />";
    content = content.replace("<messageicon/>", img);

    if (typeof this.action != "undefined" && this.action != null)
        content = content.replace("${cancelaction}", this.action);

    return content;
};

nlSaveContent.prototype = new nlMessageContent;
nlSaveContent.prototype.getContent = function()
{
    var content = this.constructor.prototype.getContent.call(this,SAVE_POPUP_SHELL);
    if (!this.okAction)
        this.okAction = "";
    content = content.replace("${okaction}", this.okAction);

    return content;
};

var MSG_POPUP_SHELL = "<table class=\x22uir\-popup\x22 width=\x27100%\x27 cellspacing=\x270\x27 cellpadding=\x270\x27 role=\x27presentation\x27>\n    <tr class=\x22uir\-popup\-header\x22>\n        <td>\n            <table width=\x27100%\x27 height=\x27100%\x27 cellspacing=\x270\x27 cellpadding=\x270\x27 role=\x27presentation\x27>\n                <tr>\n                    <td valign=\x27middle\x27 nowrap=\x27\x27 style=\x27padding\-left: 2px;\x27>\n                    <\/td>\n\n                    <td nowrap=\x27\x27 class=\x27smalltextb\x27 style=\x27padding\-left: 5px; padding\-right: 1px;\x27>\n                        <messagetitle\/>\n                    <\/td>\n                <\/tr>\n            <\/table>\n        <\/td>\n    <\/tr>\n\n    <tr class=\x22uir\-popup\-body\x22><td><table cellspacing=5 cellpadding=0 class=\x22smalltextnolink\x22><tr><td style=\x22padding\-right:20px\x22 valign=\x22top\x22><messageicon\/><\/td><td width=\x27100%\x27><messagecontent\/><\/td><\/tr><tr><td\/><\/tr><tr><td colspan=2><div class=\x27uir\-popup\-button\-bar\x27>        <td>\n\n    \n\n    <table  id=\x27tbl_ok\x27 cellpadding=\x270\x27 cellspacing=\x270\x27 border=\x270\x27 class=\x27uir\-button\x27\n          style=\x27margin\-right:6px;\x27 role=\x27presentation\x27>\n\n        <tr id=\x27tr_ok\x27 class=\x27pgBntG pgBntB\x27>\n        <td id=\x27tdleftcap_ok\x27><img src=\x27\/images\/nav\/ns_x.gif\x27 class=\x27bntLT\x27 border=\x270\x27 height=\x2750%\x27 width=\x273\x27 alt=\x27\x27\/>\n            <img src=\x27\/images\/nav\/ns_x.gif\x27 class=\x27bntLB\x27 border=\x270\x27 height=\x2750%\x27 width=\x273\x27 alt=\x27\x27\/>\n        <\/td>\n        <td id=\x27tdbody_ok\x27 height=\x2720\x27 valign=\x27top\x27 nowrap class=\x27bntBgB\x27>\n\n\n    <input type=\x27button\x27 style=\x27width:50px\x27 class=\x27rndbuttoninpt bntBgT \x27\n\n        value=\x27OK\x27\n\n\t\tdata\-nsps\-type=\x27button\x27 data\-nsps\-label=\x27OK\x27\n\n    id=\x27ok\x27 name=\x27ok\x27\n\n    \n\n    \n\n     onclick=\x22closePopup(); return false;\x22\n\n\t    onmousedown=\x22this.setAttribute(\x27_mousedown\x27,\x27T\x27); setButtonDown(true, true, this);\x22\n\t    onmouseup=\x22this.setAttribute(\x27_mousedown\x27,\x27F\x27); setButtonDown(false, true, this);\x22\n\t    onmouseout=\x22if(this.getAttribute(\x27_mousedown\x27)==\x27T\x27) setButtonDown(false, true, this);\x22\n\t    onmouseover=\x22if(this.getAttribute(\x27_mousedown\x27)==\x27T\x27) setButtonDown(true, true, this);\x22\n    ><\/td> \n\n       <td id=\x27tdrightcap_ok\x27>\n           <img src=\x27\/images\/nav\/ns_x.gif\x27 height=\x2750%\x27 class=\x27bntRT\x27 border=\x270\x27 width=\x273\x27 alt=\x27\x27>\n           <img src=\x27\/images\/nav\/ns_x.gif\x27 height=\x2750%\x27 class=\x27bntRB\x27 border=\x270\x27 width=\x273\x27 alt=\x27\x27>\n       <\/td>\n\t\t<\/tr>\n\n    <\/table>\n    <\/td>\n<\/div><\/td><\/tr><\/table><\/td><\/tr>\n    <tr><td><\/td><\/tr>\n<\/table>";
var CONFIRM_POPUP_SHELL = "<table class=\x22uir\-popup\x22 width=\x27100%\x27 cellspacing=\x270\x27 cellpadding=\x270\x27 role=\x27presentation\x27>\n    <tr class=\x22uir\-popup\-header\x22>\n        <td>\n            <table width=\x27100%\x27 height=\x27100%\x27 cellspacing=\x270\x27 cellpadding=\x270\x27 role=\x27presentation\x27>\n                <tr>\n                    <td valign=\x27middle\x27 nowrap=\x27\x27 style=\x27padding\-left: 2px;\x27>\n                    <\/td>\n\n                    <td nowrap=\x27\x27 class=\x27smalltextb\x27 style=\x27padding\-left: 5px; padding\-right: 1px;\x27>\n                        <messagetitle\/>\n                    <\/td>\n                <\/tr>\n            <\/table>\n        <\/td>\n    <\/tr>\n\n    <tr class=\x22uir\-popup\-body\x22><td><table cellspacing=5 cellpadding=0 class=\x22smalltextnolink\x22><tr><td style=\x22padding\-right:20px\x22 valign=\x22top\x22><messageicon\/><\/td><td width=\x27100%\x27><messagecontent\/><\/td><\/tr><tr><td\/><\/tr><tr><td colspan=2><div class=\x27uir\-popup\-button\-bar\x27>\n    \n\n    <table  id=\x27tbl_ok\x27 cellpadding=\x270\x27 cellspacing=\x270\x27 border=\x270\x27 class=\x27uir\-button\x27\n          style=\x27margin\-right:6px;\x27 role=\x27presentation\x27>\n\n        <tr id=\x27tr_ok\x27 class=\x27pgBntG pgBntB\x27>\n        <td id=\x27tdleftcap_ok\x27><img src=\x27\/images\/nav\/ns_x.gif\x27 class=\x27bntLT\x27 border=\x270\x27 height=\x2750%\x27 width=\x273\x27 alt=\x27\x27\/>\n            <img src=\x27\/images\/nav\/ns_x.gif\x27 class=\x27bntLB\x27 border=\x270\x27 height=\x2750%\x27 width=\x273\x27 alt=\x27\x27\/>\n        <\/td>\n        <td id=\x27tdbody_ok\x27 height=\x2720\x27 valign=\x27top\x27 nowrap class=\x27bntBgB\x27>\n\n\n    <input type=\x27button\x27 style=\x27\x27 class=\x27rndbuttoninpt bntBgT \x27\n\n        value=\x27OK\x27\n\n\t\tdata\-nsps\-type=\x27button\x27 data\-nsps\-label=\x27OK\x27\n\n    id=\x27ok\x27 name=\x27ok\x27\n\n    \n\n    \n\n     onclick=\x22closePopup();${okaction}; return false;\x22\n\n\t    onmousedown=\x22this.setAttribute(\x27_mousedown\x27,\x27T\x27); setButtonDown(true, true, this);\x22\n\t    onmouseup=\x22this.setAttribute(\x27_mousedown\x27,\x27F\x27); setButtonDown(false, true, this);\x22\n\t    onmouseout=\x22if(this.getAttribute(\x27_mousedown\x27)==\x27T\x27) setButtonDown(false, true, this);\x22\n\t    onmouseover=\x22if(this.getAttribute(\x27_mousedown\x27)==\x27T\x27) setButtonDown(true, true, this);\x22\n    ><\/td> \n\n       <td id=\x27tdrightcap_ok\x27>\n           <img src=\x27\/images\/nav\/ns_x.gif\x27 height=\x2750%\x27 class=\x27bntRT\x27 border=\x270\x27 width=\x273\x27 alt=\x27\x27>\n           <img src=\x27\/images\/nav\/ns_x.gif\x27 height=\x2750%\x27 class=\x27bntRB\x27 border=\x270\x27 width=\x273\x27 alt=\x27\x27>\n       <\/td>\n\t\t<\/tr>\n\n    <\/table>\n    \n\n    \n\n    <table  id=\x27tbl_cancel\x27 cellpadding=\x270\x27 cellspacing=\x270\x27 border=\x270\x27 class=\x27uir\-button\x27\n          style=\x27margin\-right:6px;\x27 role=\x27presentation\x27>\n\n        <tr id=\x27tr_cancel\x27 class=\x27pgBntG\x27>\n        <td id=\x27tdleftcap_cancel\x27><img src=\x27\/images\/nav\/ns_x.gif\x27 class=\x27bntLT\x27 border=\x270\x27 height=\x2750%\x27 width=\x273\x27 alt=\x27\x27\/>\n            <img src=\x27\/images\/nav\/ns_x.gif\x27 class=\x27bntLB\x27 border=\x270\x27 height=\x2750%\x27 width=\x273\x27 alt=\x27\x27\/>\n        <\/td>\n        <td id=\x27tdbody_cancel\x27 height=\x2720\x27 valign=\x27top\x27 nowrap class=\x27bntBgB\x27>\n\n\n    <input type=\x27button\x27 style=\x27\x27 class=\x27rndbuttoninpt bntBgT \x27\n\n        value=\x27Cancel\x27\n\n\t\tdata\-nsps\-type=\x27button\x27 data\-nsps\-label=\x27Cancel\x27\n\n    id=\x27cancel\x27 name=\x27cancel\x27\n\n    \n\n    \n\n     onclick=\x22${cancelaction};closePopup(); return false;\x22\n\n\t    onmousedown=\x22this.setAttribute(\x27_mousedown\x27,\x27T\x27); setButtonDown(true, true, this);\x22\n\t    onmouseup=\x22this.setAttribute(\x27_mousedown\x27,\x27F\x27); setButtonDown(false, true, this);\x22\n\t    onmouseout=\x22if(this.getAttribute(\x27_mousedown\x27)==\x27T\x27) setButtonDown(false, true, this);\x22\n\t    onmouseover=\x22if(this.getAttribute(\x27_mousedown\x27)==\x27T\x27) setButtonDown(true, true, this);\x22\n    ><\/td> \n\n       <td id=\x27tdrightcap_cancel\x27>\n           <img src=\x27\/images\/nav\/ns_x.gif\x27 height=\x2750%\x27 class=\x27bntRT\x27 border=\x270\x27 width=\x273\x27 alt=\x27\x27>\n           <img src=\x27\/images\/nav\/ns_x.gif\x27 height=\x2750%\x27 class=\x27bntRB\x27 border=\x270\x27 width=\x273\x27 alt=\x27\x27>\n       <\/td>\n\t\t<\/tr>\n\n    <\/table>\n    \n<\/div><\/td><\/tr><\/table><\/td><\/tr>\n    <tr><td><\/td><\/tr>\n<\/table>";
var PROGRESS_POPUP_SHELL = "<table class=\x22uir\-popup\x22 width=\x27100%\x27 cellspacing=\x270\x27 cellpadding=\x270\x27 role=\x27presentation\x27>\n    <tr class=\x22uir\-popup\-header\x22>\n        <td>\n            <table width=\x27100%\x27 height=\x27100%\x27 cellspacing=\x270\x27 cellpadding=\x270\x27 role=\x27presentation\x27>\n                <tr>\n                    <td valign=\x27middle\x27 nowrap=\x27\x27 style=\x27padding\-left: 2px;\x27>\n                    <\/td>\n\n                    <td nowrap=\x27\x27 class=\x27smalltextb\x27 style=\x27padding\-left: 5px; padding\-right: 1px;\x27>\n                        <messagetitle\/>\n                    <\/td>\n                <\/tr>\n            <\/table>\n        <\/td>\n    <\/tr>\n\n    <tr class=\x22uir\-popup\-body\x22><td><table cellspacing=5 cellpadding=0 class=\x22smalltextnolink\x22><tr><td width=\x27100%\x27><messagecontent\/><\/td><\/tr><tr><td><messageicon\/><\/td><\/tr><tr><td>\n<div class=\x27uir\-popup\-button\-bar\x27>        <td>\n\n    \n\n    <table  id=\x27tbl_ok\x27 cellpadding=\x270\x27 cellspacing=\x270\x27 border=\x270\x27 class=\x27uir\-button\x27\n          style=\x27margin\-right:6px;\x27 role=\x27presentation\x27>\n\n        <tr id=\x27tr_ok\x27 class=\x27pgBntG\x27>\n        <td id=\x27tdleftcap_ok\x27><img src=\x27\/images\/nav\/ns_x.gif\x27 class=\x27bntLT\x27 border=\x270\x27 height=\x2750%\x27 width=\x273\x27 alt=\x27\x27\/>\n            <img src=\x27\/images\/nav\/ns_x.gif\x27 class=\x27bntLB\x27 border=\x270\x27 height=\x2750%\x27 width=\x273\x27 alt=\x27\x27\/>\n        <\/td>\n        <td id=\x27tdbody_ok\x27 height=\x2720\x27 valign=\x27top\x27 nowrap class=\x27bntBgB\x27>\n\n\n    <input type=\x27button\x27 style=\x27width:50px\x27 class=\x27rndbuttoninpt bntBgT \x27\n\n        value=\x27Cancel\x27\n\n\t\tdata\-nsps\-type=\x27button\x27 data\-nsps\-label=\x27Cancel\x27\n\n    id=\x27ok\x27 name=\x27ok\x27\n\n    \n\n    \n\n     onclick=\x22${cancelaction}; return false;\x22\n\n\t    onmousedown=\x22this.setAttribute(\x27_mousedown\x27,\x27T\x27); setButtonDown(true, true, this);\x22\n\t    onmouseup=\x22this.setAttribute(\x27_mousedown\x27,\x27F\x27); setButtonDown(false, true, this);\x22\n\t    onmouseout=\x22if(this.getAttribute(\x27_mousedown\x27)==\x27T\x27) setButtonDown(false, true, this);\x22\n\t    onmouseover=\x22if(this.getAttribute(\x27_mousedown\x27)==\x27T\x27) setButtonDown(true, true, this);\x22\n    ><\/td> \n\n       <td id=\x27tdrightcap_ok\x27>\n           <img src=\x27\/images\/nav\/ns_x.gif\x27 height=\x2750%\x27 class=\x27bntRT\x27 border=\x270\x27 width=\x273\x27 alt=\x27\x27>\n           <img src=\x27\/images\/nav\/ns_x.gif\x27 height=\x2750%\x27 class=\x27bntRB\x27 border=\x270\x27 width=\x273\x27 alt=\x27\x27>\n       <\/td>\n\t\t<\/tr>\n\n    <\/table>\n    <\/td>\n<\/div><\/td><\/tr><\/table><\/td><\/tr>\n    <tr><td><\/td><\/tr>\n<\/table>";
var TOOLTIP_POPUP_SHELL = "<div class=\x22uir\-popup\-tooltip\x22>\r\n\t\t<div class=\x22uir\-popup\-tooltip\-icon\x22>\r\n            <messageicon\/>\r\n\t\t<\/div>\r\n\t<div class=\x22uir\-popup\-tooltip\-content\x22>\r\n\t\t<div class=\x22uir\-popup\-tooltip\-title\x22><messagetitle\/><\/div>\r\n\t\t<div class=\x22uir\-popup\-tooltip\-body\x22>\r\n            <messagecontent\/>\r\n\t\t<\/div>\r\n\t<\/div>\r\n<\/div>";
var SAVE_POPUP_SHELL = "<table class=\x22uir\-popup\x22 width=\x27100%\x27 cellspacing=\x270\x27 cellpadding=\x270\x27 role=\x27presentation\x27>\n    <tr class=\x22uir\-popup\-header\x22>\n        <td>\n            <table width=\x27100%\x27 height=\x27100%\x27 cellspacing=\x270\x27 cellpadding=\x270\x27 role=\x27presentation\x27>\n                <tr>\n                    <td valign=\x27middle\x27 nowrap=\x27\x27 style=\x27padding\-left: 2px;\x27>\n                    <\/td>\n\n                    <td nowrap=\x27\x27 class=\x27smalltextb\x27 style=\x27padding\-left: 5px; padding\-right: 1px;\x27>\n                        <messagetitle\/>\n                    <\/td>\n                <\/tr>\n            <\/table>\n        <\/td>\n    <\/tr>\n\n    <tr class=\x22uir\-popup\-body\x22><td><table cellspacing=5 cellpadding=0 class=\x22smalltextnolink\x22><tr><td style=\x22padding\-right:20px\x22 valign=\x22top\x22><messageicon\/><\/td><td width=\x27100%\x27><messagecontent\/><\/td><\/tr><tr><td\/><\/tr><tr><td colspan=2><span id=\x27dontshow_fs\x27 class=\x27checkbox_unck uir\-field\-input\x27 data\-fieldtype=\x27checkbox\x27 onclick=\x27NLCheckboxOnClick(this);\x27><input type=\x27checkbox\x27 class=\x27checkbox\x27 id=\x27dontshow\x27 name=\x27dontshow\x27\/><img class=\x27checkboximage\x27 src=\x27\/images\/nav\/ns_x.gif\x27 alt=\x27\x27\/><\/span><label for=\x27dontshow\x27>Don\x27t show this next time <\/label><div class=\x27uir\-popup\-button\-bar\x27>\n    \n\n    <table  id=\x27tbl_ok\x27 cellpadding=\x270\x27 cellspacing=\x270\x27 border=\x270\x27 class=\x27uir\-button\x27\n          style=\x27margin\-right:6px;\x27 role=\x27presentation\x27>\n\n        <tr id=\x27tr_ok\x27 class=\x27pgBntG pgBntB\x27>\n        <td id=\x27tdleftcap_ok\x27><img src=\x27\/images\/nav\/ns_x.gif\x27 class=\x27bntLT\x27 border=\x270\x27 height=\x2750%\x27 width=\x273\x27 alt=\x27\x27\/>\n            <img src=\x27\/images\/nav\/ns_x.gif\x27 class=\x27bntLB\x27 border=\x270\x27 height=\x2750%\x27 width=\x273\x27 alt=\x27\x27\/>\n        <\/td>\n        <td id=\x27tdbody_ok\x27 height=\x2720\x27 valign=\x27top\x27 nowrap class=\x27bntBgB\x27>\n\n\n    <input type=\x27button\x27 style=\x27\x27 class=\x27rndbuttoninpt bntBgT \x27\n\n        value=\x27OK\x27\n\n\t\tdata\-nsps\-type=\x27button\x27 data\-nsps\-label=\x27OK\x27\n\n    id=\x27ok\x27 name=\x27ok\x27\n\n    \n\n    \n\n     onclick=\x22if(dontshow.checked) {parent.sendRequestToFrame(\x27\/app\/common\/saveconfirmation.nl?unsetpref=T\x27, \x27server_commands\x27);}if (NS.form.isChanged() \x26amp;\x26amp; (!document.forms[\x27main_form\x27].onsubmit || document.forms[\x27main_form\x27].onsubmit())) {var theForm = document.forms[\x27main_form\x27];var newOption = document.createElement(\x27input\x27);newOption.id = \x27setclientredirecturl\x27;newOption.name = \x27setclientredirecturl\x27;newOption.type = \x27hidden\x27;newOption.value = \x27${okaction}\x27; theForm.appendChild(newOption);document.forms[\x27main_form\x27].submit();} closePopup(); return false;\x22\n\n\t    onmousedown=\x22this.setAttribute(\x27_mousedown\x27,\x27T\x27); setButtonDown(true, true, this);\x22\n\t    onmouseup=\x22this.setAttribute(\x27_mousedown\x27,\x27F\x27); setButtonDown(false, true, this);\x22\n\t    onmouseout=\x22if(this.getAttribute(\x27_mousedown\x27)==\x27T\x27) setButtonDown(false, true, this);\x22\n\t    onmouseover=\x22if(this.getAttribute(\x27_mousedown\x27)==\x27T\x27) setButtonDown(true, true, this);\x22\n    ><\/td> \n\n       <td id=\x27tdrightcap_ok\x27>\n           <img src=\x27\/images\/nav\/ns_x.gif\x27 height=\x2750%\x27 class=\x27bntRT\x27 border=\x270\x27 width=\x273\x27 alt=\x27\x27>\n           <img src=\x27\/images\/nav\/ns_x.gif\x27 height=\x2750%\x27 class=\x27bntRB\x27 border=\x270\x27 width=\x273\x27 alt=\x27\x27>\n       <\/td>\n\t\t<\/tr>\n\n    <\/table>\n    \n\n    \n\n    <table  id=\x27tbl_cancel\x27 cellpadding=\x270\x27 cellspacing=\x270\x27 border=\x270\x27 class=\x27uir\-button\x27\n          style=\x27margin\-right:6px;\x27 role=\x27presentation\x27>\n\n        <tr id=\x27tr_cancel\x27 class=\x27pgBntG\x27>\n        <td id=\x27tdleftcap_cancel\x27><img src=\x27\/images\/nav\/ns_x.gif\x27 class=\x27bntLT\x27 border=\x270\x27 height=\x2750%\x27 width=\x273\x27 alt=\x27\x27\/>\n            <img src=\x27\/images\/nav\/ns_x.gif\x27 class=\x27bntLB\x27 border=\x270\x27 height=\x2750%\x27 width=\x273\x27 alt=\x27\x27\/>\n        <\/td>\n        <td id=\x27tdbody_cancel\x27 height=\x2720\x27 valign=\x27top\x27 nowrap class=\x27bntBgB\x27>\n\n\n    <input type=\x27button\x27 style=\x27\x27 class=\x27rndbuttoninpt bntBgT \x27\n\n        value=\x27Cancel\x27\n\n\t\tdata\-nsps\-type=\x27button\x27 data\-nsps\-label=\x27Cancel\x27\n\n    id=\x27cancel\x27 name=\x27cancel\x27\n\n    \n\n    \n\n     onclick=\x22closePopup(); return false;\x22\n\n\t    onmousedown=\x22this.setAttribute(\x27_mousedown\x27,\x27T\x27); setButtonDown(true, true, this);\x22\n\t    onmouseup=\x22this.setAttribute(\x27_mousedown\x27,\x27F\x27); setButtonDown(false, true, this);\x22\n\t    onmouseout=\x22if(this.getAttribute(\x27_mousedown\x27)==\x27T\x27) setButtonDown(false, true, this);\x22\n\t    onmouseover=\x22if(this.getAttribute(\x27_mousedown\x27)==\x27T\x27) setButtonDown(true, true, this);\x22\n    ><\/td> \n\n       <td id=\x27tdrightcap_cancel\x27>\n           <img src=\x27\/images\/nav\/ns_x.gif\x27 height=\x2750%\x27 class=\x27bntRT\x27 border=\x270\x27 width=\x273\x27 alt=\x27\x27>\n           <img src=\x27\/images\/nav\/ns_x.gif\x27 height=\x2750%\x27 class=\x27bntRB\x27 border=\x270\x27 width=\x273\x27 alt=\x27\x27>\n       <\/td>\n\t\t<\/tr>\n\n    <\/table>\n    \n<\/div><\/td><\/tr><\/table><\/td><\/tr>\n    <tr><td><\/td><\/tr>\n<\/table>";

nlTooltipContent.prototype.getContent = function()
{
    var content = TOOLTIP_POPUP_SHELL;
    if (typeof this.title != "undefined" && this.title != null)
        content = content.replace("<messagetitle/>", this.title);
    if (typeof this.detail != "undefined" && this.detail != null)
        content = content.replace("<messagecontent/>", this.detail);
    if (typeof this.icon != "undefined" && this.icon != null)
        content = content.replace("<messageicon/>", this.icon);

    return content;
};
