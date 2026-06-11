define('n/suitescript-ui/spa/manage/presenter/configuration/centerLinks/popup/field/CenterLinkModalInsertBeforeFieldPresenter', [
	'n/ui/classes/Class',
	'n/ui/classes/Object',
	'n/ui/widgets/data/ArrayDataSource',
	'n/ui/widgets/toolkit/Dropdown',
	'n/suitescript-ui/spa/ServiceList',
	'n/suitescript-ui/spa/manage/TranslationKeys',
	'n/suitescript-ui/spa/manage/common/Constants',
	'n/suitescript-ui/spa/manage/presenter/configuration/centerLinks/popup/field/CenterLinkModalFieldPresenter',
	'n/suitescript-ui/spa/manage/reducer/CenterLinkModalReducer'
], function (
	Class,
	Object,
	ArrayDataSource,
	Dropdown,
	ServiceList,
	TranslationKeys,
	Constants,
	CenterLinkModalFieldPresenter,
	CenterLinkModalReducer
) {
	'use strict';

	var CenterLinkModalInsertBeforeFieldPresenter = Class.create({
		extend: CenterLinkModalFieldPresenter,

		/**
		 * @class CenterLinkModalInsertBeforeFieldPresenter
		 * @extends CenterLinkModalFieldPresenter
		 */
		initialize: function CenterLinkModalInsertBeforeFieldPresenter(options) {
			CenterLinkModalInsertBeforeFieldPresenter.$super.call(this, options);

			this._centerLinksService = this.context.services.get(ServiceList.LINKS);
		},

		/** @lends CenterLinkModalInsertBeforeFieldPresenter# */
		properties: {},

		/** @lends CenterLinkModalInsertBeforeFieldPresenter# */
		methods: {
			_insertBeforeDropdownSelectionChanged: function (args) {
				this.dispatchAction(CenterLinkModalReducer.Action.SET_INSERT_BEFORE, args.currentItem);
			},
			_createInsertBeforeDropDown: function () {
				this._insertBerforeDropDown = new Dropdown({
					valueMember: 'id',
					displayMember: 'value',
					selectedValue: this.state.manage.centerLinkModal.originalSelection.insertBefore.id,
					allowEmpty: true,
					noDataMessage: this.i18n.get(TranslationKeys.SPA_MANAGEMENT_CONFIGURATION_CENTER_LINK_MODAL_INSERT_BEFORE_NO_DATA),
					automationId: AutomationIds.INSERT_BEFORE_DROPDOWN
				});
				this._insertBerforeDropDown.on(Dropdown.Event.SELECTED_ITEM_CHANGED, this._insertBeforeDropdownSelectionChanged.bind(this))

				return this._insertBerforeDropDown;
			},
			_createInsertBeforeField: function () {
				this._insertBeforeField = this._createField(
					this.i18n.get(TranslationKeys.SPA_MANAGEMENT_CONFIGURATION_CENTER_LINK_MODAL_INSERT_BEFORE_HEADER),
					this._createInsertBeforeDropDown(),
					AutomationIds.INSERT_BEFORE_ID,
					Constants.FLH.FIELD.SPA_LINK_INSERT_BEFORE);
				return this._insertBeforeField;
			},
			_selectDropDownValue: function (value) {
				if (value !== this._selected)
				{
					if (value !== '') {
						this._selected = value;
						this._insertBerforeDropDown.select({value: value});
					}
					else {
						this._insertBerforeDropDown.unselect();
					}
				}
			},
			_filterSelfFromLinkList: function(link) {
				return link.id !== this.state.manage.centerLinkModal.linkId
			},
			_processCategoriesLinksResponse: function (response) {
				var linkList = response.response.filter(this._filterSelfFromLinkList.bind(this));
				this._insertBerforeDropDown.dataSource = new ArrayDataSource(linkList);
				this._selectDropDownValue(this.state.manage.centerLinkModal.insertBefore.id);
				this._hideSpinner();
			},
			_refreshLinksDropdown :function (categoryId) {
				this._showSpinner();
				this._centerLinksService.getCategoryLinks(categoryId).then(this._processCategoriesLinksResponse.bind(this));
			}
		},

		/** @lends CenterLinkModalInsertBeforeFieldPresenter# */
		overrides: {
			_onCreateView: function () {
				var selectedCategory = this.state.manage.centerLinkModal.originalSelection.location.category.id;
				if (selectedCategory !== '' ) {
					this._refreshLinksDropdown(selectedCategory);
				}
				return this._createInsertBeforeField();
			},
			_onStateChanged: function (old, current) {
				if (old.manage.centerLinkModal.location.category.id !== current.manage.centerLinkModal.location.category.id){
					this._refreshLinksDropdown(current.manage.centerLinkModal.location.category.id);
				}

				if (old.manage.centerLinkModal.insertBeforeError !== current.manage.centerLinkModal.insertBeforeError){
					this._setFieldError(current.manage.centerLinkModal.insertBeforeError);
				}

				if (old.manage.centerLinkModal.insertBefore.id !== current.manage.centerLinkModal.insertBefore.id){
					this._selectDropDownValue(current.manage.centerLinkModal.insertBefore.id);
				}
			}
		},
		static: {
			AutomationIds: Object.freeze({
				INSERT_BEFORE_DROPDOWN: "manage-spa-configuration-center-link-modal-insert-editable-field",
				INSERT_BEFORE_ID: "insert-before"
			})
		}
	});

	var AutomationIds = CenterLinkModalInsertBeforeFieldPresenter.AutomationIds;

	return CenterLinkModalInsertBeforeFieldPresenter;
});