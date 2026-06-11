define('n/suitescript-ui/spa/manage/presenter/basicInfo/BasicInfoNamePresenter', [
	'n/ui/classes/Class',
	'n/ui/classes/Object',
	'n/ui/classes/immutable/ImmutableObject',
	'n/ui/compounds/app/Presenter',
	'n/ui/widgets/Service',
	'n/ui/widgets/toolkit/StackPanel',
	'n/suitescript-ui/spa/ServiceList',
	'n/suitescript-ui/spa/manage/TranslationKeys',
	'n/suitescript-ui/spa/manage/common/Constants',
	'n/suitescript-ui/spa/manage/common/EditableTextField',
	'n/suitescript-ui/spa/manage/common/FieldVisibilityHelper',
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
	EditableTextField,
	FieldVisibilityHelper,
	PermissionHelper,
	SpaReducer,
	StateProps
) {
	'use strict';

	var BasicInfoNamePresenter = Class.create({
		extend: Presenter,

		/**
		 * @class BasicInfoNamePresenter
		 * @extends Presenter
		 */
		initialize: function BasicInfoNamePresenter(options) {
			BasicInfoNamePresenter.$super.call(this, options);
			this._spaService = this.context.services.get(ServiceList.SPA);
			this._helpService = this.context.services.get(Service.HELP);
		},

		/** @lends BasicInfoNamePresenter# */
		properties: {},

		/** @lends BasicInfoNamePresenter# */
		methods: {
			_getSpaUpdatedField: function (spa, updateField, value) {
				return ImmutableObject.set(spa, updateField, value);
			},
			_onSaveSuccess: function (value) {
				this.context.dispatchAction(SpaReducer.Action.SET_NAME, value);
			},
			_onSave: function (value) {
				var title = this.i18n.get(PresenterConstants.FIELD_DETAILS.TITLE);
				var updatedSpaDetails = this._getSpaUpdatedField(
					this.state.manage.spa,
					StateProps.SPA.NAME,
					value);
				return this._spaService.updateSpa(this.state.manage.spa.id, updatedSpaDetails, title)
					.then(this._onSaveSuccess.bind(this, value));
			},
			_createComponent: function () {
				var title = this.i18n.get(PresenterConstants.FIELD_DETAILS.TITLE);
				this._component = new EditableTextField({
					automationId: AutomationIds.NAME_FIELD,
					mandatory: true,
					title: title,
					selectedValue: this.state.manage.spa.name,
					maxLength: PresenterConstants.FIELD_DETAILS.MAX_LENGTH,
					onValidate: this._validateName.bind(this),
					serverErrorProcessor: this._spaService.updateSpaGetSingleError.bind(this._spaService, title),
					onSave: this._onSave.bind(this),
					editable: FieldVisibilityHelper.isEditable(this.state.manage.spa) && PermissionHelper.userHasEditPermission(),
					helpService: this._helpService,
					fieldId: Constants.FLH.FIELD.SPA_NAME,
					parentId: Constants.FLH.PARENT_ID
				});

				this._placeholder.clear().add(this._component);
			},
			_validateName: function (name) {
				if (name === null || name === '') {
					return this.i18n.get(PresenterConstants.FIELD_DETAILS.ERROR.MANDATORY_FIELD);
				}

				return '';
			}
		},

		/** @lends BasicInfoNamePresenter# */
		overrides: {
			_onCreateView: function () {
				this._placeholder = new StackPanel({orientation: StackPanel.Orientation.VERTICAL});
				this._createComponent();

				return this._placeholder;
			},
			_onStateChanged: function (old, current) {
				if (old.manage.spa.name !== current.manage.spa.name
					|| old.manage.spa.locked !== current.manage.spa.locked) {
					this._component = this._createComponent();
				}
			}
		},
		static: {
			AutomationIds: Object.freeze({
				NAME_FIELD: "manage-spa-basic-info-name"
			}),
			Constants: Object.freeze({
				FIELD_DETAILS: Object.freeze({
					TITLE: TranslationKeys.SPA_MANAGE_FIELD_NAME,
					MAX_LENGTH: 1000,
					ERROR: Object.freeze({
						MANDATORY_FIELD: TranslationKeys.SPA_MANAGE_MANDATORY_NAME_ERROR
					})
				})
			})
		}
	});

	var AutomationIds = BasicInfoNamePresenter.AutomationIds;
	var PresenterConstants = BasicInfoNamePresenter.Constants;

	return BasicInfoNamePresenter;
});