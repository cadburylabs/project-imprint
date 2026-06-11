define('n/suitescript-ui/spa/manage/presenter/configuration/ConfigurationExecuteAsPresenter', [
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

	var ConfigurationExecuteAsPresenter = Class.create({
		extend: Presenter,

		/**
		 * @class ConfigurationExecuteAsPresenter
		 * @extends Presenter
		 */
		initialize: function ConfigurationExecuteAsPresenter(options) {
			ConfigurationExecuteAsPresenter.$super.call(this, options);
			this._rolesService = this.context.services.get(ServiceList.ROLES);
			this._spaService = this.context.services.get(ServiceList.SPA);
			this._helpService = this.context.services.get(Service.HELP);
		},

		/** @lends ConfigurationExecuteAsPresenter# */
		properties: {},

		/** @lends ConfigurationExecuteAsPresenter# */
		methods: {
			_loadRolesAndComponent: function () {
				var that = this;
				if (this.state.manage.spa.scriptDeploymentId != "") {
					this._rolesService.getExecuteAsRoleList(this.state.manage.spa.scriptDeploymentId)
						.then(function (roles) {
							that._createComponent(roles);
						});
				} else {
					return that._createComponent([]);
				}
			},

			_getSpaUpdatedField: function (spa, updateField, value) {
				return ImmutableObject.set(spa, updateField, value);
			},
			_serverErrorProcessor: function (response) {
				return response.response.validationErrors[0].message;
			},
			_onSaveSuccess: function (value) {
				this.context.dispatchAction(SpaReducer.Action.SET_EXECROLE, value);
			},
			_onSave: function (value) {
				var title = this.i18n.get(PresenterConstants.FIELD_DETAILS.title);
				var updatedSpaDetails = this._getSpaUpdatedField(
					this.state.manage.spa,
					StateProps.SPA.EXECUTE_AS_ROLE,
					value);
				return this._spaService.updateSpa(this.state.manage.spa.id, updatedSpaDetails, title)
					.then(this._onSaveSuccess.bind(this, value));
			},
			_createComponent: function (roles) {

				this._component = new EditableDropDownComponent({
					automationId: AutomationIds.EXECUTE_AS_ROLE_FIELD,
					title: this.i18n.get(PresenterConstants.FIELD_DETAILS.title),
					selectedValue: this.state.manage.spa.executeAsRoleId,
					source: roles,
					valueMember: PresenterConstants.FIELD_DETAILS.valueMember,
					displayMember: PresenterConstants.FIELD_DETAILS.displayMember,
					editable: PermissionHelper.userHasEditPermission(),
					serverErrorProcessor: this._serverErrorProcessor,
					onSave: this._onSave.bind(this),
					helpService: this._helpService,
					fieldId: Constants.FLH.FIELD.SPA_EXECUTE_AS,
					parentId: Constants.FLH.PARENT_ID
				});
				this._placeholder.clear().add(this._component);

				this._placeholder.clear().add(this._component);
			}
		},

		/** @lends ConfigurationExecuteAsPresenter# */
		overrides: {
			_onCreateView: function () {
				this._placeholder = new StackPanel({orientation: StackPanel.Orientation.VERTICAL});
				this._loadRolesAndComponent();
				return this._placeholder;
			},
			_onStateChanged: function (old, current) {
				if (old.manage.spa.scriptDeploymentId !== current.manage.spa.scriptDeploymentId
					|| old.manage.spa.executeAsRoleId !== current.manage.spa.executeAsRoleId) {
					this._loadRolesAndComponent();
				}
			}
		},
		static: {
			AutomationIds: Object.freeze({
				EXECUTE_AS_ROLE_FIELD: "manage-spa-configuration-execute-as-role"
			}),
			Constants: Object.freeze({
				FIELD_DETAILS: Object.freeze({
					title: TranslationKeys.SPA_MANAGE_FIELD_EXECUTE_AS,
					valueMember: "id",
					displayMember: "value"
				})
			})
		}
	});

	var AutomationIds = ConfigurationExecuteAsPresenter.AutomationIds;
	var PresenterConstants = ConfigurationExecuteAsPresenter.Constants;

	return ConfigurationExecuteAsPresenter;
});