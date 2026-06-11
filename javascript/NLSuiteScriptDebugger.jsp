





<!-- version 2026.1 -->
/* Debugger UI supports SuiteScript version 1.0 and 2.0*/
/*place holder for deplayed cancel request.  We don't want to send cancelr equest while script is running because it might cause dead lock on the server side.  Stop gap fix before we can fix the dead lock issue on the server.*/
var deplayedCancelRequest;
/* client track if the script is running mode */
var isScriptInRunningMode = false;

var debugSessionId;

//client side tracking if it's a adhoc/attach/load mode
var currentDebugMode;

var currentChromeDevtoolsUrl;

//client side track if it's UI control or script control, meaning it's stop at a breakpoint vs. script is currently running.
var scriptIsRunning =false;

var breakpoints = new Array();

var watches = new Array();

var chromeDevtools = function() {
	var urlFetchedTime = null;
	var urlTtlSeconds = null;
	var debugSessionGuid = null;
	var lastOperation = null;

	function shouldUse()
	{
		var runtimeVersionElement = document.forms['main_form'].elements['runtimeversion'];
		return (runtimeVersionElement && runtimeVersionElement.value  == '2.1');
	}

	function debugScript(operation)
	{
		lastOperation = operation;

		disableDebugButtons(true);
		disableCancelButton(false);
		disableDebuggerWindow(false);
		hideDebuggerWindowButtons(true);
		currentChromeDevtoolsUrl = "";

		var postdata = '<nsDebugInitRequest operation="' + operation + '">';
		if (operation == 'adhoc') {
			var runtimeVersion = document.forms['main_form'].elements['runtimeversion'].value;
			var script = document.forms['main_form'].elements['mainscript'].value;
			// TODO: check script empty
			postdata += '<script runtimeversion="' + runtimeVersion + '"><![CDATA[' + script + ']]></script>';
			document.getElementById('debuggerwindow').innerHTML = '<pre>' + script + '</pre>';
		}
		else {
			postdata += '<scriptId>' + document.forms['main_form'].elements['script'].value + '</scriptId>';
			postdata += '<deployId>' + document.forms['main_form'].elements['deploy'].value + '</deployId>';
			postdata += '<trigger>' + document.forms['main_form'].elements['trigger'].value + '</trigger>';
		}
		postdata += '</nsDebugInitRequest>';
		var request = new NLXMLHttpRequest();
		request.setResponseHandler(initDebugCallback);
		request.requestURL('/app/common/scripting/debugger/chromedevtools/init.nl', postdata, null, true, 'POST');
	}

	function cancel()
	{
		var nsPayload = "<nsDebugRequest operation='invalidateDebugSession'></nsDebugRequest>";
		var request = new NLXMLHttpRequest();
		request.setResponseHandler(cancelCallback);
		request.requestURL('/app/common/scripting/scriptdebugger.nl', nsPayload, null, true);
	}

	function rerunScript()
	{
		debugScript(lastOperation);
	}

	function switchToEditor()
	{
		setDebuggerStatusBar("New Script");
		nlapiDisableField('runtimeversion', false);
		disableDebugButtons(false);
		disableDebuggerWindow(true);
	}

	function cancelCallback(response)
	{
		if (handleCallbackError(response, null))
			return;
		var objJSON = eval("(" + response.getBody() + ")");
		var debuggerState = objJSON.debuggerState;
		if (debuggerState.status == 'completed')
		{
			handleDebugComplete();
		}
		else
		{
			setTimeout(cancel, 1000);
		}
	}

	function initDebugCallback(response)
	{
		// TODO: error handling
		var parsedResponse = JSON.parse(response.getBody());
		updateState();
	}

	function updateState() {
		var xhttp = new XMLHttpRequest();
		xhttp.onreadystatechange = function() {
			if (this.readyState == 4 && this.status == 200) {
				var response = JSON.parse(this.responseText);
				if (response.state == 'waitingForChromeDevtoolsAttach') {
					setDebuggerStatusBar("Waiting for debugger to attach");  // TODO: SSLANGUAGE-1013
					fetchChromeDevtoolsUrlAndOpenAWindow();
				}
				if (response.state == 'debugging') {
					var scriptTitle = lastOperation == 'adhoc'
						? 'New Script'
						: response.title;
					setDebuggerStatusBar("Debugging " + scriptTitle);
				}
				if (response.state == 'waitingForAttach') {
					setDebuggerStatusBar("Waiting for User Action");
				}
				if (response.state == 'waitingForChromeDevtoolsReAttach') {
					setDebuggerStatusBar("Waiting for debugger to reattach"); // TODO: SSLANGUAGE-1014
					fetchChromeDevtoolsUrlAndOpenAWindow();
				}
				if (response.state == 'debugComplete') {
					handleDebugComplete();
				}
				else {
					updateState();
				}
			}
		};
		xhttp.open("GET", "/app/common/scripting/debugger/chromedevtools/getstate.nl", true);
		xhttp.send();
	}

	function handleDebugComplete()
	{
		disableCancelButton(true);
		hideDebuggerWindowButtons(false);

		if (lastOperation == 'adhoc')
			setDebuggerStatusBar("Completed New Script Execution");
		else
			setDebuggerStatusBar("Completed Deployed Script Execution");
	}

	function fetchChromeDevtoolsUrlAndOpenAWindow() {
		var xhttp = new XMLHttpRequest();
		xhttp.onreadystatechange = function() {
			if (this.readyState == 4 && this.status == 200) {
				var response = JSON.parse(this.responseText);
				if ("" === currentChromeDevtoolsUrl) {
					currentChromeDevtoolsUrl = response.url;
					window.open(response.url, 'Script Debugger');
                }
			}
		};
		xhttp.open("GET", "/app/common/scripting/debugger/chromedevtools/newdebugurl.nl", true);
		xhttp.send();
	}

	function disableCancelButton(disable)
	{
		if (disable)
		{
			document.getElementById('cancel').disabled = true;
			document.getElementById('cancel').firstChild.src = '/images/debugger/cancel_disabled.gif';
		}
		else
		{
			document.getElementById('cancel').disabled = false;
			document.getElementById('cancel').firstChild.src = '/images/debugger/cancel.gif';
		}
	}

	function disableDebuggerWindow(disable)
	{
		if (disable)
		{
			document.getElementById('debuggerwindow').style.display = 'none';
			document.getElementById('mainscript').style.display = '';
			document.getElementById('editorstatusbar').style.display = '';
		}
		else
		{
			document.getElementById('debuggerwindow').style.display = '';
			document.getElementById('mainscript').style.display = 'none';
			document.getElementById('editorstatusbar').style.display = 'none';
		}
	}

	function hideDebuggerWindowButtons(hide)
	{
		if (hide)
		{
			document.getElementById('debuggerwindow').innerHTML = '';
		}
		else
		{
			// TODO: DRY
			
			document.getElementById('debuggerwindow').innerHTML = "<SPAN class='smalltext'><TABLE cellSpacing=0 cellPadding=3 border=0><TBODY><TR><TD><span id='tbl_rerunscript'><BUTTON class='smalltext' style='color: #000000; font-weight: bold; cursor: pointer;' value='Re-run Script' title='Re-run Script' id='rerunscript' name='rerunscript' onclick=\"chromeDevtools.rerunScript(); return false;\"><img src='/images/debugger/rerun.gif' style='vertical-align: bottom' alt='' />&nbsp;Re-run Script</button></span></TD><TD><span id='tbl_showeditor'><BUTTON class='smalltext' style='color: #000000; font-weight: bold; cursor: pointer;' value='Switch to Editor' title='Switch to Editor' id='showeditor' name='showeditor' onclick=\"chromeDevtools.switchToEditor(); return false;\"><img src='/images/debugger/editor.gif' style='vertical-align: bottom' alt='' />&nbsp;Switch to Editor</button></span></TD></TR></TBODY></TABLE></SPAN>";
		}
	}

	/**
	 * Affects the "Debug Script" and "Debug Existing" buttons.
	 */
	function disableDebugButtons(disable)
	{
		if (disable)
		{
			document.getElementById('debug').disabled = true;
			document.getElementById('debug').firstChild.src = '/images/debugger/debug_disabled.gif';
			document.getElementById('attach').disabled = true;
			document.getElementById('attach').firstChild.src = '/images/debugger/attach_disabled.gif';
		}
		else
		{
			document.getElementById('debug').disabled = false;
			document.getElementById('debug').firstChild.src = '/images/debugger/debug.gif';
			document.getElementById('attach').disabled = false;
			document.getElementById('attach').firstChild.src = '/images/debugger/attach.gif';
		}
	}

	return {
		shouldUse: shouldUse,
		debugScript: debugScript,
        rerunScript: rerunScript,
        switchToEditor: switchToEditor,
		cancel: cancel
	};
}();

function handleCallbackError(response, command)
{
	if ( response.getError() != null )
	{
		showDebugger( false, command, 'completed' )
		buildLogConsole( 'system', response.getError().getCode(), response.getError().getDetails() );
		return true;
	}
	return false;
}

/**
 * Script Runner. Initiate Script execution session with integrated execution log
 *
 * @param mode		Two modes of adhoc SuiteScript execution: runclient or runserver
 * @param runnow	Used for client script execution (deferred so that dialogue can be rendered)
 */
function runScript( mode )
{
	var sScript = document.forms['main_form'].elements['mainscript'].value;
	if ( isValEmpty( sScript ) ) return;

	showDebugger( true, mode )
	if ( mode == 'runserver' )
	{
		var nsPayload = "<nsDebugRequest operation='runserver'><script><![CDATA[" + sScript + "]]></script>";
        if ( breakpoints.length > 0 )
        {
            nsPayload += "<breakpoint>";
            for ( var i = 0; i < breakpoints.length; i++ )
            {
                var bp = breakpoints[i];
                if ( bp.type=="line" )
                    nsPayload += "<file id ='" + bp.fileid + "' hashcode='" + bp.hashcode + "' url='"+ bp.url + "'><line>" + bp.line + "</line></file>";
                else if ( bp.type=="userevent" )
                    nsPayload += "<userevent><script>" + bp.script + "</script><deploy>" + bp.deploy + "</deploy></userevent>";
                else if ( bp.type=="customplugin" )
                    nsPayload += "<customplugin><script>" + bp.script + "</script></customplugin>";
            }
            nsPayload += "</breakpoint>";
        }
        if ( watches.length > 0 )
        {
            nsPayload += "<watches>";
            for ( var i = 0; i < watches.length; i++ )
            {
                var watch = watches[i];
                nsPayload += "<watch>" + watch.expression + "</watch>";
            }
            nsPayload += "</watches>";
        }
        nsPayload += "</nsDebugRequest>";
		var request = new NLXMLHttpRequest();
		request.setResponseHandler( runScriptCallback );
		request.requestURL( '/app/common/scripting/scriptdebugger.nl', nsPayload, null, true )
	}
	else
	{
		sScript = "try { "+sScript+" }\n" +
				  "catch( e ) { var error = nlapiCreateError( e ); nlapiLogExecution( 'system', error.getCode(), error.getDetails() ) }\n" +
				  "finally { showDebugger( false, '"+mode+"', 'completed' ); }";
		setTimeout( sScript, 100 )
	}
}
/**
 * Handle server response for remote script execution request.
 *
 * @param response	NLXMLResponse object containing server response data (error or
 */
function runScriptCallback(response)
{
	if ( handleCallbackError( response, 'runserver' ) ) return;

	var objJSON = eval("(" + response.getBody() + ")");
	var debuggerState = objJSON.debuggerState;
	buildLogConsoles( debuggerState );
	showDebugger( false, 'runserver', debuggerState.status )
}
/**
 * Toggle Debugger Window display between script textarea box and debugger pane. In debug mode, we include the
 * script line numbers, a section for setting breakpoints, and we also display the debugger specific buttons
 *
 * @param show  True if we're switching into the readonly debugger window mode. Otherwise display the textarea for ahodc editing
 * @param mode - debugging mode if were showing the debugger: adhoc|attach|load|runserver|runclient
 * @param status - run/debug status: completed|idle|running|notinitialized
 */
function showDebugger( show, mode, status )
{
    scriptIsRunning = false;
    var debugmode = mode != 'runserver' && mode != 'runclient'
    if ( show )
    {
        buildLogConsoles( null );
        if ( debugmode )
        {
            buildSourceCode( null );
            buildLocals( null );
            buildWatches( null );
			buildHistory( null );
        }
        setDebuggerStatusBar( "" );
		if ( document.getElementById('debug') != null )
		{
			document.getElementById('debug').disabled = true;
			document.getElementById('debug').firstChild.src = '/images/debugger/debug_disabled.gif';
			document.getElementById('attach').disabled = true;
			document.getElementById('attach').firstChild.src = '/images/debugger/attach_disabled.gif';
			document.getElementById('cancel').disabled = false;
			document.getElementById('cancel').firstChild.src = '/images/debugger/cancel.gif';
			disableDebuggerButtons( !debugmode )			
		}
		else
		{
			document.getElementById('runserver').disabled = true;
			document.getElementById('runserver').firstChild.src = '/images/debugger/run_disabled.gif';
			document.getElementById('runclient').disabled = true;
			document.getElementById('runclient').firstChild.src = '/images/debugger/run_disabled.gif';
		}
		document.getElementById('debuggerwindow').style.display = 'block';
        document.getElementById('mainscript').style.display = 'none';
		document.getElementById('editorstatusbar').style.display = 'none';

	    setDebuggerStatusBar( (	mode == "attach" ? "Waiting for User Action" :
		    mode == "load" ? "Loading Script" :
			    "Running Script") + "&nbsp;<img border=0 src='/images/debugger/running.gif'>" )
    }
    else
    {
		if ( document.getElementById('debug') != null )
		{
			disableDebuggerButtons( true );
			document.getElementById('cancel').disabled = true;
			document.getElementById('cancel').firstChild.src = '/images/debugger/cancel_disabled.gif';
		}
		if ( status != null )
        {
        
			setDebuggerStatusBar( mode == "load" || mode == "attach" ? "Completed Deployed Script Execution" : "Completed New Script Execution" )
			var html = debugmode ? "<span id='tbl_rerunscript'><BUTTON class='smalltext' style='color: #000000; font-weight: bold; cursor: pointer;' value='Re-run Script' title='Re-run Script' id='rerunscript' name='rerunscript' onclick=\"nlapiDisableField('runtimeversion',true);debugScript( '%mode%' ); return false;\"><img src='/images/debugger/rerun.gif' style='vertical-align: bottom' alt='' />&nbsp;Re-run Script</button></span>".replace('%mode%', mode) : "<span id='tbl_rerunscript'><BUTTON class='smalltext' style='color: #000000; font-weight: bold; cursor: pointer;' value='Re-run Script' title='Re-run Script' id='rerunscript' name='rerunscript' onclick=\"nlapiDisableField('runtimeversion',true);runScript( '%mode%' ); return false;\"><img src='/images/debugger/rerun.gif' style='vertical-align: bottom' alt='' />&nbsp;Re-run Script</button></span>".replace('%mode%', mode);
			var htmlEdit = "<span id='tbl_showeditor'><BUTTON class='smalltext' style='color: #000000; font-weight: bold; cursor: pointer;' value='Switch to Editor' title='Switch to Editor' id='showeditor' name='showeditor' onclick=\"nlapiDisableField('runtimeversion',false);showDebugger( false, '%mode%', null ); return false;\"><img src='/images/debugger/editor.gif' style='vertical-align: bottom' alt='' />&nbsp;Switch to Editor</button></span>".replace('%mode%', mode);
			document.getElementById('debuggerwindow').innerHTML = "<SPAN class='smalltext'><TABLE cellSpacing=0 cellPadding=3 border=0><TBODY><TR><TD>"+html+"</TD><TD>"+htmlEdit+"</TD></TR></TBODY></TABLE></SPAN>";
		}
        else
        {
            setDebuggerStatusBar( "New Script" );
            document.getElementById('debuggerwindow').innerHTML = "";
			if ( document.getElementById('debug') != null )
			{
				document.getElementById('debug').disabled = false;
				document.getElementById('debug').firstChild.src = '/images/debugger/debug.gif';
				document.getElementById('attach').disabled = false;
				document.getElementById('attach').firstChild.src = '/images/debugger/attach.gif';
			}
			else
			{
				document.getElementById('runserver').disabled = false;
				document.getElementById('runserver').firstChild.src = '/images/debugger/run.gif';
				document.getElementById('runclient').disabled = false;
				document.getElementById('runclient').firstChild.src = '/images/debugger/run.gif';
			}
			document.getElementById('mainscript').style.display = 'block';
			document.getElementById('mainscript').disabled = false;			
			document.getElementById('editorstatusbar').style.display = 'block';
			document.getElementById('debuggerwindow').style.display = 'none';
        }
    }
}
function disableDebuggerButtons(disable)
{
    scriptIsRunning = disable;
    if ( document.getElementById('debug') != null )
    {
        document.getElementById('stepover').disabled = disable;
        document.getElementById('stepover').firstChild.src = '/images/debugger/stepover'+(disable ? '_disabled' : '')+'.gif';
        document.getElementById('stepinto').disabled = disable;
        document.getElementById('stepinto').firstChild.src = '/images/debugger/stepinto'+(disable ? '_disabled' : '')+'.gif';
        document.getElementById('stepout').disabled = disable;
        document.getElementById('stepout').firstChild.src = '/images/debugger/stepout'+(disable ? '_disabled' : '')+'.gif';
        document.getElementById('continue').disabled = disable;
        document.getElementById('continue').firstChild.src = '/images/debugger/continue'+(disable ? '_disabled' : '')+'.gif';
    }
}

	/**
 * Scroll debugger pane until a particular line of content is in view.
 *
 * TODO: promote this function to NLAppUtil.js or NLUIWidgets.js since it is quite general
 *
 * @param line  line of content (usually stored in a DIV being displayed)
 * @param pane  container for debugger content (should be a DIV)
 */
function scrollIntoView(line, pane)
{
    var scrollTop = pane.scrollTop;
    var scrollHeight = pane.offsetHeight;
    var lineTop = line.offsetTop;
    var lineHeight = line.offsetHeight;
    if (scrollTop > lineTop)
        line.scrollIntoView(true);
    else if (scrollTop + scrollHeight < lineTop + lineHeight)
        line.scrollIntoView(false);
}
/**
 * Build/Display main debugger UI
 *
 * @param debuggerState object containing debugger state information with the following properties:
 *                          mode:    mode the debugger is in: adhoc|attach|load
 *                          status:    debugger status: debugging|idle|completed
 *                          console:    array of execution log entries [{type, subject, details, timestamp} ... ]
 *                          evaluation:    array of watch expressions [{expression, value, type, haschildren} ... ]
 *                          properties:    array of property expressions [{expression, value, type, haschildren, index} ... ]
 *                          watches:    array of watch expressions [{expression, value, type, haschildren} ... ]
 *                          source:     { html, title, url, sourceid, selectedline, currentline, lines:  array of source lines [{source,breakpoint,breakable,currentline} ... ] }
 *                          breakpoints: array of userevent objects [{scriptId,deployId,recordType,status, script} ... ] }
 *                          callstack:  array of functions called during callstack [{name,locals,index} ... ]
 *                                      where locals is an array of expressions [{expression, value, type, haschildren} ... ]
 * @param operation         The debugger command issued: stepover|stepinto|stepout|cancel|go|addwatch|breakpoint|switchframe|adduserevent
 * @param optionalArg 		Optional argument used to configure command.
 */
function buildSourceCode( debuggerState, operation, optionalArg )
{
    if ( debuggerState == null )
	{
		setDebuggerInfo( "debugger", "content", "" );
		setFormValue( document.forms['main_form'].elements['url'], "" );
		setFormValue( document.forms['main_form'].elements['sourceid'], "" );
		setFormValue( document.forms['main_form'].elements['lastselection'], "" );
		setFormValue( document.forms['main_form'].elements['lastbreakpoint'], "" );
	}
	else
    {
		var url = debuggerState.source.url;
		var sourceid = debuggerState.source.sourceid;
		var lines = debuggerState.source.lines;
        var currentline = debuggerState.source.currentline;
		var selectedline = debuggerState.source.selectedline;
        var runtimeversion = debuggerState.source.runtimeversion;
		if (document.getElementById('debugger_splits') == null || url != getFormValue(document.forms['main_form'].elements['url']) || sourceid != getFormValue(document.forms['main_form'].elements['sourceid']))
        {
			var debuggerHtml = debuggerState.source.html;
            setDebuggerInfo( "debugger", "content", debuggerHtml );
			setFormValue( document.forms['main_form'].elements['url'], url );
			setFormValue( document.forms['main_form'].elements['sourceid'], sourceid );
			setFormValue( document.forms['main_form'].elements['lastselection'], new String(selectedline) );
			setFormValue( document.forms['main_form'].elements['lastbreakpoint'], new String(currentline) );
		}
        else if ( operation == 'breakpoint' )
        {
			var linenum = parseInt( optionalArg.line );
			var line = lines[ linenum-1 ];
			document.getElementById('debugger'+linenum).childNodes[1].firstChild.style.visibility = line.breakpoint ? "visible" : "hidden";
		}
		else
        {
			var lastselection = parseInt( getFormValue( document.forms['main_form'].elements['lastselection'] ) );
			var lastbreakpoint = parseInt( getFormValue( document.forms['main_form'].elements['lastbreakpoint'] ) );
			var linesToProcess = currentline != null ? [currentline, selectedline, lastselection, lastbreakpoint] : [selectedline, lastselection, lastbreakpoint];
			for ( var i = 0; i < linesToProcess.length; i++ )
            {
				if ( isValEmpty(linesToProcess[i]) || isNaN(linesToProcess[i]) ) continue;
				var line = lines[linesToProcess[i]-1];
				var cell = document.getElementById('debugger'+line.linenum).childNodes[2];
				cell.style.backgroundColor = line.currentline ? "#FFFF44" : line.selectedline ? "#B8C7DB" : "#FFFFFF";
			}
			setFormValue( document.forms['main_form'].elements['lastselection'], new String(selectedline) );
			setFormValue( document.forms['main_form'].elements['lastbreakpoint'], new String(currentline) );
        }
        /* auto-scroll to current line (or selected line) as necessary. */
        if ( operation != 'breakpoint' && selectedline != null )
            scrollIntoView( document.getElementById('debugger'+selectedline), document.getElementById('debuggerwindow') )

        setFormValue( document.forms['main_form'].elements['runtimeversion'], runtimeversion );
    }
}
/**
 * Build Execution Logs (Console)
 *
 * @param debuggerState object containing debugger state information with the following properties:
 *                          mode:    mode the debugger is in: adhoc|attach|load
 *                          status:    debugger status: debugging|idle|completed
 *                          console:    array of execution log entries [{type, subject, details, timestamp} ... ]
 *                          evaluation:    array of watch expressions [{expression, value, type, haschildren} ... ]
 *                          properties:    array of property expressions [{expression, value, type, haschildren, index} ... ]
 *                          watches:    array of watch expressions [{expression, value, type, haschildren} ... ]
 *                          source:     { html, title, url, sourceid, selectedline, currentline, lines:  array of source lines [{source,breakpoint,breakable,currentline} ... ] }
 *                          breakpoints: array of userevent objects [{scriptId,deployId,recordType,status, script} ... ] }
 *                          callstack:  array of functions called during callstack [{name,locals,index} ... ]
 *                                      where locals is an array of expressions [{expression, value, type, haschildren} ... ]
 */
function buildLogConsoles(debuggerState)
{
    if ( debuggerState == null )
    {
		setDebuggerInfo( "console", "content", "" );
		setDebuggerInfo( "console", "count", 0 );
    }
	else
	{
		for ( var i = 0; i < debuggerState.console.length; i++ )
			buildLogConsole( debuggerState.console[i].type, debuggerState.console[i].subject, debuggerState.console[i].details, debuggerState.console[i].timestamp )
	}
}
/**
 * Build Execution Log (Console).
 *
 * @param type          Log type: (system|debug|audit|error|emergency)
 * @param title         Log title   (required)
 * @param details       Log details (optional)
 * @param timestamp     Log timestamp (server generated but in the user's timezone)
 */
function buildLogConsole(type, title, details, timestamp)
{
    var count = getDebuggerInfo( 'console', 'count' )+1;
    var hasDetails = !isValEmpty(details);
	var colormap = {"debug" : "black", "audit" : "#006600", "error" : "#0066CC", "emergency" : "#CC3300", "system" : "red", "internal" : "gray", "warning" : "#663300" };
	var html = "<TABLE border=0 width=100% cellpadding=2 cellspacing=0 id='console"+count+"'>";
		html += "<TR style='width: 100%' id='consolesummary"+count+"' onmouseover='highlightConsoleLine(this.id, true)' onmouseout='highlightConsoleLine(this.id, false)'>";
			html +=	"<TD class='smalltext' style='width: 10%; white-space:nowrap; font-family: Courier New; font-weight: bold; color: "+colormap[type]+"'>";
				html += "<img onclick='showConsoleDetails(\"consolesummary"+(count)+"\", this.src.indexOf(\"plus.gif\") > 0)' src='/images/nav/tree/plus.gif' style='vertical-align: top; cursor: pointer; visibility:"+(hasDetails ? 'visible' : 'hidden')+"'>"+type;
			html += "</TD>";
			html += "<TD class='smalltext' style='width: 75%; white-space:nowrap; font-family: Courier New; font-weight: bold; color: "+colormap[type]+"'>"+title+"</TD>";
			html += "<TD class='smalltext' style='white-space:nowrap; font-family: Courier New; text-align: right'>"+nvl(timestamp,'&nbsp;')+"</TD>";
		html += "</TR>";
	if ( hasDetails )
		html += "<TR style='display: none; width: 100%' id='consoledetails"+count+"'><TD>&nbsp;</TD><TD colspan=2 class='smalltext' style='font-family: Courier New'>"+( details.replace(/[\n]/g, '<br>') )+"</TD></TR>";
	html += "</TABLE>";
	var consoleHtml = document.getElementById('consolewindow').innerHTML;
	setDebuggerInfo( "console", "content", html + consoleHtml );
	setDebuggerInfo( "console", "count", count )
}
/**
 * Display properties for an expression|variable by fetching and then expanding the variables window one level to
 * show property details. This also handles collapsing of this view.
 *
 * @param id       DOM id containing the current node
 * @param expand   If true then we need to expand the properties. Otherwise collapse the properties one level
 */
function showConsoleDetails( id, expand )
{
	var node = document.getElementById( id.replace('summary', 'details') );
    node.style.display = expand ? '' : 'none' ;
    document.getElementById( id ).firstChild.firstChild.src= expand ? '/images/nav/tree/minus.gif' : '/images/nav/tree/plus.gif';
}
/**
 * Highlight console line
 *
 * @param id       DOM id containing the current node
 * @param expand   Highlight the line if true. Unhighlight otherwise
 */
function highlightConsoleLine( id, higlight )
{
    document.getElementById( id ).style.backgroundColor = higlight ? "EEEEEE" : "FFFFFF";
    var node = document.getElementById( id.replace('console', 'consoledetails') );
    if ( node != null )
        node.style.backgroundColor = higlight ? "EEEEEE" : "FFFFFF";
}
/**
 * Build/Display watch expressions UI
 *
 * @param debuggerState object containing debugger state information with the following properties:
 *                          mode:    mode the debugger is in: adhoc|attach|load
 *                          status:    debugger status: debugging|idle|completed
 *                          console:    array of execution log entries [{type, subject, details, timestamp} ... ]
 *                          evaluation:    array of watch expressions [{expression, value, type, haschildren} ... ]
 *                          properties:    array of property expressions [{expression, value, type, haschildren, index} ... ]
 *                          watches:    array of watch expressions [{expression, value, type, haschildren} ... ]
 *                          source:     { html, title, url, sourceid, selectedline, currentline, lines:  array of source lines [{source,breakpoint,breakable,currentline} ... ] }
 *                          breakpoints: array of userevent objects [{scriptId,deployId,recordType,status, script} ... ] }
 *                          callstack:  array of functions called during callstack [{name,locals,index} ... ]
 *                                      where locals is an array of expressions [{expression, value, type, haschildren} ... ]
 */
function buildWatches(debuggerState, statusMessage)
{
    document.forms['watches_form'].reset();
    var watchInputField = document.forms['watches_form'].elements['watchexpression'];
    disableField(watchInputField, false);
    if(debuggerState == null && statusMessage!=null) /*null out the data and show status message.*/
    {
         setDebuggerInfo( 'watches', 'content', statusMessage );
         disableField(watchInputField, true);
    }
    else if ( debuggerState == null || debuggerState.status != 'running' )
        setDebuggerInfo( 'watches', 'content', '' );
    else
    {
        var watchHtml = "";
        watches = [];
        for ( var i = 0; i < debuggerState.watches.length; i++ )
        {
            var watch = debuggerState.watches[ i ];
            watches.push(watch);
            var expression = watch.expression;
            var type = isValEmpty(watch.type) ? '' : '{'+watch.type+'} ';
            var value = isValEmpty(watch.value) ? "&nbsp;" : watch.value.replace(/\s/g, '&nbsp;');
            var objImg = deriveDebuggerObjectImageName(watch);
			watchHtml +=    "<DIV id='watches"+(i+1)+"' style='white-space: nowrap'>";
				watchHtml +=   "<img src='/images/debugger/cancel.gif' style='cursor: pointer' onclick='addWatch(this.parentNode.getAttribute(\"expression\"))'>";
				watchHtml +=   "<img onclick='showProperties(\"watches"+(i+1)+"\", this.parentNode.getAttribute(\"expression\"), this.src.indexOf(\"plus.gif\") > 0)' src='/images/nav/tree/plus.gif' id='watches"+(i+1)+"_icon' style='vertical-align: top; cursor: pointer; visibility:"+(watch.haschildren ? 'visible' : 'hidden')+"'>";
                watchHtml +=   "<img src='/images/debugger/"+objImg+".gif' style='vertical-align: top'>";
                watchHtml +=   "<SPAN style='vertical-align: top; font-family: Courier New'>"+expression+" = "+type+value+"</SPAN>";
            watchHtml +=    "</DIV>"
		}
		setDebuggerInfo( 'watches', 'content', watchHtml )
		for ( var i = 0; i < debuggerState.watches.length; i++ )
			document.getElementById('watches'+(i+1)).setAttribute('expression', debuggerState.watches[ i ].expression)
		setDebuggerInfo( 'watches', 'count', debuggerState.watches.length )
    }
}
/**
 * Build/Display Local Variables and Call Stack UI
 *
 * @param debuggerState object containing debugger state information with the following properties:
 *                          mode:    mode the debugger is in: adhoc|attach|load
 *                          status:    debugger status: debugging|idle|completed
 *                          console:    array of execution log entries [{type, subject, details, timestamp} ... ]
 *                          evaluation:    array of watch expressions [{expression, value, type, haschildren} ... ]
 *                          properties:    array of property expressions [{expression, value, type, haschildren, index} ... ]
 *                          watches:    array of watch expressions [{expression, value, type, haschildren} ... ]
 *                          source:     { html, title, url, sourceid, selectedline, currentline, lines:  array of source lines [{source,breakpoint,breakable,currentline} ... ] }
 *                          breakpoints: array of userevent objects [{scriptId,deployId,recordType,status, script} ... ] }
 *                          callstack:  array of functions called during callstack [{name,locals,index} ... ]
 *                                      where locals is an array of expressions [{expression, value, type, haschildren} ... ]
 */
function buildLocals(debuggerState, statusMessage)
{
    document.forms['locals_form'].reset();
    deleteAllSelectOptions( document.forms['locals_form'].elements['callframe'] )
    if(debuggerState == null && statusMessage!=null) /*null out the data and show status message.*/
    {
        setDebuggerInfo( 'locals', 'content', statusMessage )
        setDebuggerInfo( 'locals', 'count', 0 )
    }
    else if ( debuggerState == null || debuggerState.status != 'running' )
    {
        setDebuggerInfo( 'locals', 'content', '' )
        setDebuggerInfo( 'locals', 'count', 0 )
    }
    else
    {
		for ( var j = 0; debuggerState.stacktrace != null && j < debuggerState.stacktrace.length; j++ )
        {
            var frame = debuggerState.stacktrace[ j ];
            addSelectOption( document, document.forms['locals_form'].elements['callframe'], frame.name, frame.frame, frame.selected )
        }


        var localsHtml = "";
        for ( var i = 0; debuggerState.localvariables != null && i < debuggerState.localvariables.length; i++ )
        {
            var local = debuggerState.localvariables[i]
            var expression = local.expression;
            var type = isValEmpty(local.type) ? '' : '{'+local.type+'} ';
            var value = isValEmpty(local.value) ? "&nbsp;" : local.value.replace(/\s/g, '&nbsp;');
            var objImg = deriveDebuggerObjectImageName(local);
            localsHtml +=   "<DIV id='locals"+(i+1)+"' style='white-space: nowrap;'>";
            localsHtml +=   "<img onclick='showProperties(\"locals"+(i+1)+"\", \""+expression+"\", this.src.indexOf(\"plus.gif\") > 0)' src='/images/nav/tree/plus.gif' id='locals"+(i+1)+"_icon' style='vertical-align: top; cursor: pointer; visibility:"+(local.haschildren ? 'visible' : 'hidden')+"'>";
            localsHtml +=   "<img src='/images/debugger/"+objImg+".gif' style='vertical-align: top'>";
            localsHtml +=   "<SPAN style='vertical-align: top; font-family: Courier New'>"+expression+" = "+type+value+"</SPAN>";
            localsHtml +=   "</DIV>";
        }

        setDebuggerInfo( 'locals', 'content', localsHtml )
        setDebuggerInfo( 'locals', 'count', debuggerState.localvariables != null ? debuggerState.localvariables.length : 0 )
    }
}
/**
 * Switch Call Frames to one selected by the user
 *
 * @param idx index into selected call frame (0 being the current frame in the debugger)
 */
function switchCallFrame( idx )
{
    debugCommand( 'switchframe', idx )
}
/**
 * Add/Remove a User Event Break point
 *
 * @param id	unique identifier for this deployment: scriptId_deployId
 */
function addUserEvent( id )
{
    var obj = new Object();
    obj.scriptId = id.split('_')[0]
    obj.deployId = id.split('_')[1]
    debugCommand( 'adduserevent', obj )
}

/**
* Add/Remove a User Event Break point
*
* @param id	unique identifier for this deployment: scriptId_deployId
*/
function addCustomplugin( id )
{
     var obj = new Object();
     obj.scriptId = id;
     debugCommand( 'addcustomplugin', obj )
}

/**
 * Build/Display watch expressions UI
 *
 * @param debuggerState object containing debugger state information with the following properties:
 *                          mode:    mode the debugger is in: adhoc|attach|load
 *                          status:    debugger status: debugging|idle|completed
 *                          console:    array of execution log entries [{type, subject, details, timestamp} ... ]
 *                          evaluation:    array of watch expressions [{expression, value, type, haschildren} ... ]
 *                          properties:    array of property expressions [{expression, value, type, haschildren, index} ... ]
 *                          watches:    array of watch expressions [{expression, value, type, haschildren} ... ]
 *                          source:     { html, title, url, sourceid, selectedline, currentline, lines:  array of source lines [{source,breakpoint,breakable,currentline} ... ] }
 *                          breakpoints: array of userevent objects [{scriptId,deployId,recordType,status, script} ... ] }
 *                          callstack:  array of functions called during callstack [{name,locals,index} ... ]
 *                                      where locals is an array of expressions [{expression, value, type, haschildren} ... ]
 */
function buildBreakPoints(debuggerState)
{
    document.forms['breakpoints_form'].reset();
    if ( debuggerState == null || debuggerState.status != 'running' )
        setDebuggerInfo( 'breakpoints', 'content', '' )
    else
    {
        var html = "<TABLE border=0 width=100% cellpadding=1 cellspacing=0 style='overflow: auto' id='breakpoints_splits'>";
        breakpoints = new Array();
        for ( var i = 0; i < debuggerState.breakpoints.length; i++ )
        {
            var breakpoint = debuggerState.breakpoints[i];
            breakpoints.push(breakpoint);
			var backgroundStyle = breakpoint.status.indexOf('Active') == 0 ? "#FFFF44" : "#FFFFFF";
			html += "<TR id='breakpoints"+(i+1)+"' style='width: 100%; background-color: "+backgroundStyle+"'>";
			if ( breakpoint.type == 'userevent' )
			{
				html +=	"<TD class='smalltext' style='width: 2%; white-space:nowrap'><img src='/images/debugger/cancel.gif' style='vertical-align: top; cursor: pointer' onclick='addUserEvent(\""+(breakpoint.script+'_'+breakpoint.deploy)+"\")'></TD>" +
						"<TD class='smalltext' style='width: 10%; white-space:nowrap'>"+breakpoint.typename+"</TD>" +
						"<TD class='smalltext' style='white-space:nowrap'>"+breakpoint.name+" ("+breakpoint.record+")</TD>" +
						"<TD class='smalltext' style='white-space:nowrap'>"+breakpoint.status+"</TD>";
			}
            else if ( breakpoint.type == 'customplugin' )
            {
                html +=	"<TD class='smalltext' style='width: 2%; white-space:nowrap'><img src='/images/debugger/cancel.gif' style='vertical-align: top; cursor: pointer' onclick='addCustomplugin(\""+(breakpoint.script)+"\")'></TD>" +
                           "<TD class='smalltext' style='width: 10%; white-space:nowrap'>"+breakpoint.typename+"</TD>" +
                           "<TD class='smalltext' style='white-space:nowrap'>"+breakpoint.name+"</TD>" +
                           "<TD class='smalltext' style='white-space:nowrap'>"+breakpoint.status+"</TD>";
            }
			else
			{
				html +=	"<TD class='smalltext' style='width: 2%; white-space:nowrap'><img src='/images/debugger/cancel.gif' style='vertical-align: top; cursor: pointer' onclick='setBreakPoint("+breakpoint.line+",\""+breakpoint.url+"\")'></TD>" +
					   	"<TD class='smalltext' style='width: 10%; white-space:nowrap'>"+breakpoint.typename+"</TD>" +
						"<TD class='smalltext' style='white-space:nowrap'>"+ breakpoint.url +": line "+breakpoint.line+"</TD>" +
						"<TD class='smalltext' style='white-space:nowrap'>"+breakpoint.status+"</TD>";
			}
			html += "</TR>";
        }
        html += "</TABLE>"
        setDebuggerInfo( 'breakpoints', 'content', html )
        setDebuggerInfo( 'breakpoints', 'count', debuggerState.breakpoints.length )
    }
}
/**
 * Display properties for an expression|variable by fetching and then expanding the variables window one level to
 * show property details. This also handles collapsing of this view.
 *
 * @param id        DOM id containing the current compound expression|variable
 * @param expression    The current expression variable
 * @param expand   If true then we need to expand the properties. Otherwise collapse the properties one level
 */
function showProperties( id, expression, expand )
{
    var node = document.getElementById(id);
    var imgnode = document.getElementById(id + '_icon');
    var level = id.split('_').length;
    var childnodes = node.getElementsByTagName('DIV');
    if (expand)
    {
        var notYetLoaded = childnodes == null || childnodes.length == 0;
        if (notYetLoaded)
        {
            imgnode.setAttribute('expandImageSrc', imgnode.src)
            imgnode.src = '/images/help/animated_loading.gif';
            loadProperties(id, expression);
        }
        else
        {
            for (var i = 0; i < childnodes.length; i++)
                if (childnodes[i].id.split('_').length == level + 1)
                    childnodes[i].style.display = 'block';
            imgnode.src = imgnode.src.replace('plus', 'minus');
        }
    }
    else
    {
        for (var i = 0; i < childnodes.length; i++)
            if (childnodes[i].id.split('_').length == level + 1)
                childnodes[i].style.display = 'none';
        imgnode.src = imgnode.src.replace('minus', 'plus');
    }
}

/**
 * Fetch variable properties asynchronously from the debugger.. Returns the next level of properties for an expression
 * or variable.
 *
 * @param id            ID of the variable on the debugger page
 * @param expression    The expression or variable.
 */
function loadProperties( id, expression, frame )
{
	var propertyObjs = new Object();
	propertyObjs.id = id;
	propertyObjs.expression = expression;
	debugCommand('loadproperties', propertyObjs)
}

/**
*  Find appropriate icon image name for object type.
 *
 *@param property
* @returns {string}
 */
function deriveDebuggerObjectImageName(property)
{
    return property.haschildren
    ? (property.type
       //Version 1 nlobj*
       && (property.type.toLowerCase().indexOf('nlobj') == 0
           //Version 2 Object
           || property.isNsJsObject)
    ? 'objectns' : 'object') : 'primitive';
}

/**
 * Build up and display the server-generated properties for a variable node on the page
 *
 * @param debuggerState object containing debugger state information with the following properties:
 *                          mode:    mode the debugger is in: adhoc|attach|load
 *                          status:    debugger status: debugging|idle|completed
 *                          console:    array of execution log entries [{type, subject, details, timestamp} ... ]
 *                          evaluation:    array of watch expressions [{expression, value, type, haschildren} ... ]
 *                          properties:    array of property expressions [{expression, value, type, haschildren, index} ... ]
 *                          watches:    array of watch expressions [{expression, value, type, haschildren} ... ]
 *                          source:     { html, title, url, sourceid, selectedline, currentline, lines:  array of source lines [{source,breakpoint,breakable,currentline} ... ] }
 *                          breakpoints: array of userevent objects [{scriptId,deployId,recordType,status, script} ... ] }
 *                          callstack:  array of functions called during callstack [{name,locals,index} ... ]
 *                                      where locals is an array of expressions [{expression, value, type, haschildren} ... ]
 * @param id            ID for the variable on the page whose properties are being built
 * @param expression    variable whose properties are being built
 * @param frame         call frame where this expression should be evaluated
 */
function buildProperties(debuggerState, id, expression, frame)
{
    var idObjs = id.split('_');
    var level = idObjs.length;
    var node = document.getElementById( id );

    for ( var i = 0; i < debuggerState.properties.length; i++ )
    {
        var property = debuggerState.properties[i];
        var index = property.index;
        var subexpression = expression + ( index != null ? "["+index+"]" : "."+ property.expression ) ;
        var displayexpression = index != null ? "["+index+"]" : property.expression;
        var type = isValEmpty(property.type) ? '' : '{'+property.type+'} ';
        var value = isValEmpty(property.value) ? "&nbsp;" : property.value.replace(/\s/g, '&nbsp;');

        var div = document.createElement("DIV");
        div.id = id + '_' + (i+1);
        div.style.whiteSpace = 'nowrap';
        div.setAttribute( "lastsibling", i == debuggerState.properties.length-1 ? "T" : "F" )
		var objImg = deriveDebuggerObjectImageName(property);
		var img = property.haschildren ? (i == debuggerState.properties.length-1 ? 'plus_l' : 'plus_t') : (i == debuggerState.properties.length-1 ? 'l' : 't');
        var spanHtml = id.indexOf( 'watches' ) == 0 ? "<img src='/images/debugger/cancel.gif' style='vertical-align: top; visibility: hidden'>" : "";
        var x = [];
        for ( var j = 0; j < level; j++ )
        {
            x[x.length] = idObjs[j];
            var hideBar = j == 0 || document.getElementById( x.join('_') ).getAttribute("lastsibling") == "T";
            spanHtml +=   "<img src='/images/nav/tree/bar.gif' style='vertical-align: top; visibility: "+(hideBar ? 'hidden' : 'visible')+"'>";
        }
        spanHtml +=   "<img onclick='showProperties(\""+div.id+"\", \""+subexpression+"\", this.src.indexOf(\"plus\") > 0, "+frame+")' id='"+div.id+"_icon' src='/images/nav/tree/"+img+".gif' style='vertical-align: top; cursor: pointer'>";
        spanHtml +=   "<img src='/images/debugger/"+objImg+".gif' style='vertical-align: top'>";
        spanHtml +=   "<SPAN style='vertical-align: top; font-family: Courier New'>"+displayexpression+" = "+type+value+"</SPAN>";
        div.innerHTML = spanHtml;
        node.appendChild( div );
    }
    document.getElementById( id + '_icon' ).src = document.getElementById( id + '_icon' ).getAttribute('expandImageSrc').replace('plus','minus');
}
/**
 * Build/Display command (eval) history UI
 *
 * @param debuggerState object containing debugger state information with the following properties:
 *                          mode:    mode the debugger is in: adhoc|attach|load
 *                          status:    debugger status: debugging|idle|completed
 *                          console:    array of execution log entries [{type, subject, details, timestamp} ... ]
 *                          evaluation:    array of watch expressions [{expression, value, type, haschildren} ... ]
 *                          properties:    array of property expressions [{expression, value, type, haschildren, index} ... ]
 *                          watches:    array of watch expressions [{expression, value, type, haschildren} ... ]
 *                          source:     { html, title, url, sourceid, selectedline, currentline, lines:  array of source lines [{source,breakpoint,breakable,currentline} ... ] }
 *                          breakpoints: array of userevent objects [{scriptId,deployId,recordType,status, script} ... ] }
 *                          callstack:  array of functions called during callstack [{name,locals,index} ... ]
 *                                      where locals is an array of expressions [{expression, value, type, haschildren} ... ]
 */
function buildHistory(debuggerState, statusMessage)
{
    var count = getDebuggerInfo( 'history', 'count' )+1;
    document.forms['history_form'].reset();
    var evalExprInputField = document.forms['history_form'].elements['evalexpression'];
    disableField(evalExprInputField, false);
    if(debuggerState == null && statusMessage!=null) /*null out the data and show status message.*/
    {
        setDebuggerInfo( 'history', 'content', statusMessage )
        setDebuggerInfo( 'history', 'count', 0 )
        disableField(evalExprInputField, true);
    }
    else if ( debuggerState == null || debuggerState.status != 'running' )
    {
        setDebuggerInfo( 'history', 'content', '' )
        setDebuggerInfo( 'history', 'count', 0 )
    }
    else
    {
        var expression = nvl( debuggerState.evaluation.expression, "&nbsp;" );
        var value = nvl( debuggerState.evaluation.value, "&nbsp;" );

        var html = "<DIV style='color: blue; padding: 1px 0 1px 2px; white-space: nowrap; font-family: Courier New'>$ "+expression+"</DIV>";
        html += "<DIV style='background-color: #EEEEEE'; padding: 1px 0 1px 2px; white-space: nowrap; font-family: Courier New' id='history"+count+"'>&gt; "+value+"</DIV>";

		var historyHtml = document.getElementById('historywindow').innerHTML;
        setDebuggerInfo( 'history', 'content', html+historyHtml )
        setDebuggerInfo( 'history', 'count', count )
    }
}
/**
 * Set status bar contents for main debugger window
 *
 * @param info information to set
 */
function setDebuggerStatusBar(info)
{
    if ( info == null )
        info  = "&nbsp;"
    document.getElementById('debuggerstatusbar').firstChild.innerHTML = info;
}
/**
 * Set information in a debugger sub-window
 *
 * @param tabname   debug window tab name: watches|console|locals|history|userevent|debugger (main)
 * @param type      debug window information type: count|history|content
 * @param info      information to set
 */
function setDebuggerInfo(tabname, type, info)
{
	if ( type == 'content' )
        document.getElementById(tabname+'window').innerHTML = info;
    else if ( type == 'count' )
    {
        if ( document.forms[tabname+'_form'].elements[tabname+'count'] != null )
            setFormValue( document.forms[tabname+'_form'].elements[tabname+'count'], new String( info ) );
        setDebuggerTabTotal( tabname, info )    /* Defined in NLScriptDebuggerEntryForm.java (requires logic in NLBottomTab) */
    }
}
/**
 * Return information from a debugger sub-window
 *
 * @param tabname   debug window tab name: watches|console|locals|history
 * @param type      debug window information type: count|history
 */
function getDebuggerInfo(tabname, type)
{
    if ( type == 'count' )
    {
        var count = getFormValue( document.forms[tabname+'_form'].elements[tabname+'count'] )
        return isValEmpty( count ) ? 0 : parseInt( count, 10 );
    }
	return null;
}
/**
 * Initiate script debugging session. Operates in three modes:
 *  adhoc:  script is entered by user in UI
 *  attach: script (UE, Portlet, Suitelet) will be attached to by the debugger
 *  load:   script is executed inline directly from a scheduled script deployment
 *
 * script for adhoc is stored in a textarea called mainscript on the main form
 * script and deployment ids for load and attach are stored in 2 hidden fields (named script and deploy) on the main form
 *
 * @param sMode     mode of debugging: load|adhoc|attach
 */
function debugScript( sMode )
{
	if (chromeDevtools.shouldUse()) {
		chromeDevtools.debugScript(sMode);
		return;
	}

    if(sMode == "null")
        sMode = currentDebugMode; // this when debug session get invalidate, and user click on re-run again.
    else
        currentDebugMode = sMode;
	var sScript = document.forms['main_form'].elements['mainscript'].value;
	if ( isValEmpty( sScript ) && sMode == 'adhoc' ) return;

	showDebugger( true, sMode );
    var runtimeVersion = ((sMode=='adhoc'&& document.forms['main_form'].elements['runtimeversion'])?document.forms['main_form'].elements['runtimeversion'].value:'1.0');
    var nsPayload = "<nsDebugRequest operation='"+sMode+"'>";
    nsPayload += sMode == 'adhoc' ? ("<script "+" runtimeversion='"+  runtimeVersion + "'><![CDATA[" + sScript + "]]></script>") : ("<scriptId>" + document.forms['main_form'].elements['script'].value + "</scriptId><deployId>" + document.forms['main_form'].elements['deploy'].value + "</deployId><type>" + document.forms['main_form'].elements['scripttype'].value + "</type><trigger>" + document.forms['main_form'].elements['trigger'].value + "</trigger>");
	nsPayload += '<url><![CDATA['+ getFormValue( document.forms['main_form'].elements['url'] ) +']]></url>';
    if ( breakpoints.length > 0 )
    {
        nsPayload += "<breakpoint>";
        for ( var i = 0; i < breakpoints.length; i++ )
        {
            var bp = breakpoints[i];
            if ( bp.type=="line" )
                nsPayload += "<file id ='" + bp.fileid + "' hashcode='" + bp.hashcode + "' url='"+ bp.url + "'><line>" + bp.line + "</line></file>";
            else if ( bp.type=="userevent" )
                nsPayload += "<userevent><script>" + bp.script + "</script><deploy>" + bp.deploy + "</deploy></userevent>";
            else if ( bp.type=="customplugin" )
                nsPayload += "<customplugin><script>" + bp.script + "</script></customplugin>";
        }
        nsPayload += "</breakpoint>";
    }
    if ( watches.length > 0 )
    {
        nsPayload += "<watches>";
        for ( var i = 0; i < watches.length; i++ )
        {
            var watch = watches[i];
            nsPayload += "<watch>" + watch.expression + "</watch>";
        }
        nsPayload += "</watches>";
    }
	nsPayload += "</nsDebugRequest>";

    var request = new NLXMLHttpRequest();
    request.setResponseHandler( function(response) { debugCommandCallback(response, sMode); } )
    request.requestURL( '/app/common/scripting/scriptdebugger.nl', nsPayload, null, true );
}

function invalidateDebugSession()
{
        if (document.getElementById('invalidateImage'))
	        document.getElementById('invalidateImage').style.display='';
        if (document.getElementById('invalidateMsg'))
        	document.getElementById('invalidateMsg').style.display="none";
        var nsPayload = "<nsDebugRequest operation='invalidateDebugSession'></nsDebugRequest>";
		var request = new NLXMLHttpRequest();
		request.setResponseHandler( function(response) { invalidateDebugSessionCallback(response)} );
		request.requestURL( '/app/common/scripting/scriptdebugger.nl', nsPayload, null, true )
}

/**
 * Called from attach to script popup page and done this way to workaround Firefox bug preventing AJAX calls in parent window when popup closes
 * prior to return of AJAX call. Stash mode in a hidden field and then call debugScript() using this field
 */
function startDebugger( ) { debugScript( document.forms['main_form'].elements['operation'].value ); }

/**
 * Resume an existing debug session (called when user navigates to the debugger page while a debug session is in progress
 *  adhoc:  script is entered by user in UI
 *  attach: script (UE, Portlet, Suitelet) will be attached to by the debugger
 *  load:   script is executed inline directly from a scheduled script deployment
 *
 * script for adhoc is stored in a textarea called mainscript on the main form
 * script and deployment ids for load and attach are stored in 2 hidden fields (named script and deploy) on the main form
 *
 * @param sMode     mode of debugging: load|adhoc|attach
 */
function resumeDebugger( sMode)
{
	showDebugger( true, sMode )
    var nsPayload = "<nsDebugRequest operation='resume' debugsessionid='" +debugSessionId + "'></nsDebugRequest>";
    var request = new NLXMLHttpRequest();
    request.setResponseHandler( function(response) { debugCommandCallback(response, sMode); } )
    request.requestURL( '/app/common/scripting/scriptdebugger.nl', nsPayload, null, true );
}

/**
 * Execute atomic command on the server-side debugger
 * @param command - debugger command issued:
 *                  stepover    execute current line and move to the next
 *                  stepinto    jump into the next function call on the current line
 *                  stepout     return from the current function (continue executing until return call)
 *                  cancel      cancel the current debugging session
 *                  go          resume execution (until the next breakpoint)
 *                  addwatch    add/remove a watch expression
 *                  breakpoint  set/unset a breakpoint
 *                  eval        evaluate an expression in the current frame
 *                  loadproperties  load all immediate child properties of a variable (in a window)
 *                  switchframe  switch to a different call frame (update locals, watch variables and debugger UI)
 *                  adduserevent  add/remove user event listener
 * @param optionalArg - optional argument used for modifying command request.
 *                          For breakpoint, this is an object [line, url] containing the break point
 *                          For eval, this is the expression to evaluate
 *                          For addwatch, this is the watch expression to add
 *                          For loadproperties, this is an object [id,expression] containing info about the expression being expanded
 *                          For adduserevent, this is an object [scriptId,deployId] containing the user event script deployment identifier
 */
function debugCommand( command, optionalArg )
{
	if (command == 'cancel' && chromeDevtools.shouldUse()) {
		chromeDevtools.cancel();
		return;
    }

    var nsPayload = "<nsDebugRequest operation='"+command+"' debugsessionid='"+debugSessionId +"'>";

    if ( command == 'breakpoint' )
        nsPayload += '<breakpoint><line>'+ optionalArg.line +'</line><url>'+optionalArg.url+'</url></breakpoint>';
    else if ( command == 'eval' )
        nsPayload += '<eval><![CDATA['+ optionalArg +']]></eval>';
    else if ( command == 'loadproperties' )
        nsPayload += '<variable><![CDATA['+ optionalArg.expression +']]></variable>';
    else if ( command == 'adduserevent' )
        nsPayload += '<scriptId>'+ optionalArg.scriptId +'</scriptId><deployId>'+optionalArg.deployId+'</deployId>';
    else if ( command == 'addcustomplugin' )
        nsPayload += '<scriptId>'+ optionalArg.scriptId +'</scriptId>';
    else if ( command == 'addwatch' )
        nsPayload += '<watch><![CDATA['+ optionalArg +']]></watch>';
	nsPayload += '<url><![CDATA['+ getFormValue( document.forms['main_form'].elements['url'] ) +']]></url>';
	nsPayload += '<sourceid><![CDATA['+ getFormValue( document.forms['main_form'].elements['sourceid'] ) +']]></sourceid>';
	if ( command.indexOf('step') != 0 && command != 'go' )
        nsPayload += '<frame>'+ getFormValue( document.forms['locals_form'].elements['callframe'] ) +'</frame>';
    nsPayload +=    "</nsDebugRequest>";

    if(command == 'go' ||  command.indexOf('step') == 0 )      //reset debug state when run/step button is pressed.
    {
        var statusMessage="The script is running . . .";
        buildLocals( null, statusMessage );
        buildWatches( null, statusMessage );
		buildHistory( null, statusMessage );
        isScriptInRunningMode = true;
    }

    var request = new NLXMLHttpRequest();
    request.setResponseHandler( function(response) { debugCommandCallback(response, command, optionalArg); } )
    if(command == 'cancel' && isScriptInRunningMode)   /* deplay request*/
    {
        deplayedCancelRequest = new Array();
        deplayedCancelRequest[0]=request;
        deplayedCancelRequest[1]=nsPayload;
    }
    else
    {
        request.requestURL( '/app/common/scripting/scriptdebugger.nl', nsPayload, null, true )
    }

	disableDebuggerButtons( true )
	setDebuggerStatusBar( "Running Script&nbsp;<img style='vertical-align: middle' border=0 src='/images/debugger/running.gif'>" )
}

function invalidateDebugSessionCallback(response)
{
    if ( handleCallbackError( response, null ) ) return;
    var objJSON = eval("(" + response.getBody() + ")");
	var debuggerState = objJSON.debuggerState;
    if ( debuggerState.status == 'completed' )
    {
        redirectToThisPage();
    }
    else
    {
       setTimeout('invalidateDebugSession()',1000);
    }
}

function redirectToThisPage()
{
    window.onbeforeunload  = null;
    window.location.href= '/app/common/scripting/scriptdebugger.nl';
}

/**
 * Process the response to an issued debugger command. The typical handling of this response will result in
 * an update to the debugger UI, the watch windows, and the locals window. If the debug command resulted in the
 * termination of the script's execution (i.e. go, continue with no break points, or an error) then the debugger
 * is hidden (for now) and the console is cleared..
 *
 * @param response  response object containing debugger status in a JSON response:
 *                      { debuggerStatus : { status, mode, breakpoints, watches, callstack, source, evaluation, properties, console } }
 * @param command   Debug command issued to server
 * @param optionalArg Optional argument used to configure command.
 */
function debugCommandCallback(response, command, optionalArg)
{
	if ( handleCallbackError( response, command ) ) return;

	var objJSON = eval("(" + response.getBody() + ")");
	var debuggerState = objJSON.debuggerState;
    debugSessionId = debuggerState.debugsessionid;

	if ( debuggerState.status == 'invalidDebugSession' )
    {
        redirectToThisPage();
    }

    if(command == 'go' ||  command.indexOf('step') == 0 )
    {
        isScriptInRunningMode = false;
        if(deplayedCancelRequest != null)
        {
            var cancelRequest = deplayedCancelRequest[0];
            cancelRequest.requestURL( '/app/common/scripting/scriptdebugger.nl', deplayedCancelRequest[1], null, true );
            deplayedCancelRequest = null;
            return;
        }
    }
	if ( debuggerState.status == "running" )
	{
		if ( command == 'eval' )
		{
			buildHistory( debuggerState )
			buildLocals( debuggerState )
			buildWatches( debuggerState )
		}
		else if ( command == 'loadproperties' )
			buildProperties( debuggerState, optionalArg.id, optionalArg.expression )
		else if ( command == 'adduserevent' )
			buildBreakPoints( debuggerState )
		else if ( command == 'breakpoint' )
		{
			buildSourceCode( debuggerState, command, optionalArg )
			buildBreakPoints( debuggerState )
		}
		else
		{
			buildSourceCode( debuggerState, command, optionalArg )
			buildLocals( debuggerState )
			buildWatches( debuggerState )
			buildBreakPoints( debuggerState )
            buildHistory( null )
		}
		buildLogConsoles( debuggerState );
		setDebuggerStatusBar( "Debugging&nbsp;"+debuggerState.source.title );
		disableDebuggerButtons( false )
	}
	else if ( debuggerState.status == 'idle'  && debuggerState.script != null )
		resumeDebugger( debuggerState.mode );
	else
	{
        if ( debuggerState.status == 'completed' )
        {
            buildLocals( null );
            buildWatches( null);
            buildHistory( null);
            buildBreakPoints(null);
        }
		buildLogConsoles( debuggerState );
		showDebugger( false, debuggerState.mode, debuggerState.status )
		if ( command == 'loadproperties' )
			document.getElementById( optionalArg.id + '_icon' ).src = document.getElementById( optionalArg.id + '_icon' ).getAttribute('expandImageSrc');
	}
}
/**
 * Set or unset break points in the script
 * @param line  line number containing the new (or old) break point
 */
function setBreakPoint( line, url )
{
    if(scriptIsRunning) return; //same effect as disable button for go/stepover/etc.

	var obj = new Object();
	obj.line = line;
	obj.url = url != null ? url : getFormValue( document.forms['main_form'].elements['url'] );
	debugCommand( 'breakpoint', obj )
}
/**
 * Add a watch expression to the watches window
 * @param expression
 */
function addWatch( expression )
{
    debugCommand( 'addwatch', expression );
}
/**
 * Evaluate an ad-hoc JavaScript expression in the current debugging context
 * @param expression
 */
function evalScript( expression )
{
    debugCommand( 'eval', expression )
}
/**
 * Display the caret position in the Editor status bar.
 * For IE, grab the current selection and move the end of the textarea's textrange to the end of this selection. This
 * allows us to compute the caret position. Use line breaks to then compute row and column number.
 * Special handling for an anomaly in IE where line breaks are ignored in textranges.
 * This results in the the end of a line being indistinguishable from the start of the next line. Use the caret offset position
 * to compute this edge case.
 *
 * For Firefox, use fld.selectionStart and fld.selectionEnd properties (how useful)
 *
 * @param fld  		textarea field used as the editor for entering ad-hoc scripts
 * @param display	If true the caret position should be displayed, otherwise invoke this function asynchronously (done this way to
 * 					optimize for user experience)
 */
function showCaretPosition(fld,display)
{
	if ( display )
	{
		var start = 0;
		var end = 0;
		var len = 0;
		var rownum = 0;
		var column = 0;
		if (document.selection)
		{
			var range = document.selection.createRange();
			var stored = range.duplicate();
			stored.moveToElementText(fld);
			stored.setEndPoint('EndToEnd', range);

			start = stored.text.length - range.text.length;
			end = start + range.text.length;
			len = fld.value.replace(/[\r]/g,'').length;
			rownum = fld.value.substring(0, start).split('\n').length;
			column = start - fld.value.substring(0, start).lastIndexOf('\n')

			var linenum = (((range.offsetTop+fld.scrollTop) - (findPosY(fld)+4))/range.boundingHeight)+1;
			if ( linenum > rownum ) { rownum = linenum; column = 1;	}
		}
		else
		{
			start = fld.selectionStart;
			end = fld.selectionEnd;
			len = fld.value.length;
			rownum = fld.value.substring(0, start).split('\n').length;
			column = start - fld.value.substring(0, start).lastIndexOf('\n')
		}
		var statusBar = document.getElementById('editorstatusbar');
		if ( statusBar.style.display == 'none' )
		{
			statusBar.style.top = findPosY(fld)+300
			statusBar.style.left = findPosX(fld)
			statusBar.style.display = 'block'
		}
		statusBar.firstChild.innerHTML = 'Line: '+rownum+'&nbsp;&nbsp;Column: '+column;
	}
	else
		setTimeout( function() { showCaretPosition(fld, true) }, 0 );
}
/**
 * onKeyPress event handlers for debugger
 *
 * 	Space bar: stepover
 * 	Shift + Space bar: continue
 * 	i: stepinto
 * 	o: stepout
 * 	q: cancel -or- show editor
 * 	d: debug script
 * 	a: debug existing (attach)
 * 	s: run script (server)
 * 	c: run script (client)
 * 	r: re-run script
 * 	Enter: add watch -or- eval expression
 *
 * @param evt	onkeypress event object
 */
function onKeyPressDebugger(evt)
{
	var key = getEventKeypress(evt)
	var target = getEventTarget(evt)
	var notInputTarget = target.tagName != 'INPUT';

	switch(key)
	{
		case 13: 
			if ( target.name == 'watchexpression' || target.name == 'evalexpression' )
			{
				eval( target.name == 'watchexpression' ? "addWatch(trim(target.value))" : "evalScript(trim(target.value))" )
				setEventCancelBubble(evt);
				setEventPreventDefault(evt);
			}
	        break;
		case 32:  
			if ( document.getElementById('stepover') != null && !document.getElementById('stepover').disabled && notInputTarget )
				document.getElementById( getEventShiftKey(evt) ? 'continue' : 'stepover' ).click()
			break;
		case 97: 
			if ( document.getElementById('attach') != null && !document.getElementById('attach').disabled && notInputTarget )
				document.getElementById('attach').click()
			break;
		case 99: 
			if ( document.getElementById('runclient') != null && !document.getElementById('runclient').disabled && notInputTarget )
				document.getElementById('runclient').click()
			break;
		case 100: 
			if ( document.getElementById('debug') != null && !document.getElementById('debug').disabled && notInputTarget )
				document.getElementById('debug').click()
			break;
		case 105: 
			if ( document.getElementById('stepinto') != null && !document.getElementById('stepinto').disabled && notInputTarget )
				document.getElementById('stepinto').click()
			break;
		case 111: 
			if ( document.getElementById('stepout') != null && !document.getElementById('stepout').disabled && notInputTarget )
				document.getElementById('stepout').click()
			break;
		case 113: 
			if ( document.getElementById('cancel') != null && !document.getElementById('cancel').disabled && notInputTarget )
				document.getElementById('cancel').click()
			else if ( notInputTarget && document.getElementById('showeditor') != null )
				document.getElementById('showeditor').click()
			break;
		case 114: 
			if ( document.getElementById('rerunscript') != null && notInputTarget )
				document.getElementById('rerunscript').click()
			break;
		case 115: 
			if ( document.getElementById('runserver') != null && !document.getElementById('runserver').disabled && notInputTarget )
				document.getElementById('runserver').click()
			break;
	}
}
document.onkeypress = function(event) { onKeyPressDebugger( event ); }
