define('n/suitescript-ui/spa/manage/presenter/basicInfo/BasicInfoIdPresenter', [
	'n/ui/classes/Class',
	'n/ui/classes/Object',
	'n/ui/classes/immutable/ImmutableObject',
	'n/ui/compounds/app/Presenter',
	'n/ui/widgets/Service',
	'n/ui/widgets/toolkit/StackPanel',
	'n/suitescript-ui/spa/RouteList',
	'n/suitescript-ui/spa/ServiceList',
	'n/suitescript-ui/spa/manage/TranslationKeys',
	'n/suitescript-ui/spa/manage/common/Constants',
	'n/suitescript-ui/spa/manage/common/EditableTextField',
	'n/suitescript-ui/spa/manage/common/FieldVisibilityHelper',
	'n/suitescript-ui/spa/manage/common/PermissionHelper',
	'n/suitescript-ui/spa/manage/reducer/StateProps'
], function (
	Class,
	Object,
	ImmutableObject,
	Presenter,
	Service,
	StackPanel,
	RouteList,
	ServiceList,
	TranslationKeys,
	Constants,
	EditableTextField,
	FieldVisibilityHelper,
	PermissionHelper,
	StateProps
) {
	'use strict';

	var BasicInfoIdPresenter = Class.create({
		extend: Presenter,

		/**
		 * @class BasicInfoIdPresenter
		 * @extends Presenter
		 */
		initialize: function BasicInfoIdPresenter(options) {
			BasicInfoIdPresenter.$super.call(this, options);
			this._spaService = this.context.services.get(ServiceList.SPA);
			this._helpService = this.context.services.get(Service.HELP);
		},

		/** @lends BasicInfoIdPresenter# */
		properties: {},

		/** @lends BasicInfoIdPresenter# */
		methods: {
			_getSpaUpdatedField: function (spa, updateField, value) {
				return ImmutableObject.set(spa, updateField, value);
			},
			_removePrefix: function (value) {
				return value.replace(PresenterConstants.FIELD_DETAILS.PREFIX, "");
			},
			_addPrefix: function (value) {
				return PresenterConstants.FIELD_DETAILS.PREFIX + value;
			},

			_idFormatter: function (text) {
				if (text !== '') {
					return text.toLowerCase();
				}
				return text;
			},
			_onSaveSuccess: function (newSpaId) {
				var router = this.context.services.get(ServiceList.ROUTER);
				router.redirectTo(RouteList.MANAGE_BASIC_INFO, {id: newSpaId});
			},
			_onSave: function (value) {
				var title = this.i18n.get(PresenterConstants.FIELD_DETAILS.TITLE);
				var newSpaId = this._addPrefix(value);
				var updatedSpaDetails = this._getSpaUpdatedField(
					this.state.manage.spa,
					StateProps.SPA.ID,
					newSpaId);
				return this._spaService.updateSpa(this.state.manage.spa.id, updatedSpaDetails, title)
					.then(this._onSaveSuccess.bind(this, newSpaId));
			},
			_createComponent: function () {
				var title = this.i18n.get(PresenterConstants.FIELD_DETAILS.TITLE);
				this._component = new EditableTextField({
					automationId: AutomationIds.ID_FIELD,
					mandatory: true,
					title: title,
					selectedValue: this._removePrefix(this.state.manage.spa.id),
					prefix: PresenterConstants.FIELD_DETAILS.PREFIX,
					maxLength: PresenterConstants.FIELD_DETAILS.MAX_LENGTH,
					onValidate: this._validateId.bind(this),
					formatter: this._idFormatter,
					serverErrorProcessor: this._spaService.updateSpaGetSingleError.bind(this._spaService, title),
					onSave: this._onSave.bind(this),
					editable : FieldVisibilityHelper.isEditable(this.state.manage.spa) && PermissionHelper.userHasEditPermission(),
					helpService: this._helpService,
					fieldId: Constants.FLH.FIELD.SPA_ID,
					parentId: Constants.FLH.PARENT_ID,
				});

				this._placeholder.clear().add(this._component);
			},
			_validateId: function (spaId) {
				if (PresenterConstants.FIELD_DETAILS.INVALID_CHAR_REGEX_PATTERN.test(spaId)) {
					return this.i18n.get(PresenterConstants.FIELD_DETAILS.ERROR.INVALID_CHAR);
				}

				if (spaId === null || spaId === '') {
					return this.i18n.get(PresenterConstants.FIELD_DETAILS.ERROR.MANDATORY_FIELD);
				}

				return '';
			}
		},

		/** @lends BasicInfoIdPresenter# */
		overrides: {
			_onCreateView: function () {
				this._placeholder = new StackPanel({orientation: StackPanel.Orientation.VERTICAL});
				this._createComponent();

				return this._placeholder;
			},
			_onStateChanged: function (old, current) {
				if (old.manage.spa.id !== current.manage.spa.id
					|| old.manage.spa.locked !== current.manage.spa.locked) {
					this._component = this._createComponent();
				}
			}
		},
		static: {
			AutomationIds: Object.freeze({
				ID_FIELD: "manage-spa-basic-info-id",
			}),
			Constants: Object.freeze({
				FIELD_DETAILS: Object.freeze({
					TITLE: TranslationKeys.SPA_MANAGE_FIELD_ID,
					PREFIX: "custspa_",
					MAX_LENGTH: 20,
					INVALID_CHAR_REGEX_PATTERN: /[^\w_\d]/,
					ERROR: Object.freeze({
						MANDATORY_FIELD: TranslationKeys.SPA_MANAGE_MANDATORY_ID_ERROR,
						INVALID_CHAR: TranslationKeys.SPA_MANAGE_INVALID_ID_ERROR
					})
				})
			})
		}
	});

	var AutomationIds = BasicInfoIdPresenter.AutomationIds;
	var PresenterConstants = BasicInfoIdPresenter.Constants;

	return BasicInfoIdPresenter;
});