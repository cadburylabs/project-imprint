define('n/suitescript-ui/spa/manage/presenter/basicInfo/BasicInfoSuiteAppFieldPresenter', [
	'n/ui/classes/Class',
	'n/ui/classes/Object',
	'n/ui/compounds/app/Presenter',
	'n/ui/widgets/Service',
	'n/ui/widgets/toolkit/StackPanel',
	'n/suitescript-ui/spa/ServiceList',
	'n/suitescript-ui/spa/manage/TranslationKeys',
	'n/suitescript-ui/spa/manage/common/Constants',
	'n/suitescript-ui/spa/manage/common/EditableDropDownComponent',
	'n/suitescript-ui/spa/manage/reducer/BasicInfoReducer'
], function (
	Class,
	Object,
	Presenter,
	Service,
	StackPanel,
	ServiceList,
	TranslationKeys,
	Constants,
	EditableDropDownComponent,
	BasicInfoReducer
) {
	'use strict';

	var BasicInfoSuiteAppFieldPresenter = Class.create({
		extend: Presenter,

		/**
		 * @class BasicInfoSuiteAppFieldPresenter
		 * @extends Presenter
		 */
		initialize: function BasicInfoSuiteAppFieldPresenter(options) {
			BasicInfoSuiteAppFieldPresenter.$super.call(this, options);
			this._suiteappService = this.context.services.get(ServiceList.SUITEAPP);
			this._helpService = this.context.services.get(Service.HELP);
		},

		/** @lends BasicInfoSuiteAppFieldPresenter# */
		properties: {},

		/** @lends BasicInfoSuiteAppFieldPresenter# */
		methods: {
			_loadSuiteAppList: function () {
				this._suiteappService.getSuiteAppList()
					.then(this._suiteAppListLoaded.bind(this))
			},
			_suiteAppListLoaded: function (response) {
				this.dispatchAction(BasicInfoReducer.Action.SET_SUITEAPP, response.response);
			},
			_onSave: function () {
				console.log("SAVE!");
			},
			_onError: function (response) {
				console.log(response);
				return "Some Error";
			},
			_createComponent: function (suiteappList) {
				this._component = new EditableDropDownComponent({
					automationId: AutomationIds.SUITEAPP_FIELD,
					title: this.i18n.get(PresenterConstants.FIELD_DETAILS.TITLE),
					selectedValue: this.state.manage.spa.suiteAppId,
					source: suiteappList,
					valueMember: PresenterConstants.FIELD_DETAILS.VALUE_MEMBER,
					displayMember: PresenterConstants.FIELD_DETAILS.DISPLAY_MEMBER,
					editable: false, //TODO: Set editable true for enabling editing the field
					serverErrorProcessor: this._onError,
					onSave: this._onSave.bind(this),
					helpService: this._helpService,
					fieldId: Constants.FLH.FIELD.SPA_SUITEAPP,
					parentId: Constants.FLH.PARENT_ID,
				});

				this._placeholder.clear().add(this._component);
			}
		},

		/** @lends BasicInfoSuiteAppFieldPresenter# */
		overrides: {
			_onCreateView: function () {
				this._placeholder = new StackPanel({orientation: StackPanel.Orientation.VERTICAL});
				this._loadSuiteAppList();

				return this._placeholder;
			},
			_onStateChanged: function (old, current) {
				if (old.manage.basicInfo.suiteappList !== current.manage.basicInfo.suiteappList
						|| old.manage.spa.suiteAppId !== current.manage.spa.suiteAppId
						&& current.manage.basicInfo.suiteappList !== []
						&& current.manage.spa.suiteAppId !== '') {
					this._createComponent(current.manage.basicInfo.suiteappList)
				}
			}
		},
		static: {
			AutomationIds: Object.freeze({
				SUITEAPP_FIELD: "manage-spa-basic-info-suiteapp"
			}),
			Constants: Object.freeze({
				FIELD_DETAILS: Object.freeze({
					TITLE: TranslationKeys.SPA_MANAGEMENT_FIELD_SUITEAPP,
					VALUE_MEMBER: "appId",
					DISPLAY_MEMBER: "projectName"
				})
			})
		}
	});

	var PresenterConstants = BasicInfoSuiteAppFieldPresenter.Constants;
	var AutomationIds = BasicInfoSuiteAppFieldPresenter.AutomationIds;

	return BasicInfoSuiteAppFieldPresenter;
});