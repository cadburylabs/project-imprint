/*
 * Copyright © 2026, Oracle and/or its affiliates.
 */

var transactions = transactions || {};
transactions.journalentry = transactions.journalentry || {};
transactions.journalentry.form = transactions.journalentry.form || {};

transactions.journalentry.form.record = (function ()
{
	var openPopupWindow = function (journalId, buttonId)
	{
		var sUrl = "/app/accounting/transactions/JournalEntryPopup.nl?noNextRedirect=T&id=" + encodeURIComponent(journalId);
		var summaries = NS.Translations.dictionary['NLFormlabelContext.SUMMARIES'];
		var dialog = NS.Translations.dictionary['NLFormlabelContext.AI_SUMMARY_PLEASE_WAIT_DIALOG'];
		var insight = NS.Translations.dictionary['NLFormlabelContext.INSIGHT'];
		var newwindow = window.open('', insight, 'width=800,height=600');
		if (newwindow) {
			newwindow.document.open();
			newwindow.document.write(`<!DOCTYPE html>
<html>
<head>
    <title>${summaries}</title>
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
    <div class="text">${dialog}</div>
</body>
</html>
`);
			newwindow.document.close();
			newwindow.location.href = sUrl;
		}
		if (newwindow && newwindow.focus) {
			newwindow.focus();
		}

		setButtonDisabled(buttonId, true);

		var pollTimer = setInterval(function () {
			if (newwindow.closed) {
				clearInterval(pollTimer);
				setButtonDisabled(buttonId, false);
			}
		}, 500);

		return false;
	};

	return {
		openPopupWindow: openPopupWindow
	}
})();
