






DEFAULT_CONTEXT_KEY = 0;

ID_FIELD = "id";

ROW_STATE_TEMP = -1;
ROW_STATE_NONE = 0;
ROW_STATE_NEW = 1;
ROW_STATE_MODIFIED = 2;
ROW_STATE_DELETE = 3;

ROW_STATE_NAMES = ["VIEW", "CREATE", "EDIT", "DELETE"];

SEGMENT_ID_DELETED_ROWS = -1;

var uniqueCounter=0;
var rmId=0;

var bIsBackendRequest = false;

function NLShowChildRecordPopup(containingRecordManagerName, targetRecordManagerName, bReadOnly, url, triggerObject, linenum, options, ignoreParamsIfValueMatch)
{
    if (!options) options = {};
    var listeners = {};
    var canShowChildRecordFuncName =  containingRecordManagerName + "_" +  targetRecordManagerName + "canShowChildRecord";
    if (window[canShowChildRecordFuncName] && !window[canShowChildRecordFuncName](linenum))
        return;

    if (NLGetBusinessObject && NLGetBusinessObject())
    {
        url = NLModifyChildRecordURL(containingRecordManagerName, targetRecordManagerName, bReadOnly, url, linenum, options, ignoreParamsIfValueMatch);
        listeners['beforeclose'] = function(){
            eval("NLGetBusinessObject().endChildTransaction()");
            if (options.onclose && typeof options.onclose == 'function') {
                options.onclose();
            }
        };
    }

    var containingRecordManager =  NLGetBusinessObject().getRecordManager(containingRecordManagerName);

    var currentSubrecord;
    var currentCacheKey;
    try
    {
        for(var key in window.subrecordcache)
        {
            if ( (linenum == -1 || containingRecordManager.getActiveRow() == (linenum-1)) && window.subrecordcache.hasOwnProperty(key) && window.subrecordcache[key] && window.subrecordcache[key].recordmanagername == targetRecordManagerName && window.subrecordcache[key].isOnServer )
            {
                currentCacheKey = key;
                currentSubrecord = window.subrecordcache[key];
                currentSubrecord.commit();
            }
        }
    }
    catch(error)
    {
        currentSubrecord.recordmanager.cancelChildTransaction();
        window.subrecordcache[currentCacheKey] = null;
    }

    if ( currentSubrecord && currentSubrecord.isOnServer && currentSubrecord.subrecordinstance!='' )
    {
        url += ('&subrecordKey=' + currentSubrecord.subrecordinstance);
    }

    

    var width = options['width'] || 550;
    var height = options['height'] || 350;
    nlExtOpenWindow(url,"childdrecord",width, height,triggerObject, true,'', listeners);
}

function NLModifyChildRecordURL(containingRecordManagerName, targetRecordManagerName, bReadOnly, url, linenum, options, ignoreParamsIfValueMatch)
{
    if (!options) options = {};
    var containingRecordManager =  NLGetBusinessObject().getRecordManager(containingRecordManagerName);
    if (containingRecordManager)
    {
        if (linenum > 0)
            containingRecordManager.setActiveRow(linenum -1);
    }
    var targetRecordManager = NLGetBusinessObject().getRecordManager(targetRecordManagerName);
    var params = new Object();
    if (targetRecordManager)
        params = targetRecordManager.getContextParams();
    else
    {
        if (containingRecordManager)
            params = containingRecordManager.getContextParamsForChild(targetRecordManagerName);
    }

    if (!(targetRecordManager && targetRecordManager.isReadOnly()) && !bReadOnly && !isValEmpty(params['id']) && params['id']>0)
        params['e'] = 'T';

    var extra_params = options.extra_params || {};
    for (var key in extra_params) {
        if (params[key] === undefined) {
            params[key] = extra_params[key];
        }
    }

    params['popup']='T';
    params['userm']='T';
    
    params['hasrm']='T';
    
    params['rmloaddata']= targetRecordManager ? (targetRecordManager.isDataSetLoaded(undefined, true) ? "F" : "T") : "T" ;

    if (ignoreParamsIfValueMatch!=null)
    {
        for (var ignoreParamKey in ignoreParamsIfValueMatch)
        {
            if (params[ignoreParamKey] == ignoreParamsIfValueMatch[ignoreParamKey])
                params[ignoreParamKey] = '';
        }
    }
    return addNextParamPrefixToURL(url) + formEncodeURLParams(params);
}