define('n/suitescript-ui/spa/manage/presenter/configuration/centerLinks/popup/field/CenterLinkModalLocationFieldPresenter', [
	'n/ui/classes/Class',
	'n/ui/classes/Object',
	'n/ui/widgets/toolkit/Dropdown',
	'n/ui/widgets/toolkit/StackPanel',
	'n/suitescript-ui/spa/ServiceList',
	'n/suitescript-ui/spa/manage/TranslationKeys',
	'n/suitescript-ui/spa/manage/common/Constants',
	'n/suitescript-ui/spa/manage/presenter/configuration/centerLinks/CenterLinksHelper',
	'n/suitescript-ui/spa/manage/presenter/configuration/centerLinks/popup/CenterLinkLocationListHelper',
	'n/suitescript-ui/spa/manage/presenter/configuration/centerLinks/popup/field/CenterLinkModalFieldPresenter',
	'n/suitescript-ui/spa/manage/presenter/configuration/centerLinks/popup/field/CenterLinkModalLocationDropDownPicker',
	'n/suitescript-ui/spa/manage/reducer/CenterLinkModalReducer'
], function (
	Class,
	Object,
	Dropdown,
	StackPanel,
	ServiceList,
	TranslationKeys,
	Constants,
	CenterLinksHelper,
	CenterLinkLocationListHelper,
	CenterLinkModalFieldPresenter,
	CenterLinkModalLocationDropDownPicker,
	CenterLinkModalReducer
) {
	'use strict';

	var CenterLinkModalLocationFieldPresenter = Class.create({
		extend: CenterLinkModalFieldPresenter,

		/**
		 * @class CenterLinkModalLocationFieldPresenter
		 * @extends CenterLinkModalFieldPresenter
		 */
		initialize: function CenterLinkModalLocationFieldPresenter(options) {
			CenterLinkModalLocationFieldPresenter.$super.call(this, options);
			this._centerLinksService = this.context.services.get(ServiceList.LINKS);
			this._centerLinksDataSource = [];
		},

		/** @lends CenterLinkModalLocationFieldPresenter# */
		properties: {},

		/** @lends CenterLinkModalLocationFieldPresenter# */
		methods: {
			_processCenterLinksResponse: function (response) {
				this._centerLinksDataSource = CenterLinkLocationListHelper.buildCenterLinksDataSource(response.response);
				this._picker.dataSource = this._centerLinksDataSource;
			},
			_loadData: function () {
				this._centerLinksService.getCenters().then(this._processCenterLinksResponse.bind(this));
			},
			_createMenuLocationTree: function (owner) {
				this._picker = new CenterLinkModalLocationDropDownPicker({
					dataSource: this._centerLinksDataSource,
					owner: owner
				});

				return this._picker;
			},
			_locationDropdownSelectionChanged: function (args) {
				if (args.currentItem) {
					this.dispatchAction(CenterLinkModalReducer.Action.SET_LOCATION, args.currentItem.location);
				}
			},
			_createLocationsDropDown: function () {
				var selectedLocation = CenterLinksHelper.getLinkLocation(this.state.manage.centerLinkModal.originalSelection.location)
				this._locationDropdown = new Dropdown({
					valueMember: 'id',
					displayMember: 'locationDescription',
					picker: this._createMenuLocationTree.bind(this),
					automationId: AutomationIds.LOCATION_DROPDOWN,
					ariaLabel: AutomationIds.LOCATION_DROPDOWN,
					selectedItem: {locationDescription: selectedLocation},
					allowCustomText: true
				});
				this._locationDropdown.on(Dropdown.Event.SELECTED_ITEM_CHANGED, this._locationDropdownSelectionChanged.bind(this));
				return this._locationDropdown;
			},
			_createMenuLocationField: function () {
				return this._createField(
					this.i18n.get(TranslationKeys.SPA_MANAGEMENT_CONFIGURATION_CENTER_LINK_MODAL_LOCATION_HEADER),
					this._createLocationsDropDown(),
					AutomationIds.LOCATION_ID,
					Constants.FLH.FIELD.SPA_LINK_LOCATION);
			},
			_createContent: function () {
				this._content = new StackPanel({
					orientation: StackPanel.Orientation.VERTICAL
				});
				this._content.add(this._createMenuLocationField());

				return this._content;
			}
		},

		/** @lends CenterLinkModalLocationFieldPresenter# */
		overrides: {
			_onCreateView: function () {
				this._content = this._createContent();
				this._loadData();

				return this._content;
			},
			_onStateChanged: function (old, current) {
				if (old.manage.centerLinkModal.locationError !== current.manage.centerLinkModal.locationError) {
					this._setFieldError(current.manage.centerLinkModal.locationError);
				}

				if (old.manage.centerLinkModal.location !== current.manage.centerLinkModal.location) {
					this._locationDropdown.selectedText = CenterLinksHelper.getLinkLocation(current.manage.centerLinkModal.location);
				}

			}
		},
		static: {
			AutomationIds: Object.freeze({
				LOCATION_DROPDOWN: "manage-spa-configuration-center-link-modal-location-editable-field",
				LOCATION_ID: "location"
			})
		}
	});

	var AutomationIds = CenterLinkModalLocationFieldPresenter.AutomationIds;

	return CenterLinkModalLocationFieldPresenter;
});