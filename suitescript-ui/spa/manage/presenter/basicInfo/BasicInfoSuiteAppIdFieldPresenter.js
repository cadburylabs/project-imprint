define('n/suitescript-ui/spa/manage/presenter/basicInfo/BasicInfoSuiteAppIdFieldPresenter', [
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

	var BasicInfoSuiteAppIdFieldPresenter = Class.create({
		extend: Presenter,

		/**
		 * @class BasicInfoSuiteAppIdFieldPresenter
		 * @extends Presenter
		 */
		initialize: function BasicInfoSuiteAppIdFieldPresenter(options) {
			BasicInfoSuiteAppIdFieldPresenter.$super.call(this, options);
			this._helpService = this.context.services.get(Service.HELP);
		},

		/** @lends BasicInfoSuiteAppIdFieldPresenter# */
		properties: {},

		/** @lends BasicInfoSuiteAppIdFieldPresenter# */
		methods: {
			_createContent: function () {
				this._content = new Text({
					text: this.state.manage.spa.suiteAppId,
					automationId: AutomationIds.SUITEAPPID_FIELD
				});

				return this._content;
			},
			_updateContent: function (value) {
				this._content.text = value;
			}
		},

		/** @lends BasicInfoSuiteAppIdFieldPresenter# */
		overrides: {
			_onCreateView: function () {
				return new ComponentWithHelp({
					component: this._createContent(),
					label: this.i18n.get(PresenterConstants.FIELD_DETAILS.TITLE),
					helpService: this._helpService,
					fieldId: Constants.FLH.FIELD.SPA_SUITEAPP_ID,
					labelPlacement: ComponentWithHelp.labelPlacement.TOP,
					type: ComponentWithHelp.TYPE.LABEL
				});
			},
			_onStateChanged: function (old, current) {
				if (old.manage.spa.suiteAppId != current.manage.spa.suiteAppId
						&& current.manage.spa.suiteAppId != null) {
					this._updateContent(current.manage.spa.suiteAppId);
				}
			}
		},
		static: {
			AutomationIds: Object.freeze({
				SUITEAPPID_FIELD: "manage-spa-basic-info-suiteapp-id"
			}),
			Constants: Object.freeze({
				FIELD_DETAILS: Object.freeze({
					TITLE: TranslationKeys.SPA_MANAGEMENT_FIELD_SUITEAPP_ID
				})
			})
		}
	});

	var PresenterConstants = BasicInfoSuiteAppIdFieldPresenter.Constants;
	var AutomationIds = BasicInfoSuiteAppIdFieldPresenter.AutomationIds;

	return BasicInfoSuiteAppIdFieldPresenter;
});