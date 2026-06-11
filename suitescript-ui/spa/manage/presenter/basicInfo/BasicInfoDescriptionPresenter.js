define('n/suitescript-ui/spa/manage/presenter/basicInfo/BasicInfoDescriptionPresenter', [
	'n/ui/classes/Class',
	'n/ui/classes/Object',
	'n/ui/classes/immutable/ImmutableObject',
	'n/ui/compounds/app/Presenter',
	'n/ui/widgets/Service',
	'n/ui/widgets/toolkit/StackPanel',
	'n/suitescript-ui/spa/ServiceList',
	'n/suitescript-ui/spa/manage/TranslationKeys',
	'n/suitescript-ui/spa/manage/common/Constants',
	'n/suitescript-ui/spa/manage/common/EditableTextAreaField',
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
	EditableTextAreaField,
	FieldVisibilityHelper,
	PermissionHelper,
	SpaReducer,
	StateProps
) {
	'use strict';

	var BasicInfoDescriptionPresenter = Class.create({
		extend: Presenter,

		/**
		 * @class BasicInfoDescriptionPresenter
		 * @extends Presenter
		 */
		initialize: function BasicInfoDescriptionPresenter(options) {
			BasicInfoDescriptionPresenter.$super.call(this, options);
			this._spaService = this.context.services.get(ServiceList.SPA);
			this._helpService = this.context.services.get(Service.HELP);
		},

		/** @lends BasicInfoDescriptionPresenter# */
		properties: {},

		/** @lends BasicInfoDescriptionPresenter# */
		methods: {
			_getSpaUpdatedField: function (spa, updateField, value) {
				return ImmutableObject.set(spa, updateField, value);
			},
			_onSaveSuccess:function (value) {
				this.context.dispatchAction(SpaReducer.Action.SET_DESCRIPTION, value);
			},
			_onSave: function (value) {
				var title = this.i18n.get(PresenterConstants.FIELD_DETAILS.TITLE);
				var updatedSpaDetails = this._getSpaUpdatedField(
					this.state.manage.spa,
					StateProps.SPA.DESCRIPTION,
					value);
				return this._spaService.updateSpa(this.state.manage.spa.id, updatedSpaDetails, title)
					.then(this._onSaveSuccess.bind(this, value));
			},
			_createComponent: function () {
				var title = this.i18n.get(PresenterConstants.FIELD_DETAILS.TITLE);
				this._component = new EditableTextAreaField({
					automationId: AutomationIds.DESCRIPTION_FIELD,
					title: title,
					selectedValue: this.state.manage.spa.description,
					maxLength: PresenterConstants.FIELD_DETAILS.MAX_LENGTH,
					serverErrorProcessor: this._spaService.updateSpaGetSingleError.bind(this._spaService, title),
					onSave: this._onSave.bind(this),
					editable: FieldVisibilityHelper.isEditable(this.state.manage.spa) && PermissionHelper.userHasEditPermission(),
					helpService: this._helpService,
					fieldId: Constants.FLH.FIELD.SPA_DESCRIPTION,
					parentId: Constants.FLH.PARENT_ID
				});

				this._placeholder.clear().add(this._component);
			}
		},

		/** @lends BasicInfoDescriptionPresenter# */
		overrides: {
			_onCreateView: function () {
				this._placeholder = new StackPanel({orientation: StackPanel.Orientation.VERTICAL});
				this._createComponent();

				return this._placeholder;
			},
			_onStateChanged: function (old, current) {
				if (old.manage.spa.description !== current.manage.spa.description
				|| old.manage.spa.locked !== current.manage.spa.locked) {
					this._component = this._createComponent();
				}
			}
		},
		static: {
			AutomationIds: Object.freeze({
				DESCRIPTION_FIELD: "manage-spa-basic-info-description"
			}),
			Constants: Object.freeze({
				FIELD_DETAILS: Object.freeze({
					TITLE: TranslationKeys.SPA_MANAGE_FIELD_DESCRIPTION,
					MAX_LENGTH: 1000
				})
			})
		}
	});

	var AutomationIds = BasicInfoDescriptionPresenter.AutomationIds;
	var PresenterConstants = BasicInfoDescriptionPresenter.Constants;

	return BasicInfoDescriptionPresenter;
});