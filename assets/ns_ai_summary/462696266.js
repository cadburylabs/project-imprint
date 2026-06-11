var nsai=nsai||{};nsai.summaryframework=function(){return{openRecordPopupWindow:function(b,c,d){b="/app/summaryframework/web/recordsummarypopup.nl?id="+encodeURIComponent(b)+"&type="+encodeURIComponent(c)+"&noNextRedirect=T";c=NS.Translations.dictionary["NLFormlabelContext.SUMMARIES"];var e=NS.Translations.dictionary["NLFormlabelContext.AI_SUMMARY_PLEASE_WAIT_DIALOG"],a=window.open("",NS.Translations.dictionary["NLFormlabelContext.INSIGHT"],"width=800,height=600");a&&(a.document.open(),a.document.write(`<!DOCTYPE html>
<html>
<head>
    <title>${c}</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        body {
            font-family: 'Oracle Sans', 'Helvetica Neue', sans-serif;
            font-size: 14px;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            height: 100vh;
            margin: 0;
            background-color: #fff;
        }
        .loader {
            border: 8px solid #f3f3f3;
            border-top: 8px solid #000;
            border-radius: 50%;
            width: 60px;
            height: 60px;
            animation: spin 2s linear infinite;
            will-change: transform;
            /* Safari: */
            -webkit-animation: spin 2s linear infinite;
            transform: translateZ(0);
        }
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
        /* Safari */
        @-webkit-keyframes spin {
            0% { -webkit-transform: rotate(0deg); transform: rotate(0deg); }
            100% { -webkit-transform: rotate(360deg); transform: rotate(360deg); }
        }
        .text {
            font-size: 18px;
            color: #000000;
            padding: 25px;
        }
    </style>
</head>
<body>
    <div class="loader"></div>
    <div class="text">${e}</div>
</body>
</html>
`),a.document.close(),a.location.href=b);a&&a.focus&&a.focus();setButtonDisabled(d,!0);var f=setInterval(function(){a.closed&&(clearInterval(f),setButtonDisabled(d,!1))},500);return!1}}}();
//# sourceMappingURL=/assets/ns_ai_summary/462696266.map