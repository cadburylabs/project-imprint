/** [BEGIN] AMD Compatibility Prefix (Inserted By NetSuite) **/
var nlapi = nlapi || {};
nlapi.defineExists = typeof define !== 'undefined';
try {
if (!nlapi.defineExists) define = _N_define;
/** [END] AMD Compatibility Prefix (Inserted By NetSuite) **/

/**
 * Copyright (c) 2021, Oracle and/or its affiliates. All rights reserved.
 * otherwise make available this code.
 *
 * @author syadav
 * @NScriptType ClientScript
 * @NApiVersion 2.1
 * @NModuleScope Public
 */

define(['../../lib/9997_CommonLib',
        '../../lib/wrapper/9997_NsWrapperFormat',
        '../../lib/wrapper/9997_NsWrapperDialog',
        '../../lib/wrapper/9997_NsWrapperSearch',
        '../../lib/wrapper/15817_NsWrapperTranslation',
        '../../lib/wrapper/9997_NsWrapperUrl',
        '../../lib/wrapper/9997_NsWrapperRecord',
        '../../lib/wrapper/9997_NsWrapperRuntime',
        '../../app/paymentselection/processor/15767_PaymentSelection_Validator',
        '../../lib/8859_Constants',
        '../../lib/wrapper/9997_NsWrapperHTTPS',
        'N/search',
        'N/record',
        '../../lib/8859_SearchUtil',
        'N/email'
    ],

    function(commonLib, format, dialog, search, translator, url, record, runtime, paymentValidator, constants, https,nssearch, nsRecord,searchUtil,email) {
        var myRecord, paymentType, isGlobalPayment;
        var isBatchPayment = false;
        // Constants
        var SUBLIST_ID = 'custpage_2663_sublist';
        var EXCHANGERATE_SUBLIST_ID = 'custpage_exchange_rate';
        var MARK_COL = 'custpage_pay';
        var MARK_KEY = 'custpage_mark_key';
        var MARK_PROPERTY = 'custpage_linemarkdata';
        var MARK_ENTITY_PROPERTY = 'custpage_line_entitydata';

        var AGG_FIELD_ID = 'custpage_2663_aggregate';
        var AGG_METHOD_FIELD_ID = 'custpage_2663_agg_method';
        var GE_AGG_FIELD_ID = 'custpage_15529_aggregate';
        var GE_AGG_METHOD_FIELD_ID = 'custpage_15529_agg_method';

        var EFT_PAYMENT_TYPE_CODE = 'eft'
        var DD_PAYMENT_TYPE_CODE = 'dd'
        var CR_PAYMENT_TYPE_CODE = 'custref'

        //Approval Type
        var APPROVALTYPE_BILLPAYMENT = '1';
        var APPROVALTYPE_VENDORPAYMENT = '2';
        var APPROVALTYPE_BATCHPAYMENT = '3';

        var INIT_VALUES = {};
        var MESSAGEMAP_ALERT = [];

        var PFA_RECORD_TYPE = 'customrecord_2663_file_admin';

        //to allow us to distinguish if on submit we are either:
        //processing the transaction ( trigger is the submit button) or
        //reloading the page to show a new page ( trigger is the select page drop down )
        var TRIGGER = {
            submit   : 'submit',
            paginate : 'paginate',
            refresh  : 'refresh'
        };

        var IS_DEPARTMENT = false;
        var IS_CLASS = false;
        var IS_LOCATION = false;

        /**
         * Function to be executed after page is initialized.
         *
         * @param {Object} scriptContext
         *
         */
        function pageInit(scriptContext) {
            var currRecord = scriptContext.currentRecord;
            myRecord = currRecord;

            //Add Translations for the Alerts and Messages
            var trans_messages = currRecord.getValue({fieldId: 'custpage_translation_messages'});
            MESSAGEMAP_ALERT = typeof trans_messages === 'string' ? JSON.parse(trans_messages) : {};

            //Customize the Submit button
            var isSeinField = commonLib.getVersion() === '2014.1';
            // set the custom submit button classes
            var buttonClass = isSeinField ? 'pgBntY' : 'pgBntG pgBntB';
            if (document.getElementById("tr_custpage_submitter")){
                document.getElementById("tr_custpage_submitter").className = buttonClass;
            }

            if (document.getElementById("tr_secondarycustpage_submitter")) {
                document.getElementById("tr_secondarycustpage_submitter").className = buttonClass;
            }
            
            //Get DCL feature values
            IS_DEPARTMENT = commonLib.isDepartment();
            IS_CLASS = commonLib.isClass();
            IS_LOCATION = commonLib.isLocation();
            
            paymentType = currRecord.getValue({ fieldId : 'custpage_2663_paymenttype'});
            isGlobalPayment = currRecord.getValue({ fieldId : 'custpage_15529_global_payment'});
            isBatchPayment = currRecord.getValue({ fieldId : 'custpage_2663_batch'}) || false;
            if(paymentType === DD_PAYMENT_TYPE_CODE){
                setProcessDateAndPostingPeriod(currRecord);
                //toggleAggregateMethodField(currRecord, AGG_FIELD_ID, AGG_METHOD_FIELD_ID);
                recalcLines_DD(currRecord);
            }
            else if(paymentType === 'pp'){
                recalcLines_PP(currRecord);
            }
            else if(paymentType === CR_PAYMENT_TYPE_CODE){
                setProcessDate(currRecord);
            }
            else if (paymentType !== 'custref') {
                var custPaymentType = currRecord.getValue({ fieldId : 'custpage_2663_custbody_payment_type'});
                if (custPaymentType) {
                    INIT_VALUES['custpage_2663_custbody_payment_type'] = custPaymentType;
                }
                setProcessDateAndPostingPeriod(currRecord);
            }

            if(paymentType !== 'pp') {

                //Set hidden custpage_2663_process_date_millis
                setProcessDateMillis(currRecord);
                //Update Display Type of Aggregate Method Field only for EFT and DD
                if([EFT_PAYMENT_TYPE_CODE, DD_PAYMENT_TYPE_CODE].indexOf(paymentType) > -1){
                    if(!isGlobalPayment){
                        toggleAggregateMethodField(currRecord, AGG_FIELD_ID, AGG_METHOD_FIELD_ID);
                    }else{
                        toggleAggregateMethodField(currRecord, GE_AGG_FIELD_ID, GE_AGG_METHOD_FIELD_ID);
                    }
                }


                var selectedCompanyBank = currRecord.getValue({fieldId: 'custpage_2663_bank_account'});

                if (selectedCompanyBank && (selectedCompanyBank !== '{}')) {
                    if((paymentType !== DD_PAYMENT_TYPE_CODE) && (!isBatchPayment || currRecord.getValue({fieldId : 'custpage_2663_summarized_placeholder'}) !='T')){
                        recalcLines_EFT(currRecord);
                    }
                }
            }
        }

        /*
        Save Record is not required rather we are using ep_Submit() to also utilize proper Permissions check.
        Can be removed later once the functionality is verified.

                /!**
                 * Preforms validations and submits to Suitelet for further processing
                 * @param scriptContext
                 * @param trigger
                 * @returns {boolean}
                 *!/
                function saveRecord(scriptContext, trigger) {
                    var MSGMAP = translator.getTranslation(translator.PAGE.PAYMENT_SELECTION_CS);
                    var msgs = MSGMAP.getComponentTranslation(MSGMAP.names.ui, MSGMAP);
                    var returnVal = true;
                    var currRec = scriptContext.currentRecord;

                    paymentType = currRec.getValue({ fieldId : 'custpage_2663_paymenttype'});
                    var noSelectedTrans = (currRec.getValue({fieldId: 'custpage_2663_total_amount'})) <= 0;
                    if (paymentType === 'custref') {
                        if (noSelectedTrans) {
                            showAlert(msgs.notran);
                            return false;
                        }
                    }
                    else if (paymentType === 'pp') {
                        noSelectedTrans = noSelectedTrans && (currRec.getValue({ fieldId : 'custpage_2663_void_total_amount'}) <= 0);
                        if (noSelectedTrans) {
                            showAlert(msgs.nocheques);
                            return false;
                        }
                        setChequeNumbers(currRec, msgs);
                    }
                    setSubmitTrigger(currRec, TRIGGER.submit);
                    return returnVal;
                }
        */

        /**
         * Function to be executed when field is changed.
         *
         * @param {Object} scriptContext
         * @param {Record} scriptContext.currentRecord - Current form record
         * @param {string} scriptContext.sublistId - Sublist name
         * @param {string} scriptContext.fieldId - Field name
         * @param {number} scriptContext.lineNum - Line number. Will be undefined if not a sublist or matrix field
         * @param {number} scriptContext.columnNum - Line number. Will be undefined if not a matrix field
         *
         * @since 2015.2
         */
        function fieldChanged(scriptContext) {
            var currRec = scriptContext.currentRecord;
            var line = scriptContext.line;
            var fieldChangedID = scriptContext.fieldId;

            switch(fieldChangedID) {
                case AGG_FIELD_ID:
                    toggleAggregateMethodField(currRec, AGG_FIELD_ID, AGG_METHOD_FIELD_ID);
                    break;

                case GE_AGG_FIELD_ID:
                    toggleAggregateMethodField(currRec, GE_AGG_FIELD_ID, GE_AGG_METHOD_FIELD_ID);
                    break;

                case 'custpage_2663_process_date':
                    if (paymentType !== 'custref') {
                        //Set Accounting Period
                        setPostingPeriodFromProcessDate(currRec);
                        //Set hidden custpage_2663_process_date_millis
                        setProcessDateMillis(currRec);
                        if(paymentType === DD_PAYMENT_TYPE_CODE || paymentType === EFT_PAYMENT_TYPE_CODE){
                            refreshPage(currRec);
                        }
                    }
                    break;

                case 'custpage_2663_bank_account':
                    if (paymentType === 'pp') {
                        currRec.setValue({fieldId : 'custpage_2663_first_check_no', value : '', ignoreFieldChange: false});
                        currRec.setValue({fieldId : 'custpage_2663_last_check_no', value : '', ignoreFieldChange: false});
                    } else if (paymentType === 'dd') {
                        var bankAcc = currRec.getValue({fieldId : 'custpage_2663_bank_account'});
                        var isValidSepaTemplate = isValidSepaDDTemplate(bankAcc);
                        if(!isValidSepaTemplate && bankAcc) {
                            currRec.setValue({fieldId : 'custpage_2663_bank_account', value : '', ignoreFieldChange: true});
                        }

                        clearFilters(currRec);
                    } else {
                        clearFilters(currRec);
                    }
                    clearLines(currRec);
                    refreshPage(currRec);
                    break;

                case 'custpage_2663_ar_account':
                    var bankAccount = currRec.getValue({fieldId : 'custpage_2663_bank_account'});
                    var isValidSepaTemp = isValidSepaDDTemplate(bankAccount);
                    if(!isValidSepaTemp && bankAccount) {
                        currRec.setValue({fieldId : 'custpage_2663_bank_account', value : '', ignoreFieldChange: true});
                    }
                    clearLines(currRec);
                    refreshPage(currRec);
                    break;
                case 'custpage_2663_ap_account':
                case 'custpage_2663_batchid':
                    clearLines(currRec);
                    refreshPage(currRec);
                    break;
                case 'custpage_2663_first_check_no':
                case 'custpage_2663_last_check_no':
                case 'custpage_2663_date_from':
                case 'custpage_2663_date_to':
                    setDateFromField(currRec, fieldChangedID);
                    if(((paymentType === 'pp' || paymentType ==='custref') && currRec.getValue({fieldId : 'custpage_2663_bank_account'})) ||
                        (paymentType === 'eft' && currRec.getValue({fieldId : 'custpage_2663_bank_account'}) && currRec.getValue({fieldId : 'custpage_2663_ap_account'})) ||
                        (paymentType === 'dd' && currRec.getValue({fieldId : 'custpage_2663_bank_account'}) && currRec.getValue({fieldId : 'custpage_2663_ar_account'}))){
                        clearLines(currRec);
                        refreshPage(currRec);
                    }
                    break;
                case 'custpage_2663_bank_tranamt_from':
                case 'custpage_2663_bank_tranamt_to':
                    if(((paymentType === 'pp' || paymentType ==='custref') && currRec.getValue({fieldId : 'custpage_2663_bank_account'})) ||
                        (paymentType === 'eft' && currRec.getValue({fieldId : 'custpage_2663_bank_account'}) && currRec.getValue({fieldId : 'custpage_2663_ap_account'})) ||
                        (paymentType === 'dd' && currRec.getValue({fieldId : 'custpage_2663_bank_account'}) && currRec.getValue({fieldId : 'custpage_2663_ar_account'}))){

                        var fieldToSet = (fieldChangedID === 'custpage_2663_bank_tranamt_from') ? 'custpage_2663_bank_tranamt_from' : 'custpage_2663_bank_tranamt_to';
                        var currFilterValue = currRec.getValue({ fieldId : fieldToSet});
                        if(currFilterValue<0){
                            showAlert(MESSAGEMAP_ALERT['alertnegativeamount'])
                            currRec.setValue({fieldId : fieldToSet, value : 0});
                        }
                    setTranAmtFromField(currRec, fieldChangedID);
                    clearLines(currRec);
                    refreshPage(currRec);
                }
                    break;
                //768364 - credit without due date filters
                case 'custpage_2663_credit_due_date' :
                    toggleHiddenCheckBoxField(currRec, fieldChangedID);
                    clearLines(currRec);
                    refreshPage(currRec);
                    break; //END
                case 'custpage_2663_customer':
                case 'custpage_2663_vendor':
                case 'custpage_2663_employee':
                case 'custpage_2663_partner':
                case 'custpage_2663_onhold':
                case 'custpage_2663_transtype':
                case 'custpage_2663_dept_filter':
                case 'custpage_2663_class_filter':
                case 'custpage_2663_loc_filter':
                    if(currRec.getValue({fieldId : 'custpage_2663_bank_account'}) || (paymentType !== 'custref' && currRec.getValue({fieldId : 'custpage_2663_bank_account'}) && currRec.getValue({fieldId : 'custpage_2663_ap_account'})) || (paymentType === DD_PAYMENT_TYPE_CODE && currRec.getValue({fieldId : 'custpage_2663_bank_account'}) && currRec.getValue({fieldId : 'custpage_2663_ar_account'}))) {
                        //Toggle required hidden checkbox field
                        if(fieldChangedID === 'custpage_2663_onhold'){
                            toggleHiddenCheckBoxField(currRec, fieldChangedID);
                        }
                        clearLines(currRec);
                        refreshPage(currRec);
                    }
                    break;
                case 'custpage_2663_void':
                    currRec.setValue({fieldId : 'custpage_2663_first_check_no', value : '', ignoreFieldChange: false});
                    currRec.setValue({fieldId : 'custpage_2663_last_check_no', value : '', ignoreFieldChange: false});
                    currRec.setValue({fieldId : 'custpage_2663_void_hdn', value : currRec.getValue({ fieldId : 'custpage_2663_void'}), ignoreFieldChange: true});
                    var cBankAccountID = currRec.getValue({fieldId : 'custpage_2663_bank_account'});
                    if(cBankAccountID && (cBankAccountID !== '{}')){
                        clearLines(currRec);
                        refreshPage(currRec);
                    }
                    break;

                case 'custpage_2663_exclude_cleared':
                    currRec.setValue({fieldId : 'custpage_2663_first_check_no', value : '', ignoreFieldChange: false});
                    currRec.setValue({fieldId : 'custpage_2663_last_check_no', value : '', ignoreFieldChange: false});
                    currRec.setValue({fieldId : 'custpage_2663_exclude_cleared_hdn', value : currRec.getValue({ fieldId : 'custpage_2663_exclude_cleared'}), ignoreFieldChange: true});
                    var bankAccountID = currRec.getValue({fieldId : 'custpage_2663_bank_account'});
                    if(bankAccountID && (bankAccountID !== '{}')){
                        clearLines(currRec);
                        refreshPage(currRec);
                    }
                    break;
                case 'custpage_currency_exchange':
                    // set value to 1 if less than or equal to 0
                    if(currRec.getSublistValue({
                        sublistId: 'custpage_exchange_rate',
                        fieldId: 'custpage_currency_exchange',
                        line: line
                    }) <= 0){
                        setExchangeRateSublistVal(currRec, 'custpage_currency_exchange', 1, line);
                    }

                    // set the exchange rate
                    if (currRec.getValue({ fieldId : 'custpage_2663_exchange_rates'})) {
                        var exchangeRateObj = JSON.parse(currRec.getValue({ fieldId : 'custpage_2663_exchange_rates'}));
                        exchangeRateObj[currRec.getSublistValue({
                            sublistId: 'custpage_exchange_rate',
                            fieldId: 'custpage_currency_id',
                            line: line
                        })] = currRec.getSublistValue({
                            sublistId: 'custpage_exchange_rate',
                            fieldId: 'custpage_currency_exchange',
                            line: line
                        });
                        currRec.setValue({fieldId : 'custpage_2663_exchange_rates', value: JSON.stringify(exchangeRateObj), ignoreFieldChange: true});
                    }
                    break;

                case 'custpage_pay':
                case 'custpage_linemarkdata':
                case 'custpage_line_entitydata':
                case 'custpage_payment':
                case 'custpage_discamount':
                case 'custpage_2663_sublist_page':
                    _sublistFieldChanged(currRec, fieldChangedID, line, true);
                    break;
                case 'custpage_2663_sublist_max':
                    var transPerPage = currRec.getValue({fieldId: 'custpage_2663_sublist_max'});
                    currRec.setValue({fieldId: 'custpage_2663_transperpage', value : transPerPage, ignoreFieldChange: true});
                    _sublistFieldChanged(currRec, fieldChangedID, line, true);
                    break;
                case 'custpage_2663_summarized':
                    currRec.setValue({fieldId: 'custpage_2663_summarized_placeholder', value : currRec.getValue({fieldId: 'custpage_2663_summarized'}) ? 'T' : 'F', ignoreFieldChange: true});
                    currRec.setValue({fieldId: 'custpage_2663_format_currency', value : '', ignoreFieldChange: true});
                    currRec.setValue({fieldId: 'custpage_2663_exchange_rates', value : '', ignoreFieldChange: true});
                    clearLines(currRec);
                    refreshPage(currRec);
                    break;
                default:
                    if (paymentType !== 'custref' || paymentType !== 'pp' || paymentType !== DD_PAYMENT_TYPE_CODE) {
                        if(isGrouponField(currRec,scriptContext.fieldId)){
                            if(currRec.getValue({fieldId : 'custpage_2663_bank_account'}) && currRec.getValue({fieldId : 'custpage_2663_ap_account'})){
                                if (scriptContext.fieldId != 'custpage_2663_custbody_payment_type' || currRec.getValue({fieldId : 'custpage_2663_custbody_payment_type'}) != INIT_VALUES[scriptContext.fieldId]) {
                                    if(fieldChangedID === 'custpage_2663_custbody_hold_payment_bill'){
                                        toggleHiddenCheckBoxField(currRec, fieldChangedID);
                                    }
                                    clearLines(currRec);
                                    refreshPage(currRec);
                                }
                            }
                        }
                    }
                    if(isCustomField(currRec,scriptContext.fieldId)){
                        if(currRec.getValue({fieldId : 'custpage_2663_bank_account'}) ){ //(currRec.getValue({fieldId : 'custpage_2663_ap_account'}) || currRec.getValue({fieldId : 'custpage_2663_ar_account'} Removing this check to support for custom CR
                            var fieldObj = currRec.getField(fieldChangedID)
                            var fieldType = fieldObj.type;
                            if(fieldType === 'checkbox'){
                                toggleHiddenCheckBoxField(currRec, fieldChangedID);
                            }
                            clearLines(currRec);
                            refreshPage(currRec);
                        }
                    }
            }

        }

        /**
         * Sets the check numbers if they are not equal to the min and max check numbers in list
         */

        function setChequeNumbers(currRec, MSGMAP) {
            var firstCheckNo = currRec.getValue({ fieldId : 'custpage_2663_first_check_no'});
            var lastCheckNo = currRec.getValue({ fieldId : 'custpage_2663_last_check_no'});
            var firstCheckNoHidden = currRec.getValue({ fieldId : 'custpage_2663_fcn_hidden'});
            var lastCheckNoHidden = currRec.getValue({ fieldId : 'custpage_2663_lcn_hidden'});

            if (firstCheckNo && firstCheckNoHidden) {
                if (parseInt(firstCheckNo, 10) !== parseInt(firstCheckNoHidden, 10)) {
                    showAlert(MSGMAP.smallchequenum);
                    currRec.setValue({fieldId : 'custpage_2663_first_check_no', value: firstCheckNoHidden});
                }
            }

            if (lastCheckNo && lastCheckNoHidden) {
                if (parseInt(lastCheckNo, 10) !== parseInt(lastCheckNoHidden, 10)) {
                    showAlert(MSGMAP.highchequenum);
                    currRec.setValue({fieldId : 'custpage_2663_last_check_no', value: lastCheckNoHidden});
                }
            }
        }


        /**
         * Depending of the selection of Aggregation Field, enable/disable the aggregation Method list dropdown
         * @param currRec
         * @param aggregateFieldId
         * @param aggMethodFieldId
         */
        function toggleAggregateMethodField(currRec, aggregateFieldId, aggMethodFieldId) {
            var isAggMethodDisabled = !currRec.getValue({ fieldId : aggregateFieldId});
            if (isAggMethodDisabled) {
                currRec.setValue({fieldId : aggMethodFieldId, value : '', ignoreFieldChange: false});
            }
            currRec.getField({fieldId : aggMethodFieldId}).isDisabled = isAggMethodDisabled;
            currRec.setValue({fieldId : aggregateFieldId+'_hdn', value : currRec.getValue({ fieldId : aggregateFieldId}), ignoreFieldChange: true});
        }

        /**
         * Used to set the hidden checkbox field for a visible.
         * @param currRec
         * @param fieldId
         */
        function toggleHiddenCheckBoxField(currRec, fieldId){
            currRec.setValue({fieldId : fieldId+'_hdn', value : currRec.getValue({ fieldId : fieldId}), ignoreFieldChange: true});
        }

        /**
         * Function to clear the EFT Filters from current Record set each fields values to empty string.
         * @param currRec
         */
        function clearFilters(currRec) {

            if(paymentType === 'dd'){
                clearFilters_DD(currRec);
            }
            else if (paymentType === 'custref') {
                clearFilters_CR(currRec);
            } else {
                // Un-set Account
                currRec.setValue({ fieldId : 'custpage_2663_ap_account', value : '', ignoreFieldChange: true});

                if(!isBatchPayment){
                    // unset entity filters and bank account related fields
                    currRec.setValue({ fieldId : 'custpage_2663_vendor', value : '', ignoreFieldChange: true});
                    currRec.setValue({ fieldId : 'custpage_2663_employee', value : '', ignoreFieldChange: true});
                    currRec.setValue({ fieldId : 'custpage_2663_partner', value : '', ignoreFieldChange: true});
                }

                // set default transactions to blank when bank is changed
                currRec.setValue({ fieldId : 'custpage_2663_trans_marked', value : '', ignoreFieldChange: true});

                if(isBatchPayment){
                    currRec.setValue({ fieldId : 'custpage_2663_batchid', value : '', ignoreFieldChange: true});
                    currRec.setValue({ fieldId : 'custpage_2663_summarized_placeholder', value : '', ignoreFieldChange: true});
                }

                // set dcl
                if (IS_DEPARTMENT) {
                    currRec.setValue({ fieldId : 'custpage_2663_department', value : '', ignoreFieldChange: true});
                }

                if (IS_CLASS) {
                    currRec.setValue({ fieldId : 'custpage_2663_classification', value : '', ignoreFieldChange: true});
                }

                if (IS_LOCATION) {
                    currRec.setValue({ fieldId : 'custpage_2663_location', value : '', ignoreFieldChange: true});
                }

                currRec.setValue({ fieldId : 'custpage_2663_format_currency', value : '', ignoreFieldChange: true});
                currRec.setValue({ fieldId : 'custpage_2663_exchange_rates', value : '', ignoreFieldChange: true});
            }
        }

        function clearFilters_CR(currRec) {
            // Un-set customer
            currRec.setValue({ fieldId : 'custpage_2663_customer', value : '', ignoreFieldChange: true});
            // set default transactions to blank when bank is changed
            currRec.setValue({ fieldId : 'custpage_2663_trans_marked', value : '', ignoreFieldChange: true});

            currRec.setValue({ fieldId : 'custpage_2663_format_currency', value : '', ignoreFieldChange: true});
            currRec.setValue({ fieldId : 'custpage_2663_exchange_rates', value : '', ignoreFieldChange: true});


        }

        function clearFilters_DD(currRec) {
            // unset account
            currRec.setValue({ fieldId : 'custpage_2663_ar_account', value : '', ignoreFieldChange: true});
            // unset entity filters
            currRec.setValue({ fieldId : 'custpage_2663_customer', value : '', ignoreFieldChange: true});
            // set default transactions to blank when bank is changed
            currRec.setValue({ fieldId : 'custpage_2663_trans_marked', value : '', ignoreFieldChange: true});

            // unset dcl
            if (IS_DEPARTMENT) {
                currRec.setValue({ fieldId : 'custpage_2663_dept_filter', value : '', ignoreFieldChange: true});
                currRec.setValue({ fieldId : 'custpage_2663_department', value : '', ignoreFieldChange: true});
            }

            if (IS_CLASS) {
                currRec.setValue({ fieldId : 'custpage_2663_class_filter', value : '', ignoreFieldChange: true});
                currRec.setValue({ fieldId : 'custpage_2663_classification', value : '', ignoreFieldChange: true});
            }

            if (IS_LOCATION) {
                currRec.setValue({ fieldId : 'custpage_2663_loc_filter', value : '', ignoreFieldChange: true});
                currRec.setValue({ fieldId : 'custpage_2663_location', value : '', ignoreFieldChange: true});
            }

            currRec.setValue({ fieldId : 'custpage_2663_format_currency', value : '', ignoreFieldChange: true});
            currRec.setValue({ fieldId : 'custpage_2663_exchange_rates', value : '', ignoreFieldChange: true});
        }

        /**
         * Function to clear transaction specific fields.
         * @param currRec
         */
        function clearLines(currRec) {

            var numPages = Number(currRec.getValue({fieldId : 'custpage_2663_sublist_numpages'}));

            for (var i = 0; i < numPages; i++) {

                var param = 'custpage_2663_sublist_markdata' + i;
                currRec.setValue({fieldId : param, value: JSON.stringify({}), ignoreFieldChange: true});
            }

            if (paymentType !== 'pp') {
                // set mark all as blank
                currRec.setValue({fieldId: 'custpage_2663_sublist_mark_all', value: '', ignoreFieldChange: true});
            }

            // set totals to 0
            currRec.setValue({ fieldId : 'custpage_2663_payment_lines', value : '', ignoreFieldChange: true});
            currRec.setValue({ fieldId : 'custpage_2663_total_amount', value : '', ignoreFieldChange: true});
            if (paymentType !== 'custref') {
                currRec.setValue({ fieldId : 'custpage_2663_void_payment_lines', value : '', ignoreFieldChange: true});
                currRec.setValue({ fieldId : 'custpage_2663_void_total_amount', value : '', ignoreFieldChange: true});
                if (paymentType !== 'pp') {
                    currRec.setValue({fieldId: 'custpage_2663_total_payees', value: '', ignoreFieldChange: true});
                }
            }

            //reset the current selected page
            currRec.setValue({ fieldId : 'custpage_2663_sublist_currpage', value : '', ignoreFieldChange: true});
        }


        /**
         * Returns true if the field is for Groupon
         * @param name
         * @returns {boolean}
         */
        function isGrouponField(currRec,name) {
            var grouponFieldVal = false;
            if (name) {
                // check if there are additional filters for Groupon
                var addlEntityFieldsStr = currRec.getValue({fieldId : 'custpage_2663_af_flds_entityfilters'});
                var grouponFields = [];
                if (addlEntityFieldsStr) {
                    var addlEntityFields = JSON.parse(addlEntityFieldsStr);
                    grouponFields = grouponFields.concat(addlEntityFields);
                }

                var addlTransactionFieldsStr = currRec.getValue({fieldId : 'custpage_2663_af_flds_transfilters'});

                if (addlTransactionFieldsStr) {
                    var addlTransactionFields = JSON.parse(addlTransactionFieldsStr);
                    grouponFields = grouponFields.concat(addlTransactionFields);
                }

                // check if the field name is a groupon field
                for (var i = 0; i < grouponFields.length; i++) {
                    if (grouponFields[i] == name) {
                        grouponFieldVal = true;
                        break;
                    }
                }
            }

            return grouponFieldVal;
        }

        /**
         * Returns true if the field is customized
         * @param name
         * @returns {boolean}
         */
        function isCustomField(currRec, name) {
            var customFieldVal = false;

            if (name) {
                // check if there are additional custom filters
                var addlEntityFieldsStr = currRec.getValue({ fieldId : 'custpage_2663_custom_flds_transfilters'});
                var customFields = [];

                if (addlEntityFieldsStr) {
                    var addlEntityFields = JSON.parse(addlEntityFieldsStr);
                    customFields = customFields.concat(addlEntityFields);
                }

                // check if the field name is a custom field
                for (var i = 0; i < customFields.length; i++) {
                    if (customFields[i] == name) {
                        customFieldVal = true;
                        break;
                    }
                }
            }

            return customFieldVal;
        }

        /**
         * Sets sublist's fields value
         * @param {[type]} currRec [description]
         * @param {[type]} field   [description]
         * @param {[type]} value   [description]
         * @param {[type]} line    [description]
         */
        function setSublistVal(currRec, field, value, line, ignoreFieldChangeTrigger){

            currRec.selectLine({
                sublistId:SUBLIST_ID,
                line:line
            });

            currRec.setCurrentSublistValue({
                sublistId:SUBLIST_ID,
                fieldId: field,
                value: value,
                ignoreFieldChange : true //temporarily ignore all
            });

            currRec.commitLine({sublistId:SUBLIST_ID});
        }

        /**
         * Sets ExchangeRate sublist's fields value
         * @param currRec
         * @param field
         * @param value
         * @param line
         * @param ignoreFieldChangeTrigger
         */
        function setExchangeRateSublistVal(currRec, field, value, line, ignoreFieldChangeTrigger){

            currRec.selectLine({
                sublistId: EXCHANGERATE_SUBLIST_ID,
                line: line
            });

            currRec.setCurrentSublistValue({
                sublistId: EXCHANGERATE_SUBLIST_ID,
                fieldId: field,
                value: value,
                ignoreFieldChange: !commonLib.isNullorEmpty(ignoreFieldChangeTrigger) ? ignoreFieldChangeTrigger : true
            });

            currRec.commitLine({sublistId: EXCHANGERATE_SUBLIST_ID});
        }

        /**
         * Sets trigger type
         * @param {[type]} currRec [description]
         * @param {[type]} trigger [description]
         */
        function setSubmitTrigger(currRec, trigger){
            if(currRec && trigger){
                currRec.setValue({
                    fieldId : 'custpage_2663_trigger',
                    value   : trigger
                });
            }
        }

        /**
         * Re-loads current page with currently selected parameters
         * @param currRec
         */
        function refreshPage(currRec){
            currRec.setValue({fieldId : SUBLIST_ID + '_page_size_change', value: 'F', ignoreFieldChange: true});
            setSubmitTrigger(currRec, TRIGGER.refresh);
            setWindowChanged(window, false);
            document.forms.main_form.submit();
        }

        /**
         * Selects all transactions
         * @return {[type]} [description]
         */
        function markAllHandler() {
            myRecord.setValue({fieldId : 'custpage_2663_sublist_mark_all', value : 'T', ignoreFieldChange : true});
            refreshPage(myRecord);
        }

        /**
         * De-selects all selected transactions
         * @return {[type]} [description]
         */
        function unmarkAllHandler(){
            //Verify - unsetLines in SS1?
            myRecord.setValue({fieldId : 'custpage_2663_sublist_mark_all', value : 'F', ignoreFieldChange : true});
            refreshPage(myRecord);
        }

        /**
         * Redirects to PFA list page on Click of cancel
         * @param  {[type]} recordId [description]
         * @return {[type]}          [description]
         */
        function cancel(recordId) {
            setWindowChanged(window, false);
            var cancelUrl = '/app/common/search/searchresults.nl?searchid=customsearch_2663_payment_file_admin';
            if (recordId) {
                cancelUrl = url.resolveRecord({
                    recordType: PFA_RECORD_TYPE,
                    recordId: recordId,
                    isEditMode: false
                });
            }
            location.assign(cancelUrl);
        }

        /**
         * Set Posting Period from the selected process date and list of open periods
         * @param currRec
         */
        function setPostingPeriodFromProcessDate(currRec) {
            var currProcessDate = currRec.getValue({fieldId : 'custpage_2663_process_date'});
            var currPostingPeriod = currRec.getValue({fieldId : 'custpage_2663_postingperiod'});
            var startDate = currRec.getValue({fieldId : 'custpage_2663_ppstart'});
            var endDate = currRec.getValue({fieldId : 'custpage_2663_ppend'});
            var closedPeriods = currRec.getValue({fieldId : 'custpage_2663_ppclosed'});

            if ( currProcessDate && currPostingPeriod) {
                var accountingPeriod = commonLib.getAccountingPeriodFromList(currProcessDate, true, startDate, endDate, closedPeriods);
                if (accountingPeriod) {
                    if (currPostingPeriod != accountingPeriod) {
                        currRec.setValue({
                            fieldId: 'custpage_2663_postingperiod',
                            value: accountingPeriod,
                            ignoreFieldChange: true
                        });
                    }
                }
            }
        }

        /**
         * Set the custpage_2663_process_date field with process date
         * @param currRec
         */
        function setProcessDate(currRec){

            if(!currRec.getValue({fieldId : 'custpage_2663_process_date'})){
                var millisDate = currRec.getValue({fieldId : 'custpage_2663_process_date_millis'});
                var dateObj = new Date();
                if(millisDate) {
                    dateObj = new Date(millisDate);
                }
                var localDateObj = format.parse({ value: dateObj, type: format.Type.DATE })
                currRec.setValue({ fieldId : 'custpage_2663_process_date', value : localDateObj, ignoreFieldChange : true});//Note ignoreFieldChange=true to avoid page reload
            }
        }

        /**
         * Set the custpage_2663_process_date_millis field with milliseconds value
         * @param currRec
         */
        function setProcessDateMillis(currRec){
            var currProcessDate = currRec.getValue({fieldId : 'custpage_2663_process_date'});
            if(currProcessDate){
                //Parse it to date
                var dateObj = format.parse({ value: currProcessDate, type: format.Type.DATE });
                if(dateObj){
                    var millis = dateObj.getTime();
                    currRec.setValue({ fieldId : 'custpage_2663_process_date_millis', value : millis, ignoreFieldChange : true});
                }
            }
        }

        function setProcessDateAndPostingPeriod(currRec){
            if(!currRec.getValue({fieldId : 'custpage_2663_process_date'})){
                setProcessDate(currRec);
                setPostingPeriodFromProcessDate(currRec);
            }
        }

        /**
         * SuiteScript dialog alert
         * @param title
         * @param message
         */
        function showAlert(message){
            dialog.defaultAlert({
                message : message
            });
        }

        /**
         * Updates sublist marked fields
         * @param currRec
         */
        function _fieldChanged(currRec, name, lineNum) {
            // ---- Sublist fields ----
            if (name === SUBLIST_ID + '_page' || name === SUBLIST_ID + '_max') {
                currRec.setValue({fieldId : SUBLIST_ID + '_currpage', value: currRec.getValue({fieldId : SUBLIST_ID + '_page'}), ignoreFieldChange: true});
                currRec.setValue({fieldId : SUBLIST_ID + '_maxinpage', value: currRec.getValue({fieldId : SUBLIST_ID + '_max'}), ignoreFieldChange: true});
                currRec.setValue({fieldId : SUBLIST_ID + '_page_size_change', value: 'F', ignoreFieldChange: true});
                if (name === SUBLIST_ID + '_max') {
                    currRec.setValue({fieldId : SUBLIST_ID + '_page_size_change', value: 'T', ignoreFieldChange: true});
                    currRec.setValue({fieldId : SUBLIST_ID + '_currpage', value: 0, ignoreFieldChange: true});
                }
                paginate(currRec);
            }
            else {
                if (name === MARK_COL || name === MARK_PROPERTY) {
                    // prepare object for marking
                    _toggleLineMarked(currRec, lineNum, currRec.getSublistValue({ sublistId : 'custpage_2663_sublist', fieldId : MARK_PROPERTY, line : lineNum}), currRec.getSublistValue({sublistId : 'custpage_2663_sublist', fieldId : MARK_ENTITY_PROPERTY, line : lineNum}));
                    // set mark all field to false
                    currRec.setValue({fieldId : SUBLIST_ID + '_mark_all', value: 'transUnmarked', ignoreFieldChange: false});
                }
            }
        }

        /**
         * Adds the marked line to hidden fields and refreshes the page dropdown
         * @param currRec
         * @param lineNum
         * @param lineVal
         * @private
         */
        function _toggleLineMarked(currRec, lineNum, lineVal, entityLineVal) {
            if (currRec) {

                var sublistId = SUBLIST_ID;
                var markCol = MARK_COL;
                var markKey = MARK_KEY;

                if (sublistId && markCol && markKey) {

                    lineVal = lineVal || '';

                    var isLineSelected = currRec.getSublistValue({ sublistId : sublistId, fieldId : markCol, line : lineNum});
                    var lineKey = currRec.getSublistValue({ sublistId : sublistId, fieldId : markKey, line : lineNum});
                    // get marked lines for page number
                    var pageNum = currRec.getValue({fieldId : sublistId+'_currpage'}) ? currRec.getValue({fieldId : sublistId+'_currpage'}) : 0;
                    var markedDataInPageStr = currRec.getValue({fieldId : sublistId+'_markdata'+pageNum}) || '{}';
                    var markedDataInPageObj = JSON.parse(markedDataInPageStr);
                    var entityDataInPageStr = currRec.getValue({fieldId : sublistId+ '_entity_data'+pageNum}) || '{}';
                    var entityDataInPageObj = JSON.parse(entityDataInPageStr);

                    if (isLineSelected && lineVal) {
                        markedDataInPageObj[lineKey] = lineVal;
                        entityDataInPageObj[lineKey] = entityLineVal;
                    }
                    else {
                        delete markedDataInPageObj[lineKey];
                        delete entityDataInPageObj[lineKey];
                    }
                    currRec.setValue({fieldId : sublistId + '_markdata' + pageNum, value : JSON.stringify(markedDataInPageObj), ignoreFieldChange : false});
                    currRec.setValue({fieldId : sublistId + '_entity_data' + pageNum, value : JSON.stringify(entityDataInPageObj), ignoreFieldChange : false});
                }

            }

        }

        /**
         * Handles field change for sublist
         */
        function _sublistFieldChanged(currRec, name, line, currFlag){
            if (paymentType === 'custref') {
                sublistFieldChanged_CR(currRec, name, line);
            }
            else if (paymentType ==='pp') {
                _fieldChanged(currRec, name, line);
            }
            else {
                sublistFieldChanged(currRec, name, line, currFlag) //handles DD and EFT
            }
        }

        /**
         * Handles field change for sublist of CR suitelet
         */
        function sublistFieldChanged_CR(currRec, name, line) {
            if (name === 'custpage_pay') {
                // update the sublist marked fields
                _fieldChanged(currRec, name, line);
                // recalc lines
                recalcLines_EFT(currRec);

            } else {
                //Pagination refresh
                _fieldChanged(currRec, name, line);
            }
        }

        /**
         * Handles sublist field change for EFT/DD suitelet
         * @param currRec
         * @param name
         * @param line
         * @param currFlag
         */
        function sublistFieldChanged(currRec, name, line, currFlag){
            if (name === 'custpage_pay' || name === 'custpage_discamount' || name === 'custpage_payment' ) {//|| (otherProps && isInArray(name, otherProps)
                // check if selection is within maximum line selection limit
                // two ways to add a payment line: (1) using pay checkbox, (2) using payment amount field

                var payAmount = parseFloat(currRec.getSublistValue({ sublistId : 'custpage_2663_sublist', fieldId : 'custpage_payment', line : line}));
                var maxLinesSel = currRec.getValue({ fieldId : 'custpage_2663_max_lines_sel'}) || 5000;

                maxLinesSel = commonLib.getAccountID().indexOf('SB') != -1 ? Math.ceil(maxLinesSel / 2) : maxLinesSel;
                var paymentLines = currRec.getValue({ fieldId : 'custpage_2663_payment_lines'});
                var toPay = currRec.getSublistValue({ sublistId : 'custpage_2663_sublist', fieldId : 'custpage_pay', line : line});
                //var paymentType = currRec.getValue({ fieldId : 'custpage_2663_paymenttype'}); paymentType is already stored in pageInit


                if ((name === 'custpage_payment' && Math.abs(payAmount) > 0 && !toPay && maxLinesSel == paymentLines) ||
                    (name === 'custpage_pay' && toPay && payAmount == 0 && maxLinesSel == paymentLines)) {

                    // covered cases (should alert warning message):
                    //  (1) max selected entries, trying to add payment line by entering a non-zero Payment Amount
                    //  (2) max selected entries, trying to add payment line by checking Pay box

                    // covered cases (should NOT alert warning message):
                    //  (3) max selected entries, trying to remove payment line by entering a zero Payment Amount
                    //  (4) max selected entries, trying to remove payment line by unchecking Pay box
                    //  (5) max selected entries, trying to edit payment amount of 1 of them (e.g. from 2000 to 1000)

                    showAlert(MESSAGEMAP_ALERT['maxmarkedtran'] + currRec.getValue({ fieldId : 'custpage_2663_max_lines_sel'}));

                    payAmount = 0;
                    setSublistVal(currRec, 'custpage_pay', false, line);
                    setSublistVal(currRec, 'custpage_payment', formatCurrency(payAmount), line);
                }

                else {
                    if (name === 'custpage_pay' && !currRec.getValue({ fieldId : 'custpage_2663_batch'})) {

                        var amountRemaining = 0;

                        var discAmt = 0;

                        var dateToBeProcessed = format.parse({ value: currRec.getValue({ fieldId : 'custpage_2663_process_date'}), type: format.Type.DATE });
                        var discDate = currRec.getSublistValue({ sublistId : 'custpage_2663_sublist', fieldId : 'custpage_discdate', line : line});
                        if(toPay) {

                            // set amount remaining when mark column is checked, if unchecked set to 0
                            amountRemaining = currRec.getSublistValue({ sublistId : 'custpage_2663_sublist', fieldId : 'custpage_amountremaining', line : line});
                            discAmt = parseFloat(currRec.getSublistValue({ sublistId : 'custpage_2663_sublist', fieldId : 'custpage_discamount', line : line}));


                            // deduct discount amount if existing
                            //consider discount with no expiration date

                            if (discAmt > 0) {
                                if( (discDate && dateToBeProcessed <= format.parse({ value: discDate, type: format.Type.DATE })) || !discDate){
                                    amountRemaining = amountRemaining - discAmt;
                                }
                            }
                        } else{
                            if((discDate && dateToBeProcessed <= format.parse({ value : discDate, type : format.Type.DATE})) || !discDate ){

                                var origDiscAmt = currRec.getSublistValue({ sublistId : 'custpage_2663_sublist', fieldId : 'custpage_discamounthdn', line : line}) || 0;//discamounthdn is used
                                setSublistVal(currRec, 'custpage_discamount', formatCurrency(origDiscAmt), line);
                            } else{
                                setSublistVal(currRec, 'custpage_discamount', '', line);
                            }
                        }

                        // prepare object for marking
                        setSublistVal(currRec, 'custpage_payment', formatCurrency(amountRemaining), line);
                    }

                    else if (name === 'custpage_payment') {
                        // set amount boundaries
                        var amountRemaining = parseFloat(currRec.getSublistValue({ sublistId : 'custpage_2663_sublist', fieldId : 'custpage_amountremaining', line : line}));
                        var tranType =  currRec.getSublistValue({ sublistId : 'custpage_2663_sublist', fieldId : 'custpage_trantype', line : line});
                        var creditRecTypes = ['creditmemo','customerpayment','vendorcredit','vendorpayment'];

                        if (commonLib.isInArray(tranType,creditRecTypes)) {
                            // for credits, amountRemaining <= payAmount <= 0
                            payAmount = (payAmount > 0) ? 0 : payAmount;
                            payAmount = (payAmount < amountRemaining) ? amountRemaining : payAmount;
                        }
                        else {
                            // for payables, amountRemaining >= payAmount >= 0
                            payAmount = (payAmount < 0) ? 0 : payAmount;

                            var termValue = parseFloat(currRec.getSublistValue({ sublistId : 'custpage_2663_sublist', fieldId : 'custpage_disctermhdn', line : line}));
                            var dateToBeProcessed = format.parse({ value: currRec.getValue({ fieldId : 'custpage_2663_process_date'}), type: format.Type.DATE });
                            var discDate = currRec.getSublistValue({ sublistId : 'custpage_2663_sublist', fieldId : 'custpage_discdate', line : line});
                            var origDiscAmt = currRec.getSublistValue({ sublistId : 'custpage_2663_sublist', fieldId : 'custpage_discamounthdn', line : line});

                            var validTranTypeList = ['vendorbill', 'invoice'];
                            var validDateForDiscount = false;

                            //compare dates only if there's a discount date. otherwise, consider discount with no expiration
                            if((discDate && dateToBeProcessed <= format.parse({ value: discDate, type: format.Type.DATE })) || (origDiscAmt && !discDate)){
                                validDateForDiscount = true;
                            }

                            if( validDateForDiscount && commonLib.isInArray(tranType, validTranTypeList) && origDiscAmt){

                                var discAmt = "";
                                var isError = false;

                                if(payAmount && payAmount > 0){
                                    //discAmt = (payAmount / termAmt) - payAmount;//Old Discount amount calculation logic
                                    /**
                                     * During partial payment(manually enter payment amount), discount amount should be the same as the percentage of amount being paid against the total payment amount(total payment amount is the amount that clears the due: amount remaining-disc available).
                                     *
                                     * Discount Amount = (Actual Payment Amount/(Amount Remaining - Discount Available)) x Discount Available
                                     * @type {number}
                                     */
                                    discAmt = (payAmount/(amountRemaining-origDiscAmt))*origDiscAmt;

                                    if(payAmount + discAmt > amountRemaining){
                                        discAmt = amountRemaining - payAmount;
                                    }

                                    if(discAmt < 0){

                                        showAlert(MESSAGEMAP_ALERT['maxmarkedtran'] + tranType + MESSAGEMAP_ALERT['exceedremainingamt2']);

                                        setSublistVal(currRec, 'cuspage_discamount', origDiscAmt, line);

                                        if(currRec.getSublistValue({ sublistId : 'custpage_2663_sublist', fieldId : 'custpage_pay', line : line})){//Boolean true check of custpage_pay
                                            payAmount = amountRemaining - origDiscAmt;
                                        } else{
                                            payAmount = 0;
                                        }
                                        isError = true;
                                    }
                                } else {
                                    isError = true;
                                }

                                if(!isError){
                                    setSublistVal(currRec, 'custpage_discamount', discAmt != 0.0 ? discAmt.toFixed(2) : "", line);
                                }

                            } else if(payAmount > amountRemaining){

                                //showAlertMsg(MESSAGEMAP_ALERT['paymentexceed'] + tranType + MESSAGEMAP_ALERT['exceedremainingamt2']);
                                showAlert(MESSAGEMAP_ALERT['paymentexceed'] + tranType + MESSAGEMAP_ALERT['exceedremainingamt2']);

                                if(currRec.getSublistValue({ sublistId : 'custpage_2663_sublist', fieldId : 'custpage_pay', line : line})){
                                    payAmount = amountRemaining;
                                } else{
                                    payAmount = 0;
                                }
                            }
                        }

                        setSublistVal(currRec, 'custpage_payment', formatCurrency(payAmount), line);

                        // auto-check payment box
                        var payVal = false;
                        if (commonLib.isInArray(tranType,creditRecTypes)) {
                            // for credits, check if amount is less than 0
                            payVal = payAmount < 0;
                        }
                        else {
                            // for payables, check if amount is greater than 0
                            payVal = payAmount > 0;
                        }
                        setSublistVal(currRec, 'custpage_pay', payVal, line, false);//should trigger field change
                        //Set name to MarkProperty to make sure MarkData is updated with correct amount
                        name =  MARK_PROPERTY;

                    }

                    else if (name == 'custpage_discamount') {

                        var amountRemaining = currRec.getSublistValue({ sublistId : 'custpage_2663_sublist', fieldId : 'custpage_amountremaining', line : line});
                        var discAmt = parseFloat(currRec.getSublistValue({ sublistId : 'custpage_2663_sublist', fieldId : 'custpage_discamount', line : line}));
                        var origDiscAmt = currRec.getSublistValue({ sublistId : 'custpage_2663_sublist', fieldId : 'custpage_discamounthdn', line : line}) || 0;

                        var dateToBeProcessed = format.parse({ value: currRec.getValue({ fieldId : 'custpage_2663_process_date'}), type: format.Type.DATE });
                        var discDate = currRec.getSublistValue({ sublistId : 'custpage_2663_sublist', fieldId : 'custpage_discdate', line : line});
                        var tranType = currRec.getSublistValue({ sublistId : 'custpage_2663_sublist', fieldId : 'custpage_trantype', line : line});
                        var validTranTypeList = ['vendorbill', 'invoice'];


                        var termValue = parseFloat(currRec.getSublistValue({ sublistId : 'custpage_2663_sublist', fieldId : 'custpage_disctermhdn', line : line}));
                        var maxDiscAmt = amountRemaining * (termValue / 100);

                        if(discAmt != 0){

                            //consider discount with no expiration
                            if(commonLib.isInArray(tranType, validTranTypeList) && origDiscAmt && ((dateToBeProcessed <= format.parse({ value: discDate, type: format.Type.DATE }) && discDate) || (origDiscAmt && !discDate))){
                                if(discAmt && discAmt >= 0){
                                    if(discAmt > maxDiscAmt) {
                                        //Validations to allow user to enter discount amount more than the maximum discount amount.
                                        if (((discAmt + parseFloat(currRec.getSublistValue({ sublistId : 'custpage_2663_sublist', fieldId : 'custpage_payment', line : line}))) > amountRemaining) || (discAmt > amountRemaining)) {
                                            showAlert(MESSAGEMAP_ALERT['exceedremainingamt'] + tranType + MESSAGEMAP_ALERT['exceedremainingamt2']);
                                            setSublistVal(currRec, 'custpage_discamount', formatCurrency(origDiscAmt), line);
                                        }
                                    }

                                } else if (discAmt){

                                    showAlert(MESSAGEMAP_ALERT['zerodisc'])
                                    setSublistVal(currRec, 'custpage_discamount', formatCurrency(origDiscAmt), line);
                                }

                                discAmt = parseFloat(currRec.getSublistValue({ sublistId : 'custpage_2663_sublist', fieldId : 'custpage_discamount', line : line})) ? parseFloat(currRec.getSublistValue({ sublistId : 'custpage_2663_sublist', fieldId : 'custpage_discamount', line : line})) : 0.0;

                                var paymentAmount = parseFloat(currRec.getSublistValue({ sublistId : 'custpage_2663_sublist', fieldId : 'custpage_payment', line : line}));



                                if(paymentAmount + discAmt > amountRemaining){

                                    showAlert(MESSAGEMAP_ALERT['exceedremainingamt'] + tranType + MESSAGEMAP_ALERT['exceedremainingamt2'] );
                                    setSublistVal(currRec, 'custpage_payment', formatCurrency(amountRemaining-discAmt), line);
                                }

                            } else{

                                if(!commonLib.isInArray(tranType, validTranTypeList)){

                                    if(paymentType === 'eft'){
                                        showAlert(MESSAGEMAP_ALERT['discvendorbill'])
                                    }
                                    else if (paymentType === 'dd'){
                                        showAlert(MESSAGEMAP_ALERT['discvendorbill'])
                                    }
                                    else{
                                        showAlert(MESSAGEMAP_ALERT['discvendorinvoice']);
                                    }
                                } else if(!origDiscAmt){
                                    if(paymentType === 'eft'){
                                        showAlert(MESSAGEMAP_ALERT['discnotermseft'])
                                    }
                                    else{
                                        showAlert(MESSAGEMAP_ALERT['discnotermsdd']);
                                    }
                                } else if(dateToBeProcessed > format.parse({ value: discDate, type: format.Type.DATE }) && discDate){
                                    showAlert(MESSAGEMAP_ALERT['discafterperiod']);
                                }

                                setSublistVal(currRec, 'custpage_discamount', '', line);
                            }
                        }

                        //Set name to MarkProperty to make sure MarkData is updated with correct amount
                        name = MARK_PROPERTY;

                    }


                    if (currFlag) {
                        if (currRec.getSublistValue({ sublistId : 'custpage_2663_sublist', fieldId : 'custpage_pay', line : line})) {

                            var paymentAmt = currRec.getSublistValue({ sublistId : 'custpage_2663_sublist', fieldId : 'custpage_payment', line : line}) ;

                            var markObj = {
                                amount: '',
                                currency: '',
                                entity: '',
                                type: '',
                                custpage_discamount: ''
                            };

                            var entityObj ={
                                entityId: '',
                                entityName: ''
                            }

                            markObj.amount = paymentAmt;

                            if (commonLib.isMultiCurrencyEnabled()) {

                                var currencyId = currRec.getSublistValue({ sublistId : 'custpage_2663_sublist', fieldId : 'custpage_currencyhdn', line : line});

                                markObj.currency = currencyId;

                            }

                            var entityId = currRec.getSublistValue({ sublistId : 'custpage_2663_sublist', fieldId : 'custpage_entityid', line : line});

                            var entityName = currRec.getSublistValue({ sublistId : 'custpage_2663_sublist', fieldId : 'custpage_entity', line : line});
                            if (entityId) {

                                markObj.entity = entityId;
                                entityObj.entityId =entityId;
                                entityObj.entityName = entityName;

                            }

                            var tranType = currRec.getSublistValue({ sublistId : 'custpage_2663_sublist', fieldId : 'custpage_trantype', line : line});

                            if (tranType) {

                                markObj.type = tranType;

                            }

                            if(isGlobalPayment){
                                var entityBankId= currRec.getSublistValue({sublistId: 'custpage_2663_sublist',fieldId : 'custpage_entity_bank', line: line});
                                entityObj.entityBank= entityBankId;
                            }

                            var discAmt = currRec.getSublistValue({ sublistId : 'custpage_2663_sublist', fieldId : 'custpage_discamount', line : line});

                            if (discAmt) {

                                markObj.custpage_discamount = discAmt;

                            }

                            setSublistVal(currRec, MARK_PROPERTY, JSON.stringify(markObj), line, false);
                            setSublistVal(currRec,MARK_ENTITY_PROPERTY,JSON.stringify(entityObj),line,false);

                        }

                        else {
                            setSublistVal(currRec, MARK_PROPERTY, '', line);
                            setSublistVal(currRec,MARK_ENTITY_PROPERTY,'',line);
                        }

                    }



                    // update the sublist marked fields
                    _fieldChanged(currRec, name, line);



                    // recalc lines
                    if(paymentType === 'dd'){
                        recalcLines_DD(currRec);
                    }else {
                        recalcLines_EFT(currRec);
                    }

                }

            }
            else{
                //Pagination refresh
                _fieldChanged(currRec, name, line);
            }
        }

        /**
         * Formats currency as per format api
         */
        function formatCurrency(value){
            if(value){
                value = (parseFloat(value)).toFixed(2);
            }
            return isNaN(value) ? '' : value;
        }

        /**
         * Updates Total Amount, Total Lines, Total Void Amount & Total Void Lines
         * @param currRec
         */
        function recalcLines_PP(currRec) {

            var numPages = currRec.getValue({ fieldId : 'custpage_2663_sublist_numpages'});
            var totalLines = 0;
            var totalAmt = 0.0;
            var totalVoidLines = 0;
            var totalVoidAmt = 0.0;
            for (var i = 0; i < numPages; i++) {

                // get data for page
                var sublistPageMarkDataStr = currRec.getValue({ fieldId : 'custpage_2663_sublist_markdata' + i});
                var sublistPageMarkData = JSON.parse(sublistPageMarkDataStr);
                for (var j in sublistPageMarkData) {
                    if (j.indexOf('-v') !== -1) {
                        totalVoidLines++;
                        totalVoidAmt += Number(sublistPageMarkData[j]);
                    }
                    else {
                        totalLines++;
                        totalAmt += Number(sublistPageMarkData[j]);
                    }
                }

            }
            currRec.setValue({fieldId : 'custpage_2663_payment_lines', value: totalLines});
            currRec.setValue({fieldId : 'custpage_2663_total_amount', value: Math.abs(parseFloat(totalAmt)).toFixed(2)});
            currRec.setValue({fieldId : 'custpage_2663_void_payment_lines', value: totalVoidLines});
            currRec.setValue({fieldId : 'custpage_2663_void_total_amount', value: Math.abs(parseFloat(totalVoidAmt)).toFixed(2)});
        }

        /**
         * Updates Total Amount, Number of Transactions & Approval amount fields
         * @param currRec
         */
        function recalcLines_EFT(currRec) {

            if(isBatchPayment && currRec.getValue('custpage_2663_summarized')){
                return;
            }
            var bankAccount = currRec.getValue({ fieldId : 'custpage_2663_bank_account'});
            var approvalRoutingEnabled = currRec.getValue({ fieldId : 'custpage_2663_approval_routing'});
            var approvalType = '';

            if((approvalRoutingEnabled || approvalRoutingEnabled === 'T') && bankAccount){
                var approvalTypeLookup = search.lookupFields({
                    type: 'customrecord_2663_bank_details',
                    id: bankAccount,
                    columns: 'custrecord_2663_bank_approval_type'
                })['custrecord_2663_bank_approval_type'];

                //If a batch is already created and approval routing is enabled later, while viewing the batch, we get error as not AR setup is done for corresponding c-bank.
                //Hence check for the length before fetching the value.
                if(approvalTypeLookup && approvalTypeLookup.length > 0){
                    approvalType = approvalTypeLookup[0].value;
                }
            }

            var numPages = currRec.getValue({ fieldId : 'custpage_2663_sublist_numpages'});
            var mapEntityAmt = {};
            var totalLines = 0;
            var totalAmt = 0;
            var approvalAmt = 0;

            // get exchange rates (if with value)
            var exchangeRates;
            var exchangeRateValue = currRec.getValue({ fieldId : 'custpage_2663_exchange_rates'});
            if (exchangeRateValue) {

                try {
                    exchangeRates = JSON.parse(exchangeRateValue);
                }
                catch(ex) {
                    showAlert(MESSAGEMAP_ALERT['exchangeratestr'] + exchangeRateValue +  MESSAGEMAP_ALERT['defaultrate']);
                }
            }
            var isSameBankCurrencies = (currRec.getValue({ fieldId : 'custpage_2663_bank_currency'}) === currRec.getValue({ fieldId : 'custpage_2663_base_currency'}));
            for (var i = 0; i < numPages; i++) {
                // get data for page
                var sublistPageMarkDataStr = currRec.getValue({ fieldId : 'custpage_2663_sublist_markdata' + i});
                var sublistPageMarkData = JSON.parse(sublistPageMarkDataStr);

                for (var j in sublistPageMarkData) {

                    totalLines++;
                    var markData = JSON.parse(sublistPageMarkData[j]);
                    var exchangeRate = 1;  // default to 1

                    if (exchangeRates && exchangeRates[markData.currency] && isSameBankCurrencies) {
                        exchangeRate = exchangeRates[markData.currency];
                    }

                    var lineAmount = markData.amount * exchangeRate;
                    totalAmt += lineAmount;

                    if (approvalRoutingEnabled) {
                        if (approvalType == APPROVALTYPE_BILLPAYMENT) {
                            approvalAmt = approvalAmt > lineAmount ? approvalAmt : lineAmount;
                        } else if (approvalType == APPROVALTYPE_VENDORPAYMENT) {
                            if (mapEntityAmt[markData.entity]) {
                                mapEntityAmt[markData.entity] += lineAmount;
                            } else {
                                mapEntityAmt[markData.entity] = lineAmount;
                            }
                        }
                    }
                }
            }


            currRec.setValue({fieldId : 'custpage_2663_payment_lines', value: totalLines, ignoreFieldChange: true});
            currRec.setValue({fieldId : 'custpage_2663_total_amount', value: parseFloat(totalAmt).toFixed(2), ignoreFieldChange: true});

            if (approvalRoutingEnabled) {
                if (approvalType == APPROVALTYPE_VENDORPAYMENT) {
                    for (var x in mapEntityAmt) {

                        if (mapEntityAmt.hasOwnProperty(x)) {
                            var entityAmt = mapEntityAmt[x];
                            approvalAmt = approvalAmt > entityAmt ? approvalAmt : entityAmt;
                        }
                    }
                } else if (approvalType == APPROVALTYPE_BATCHPAYMENT) {
                    approvalAmt	= totalAmt;
                }

                currRec.setValue({fieldId : 'custpage_2663_approval_amount', value: formatCurrency(approvalAmt), ignoreFieldChange: true});
            }
        }

        /**
         * Updates Total Amount, Total Lines
         * @param currRec
         */
        function recalcLines_DD(currRec) {
            var numPages = currRec.getValue({ fieldId : 'custpage_2663_sublist_numpages'});
            var totalLines = 0;
            var totalAmt = 0.0;

            for (var i = 0; i < numPages; i++) {
                // get data for page
                var sublistPageMarkDataStr = currRec.getValue({ fieldId : 'custpage_2663_sublist_markdata' + i});
                var sublistPageMarkData = JSON.parse(sublistPageMarkDataStr);

                // exchange rates is not need, as we are not using it in SS1

                for (var j in sublistPageMarkData) {
                    totalLines++;
                    var markData = JSON.parse(sublistPageMarkData[j]);
                    totalAmt += Number(markData.amount); //* exchangeRate;
                }
            }

            currRec.setValue({fieldId : 'custpage_2663_payment_lines', value: totalLines, ignoreFieldChange: true});
            currRec.setValue({fieldId : 'custpage_2663_total_amount', value: parseFloat(totalAmt).toFixed(2), ignoreFieldChange: true});
        }

        /**
         * Updates total amount, lines etc based on selected paymentType
         */
        function ep_RecalcLines(){
            switch (paymentType){
                case EFT_PAYMENT_TYPE_CODE : recalcLines_EFT(myRecord); break;
                case DD_PAYMENT_TYPE_CODE : recalcLines_DD(myRecord); break;
                default: recalcLines_EFT(myRecord);
            }
        }

        /**
         * Submits current sublist form to fetch the new selected page
         * @param currRec
         */
        function paginate(currRec){
            setSubmitTrigger(currRec, TRIGGER.paginate);
            setWindowChanged(window, false);
            document.forms.main_form.submit();
        }

        /**
         * Sets dateFrom field equal to dateTo field if dateTo Field is less than dateFrom field
         * @param currRec
         * @param fieldChangedID
         */
        function setDateFromField(currRec, fieldChangedID) {
            var dateFrom = currRec.getValue({ fieldId : 'custpage_2663_date_from'});
            var dateTo = currRec.getValue({ fieldId : 'custpage_2663_date_to'});

            if (dateFrom && dateTo) {
                var startDate = format.parse({value: dateFrom, type: format.Type.DATE});
                var endDate = format.parse({value: dateTo, type: format.Type.DATE});
                if (startDate > endDate) {
                    var nameToSet = (fieldChangedID === 'custpage_2663_date_from') ? 'custpage_2663_date_to' : 'custpage_2663_date_from';
                    currRec.setValue({fieldId : nameToSet, value : currRec.getValue({ fieldId : fieldChangedID}) });
                }
            }
        }
        function setTranAmtFromField(currRec, fieldChangedID) {
            var tranAmtFrom = currRec.getValue({ fieldId : 'custpage_2663_bank_tranamt_from'});
            var tranAmtTo = currRec.getValue({ fieldId : 'custpage_2663_bank_tranamt_to'});

            if (tranAmtFrom && tranAmtTo) {
                var startAmt = format.parse({value: tranAmtFrom, type: format.Type.CURRENCY});
                var endAmt = format.parse({value: tranAmtTo, type: format.Type.CURRENCY});
                if (startAmt > endAmt) {
                    var nameToSet = (fieldChangedID === 'custpage_2663_bank_tranamt_from') ? 'custpage_2663_bank_tranamt_to' : 'custpage_2663_bank_tranamt_from';
                    currRec.setValue({fieldId : nameToSet, value : currRec.getValue({ fieldId : fieldChangedID}) });
                }
            }
        }

        function isValidSepaDDTemplate(bankId) {

            if (!bankId || bankId === '{}') {
                return false;
            }

            var templateId = search.lookupFields({type:'customrecord_2663_bank_details', id: bankId, columns:'custrecord_2663_dd_template'}).custrecord_2663_dd_template;
            templateId = templateId && templateId[0] && templateId[0].value;

            var bankFileString = null;

            var paymentFileTemplate = record.load({type: 'customrecord_2663_payment_file_format', id: templateId
            });

            var isUpdateEntity = paymentFileTemplate.getValue({fieldId : 'custrecord_2663_update_entity_details'});
            var isSortSepaDD = paymentFileTemplate.getValue({fieldId : 'custrecord_13272_sorting_sepadd'});

            if (commonLib.isSuiteTaxEnabled()) {
                bankFileString = paymentFileTemplate.getValue({fieldId : 'custrecord_12144_free_marker_body_st'})
            }

            if(!bankFileString) {
                bankFileString = paymentFileTemplate.getValue({fieldId : 'custrecord_2663_free_marker_body'});
            }

            if (isUpdateEntity) {
                if (isSortSepaDD &&
                    ((bankFileString.indexOf('payments_FRST') != -1) && (bankFileString.indexOf('ebanks_FRST') != -1) && (bankFileString.indexOf('entities_FRST') != -1) &&

                        (bankFileString.indexOf('payments_RCUR') != -1) && (bankFileString.indexOf('ebanks_RCUR') != -1) && (bankFileString.indexOf('entities_RCUR') != -1) &&

                        (bankFileString.indexOf('payments_FNAL') != -1) && (bankFileString.indexOf('ebanks_FNAL') != -1) && (bankFileString.indexOf('entities_FNAL') != -1) &&

                        (bankFileString.indexOf('payments_OOFF') != -1) && (bankFileString.indexOf('ebanks_OOFF') != -1) && (bankFileString.indexOf('entities_OOFF') != -1))) {

                    return true;

                } else {
                    showAlert(MESSAGEMAP_ALERT['errortitle'] + ' : \n' +MESSAGEMAP_ALERT['invalidsepaDD']);
                    return false;
                }
            }

            return true;

        }

        /**
         * Function to submit form
         */

        function ep_SubmitForm() {
            var msgs = MESSAGEMAP_ALERT;

            //Perform Initial Validations
            paymentType = myRecord.getValue({ fieldId : 'custpage_2663_paymenttype'});
            var noSelectedTrans = (myRecord.getValue({fieldId: 'custpage_2663_total_amount'})) <= 0;
            if (paymentType === 'custref') {
                if (noSelectedTrans) {
                    showAlert(msgs.notran);
                    return false;
                }
            }
            else if (paymentType === 'pp') {
                noSelectedTrans = noSelectedTrans && (myRecord.getValue({ fieldId : 'custpage_2663_void_total_amount'}) <= 0);
                if (noSelectedTrans) {
                    showAlert(msgs.nocheques);
                    return false;
                }
                setChequeNumbers(myRecord, msgs);
            } else if(paymentType === DD_PAYMENT_TYPE_CODE){
                if(!saveRecord_DD(myRecord)){
                    return false;
                }
            }else if(paymentType === EFT_PAYMENT_TYPE_CODE){
                if(!saveRecord_EFT(myRecord)){
                    return false;
                }
            }

            // set the refresh flag
            myRecord.setValue({fieldId : 'custpage_2663_refresh_page', value : 'F', ignoreFieldChange : true});

            var suiteletURL = url.resolveScript({
                scriptId: 'customscript_15767_processor_bridge_su',
                deploymentId:  'customdeploy_15767_processor_bridge_su',
                returnExternalUrl: false,
            });

            if (!document.forms['main_form'].onsubmit || document.forms['main_form'].onsubmit()) {

                var approvalRoutingEnabled = myRecord.getValue({fieldId : 'custpage_2663_approval_routing'});
                var bankAccount = myRecord.getValue({fieldId : 'custpage_2663_bank_account'});
                var batchId = myRecord.getValue({fieldId : 'custpage_2663_batchid'});
                var process = true;

                if (bankAccount && (approvalRoutingEnabled || batchId)) {
                    if (!myRecord.getValue({fieldId : 'custpage_2663_payment_ref'})) {
                        showAlert(msgs.refnote);
                        process = false;
                    }else {
                        var approvalAmount = myRecord.getValue({fieldId : 'custpage_2663_approval_amount'}) * 1;
                        var paymentLimit = (search.lookupFields({type:'customrecord_2663_bank_details', id: bankAccount,columns: 'custrecord_2663_bank_payment_limit'}).custrecord_2663_bank_payment_limit) * 1;

                        if (paymentLimit && approvalAmount > paymentLimit) {

                            // Check if no batch is currently being updated
                            var account = myRecord.getValue({fieldId : 'custpage_2663_ap_account'});
                            var subsidiaryId = myRecord.getValue({fieldId : 'custpage_2663_subsidiary'});

                            if (batchId || paymentValidator.canStartBatchCreation(myRecord, bankAccount, account, subsidiaryId)) {
                                if (upsertBatch(bankAccount, batchId, true)) {
                                    suiteletURL =  (isGlobalPayment) ? '/app/common/search/searchresults.nl?searchid=customsearch_17801_global_paymnt_batches' : '/app/common/search/searchresults.nl?searchid=customsearch_2663_payment_batches';
                                } else {
                                    process = false;
                                }
                            } else {
                                process = false;
                            }
                        } else if (batchId) {
                            upsertBatch(bankAccount, batchId, false, true);
                        }
                    }
                }

                if(process) {
                    document.forms.main_form.action = suiteletURL;

                    // suppress the alert
                    setWindowChanged(window, false);
                    document.forms['main_form'].submit();
                }
            }
            return true;
        }

        /**
         * Perform validations for DD before submitting the data
         * @param currRecord
         * @returns {*|boolean}
         */
        function saveRecord_DD(currRecord) {
            var result = true;

            result = paymentValidator.checkSelectedLines(currRecord,DD_PAYMENT_TYPE_CODE);

            if (result) {
                result = paymentValidator.checkEntityAmt(currRecord);
            }

            if (result) {
                result = paymentValidator.checkAccountingPeriod(currRecord);
            }

            if (result) {
                result = paymentValidator.checkDCLSettings(currRecord);
            }

            if (result) {
                var fileFormat = currRecord.getValue({fieldId:'custpage_2663_format_display'});
                var subsidiaryId = currRecord.getValue({fieldId:'custpage_2663_subsidiary'});
                var account = currRecord.getValue({fieldId:'custpage_2663_ar_account'});

                result = paymentValidator.canStartPaymentProcessing(currRecord, fileFormat, account, subsidiaryId);
            }

            if (result) {
                // perform final recalc before saving
                recalcLines_DD(currRecord);
            }

            result = result && paymentValidator.validateSegments(currRecord);

            return result;
        }

        /**
         * Perform validations of EFT before submitting the data
         * @param currRecord
         * @returns {*}
         */
        function saveRecord_EFT(currRecord){

            var result = true;
            
            if (!checkVPA()) {
                return false;
            }


             result = paymentValidator.checkSelectedLines(currRecord,'eft', isBatchPayment);

            if (result) {
                result = paymentValidator.checkEntityAmt(currRecord);
            }

            if (result) {
                result = paymentValidator.checkAccountingPeriod(currRecord);
            }

            if (result) {
                result = paymentValidator.checkDCLSettings(currRecord);
            }

            if (result && !isBatchPayment) {
                var fileFormat = currRecord.getValue({ fieldId : 'custpage_2663_format_display'});
                var subsidiaryId = currRecord.getValue({ fieldId : 'custpage_2663_subsidiary'});
                var account = currRecord.getValue({ fieldId : 'custpage_2663_ap_account'});

                result = paymentValidator.canStartPaymentProcessing(currRecord, fileFormat, account, subsidiaryId);
            }

            if (result && (!isBatchPayment || currRecord.getValue({ fieldId : 'custpage_2663_sublist_numpages'}))){
                // perform final recalc before saving
                recalcLines_EFT(currRecord);
            }

            if(!isBatchPayment){
                result = result && paymentValidator.validateSegments(currRecord);
            }

            return result;
        }

        function rejectBatch(batchId) {
            var res = false;

            if (batchId) {
                try {
                    var batchLimit = 1200;


                    var batch = record.load({type: 'customrecord_2663_file_admin', id: batchId});

                    var tranKeys = JSON.parse(batch.getValue({fieldId: 'custrecord_2663_payments_for_process_id'}) || '[]');
                    batch.setValue({fieldId: 'custrecord_2663_status', value: constants.BatchStatus.BATCH_UPDATING});

                    batch.save();


                    var totalTransactions = tranKeys.length;
                    var numOfBatches = Math.ceil(totalTransactions/batchLimit);

                    res = true;
                    for (var i = 0; i < numOfBatches; i++) {
                        var startIndex = 0;
                        var endIndex = batchLimit;

                        var responsebody = callBatchUpdaterRS('reject', batchId, startIndex, endIndex);  //TODO Test if this is working
                        var error = responsebody['error'];
                        if (error) {
                            showAlert(['An error occurred while calling the restlet:', error.code, error.message].join(' '));
                            res = false;
                            break;
                        }

                        if (responsebody['update'] !== 'complete') {
                            showAlert(['Batch rejection did not complete:', responsebody['update']].join(' '));
                            res = false;
                            break;
                        }

                    }

                    if (res && batch) {
                        batch = record.load({type: 'customrecord_2663_file_admin', id: batchId}) // Load the Batch again to avoid - RCRD_HAS_BEEN_CHANGED error thrown from core
                        //Cannot optimize multiple loading and saving by using record.submit fields because we need UE to trigger

                        batch.setValue({fieldId: 'custrecord_2663_status', value: constants.BatchStatus.BATCH_REJECTED});
                        batch.setValue({fieldId: 'custrecord_2663_total_amount', value: 0});
                        batch.setValue({fieldId: 'custrecord_2663_total_transactions', value: 0});

                        batch.save();
                    }


                } catch (ex) {

                    res = false;
                    var errorMessage = 'Error during batch rejection';
                    if (ex) {
                        errorMessage += errorMessage ? ': ' : '';
                        if(ex.type === 'error.SuiteScriptError'){
                            errorMessage += ex.name + '\n' + ex.message + '\n' + ex.stack;
                        }else{
                            errorMessage += ex.toString() + '\n' + ex.stack;
                        }
                        errorMessage += ex;
                    }
                    showAlert(errorMessage);


                    record.submitFields({
                        type: 'customrecord_2663_file_admin',
                        id: batchId,
                        values: {
                            'custrecord_2663_status' : constants.BatchStatus.BATCH_PENDINGAPPROVAL
                        },
                        options: {
                            enableSourcing: false
                        }
                    });
                }
            }

            return res;
        }

        function callBatchUpdaterRS(process, batchId, startIndex, endIndex) {
            var restLetURL = url.resolveScript({
                scriptId: 'customscript_8859_batch_updater_rs',
                deploymentId: 'customdeploy_8859_batch_updater_rs'
            })
            var finalUrl = [restLetURL, '&process=', process, '&batch_id=', batchId, '&start=', startIndex, '&end=', endIndex].join('');
            var headers = {'User-Agent-x': 'SuiteScript-Call', 'Content-Type': 'application/json'};

            var response = https.get({
                url: finalUrl,
                headers: headers
            });
            return JSON.parse(response.body);
        }

        /**
         * Calls the suitelet that executes nlapiSubmitField as Administrator.
         * Supports only single field submit.
         *
         */
        function adminSubmitField(recType, recId, fldName, fldValue, doSourcing) {
            try {
                var suiteletURL = url.resolveScript({
                    scriptId: 'customscript_15486_ep_admin_data_submit',
                    deploymentId: 'customdeploy_15486_ep_admin_data_submit'
                });
                var params = {};
                params['custparam_2663_rec_type'] = recType;
                params['custparam_2663_rec_id'] = recId;
                params['custparam_2663_fld_name'] = fldName;
                params['custparam_2663_fld_value'] = fldValue;
                params['custparam_2663_do_sourcing'] = doSourcing;

                https.post({
                    url: suiteletURL,
                    body: params
                });
            }
            catch(ex){
                showAlert('Error during adminSubmitField of field ' + fldName + ' under record ' + recType + ' with ID ' + recId);
            }
        }

        /**
         * Performs currency precision value with currency internal id
         * @param {Number} currency internal id
         */
        function getCurrencyPrecisionWithId(currency) {
            var precision = 2;
            if (currency) {
                var filters = ['internalid', 'anyof', currency];
                var searchResults = search.create({
                    type: nssearch.Type.CURRENCY,
                    filters: filters
                }).run().getRange({
                    start: 0,
                    end: 1
                });

                if (searchResults.length) {
                    // load the record if it exists
                    var currRec = record.load({type: nsRecord.Type.CURRENCY, id: currency});
                    if (currRec) {
                        precision = currRec.getValue({fieldId: 'currencyprecision'}) == null ? 2 : currRec.getValue({fieldId: 'currencyprecision'});
                    }
                }
            }

            return precision;
        }

        function getCurrencyPrecision(currencyId) {
            var precision = 2;
            if (currencyId) {
                var currency = record.load({type: nsRecord.Type.CURRENCY, id: currencyId});
                if (currency) {
                    precision = currency.getValue({fieldId: 'currencyprecision'}) || 2;
                }
            }
            return precision;
        }

        function getMarkedLines() {
            var markedLines = {};
            var sublistNumPages = myRecord.getValue({fieldId: 'custpage_2663_sublist_numpages'});
            if (sublistNumPages) {
                var totalPages = parseInt(sublistNumPages, 10);
                for (var i = 0; i < totalPages; i++) {
                    var param = 'custpage_2663_sublist_markdata' + i;
                    markedLines[param] = JSON.parse(myRecord.getValue({fieldId: param}));
                }
            }
            return markedLines;
        }

        function upsertBatch(bankAccount, batchId, close, submit, save){
            var res = true;
            try {
                var origTranKeys = [];
                var removedKeys = [];
                var tranKeys = [];
                var tranAmts = [];
                var tranDiscounts = [];
                var tranEntities = [];
                var journalKeys = [];
                var currencyPrecisionMap = [];
                var batchLimit = 825;
                var bankFlds = ['name', 'custrecord_2663_bank_batch_number'];
                var multiCurrency = commonLib.isMultiCurrencyEnabled();
                if (multiCurrency) {
                    bankFlds.push('custrecord_2663_currency');
                }
                
                var mapBankValues = search.lookupFields({type:'customrecord_2663_bank_details', id: bankAccount, columns:bankFlds});
                var batchNumber = (mapBankValues['custrecord_2663_bank_batch_number'] * 1) + 1;
                var precision = getCurrencyPrecision(multiCurrency ? mapBankValues['custrecord_2663_currency'][0].value : null);

                var markedLines = getMarkedLines();

                var process = batchId ? 'update' : 'add';

                var summarized = myRecord.getValue({fieldId: 'custpage_2663_summarized'}); //Note this returns boolean value

                var refNote = myRecord.getValue({fieldId: 'custpage_2663_payment_ref'});
                // check if refNote is populated
                if (!refNote) {
                    showAlert('Please enter value(s) for: EFT file reference note');
                    return false;
                }

                // parse marked lines for id's, amounts, discounts
                for (var i in markedLines) {
                    for (var j in markedLines[i]) {
                        var markedLineValue = JSON.parse(markedLines[i][j]);
                        var lineAmt;
                        var discAmt;

                        if (markedLineValue.hasOwnProperty('amount')) {
                            lineAmt = parseFloat(markedLineValue.amount);
                            discAmt = markedLineValue.custpage_discamount? parseFloat(markedLineValue.custpage_discamount) : 0;
                        } else {
                            lineAmt = parseFloat(markedLineValue);
                        }

                        if (multiCurrency) {
                            if ((currencyPrecisionMap[markedLineValue.currency] === undefined) || (currencyPrecisionMap[markedLineValue.currency] === '')) {
                                currencyPrecisionMap[markedLineValue.currency] = getCurrencyPrecisionWithId(markedLineValue.currency);
                            }
                            precision = currencyPrecisionMap[markedLineValue.currency];
                        }

                        // if multicurrency is on and the precision is not 2, round the value according to the currency setting
                        if (multiCurrency && precision != 2) {
                            var decimals = Math.pow(10, precision);
                            lineAmt = Math.round(lineAmt * decimals) / decimals;
                        }

                        // add the line amount and transaction key
                        tranAmts.push(formatCurrency(lineAmt)); //Do not use format.format to format the currency value, as it adds comma in between
                        tranDiscounts.push(formatCurrency(discAmt))
                        tranKeys.push(j);
                        tranEntities.push(markedLineValue.entity);
                        if (markedLineValue.type == 'journalentry') {
                            journalKeys.push(j);
                        }
                    }
                }

                if (tranKeys.length > 0 || summarized) {

                    var batch = batchId ? record.load({type: 'customrecord_2663_file_admin', id: batchId}) : record.create({type:'customrecord_2663_file_admin'});

                    if (!batchId) {
                        batch.setValue({fieldId: 'altname', value: [mapBankValues['name'], batchNumber].join('-')});
                        batch.setValue({fieldId: 'custrecord_2663_bank_account', value: bankAccount});
                        batch.setValue({fieldId: 'custrecord_2663_account', value: myRecord.getValue({fieldId: 'custpage_2663_ap_account'})});
                        batch.setValue({fieldId: 'custrecord_2663_payment_type', value: constants.PaymentType.EP_EFT});
                        batch.setValue({fieldId: 'custrecord_2663_number', value: batchNumber});
                        batch.setValue({fieldId: 'custrecord_2663_approval_level', value: constants.ApprovalLevels.APPROVAL_LEVEL1});
                        batch.setValue({fieldId: 'custrecord_2663_status', value: constants.BatchStatus.BATCH_UPDATING});
                        batch.setValue({fieldId: 'custrecord_from_eft_bill_pay_page', value: true});
                        if(isGlobalPayment){
                            batch.setValue({fieldId: 'custrecord_15529_global_payment', value: true});
                        }
                    } else {
                        origTranKeys = JSON.parse(batch.getValue('custrecord_2663_payments_for_process_id') || '[]');
                        if (tranKeys.length < origTranKeys.length) {
                            for (var i = 0, ii = origTranKeys.length; i < ii; i++) {
                                var tranKey = origTranKeys[i];
                                if (!commonLib.isInArray(tranKey, tranKeys)) {
                                    removedKeys.push(tranKey);
                                }
                            }
                        }

                        if (removedKeys.length > 0) {
                            batch.setValue({fieldId: 'custrecord_2663_removed_keys', value: JSON.stringify(removedKeys)});
                        }
                        var isOpenBatch = batch.getValue({fieldId: 'custrecord_2663_status'}) === constants.BatchStatus.BATCH_OPEN;
                        if (!close && !(save && isOpenBatch)) {
                            batch.setValue({fieldId: 'custrecord_2663_prev_approval_level', value: batch.getValue('custrecord_2663_approval_level')});
                        }
                    }

                    if (!summarized) {
                        batch.setValue({fieldId: 'custrecord_2663_payments_for_process_id', value: JSON.stringify(tranKeys)});
                        batch.setValue({fieldId: 'custrecord_2663_payments_for_process_amt', value: JSON.stringify(tranAmts)});
                        batch.setValue({fieldId: 'custrecord_2663_payments_for_process_dis', value: JSON.stringify(tranDiscounts)});
                        batch.setValue({fieldId: 'custrecord_2663_transaction_entities', value: JSON.stringify(tranEntities)});
                        batch.setValue({fieldId: 'custrecord_2663_journal_keys', value: JSON.stringify(journalKeys)});
                        batch.setValue({fieldId: 'custrecord_2663_total_amount', value: myRecord.getValue({fieldId: 'custpage_2663_total_amount'})});
                        batch.setValue({fieldId: 'custrecord_2663_total_transactions', value: myRecord.getValue({fieldId: 'custpage_2663_payment_lines'}) * 1});
                    }

                    batch.setValue({fieldId: 'custrecord_2663_ref_note', value: refNote});
                    batch.setValue({fieldId: 'custrecord_2663_process_date', value: myRecord.getValue({fieldId: 'custpage_2663_process_date'})});
                    batch.setValue({fieldId: 'custrecord_2663_posting_period', value: myRecord.getValue({fieldId: 'custpage_2663_postingperiod'})});
                    batch.setValue({fieldId: 'custrecord_2663_aggregate', value: (isGlobalPayment) ? myRecord.getValue({fieldId: 'custpage_15529_aggregate'}) : myRecord.getValue({fieldId: 'custpage_2663_aggregate'})});
                    batch.setValue({fieldId: 'custrecord_2663_agg_method', value: (isGlobalPayment) ? myRecord.getValue({fieldId: 'custpage_15529_agg_method'}) : myRecord.getValue({fieldId: 'custpage_2663_agg_method'})});

                    if (commonLib.isOneWorld()) {
                        batch.setValue({fieldId: 'custrecord_2663_payment_subsidiary', value: myRecord.getValue({fieldId: 'custpage_2663_subsidiary'})});
                    }

                    if(IS_DEPARTMENT){
                        batch.setValue({fieldId: 'custrecord_2663_department', value: myRecord.getValue({fieldId: 'custpage_2663_department'})});
                    }
                    if(IS_CLASS){
                        batch.setValue({fieldId: 'custrecord_2663_class', value: myRecord.getValue({fieldId: 'custpage_2663_classification'})});
                    }
                    if(IS_LOCATION){
                        batch.setValue({fieldId: 'custrecord_2663_location', value: myRecord.getValue({fieldId: 'custpage_2663_location'})});
                    }

                    batchId = batch.save();

                    if (process === 'add') {
                        myRecord.setValue({fieldId : 'custpage_2663_batchid', value: batchId});
                        adminSubmitField('customrecord_2663_bank_details', bankAccount, 'custrecord_2663_bank_batch_number', batchNumber);
                    }

                    if (!summarized) {

                        var totalTransactions = process === 'add' ? tranKeys.length : removedKeys.length;
                        var numOfBatches = Math.ceil(totalTransactions/batchLimit);

                        for (var i = 0; i < numOfBatches; i++) {
                            var startIndex = i * batchLimit;
                            var endIndex = (i + 1) * batchLimit;

                            var responsebody = callBatchUpdaterRS(process, batchId, startIndex, endIndex);

                            var error = responsebody['error'];
                            if (error) {
                                showAlert(['An error occurred while calling the restlet:', error.code, error.message].join(' '));
                                res = false;
                                break;
                            }

                            if (responsebody['update'] !== 'complete') {
                                showAlert(['Batch update did not complete:', responsebody['update']].join(' '));
                                res = false;
                                break;
                            }

                        }

                    }

                    if (batchId && (close || submit)) {
                        batch = record.load({type: 'customrecord_2663_file_admin', id: batchId});
                        batch.setValue({fieldId: 'custrecord_2663_status', value: submit ? constants.BatchStatus.BATCH_SUBMITTED: constants.BatchStatus.BATCH_PENDINGAPPROVAL});
                        batch.save();
                    }
                } else {
                    return rejectBatch(batchId);
                }
            } catch (ex) {
                res = false;
                var errorMessage = 'Error during batch creation';
                if (ex) {
                    errorMessage += errorMessage ? ': ' : '';
                    if(ex.type === 'error.SuiteScriptError'){
                        errorMessage += ex.name + '\n' + ex.message + '\n' + ex.stack;
                    }else{
                        errorMessage += ex.toString() + '\n' + ex.stack;
                    }
                    errorMessage += ex;
                }
                showAlert(errorMessage);
                //Set to pending approval on error
                if (process === 'add') {
                    record.submitFields({
                        type: 'customrecord_2663_file_admin',
                        id: batchId,
                        values: {
                            'custrecord_2663_status' : constants.BatchStatus.BATCH_OPEN
                        },
                        options: {
                            enableSourcing: false
                        }
                    });
                }

            }

            return res;
        }

        /**
         * Save current state of Batch
         */
        function ep_Save(){
            //Running saveRecord validations
            if(paymentType === EFT_PAYMENT_TYPE_CODE){
                if(!saveRecord_EFT(myRecord)){
                    return false;
                }
            }

            var bankAccount = myRecord.getValue({fieldId: 'custpage_2663_bank_account'});
            var batchId = myRecord.getValue({fieldId: 'custpage_2663_batchid'});
            if (bankAccount && batchId) {
                if (!document.forms['main_form'].onsubmit || document.forms['main_form'].onsubmit()) {
                    upsertBatch(bankAccount, batchId, false, false, true);

                    // set the refresh flag
                    myRecord.setValue({fieldId : 'custpage_2663_refresh_page', value : 'T', ignoreFieldChange : true});

                    // set to view mode
                    myRecord.setValue({fieldId : 'custpage_2663_edit_mode', value: false, ignoreFieldChange : true});

                    refreshPage(myRecord);
                    /*
                    // suppress the alert
                    setWindowChanged(window, false);

                    // submit the form -- calls submitForm function
                    document.forms.main_form.submit();

                     */
                }
            }
        }

        function getApprovalRoutingId(bankAccount, approvalLevel) {

            var filters = [
                ['custrecord_2663_ar_bank_acct', 'is', bankAccount],
                'and',
                ['custrecord_2663_ar_level', 'is', approvalLevel],
                'and',
                ['isinactive', 'is', 'F']
            ];

            var res = search.create({
                type: 'customrecord_2663_approval_routing',
                filters: filters
            }).run().getRange({
                start: 0,
                end: 1
            });

            if (res.length) {
                return res[0].id;
            }

            return '';
        }
        
        /**
         * Function to Approve batch
         */
        function ep_Approve() {

            //Running saveRecord validations
            if(paymentType === EFT_PAYMENT_TYPE_CODE){
                if(!saveRecord_EFT(myRecord)){
                    return false;
                }
            }

            if(!checkVPA()){
                return false; //block process and return
            }

            // set the refresh flag
            myRecord.setValue({fieldId : 'custpage_2663_refresh_page', value: 'F', ignoreFieldChange : true});

            var finalURL = url.resolveScript({
                scriptId: 'customscript_15767_processor_bridge_su',
                deploymentId:  'customdeploy_15767_processor_bridge_su',
                returnExternalUrl: false,
            });

            var ADMIN_ROLE = 3;
            var role = runtime.getCurrentUser().role;

            var postingPeriod = myRecord.getValue({fieldId : 'custpage_2663_postingperiod'});

            var fields = ['aplocked', 'arlocked', 'periodname', 'closed'];
            var values = search.lookupFields({type: nssearch.Type.ACCOUNTING_PERIOD, id: postingPeriod, columns:fields});

            var userpermission = runtime.getCurrentUser().getPermission({name: 'ADMI_PERIODOVERRIDE'});

            if ( ((typeof values.closed === 'boolean') && values.closed) || values.closed === 'T') {
                showAlert(translator.formatMessage(MESSAGEMAP_ALERT['approvealertclosed'], {periodname : values.periodname}));
                return;
            }

            if (role !== ADMIN_ROLE && userpermission === 0) {
                if ( ((typeof values.aplocked === 'boolean') && values.aplocked) || values.aplocked === 'T') {
                    showAlert(translator.formatMessage(MESSAGEMAP_ALERT['approvealertap'], {periodname : values.periodname}));
                    return;
                }
            }

            if (!document.forms['main_form'].onsubmit || document.forms['main_form'].onsubmit()) {

                if (!myRecord.getValue({fieldId : 'custpage_2663_payment_ref'})) {
                    showAlert(MESSAGEMAP_ALERT['refnote']);
                    return false;
                }

                var bankAccount = myRecord.getValue({fieldId : 'custpage_2663_bank_account'});
                var batchId = myRecord.getValue({fieldId : 'custpage_2663_batchid'});
                var approvalRoutingEnabled = myRecord.getValue({fieldId : 'custpage_2663_approval_routing'});

                if (approvalRoutingEnabled) {
                    finalURL =  (isGlobalPayment) ? '/app/common/search/searchresults.nl?searchid=customsearch_17801_global_paymnt_batches' : '/app/common/search/searchresults.nl?searchid=customsearch_2663_payment_batches';
                    
                    if (bankAccount && batchId) {
                        
                        var batch = record.load({type: 'customrecord_2663_file_admin', id: batchId});
                        var approvalAmount = myRecord.getValue({fieldId : 'custpage_2663_approval_amount'}) * 1;
                        var approvalLevel = batch.getValue({fieldId : 'custrecord_2663_approval_level'});
                        var approvalRoutingId = getApprovalRoutingId(bankAccount, approvalLevel);

                        if (approvalRoutingId) {
                            var paymentLimit = (search.lookupFields({type:'customrecord_2663_approval_routing', id: approvalRoutingId, columns:'custrecord_2663_ar_limit'}).custrecord_2663_ar_limit) * 1;
                            
                            if (paymentLimit && approvalAmount > paymentLimit) {

                                if (approvalLevel == constants.ApprovalLevels.APPROVAL_LEVEL3) {
                                    showAlert(MESSAGEMAP_ALERT['paymentlimit']);
                                } else if (upsertBatch(bankAccount, batchId)) {
                                    var nextLevel = (approvalLevel * 1) + 1;
                                    if (nextLevel <= constants.ApprovalLevels.APPROVAL_LEVEL3) {
                                        myRecord.setValue({fieldId : 'custpage_2663_edit_mode', value: false, ignoreFieldChange : true});
                                        batch = record.load({type: 'customrecord_2663_file_admin', id: batchId});
                                        batch.setValue({fieldId: 'custrecord_2663_approval_level', value: nextLevel});
                                        batch.save();
                                    }
                                }

                            } else if (upsertBatch(bankAccount, batchId)) {

                                finalURL = url.resolveScript({
                                    scriptId: 'customscript_15767_processor_bridge_su',
                                    deploymentId:  'customdeploy_15767_processor_bridge_su',
                                    returnExternalUrl: false,
                                });

                            }

                        } else {
                            showAlert(MESSAGEMAP_ALERT['incroutingsetup']);
                        }
                    }
                }
                else if (upsertBatch(bankAccount, batchId)) {
                    finalURL = url.resolveScript({
                        scriptId: 'customscript_15767_processor_bridge_su',
                        deploymentId:  'customdeploy_15767_processor_bridge_su',
                        returnExternalUrl: false,
                    });
                }

                document.forms.main_form.action = finalURL;
                // suppress the alert
                setWindowChanged(window, false);
                document.forms['main_form'].submit();
            }
        }

        /**
         * Reject and remove all transactions from Batch
         */
        function ep_Reject() {

            var batchId = myRecord.getValue({fieldId : 'custpage_2663_batchid'});
            if (batchId && rejectBatch(batchId)) {
                var finalURL = (isGlobalPayment) ? '/app/common/search/searchresults.nl?searchid=customsearch_17801_global_paymnt_batches' : '/app/common/search/searchresults.nl?searchid=customsearch_2663_payment_batches';
                // suppress the alert
                setWindowChanged(window, false);
                location.assign(finalURL);
            }
        }

        /**
         * Load page on Edit mode
         */
        function ep_Edit() {

            if(!checkVPA()){
                return false; //block process and return
            }
            
            myRecord.setValue({fieldId : 'custpage_2663_edit_mode', value: true, ignoreFieldChange: true});
            // set the refresh flag
            myRecord.setValue({fieldId : 'custpage_2663_refresh_page', value: 'T', ignoreFieldChange: true});

            refreshPage(myRecord);
            /*
            // suppress the alert
            setWindowChanged(window, false);

            // submit the form -- calls submitForm function
            document.forms.main_form.submit();
            
             */
        }

        function displayAlert(message) {
            dialog.alert({
                title: MESSAGEMAP_ALERT['alertlabel'],
                message: message
            });
        }


        function sendNotificationEmailPromise(emailRecipients, emailSubject, emailBody) {
            var emailSenderObj = runtime.getCurrentUser();
            var emailSender=emailSenderObj.id;
            var successCount= 0;
            var failedRecipients = [];
            var promises = [];

            emailRecipients.forEach(function(emailRecipient) {
                if (emailSender && emailRecipient && emailSubject && emailBody) {
                    var emailPromise = email.send.promise({
                        author: emailSender,
                        recipients: emailRecipient,
                        subject: emailSubject,
                        body: emailBody
                    })
                    .then(function () {
                        successCount++;
                    })
                    .catch(function (error) {
                        failedRecipients.push(emailRecipient);
                        console.error('Error in sending a mail', error);
                    })

                    //pushing each promise to an array, this helps to identify whether all promises are settled
                    promises.push(emailPromise);
                }
            });

            /**
             * This method is used to ensure that all promises are settled (either fulfilled or rejected) before proceeding.
             */
            Promise.allSettled(promises)
                .then(function(results) {
                    if (successCount === emailRecipients.length) {
                        displayAlert(MESSAGEMAP_ALERT['remindersuccessfullalert']);
                    }
                    else{
                        var failedRecipientsNames=[];
                        failedRecipients.forEach(function(employeeId){
                            var employeeName =  nssearch.lookupFields({
                                type : 'employee',
                                id : employeeId,
                                columns : 'entityid'
                            });
                            failedRecipientsNames.push(employeeName['entityid']);
                        })
                        var failedRecipientsList = failedRecipientsNames.join(", ");
                        var message = translator.formatMessage(MESSAGEMAP_ALERT['reminderfailedalert'], {
                            failedRecipients : failedRecipientsList
                        });
                        displayAlert(message);
                    }
                })
                .catch(function(error) {
                    console.error("Error in processing email promises", error);
                });
        }




        function ep_Remind(){
            //TODO Use N/ui/message confirm and handle the promise
            var dialogConfirm= confirm(MESSAGEMAP_ALERT['reminderwarning']);
            if(dialogConfirm){
                myRecord.setValue({fieldId : 'custpage_2663_refresh_page', value: 'T', ignoreFieldChange : true});
                var approvalRoutingEnabled = commonLib.isApprovalRoutingEnabled();
                var batchId = myRecord.getValue({fieldId: 'custpage_2663_batchid'});
                var batch = record.load({type: 'customrecord_2663_file_admin', id: batchId});
                if (approvalRoutingEnabled) {
                    if (batchId) {
                        var bankAcct = batch.getText({fieldId: 'custrecord_2663_bank_account'});
                        var scheme = 'https://';
                        var baseUrl = url.resolveDomain({
                            hostType: url.HostType.APPLICATION
                        });
                        baseUrl = scheme+baseUrl;
                        baseUrl = baseUrl.replace('extsystem', 'app');
                        var BATCH_SCRIPT_ID = 'customscript_15767_batch_selection_ap_su';
                        var BATCH_SCRIPT_DEPLOYMENT_ID = 'customdeploy_15767_batch_selection_ap_su';
                        var Url = [baseUrl, url.resolveScript({
                            scriptId: BATCH_SCRIPT_ID,
                            deploymentId: BATCH_SCRIPT_DEPLOYMENT_ID
                        }), '&custpage_2663_batchid=', batchId].join('');
                        var emailRecipients = myRecord.getValue({fieldId:'custpage_2663_batch_approver'});
                        var emailSubject = translator.formatMessage(MESSAGEMAP_ALERT['approvalsubject'], {
                            BATCH_ID: ("000000000" + batchId).substr(("000000000" + batchId).length - 8)
                        });
                        var batchName = batch.getValue("altname");
                        var totalAmount = (batch.getValue('custrecord_2663_total_amount') || 0) * 1;
                        var totalTransactions = batch.getValue('custrecord_2663_total_transactions');

                        var emailBody = translator.formatMessage(MESSAGEMAP_ALERT['approvalbody'], {
                            BATCH_NAME: batchName,
                            BANK_ACCT_NAME: bankAcct,
                            BATCH_TOTAL_AMOUNT: totalAmount,
                            BATCH_TOTAL_TRANSACTIONS: totalTransactions,
                            BATCH_APPROVE_URL: Url
                        });
                        sendNotificationEmailPromise(emailRecipients, emailSubject, emailBody);
                    }
                }
            }
        }

        //Issue 545485 - VPA Enhancement
        function checkVPA(){
            var result = !runtime.isVPAEnabled() || commonLib.getPreferenceDetails(['custrecord_ep_override_vpa']).getValue('custrecord_ep_override_vpa');
            if(!result){
                showAlert(MESSAGEMAP_ALERT['EP_00115']);
            }
            return result;
        }

        
        return {
            pageInit     : pageInit,
            fieldChanged : fieldChanged,
            //saveRecord   : saveRecord,
            markAllHandler   : markAllHandler,
            unmarkAllHandler : unmarkAllHandler,
            cancel       : cancel,
            ep_SubmitForm : ep_SubmitForm,
            ep_RecalcLines : ep_RecalcLines,
            ep_Save : ep_Save,
            ep_Approve : ep_Approve,
            ep_Reject : ep_Reject,
            ep_Edit : ep_Edit,
            ep_Remind : ep_Remind
        };

    });


/** [BEGIN] AMD Compatibility Suffix (Inserted By NetSuite) **/
} finally {
if (!nlapi.defineExists) define = undefined;
}
/** [END] AMD Compatibility Suffix (Inserted By NetSuite) **/