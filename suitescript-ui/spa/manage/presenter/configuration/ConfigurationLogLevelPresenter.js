define('n/suitescript-ui/spa/manage/presenter/configuration/ConfigurationLogLevelPresenter', [
	'n/ui/classes/Class',
	'n/ui/classes/Object',
	'n/ui/classes/immutable/ImmutableObject',
	'n/ui/compounds/app/Presenter',
	'n/ui/widgets/Service',
	'n/ui/widgets/toolkit/StackPanel',
	'n/suitescript-ui/spa/ServiceList',
	'n/suitescript-ui/spa/manage/TranslationKeys',
	'n/suitescript-ui/spa/manage/common/Constants',
	'n/suitescript-ui/spa/manage/common/EditableDropDownComponent',
	'n/suitescript-ui/spa/manage/common/PermissionHelper',
	'n/suitescript-ui/spa/manage/reducer/SpaReducer',
	'n/suitescript-ui/spa/manage/reducer/StateProps'
], function (
	Class,
	Object,
	ImmutableObject,
	Presenter,
	Service,
	StackPanel,
	ServiceList,
	TranslationKeys,
	Constants,
	EditableDropDownComponent,
	PermissionHelper,
	SpaReducer,
	StateProps
) {
	'use strict';

	var ConfigurationLogLevelPresenter = Class.create({
		extend: Presenter,

		/**
		 * @class ConfigurationLogLevelPresenter
		 * @extends Presenter
		 */
		initialize: function ConfigurationLogLevelPresenter(options) {
			ConfigurationLogLevelPresenter.$super.call(this, options);
			this._logLevelsService = this.context.services.get(ServiceList.LOG_LEVELS);
			this._spaService = this.context.services.get(ServiceList.SPA);
			this._helpService = this.context.services.get(Service.HELP);
		},

		/** @lends ConfigurationLogLevelPresenter# */
		properties: {},

		/** @lends ConfigurationLogLevelPresenter# */
		methods: {
			_loadLogLevelListRecord: function () {
				var that = this;
				if (this.state.manage.spa.scriptDeploymentId != "") {
					this._logLevelsService.getLogLevelList(this.state.manage.spa.scriptDeploymentId)
						.then(function (ajaxResponse) {
							that._createComponent(ajaxResponse.response);
						});
				} else {
					return that._createComponent([]);
				}
			},

			_getSpaUpdatedField: function (spa, updateField, value) {
				return ImmutableObject.set(spa, updateField, value);
			},
			_onSaveSuccess: function (value) {
				this.context.dispatchAction(SpaReducer.Action.SET_LOGLEVEL, value);
			},
			_onSave: function (value) {
				var title = this.i18n.get(PresenterConstants.FIELD_DETAILS.title);
				var updatedSpaDetails = this._getSpaUpdatedField(
					this.state.manage.spa,
					StateProps.SPA.LOG_LEVEL,
					value);
				return this._spaService.updateSpa(this.state.manage.spa.id, updatedSpaDetails, title)
					.then(this._onSaveSuccess.bind(this, value));
			},
			_createComponent: function (logLevels) {
				var title = this.i18n.get(PresenterConstants.FIELD_DETAILS.title);
				this._component = new EditableDropDownComponent({
					automationId: AutomationIds.LOG_LEVEL_FIELD,
					title: title,
					selectedValue: this.state.manage.spa.logLevelId,
					source: logLevels,
					valueMember: PresenterConstants.FIELD_DETAILS.valueMember,
					displayMember: PresenterConstants.FIELD_DETAILS.displayMember,
					editable: PermissionHelper.userHasEditPermission(),
					serverErrorProcessor: this._spaService.updateSpaGetSingleError.bind(this._spaService, title),
					onSave: this._onSave.bind(this),
					helpService: this._helpService,
					fieldId: Constants.FLH.FIELD.SPA_LOG_LEVEL,
					parentId: Constants.FLH.PARENT_ID
				});

				this._placeholder.clear().add(this._component);
			}
		},

		/** @lends ConfigurationLogLevelPresenter# */
		overrides: {
			_onCreateView: function () {
				this._placeholder = new StackPanel({orientation: StackPanel.Orientation.VERTICAL});
				this._loadLogLevelListRecord();
				return this._placeholder;
			},
			_onStateChanged: function (old, current) {
				if (old.manage.spa.scriptDeploymentId !== current.manage.spa.scriptDeploymentId
					|| old.manage.spa.logLevelId !== current.manage.spa.logLevelId) {
					this._loadLogLevelListRecord();
				}
			}
		},
		static: {
			AutomationIds: Object.freeze({
				LOG_LEVEL_FIELD: "manage-spa-configuration-log-level"
			}),
			Constants: Object.freeze({
				FIELD_DETAILS: Object.freeze({
					title: TranslationKeys.SPA_MANAGE_FIELD_LOG_LEVEL,
					valueMember: "id",
					displayMember: "value"
				})
			})
		}
	});

	var AutomationIds = ConfigurationLogLevelPresenter.AutomationIds;
	var PresenterConstants = ConfigurationLogLevelPresenter.Constants;

	return ConfigurationLogLevelPresenter;
});