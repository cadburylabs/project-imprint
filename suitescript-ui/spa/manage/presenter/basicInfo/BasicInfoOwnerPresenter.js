define('n/suitescript-ui/spa/manage/presenter/basicInfo/BasicInfoOwnerPresenter', [
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
	SpaReducer,
	StateProps
) {
	'use strict';

	var BasicInfoOwnerPresenter = Class.create({
		extend: Presenter,

		/**
		 * @class BasicInfoOwnerPresenter
		 * @extends Presenter
		 */
		initialize: function BasicInfoOwnerPresenter(options) {
			BasicInfoOwnerPresenter.$super.call(this, options);
			this._scriptRecordService = this.context.services.get(ServiceList.USER);
			this._spaService = this.context.services.get(ServiceList.SPA);
			this._helpService = this.context.services.get(Service.HELP);
		},

		/** @lends BasicInfoOwnerPresenter# */
		properties: {},

		/** @lends BasicInfoOwnerPresenter# */
		methods: {
			_loadOwnerListAndComponent: function () {
				var that = this;
				if (this.state.manage.spa.scriptId != "") {
					this._scriptRecordService.getOwnerList(this.state.manage.spa.scriptId)
						.then(function (ownerListResponse) {
							that._createComponent(ownerListResponse.response);
						});
				} else {
					return that._createComponent([]);
				}
			},

			_getSpaUpdatedField: function (spa, updateField, value) {
				return ImmutableObject.set(spa, updateField, value);
			},

			_onSaveSuccess: function (value) {
				this.context.dispatchAction(SpaReducer.Action.SET_OWNERID, value);
			},
			_onSave: function (value) {
				var title = this.i18n.get(PresenterConstants.FIELD_DETAILS.TITLE);
				var updatedSpaDetails = this._getSpaUpdatedField(
					this.state.manage.spa,
					StateProps.SPA.OWNER,
					value);
				return this._spaService.updateSpa(this.state.manage.spa.id, updatedSpaDetails, title)
					.then(this._onSaveSuccess.bind(this, value));
			},

			_createComponent: function (owners) {
				var title = this.i18n.get(PresenterConstants.FIELD_DETAILS.TITLE);
				this._component = new EditableDropDownComponent({
					automationId: AutomationIds.OWNER_FIELD,
					title: title,
					selectedValue: this.state.manage.spa.ownerId,
					source: owners,
					valueMember: PresenterConstants.FIELD_DETAILS.VALUE_MEMBER,
					displayMember: PresenterConstants.FIELD_DETAILS.DISPLAY_MEMBER,
					editable: false,
					serverErrorProcessor: this._spaService.updateSpaGetSingleError.bind(this._spaService, title),
					onSave: this._onSave.bind(this),
					helpService: this._helpService,
					fieldId: Constants.FLH.FIELD.SPA_OWNER,
					parentId: Constants.FLH.PARENT_ID
				});

				this._placeholder.clear().add(this._component);
			}
		},

		/** @lends BasicInfoOwnerPresenter# */
		overrides: {
			_onCreateView: function () {
				this._placeholder = new StackPanel({orientation: StackPanel.Orientation.VERTICAL});
				this._loadOwnerListAndComponent();
				return this._placeholder;
			},
			_onStateChanged: function (old, current) {
				if (old.manage.spa.ownerId !== current.manage.spa.ownerId
					|| old.manage.spa.locked !== current.manage.spa.locked) {
					this._loadOwnerListAndComponent();
				}
			}
		},
		static: {
			AutomationIds: Object.freeze({
				OWNER_FIELD: "manage-spa-basic-info-owner"
			}),
			Constants: Object.freeze({
				FIELD_DETAILS: Object.freeze({
					TITLE: TranslationKeys.SPA_MANAGE_FIELD_OWNER,
					VALUE_MEMBER: "id",
					DISPLAY_MEMBER: "value"
				})
			})
		}
	});

	var AutomationIds = BasicInfoOwnerPresenter.AutomationIds;
	var PresenterConstants = BasicInfoOwnerPresenter.Constants;

	return BasicInfoOwnerPresenter;
});