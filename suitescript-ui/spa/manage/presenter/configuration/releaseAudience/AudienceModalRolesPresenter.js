define('n/suitescript-ui/spa/manage/presenter/configuration/releaseAudience/AudienceModalRolesPresenter', [
	'n/ui/classes/Class',
	'n/ui/classes/Object',
	'n/ui/compounds/app/Presenter',
	'n/ui/compounds/component/ShuttleUI',
	'n/ui/widgets/Service',
	'n/ui/widgets/data/ArrayDataSource',
	'n/ui/widgets/toolkit/CheckBox',
	'n/ui/widgets/toolkit/Heading',
	'n/ui/widgets/toolkit/Divider',
	'n/ui/widgets/toolkit/StackPanel',
	'n/ui/widgets/toolkit/layout/GapSize',
	'n/suitescript-ui/spa/manage/TranslationKeys',
	'n/suitescript-ui/spa/manage/common/ComponentWithHelp',
	'n/suitescript-ui/spa/manage/common/Constants',
	'n/suitescript-ui/spa/manage/reducer/SpaAudienceReducer',
	'n/suitescript-ui/spa/manage/reducer/StateProps'
], function(
	Class,
	Object,
	Presenter,
	ShuttleUI,
	Service,
	ArrayDataSource,
	CheckBox,
	Heading,
	Divider,
	StackPanel,
	GapSize,
	TranslationKeys,
	ComponentWithHelp,
	Constants,
	SpaAudienceReducer,
	StateProps
) {
	'use strict';

	var AudienceModalRolesPresenter = Class.create({
		extend: Presenter,

		/**
		 * @class AudienceModalRolesPresenter
		 * @extends Presenter
		 */
		initialize: function AudienceModalRolesPresenter(options) {
			this.constructor.$super.call(this, options);
			this._helpService = this.context.services.get(Service.HELP);
		},

		/** @lends AudienceModalRolesPresenter# */
		properties: {},

		/** @lends AudienceModalRolesPresenter# */
		methods: {
			_createAllRolesCheckbox: function () {
				this._allRolesCheckBox = new CheckBox({
					automationId: AutomationIds.MODAL_ALL_ROLES_CHECKBOX,
					on: {
						toggled: this._allRolesCheckboxToggled.bind(this)
					}
				});

				return new ComponentWithHelp({
					component: this._allRolesCheckBox,
					label: this.i18n.get(PresenterConstants.FIELD_DETAILS.ALL_ROLES_CHECKBOX_LABEL),
					helpService: this._helpService,
					fieldId: Constants.FLH.FIELD.SPA_AUDIENCE_ALL_ROLES
				});
			},
			_allRolesCheckboxToggled: function (checkbox) {
				if(checkbox.reason === 'click')
					this.dispatchAction(SpaAudienceReducer.Action.ALL_ROLES_TOGGLED, checkbox.currentToggle)
			},
			_createEmptyInternalRolesShuttleSelector: function () {
				this._internalRolesShuttleSelector = new ShuttleUI({
					automationId: AutomationIds.MODAL_INTERNAL_ROLES_SHUTTLE,
					sourceDataSource: new ArrayDataSource([]),
					sourceValueMember: PresenterConstants.FIELD_DETAILS.VALUE_MEMBER,
					sourceDisplayMember: PresenterConstants.FIELD_DETAILS.DISPLAY_MEMBER,
					targetDataSource: new ArrayDataSource([]),
					targetValueMember: PresenterConstants.FIELD_DETAILS.VALUE_MEMBER,
					targetDisplayMember: PresenterConstants.FIELD_DETAILS.DISPLAY_MEMBER,
					rootStyle: { maxHeight: '200px' }
				});
				this._internalRolesShuttleSelector.on(ShuttleUI.Event.SELECTION_CHANGED, this._internalRolesShuttleSelectorSelectionChanged.bind(this));

				return this._internalRolesShuttleSelector;
			},
			_createEmptyExternalRolesShuttleSelector: function () {
				this._externalRolesShuttleSelector = new ShuttleUI({
					automationId: AutomationIds.MODAL_EXTERNAL_ROLES_SHUTTLE,
					sourceDataSource: new ArrayDataSource([]),
					sourceValueMember: PresenterConstants.FIELD_DETAILS.VALUE_MEMBER,
					sourceDisplayMember: PresenterConstants.FIELD_DETAILS.DISPLAY_MEMBER,
					targetDataSource: new ArrayDataSource([]),
					targetValueMember: PresenterConstants.FIELD_DETAILS.VALUE_MEMBER,
					targetDisplayMember: PresenterConstants.FIELD_DETAILS.DISPLAY_MEMBER,
					rootStyle: { maxHeight: '200px' }
				});
				this._externalRolesShuttleSelector.on(ShuttleUI.Event.SELECTION_CHANGED, this._externalRolesShuttleSelectorSelectionChanged.bind(this));

				return this._externalRolesShuttleSelector;
			},

			_createInternalShuttleLabel: function() {
				this._internalShuttleLabel = new Heading({
					content: this.i18n.get(PresenterConstants.FIELD_DETAILS.INTERNAL_ROLES_SHUTTLE_LABEL),
					type: Heading.Type.MEDIUM_HEADING
				});

				return this._internalShuttleLabel;
			},

			_createExternalShuttleLabel: function() {
				this._externalShuttleLabel = new Heading({
					content: this.i18n.get(PresenterConstants.FIELD_DETAILS.EXTERNAL_ROLES_SHUTTLE_LABEL),
					type: Heading.Type.MEDIUM_HEADING
				})

				return this._externalShuttleLabel;
			},
			_hasDifferentSelection: function (roleIdList) {
				var equals = true;
				var currentSelectedRoles = this.state.manage.spa.audience.editing.roles.roles
				roleIdList.forEach(function(role) {
					equals = equals && (currentSelectedRoles.includes(parseInt(role)));
				});

				return !(equals && (roleIdList.length === currentSelectedRoles.length));
			},

			_internalRolesShuttleSelectorSelectionChanged: function (args) {
				const valueArray = this._getValueArray(args.selectedItems.toArray());
				if (this._hasDifferentSelection(valueArray)) {
					this.dispatchAction(SpaAudienceReducer.Action.SELECTED_INTERNAL_ROLES_CHANGED, valueArray);
				}
			},
			_externalRolesShuttleSelectorSelectionChanged: function (args) {
				const valueArray = this._getValueArray(args.selectedItems.toArray());
				if (this._hasDifferentSelection(valueArray)) {
					this.dispatchAction(SpaAudienceReducer.Action.SELECTED_EXTERNAL_ROLES_CHANGED, valueArray);
				}
			},
			_getValueArray: function (roleList) {
				return roleList.map(({id}) => parseInt(id));
			},
			// Called when the roles are received from the endpoint
			_allRolesAvailableChangedAction: function () {
				// filter by internal and external roles
				const externalRoles = this.state.manage.spa.audience.static.allRolesAvailable.filter(({external}) => external);
				const internalRoles = this.state.manage.spa.audience.static.allRolesAvailable.filter(({external}) => !external);
				// set the data sources for the shuttles
				this._internalRolesShuttleSelector.sourceDataSource = new ArrayDataSource(internalRoles);
				this._externalRolesShuttleSelector.sourceDataSource = new ArrayDataSource(externalRoles);
				this._selectedRolesChangedAction();
			},
			_allRolesCheckedChangedAction: function () {
				const allRolesChecked = this.state.manage.spa.audience.editing.roles.allRoles;
				this._allRolesCheckBox.value = allRolesChecked;
				// this._allRolesAvailableChangedAction();
				this._internalRolesShuttleSelector.enabled = !allRolesChecked;
			},
			_buildSelectedRolesList: function (roleIdList) {
				return this.state.manage.spa.audience.static.allRolesAvailable.filter(function (role) {return roleIdList.includes(parseInt(role.id));})
			},
			_selectedRolesChangedAction: function () {
				const selectedRoles = this._buildSelectedRolesList(this.state.manage.spa.audience.editing.roles.roles);
				this._internalRolesShuttleSelector.targetDataSource = new ArrayDataSource(selectedRoles.filter(({external}) => !external));
				this._externalRolesShuttleSelector.targetDataSource = new ArrayDataSource(selectedRoles.filter(({external}) => external));
			}
		},

		/** @lends AudienceModalRolesPresenter# */
		overrides: {
			_onCreateView: function() {
				this._createEmptyInternalRolesShuttleSelector();
				this._createEmptyExternalRolesShuttleSelector();
				this._createInternalShuttleLabel();
				this._createExternalShuttleLabel();
				const content = new StackPanel({
					orientation: StackPanel.Orientation.VERTICAL,
					itemGap: GapSize.MEDIUM,
					outerGap: GapSize.MEDIUM,
					alignment: StackPanel.Alignment.START
				});

				content.add(this._internalShuttleLabel);
				content.add(this._createAllRolesCheckbox());
				content.add({
					component: this._internalRolesShuttleSelector,
					options: StackPanel.ItemOptions.KEEP_SIZE
				});
				content.add(this._externalShuttleLabel);
				content.add({
					component: this._externalRolesShuttleSelector,
					options: StackPanel.ItemOptions.KEEP_SIZE
				})
				return content;
			},
			_onStateChanged: function (oldState, currentState) {
				if (oldState.manage.spa.audience.static.allRolesAvailable !== currentState.manage.spa.audience.static.allRolesAvailable) {
					this._allRolesAvailableChangedAction();
				}
				if (oldState.manage.spa.audience.editing.roles.allRoles !== currentState.manage.spa.audience.editing.roles.allRoles) {
					this._allRolesCheckedChangedAction();
				}
				if (oldState.manage.spa.audience.editing.roles.roles !== currentState.manage.spa.audience.editing.roles.roles) {
					this._selectedRolesChangedAction();
				}
				if(oldState.manage.spa.audience.state !== currentState.manage.spa.audience.state
					&& currentState.manage.spa.audience.state === StateProps.SPA.AUDIENCE.STATE.EDITING) {
					this._allRolesAvailableChangedAction();
				}
			}
		},
		static: {
			Constants: Object.freeze({
				FIELD_DETAILS: Object.freeze({
					ALL_ROLES_CHECKBOX_LABEL: TranslationKeys.SPA_MANAGEMENT_CONFIGURATION_RELEASE_AUDIENCE_SETUP_AUDIENCE_MODAL_ALL_ROLES_CHECKBOX_LABEL,
					INTERNAL_ROLES_SHUTTLE_LABEL: TranslationKeys.SPA_MANAGEMENT_CONFIGURATION_RELEASE_AUDIENCE_INTERNAL_ROLES_LABEL,
					EXTERNAL_ROLES_SHUTTLE_LABEL: TranslationKeys.SPA_MANAGEMENT_CONFIGURATION_RELEASE_AUDIENCE_EXTERNAL_ROLES_LABEL,
					VALUE_MEMBER: "id",
					DISPLAY_MEMBER: "value"
				})
			}),
			AutomationIds: Object.freeze({
				MODAL_ALL_ROLES_CHECKBOX: "manage-spa-configuration-setup-audience-modal-all-roles-checkbox",
				MODAL_INTERNAL_ROLES_SHUTTLE: "manage-spa-configuration-setup-audience-modal-internal-roles-shuttle",
				MODAL_EXTERNAL_ROLES_SHUTTLE: "manage-spa-configuration-setup-audience-modal-external-roles-shuttle",
			})
		}
	});

	var PresenterConstants = AudienceModalRolesPresenter.Constants;
	var AutomationIds = AudienceModalRolesPresenter.AutomationIds;


	return AudienceModalRolesPresenter;
});