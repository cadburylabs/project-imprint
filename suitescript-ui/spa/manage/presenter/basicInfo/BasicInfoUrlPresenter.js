define('n/suitescript-ui/spa/manage/presenter/basicInfo/BasicInfoUrlPresenter', [
	'n/ui/classes/Class',
	'n/ui/classes/Object',
	'n/ui/classes/immutable/ImmutableObject',
	'n/ui/compounds/app/Presenter',
	'n/ui/widgets/Service',
	'n/ui/widgets/toolkit/StackPanel',
	'n/suitescript-ui/spa/ServiceList',
	'n/suitescript-ui/spa/manage/TranslationKeys',
	'n/suitescript-ui/spa/manage/common/Constants',
	'n/suitescript-ui/spa/manage/common/EditableUrlField',
	'n/suitescript-ui/spa/manage/common/FieldVisibilityHelper',
	'n/suitescript-ui/spa/manage/common/PermissionHelper',
	'n/suitescript-ui/spa/manage/common/UrlHelper',
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
	EditableUrlField,
	FieldVisibilityHelper,
	PermissionHelper,
	UrlHelper,
	SpaReducer,
	StateProps
) {
	'use strict';

	var BasicInfoUrlPresenter = Class.create({
		extend: Presenter,

		/**
		 * @class BasicInfoUrlPresenter
		 * @extends Presenter
		 */
		initialize: function BasicInfoUrlPresenter(options) {
			BasicInfoUrlPresenter.$super.call(this, options);
			this._spaService = this.context.services.get(ServiceList.SPA);
			this._helpService = this.context.services.get(Service.HELP);
		},

		/** @lends BasicInfoUrlPresenter# */
		properties: {},

		/** @lends BasicInfoUrlPresenter# */
		methods: {
			_getSpaUpdatedField: function (spa, updateField, value) {
				return ImmutableObject.set(spa, updateField, value);
			},

			_urlFormatter: function (text) {
				if (text !== '') {
					return text.toLowerCase();
				}
				return text;
			},

			_onSaveSuccess: function (value) {
				this.context.dispatchAction(SpaReducer.Action.SET_URL, value);
			},

			_onSave: function (value) {
				var title = this.i18n.get(PresenterConstants.FIELD_DETAILS.TITLE);
				var updatedSpaDetails = this._getSpaUpdatedField(
					this.state.manage.spa,
					StateProps.SPA.URL,
					value);
				return this._spaService.updateSpa(this.state.manage.spa.id, updatedSpaDetails, title)
					.then(this._onSaveSuccess.bind(this, value));
			},
			_createComponent: function () {
				var title = this.i18n.get(PresenterConstants.FIELD_DETAILS.TITLE);
				this._component = new EditableUrlField({
					automationId: AutomationIds.URL_FIELD,
					mandatory: true,
					title: title,
					selectedValue: this.state.manage.spa.url,
					urlPrefix: UrlHelper._getSpaBaseUrl(this.state.manage.spa.suiteAppId),
					maxLength: PresenterConstants.FIELD_DETAILS.MAX_LENGTH,
					onValidate: this._validateUrl.bind(this),
					formatter: this._urlFormatter,
					serverErrorProcessor: this._spaService.updateSpaGetSingleError.bind(this._spaService, title),
					onSave: this._onSave.bind(this),
					editable: FieldVisibilityHelper.isEditable(this.state.manage.spa) && PermissionHelper.userHasEditPermission(),
					helpService: this._helpService,
					fieldId: Constants.FLH.FIELD.SPA_URL,
					parentId: Constants.FLH.PARENT_ID,
				});

				this._placeholder.clear().add(this._component);
			},
			_validateUrl: function (spaUrl) {
				if (PresenterConstants.FIELD_DETAILS.INVALID_CHAR_REGEX_PATTERN.test(spaUrl)) {
					return this.i18n.get(PresenterConstants.FIELD_DETAILS.ERROR.INVALID_CHAR);
				}
				if (spaUrl === null || spaUrl === '') {
					return this.i18n.get(PresenterConstants.FIELD_DETAILS.ERROR.MANDATORY_FIELD);
				}

				return '';
			}
		},

		/** @lends BasicInfoUrlPresenter# */
		overrides: {
			_onCreateView: function () {
				this._placeholder = new StackPanel({orientation: StackPanel.Orientation.VERTICAL});
				this._createComponent();

				return this._placeholder;
			},

			_onStateChanged: function (old, current) {
				if (old.manage.spa.url !== current.manage.spa.url
					|| old.manage.spa.locked !== current.manage.spa.locked) {
					this._component = this._createComponent();
				}
			}
		},
		static: {
			AutomationIds: Object.freeze({
				URL_FIELD: "manage-spa-basic-info-url"
			}),
			Constants: Object.freeze({
				FIELD_DETAILS: Object.freeze({
					TITLE: TranslationKeys.SPA_MANAGE_FIELD_URL,
					MAX_LENGTH: 1000,
					INVALID_CHAR_REGEX_PATTERN: /[!*'();:@&=+$,/?#\[\]\s]/,
					ERROR: Object.freeze({
						MANDATORY_FIELD: TranslationKeys.SPA_MANAGE_MANDATORY_URL_ERROR,
						INVALID_CHAR: TranslationKeys.SPA_MANAGE_INVALID_URL_ERROR
					})
				})
			})
		}
	});

	var AutomationIds = BasicInfoUrlPresenter.AutomationIds;
	var PresenterConstants = BasicInfoUrlPresenter.Constants;

	return BasicInfoUrlPresenter;
});