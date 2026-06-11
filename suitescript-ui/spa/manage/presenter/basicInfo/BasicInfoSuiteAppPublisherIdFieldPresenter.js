define('n/suitescript-ui/spa/manage/presenter/basicInfo/BasicInfoSuiteAppPublisherIdFieldPresenter', [
	'n/ui/classes/Class',
	'n/ui/classes/Object',
	'n/ui/compounds/app/Presenter',
	'n/ui/widgets/Service',
	'n/ui/widgets/toolkit/Text',
	'n/suitescript-ui/spa/manage/TranslationKeys',
	'n/suitescript-ui/spa/manage/common/ComponentWithHelp',
	'n/suitescript-ui/spa/manage/common/Constants'
], function (
	Class,
	Object,
	Presenter,
	Service,
	Text,
	TranslationKeys,
	ComponentWithHelp,
	Constants
) {
	'use strict';

	var BasicInfoSuiteAppPublisherIdFieldPresenter = Class.create({
		extend: Presenter,

		/**
		 * @class BasicInfoSuiteAppPublisherIdFieldPresenter
		 * @extends Presenter
		 */
		initialize: function BasicInfoSuiteAppPublisherIdFieldPresenter(options) {
			BasicInfoSuiteAppPublisherIdFieldPresenter.$super.call(this, options);
			this._helpService = this.context.services.get(Service.HELP);
		},

		/** @lends BasicInfoSuiteAppPublisherIdFieldPresenter# */
		properties: {},

		/** @lends BasicInfoSuiteAppPublisherIdFieldPresenter# */
		methods: {
			_createContent: function () {
				this._content = new Text({
					text: this.state.manage.spa.suiteAppId,
					automationId: AutomationIds.SUITEAPP_PUBLISHERID_FIELD
				});
				this._updateContent(this.state.manage.spa.suiteAppId, this.state.manage.basicInfo.suiteappList);
				return this._content;
			},
			_updateContent: function (suiteAppId, suiteAppList) {
				var suiteApp = suiteAppList.find(function(suiteApp) {return suiteApp.appId === suiteAppId});
				if(suiteApp)
					this._content.text = suiteApp.appId.split('.').slice(0,2).join('.');
			}
		},

		/** @lends BasicInfoSuiteAppPublisherIdFieldPresenter# */
		overrides: {
			_onCreateView: function () {
				return new ComponentWithHelp({
					component: this._createContent(),
					label: this.i18n.get(PresenterConstants.FIELD_DETAILS.TITLE),
					helpService: this._helpService,
					fieldId: Constants.FLH.FIELD.SPA_SUITEAPP_PUBLISHER_ID,
					labelPlacement: ComponentWithHelp.labelPlacement.TOP,
					type: ComponentWithHelp.TYPE.LABEL
				});
			},
			_onStateChanged: function (old, current) {
				if (old.manage.basicInfo.suiteappList !== current.manage.basicInfo.suiteappList
					|| old.manage.spa.suiteAppId !== current.manage.spa.suiteAppId
					&& current.manage.basicInfo.suiteappList !== []
					&& current.manage.spa.suiteAppId !== '') {
					this._updateContent(current.manage.spa.suiteAppId, current.manage.basicInfo.suiteappList);
				}
			}
		},
		static: {
			AutomationIds: Object.freeze({
				SUITEAPP_PUBLISHERID_FIELD: "manage-spa-basic-info-suiteapp-publisherid"
			}),
			Constants: Object.freeze({
				FIELD_DETAILS: Object.freeze({
					TITLE: TranslationKeys.SPA_MANAGEMENT_FIELD_SUITEAPP_PUBLISHER_ID
				})
			})
		}
	});

	var PresenterConstants = BasicInfoSuiteAppPublisherIdFieldPresenter.Constants;
	var AutomationIds = BasicInfoSuiteAppPublisherIdFieldPresenter.AutomationIds;

	return BasicInfoSuiteAppPublisherIdFieldPresenter;
});