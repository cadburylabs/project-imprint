define('n/suitescript-ui/spa/manage/presenter/configuration/centerLinks/CenterLinkListItemPresenter', [
	'n/ui/classes/Class',
	'n/ui/classes/Object',
	'n/ui/compounds/app/Presenter',
	'n/ui/widgets/image/SystemIcon',
	'n/ui/widgets/toolkit/Button',
	'n/ui/widgets/toolkit/StackPanel',
	'n/ui/widgets/toolkit/Text',
	'n/suitescript-ui/spa/manage/common/PermissionHelper',
	'n/suitescript-ui/spa/manage/presenter/configuration/centerLinks/CenterLinkDeleteButtonPresenter',
	'n/suitescript-ui/spa/manage/presenter/configuration/centerLinks/CenterLinksHelper',
	'n/suitescript-ui/spa/manage/presenter/configuration/centerLinks/popup/CenterLinkModal',
	'n/suitescript-ui/spa/manage/presenter/configuration/centerLinks/popup/CenterLinkModalContentPresenter',
	'n/suitescript-ui/spa/manage/presenter/configuration/centerLinks/popup/CenterLinkModalSaveButtonPresenter',
	'n/suitescript-ui/spa/manage/reducer/CenterLinkModalReducer'
], function (
	Class,
	Object,
	Presenter,
	SystemIcon,
	Button,
	StackPanel,
	Text,
	PermissionHelper,
	CenterLinkDeleteButtonPresenter,
	CenterLinksHelper,
	CenterLinkModal,
	CenterLinkModalContentPresenter,
	CenterLinkModalSaveButtonPresenter,
	CenterLinkModalReducer
) {
	'use strict';

	var CenterLinkListItemPresenter = Class.create({
		extend: Presenter,

		/**
		 * @class CenterLinkListItemPresenter
		 * @extends Presenter
		 */
		initialize: function CenterLinkListItemPresenter(options) {
			CenterLinkListItemPresenter.$super.call(this, options);
			this.linkDetails = options.linkDetails;
		},

		/** @lends CenterLinkListItemPresenter# */
		properties: {
			linkDetails: {
				writable: true
			}
		},

		/** @lends CenterLinkListItemPresenter# */
		methods: {
			_buildCenter: function () {
				return new Text({
					text: this.linkDetails.center.value + Constants.CENTER_SEPARATOR,
					whitespace: true,
					type: Text.Type.STRONG,
					automationId: AutomationIds.CENTER_TEXT_PREFIX + this.linkDetails.linkId
				});
			},
			_buildLinkName: function () {
				return new Text({
					text: CenterLinksHelper.getLinkSectionLocation(this.linkDetails),
					automationId: AutomationIds.LINK_TEXT_PREFIX + this.linkDetails.linkId
				});
			},
			_getlLinkLocation: function () {
				return {
					center: this.linkDetails.center,
					section: this.linkDetails.section,
					category: this.linkDetails.category
				};
			},
			_editButtonAction: function (args) {
				var selectedValues = {
					linkId: this.linkDetails.linkId,
					location: this._getlLinkLocation(),
					linkLabel: this.linkDetails.label,
					insertBefore: {id: this.linkDetails.insertBeforeLinkId, value: ""}
				};
				this.dispatchAction(CenterLinkModalReducer.Action.SET_ORIGINAL_SELECTION,
					selectedValues);

				var centerLinkModal = new CenterLinkModal({
					owner: this._editButton,
					translationService: this.i18n,
					saveButtonPresenter: this._createChild(CenterLinkModalSaveButtonPresenter),
					contentPresenter: this._createChild(CenterLinkModalContentPresenter)
				});
				centerLinkModal.open();
			},
			_buildEditButton: function () {
				this._editButton =new Button({
					icon: SystemIcon.EDIT.withCaption('Edit'),
					type: Button.Type.PURE,
					action: this._editButtonAction.bind(this),
					automationId: AutomationIds.EDIT_BUTTON_PREFIX + this.linkDetails.linkId
				});

				return this._editButton;
			},
			_buildDeleteButton: function () {
				this._deleteButton = this._createChild(CenterLinkDeleteButtonPresenter,
					{
						presenterOptions: {
							linkId: this.linkDetails.linkId
						}
					}).createView();
				return this._deleteButton;
			}
		},

		/** @lends CenterLinkListItemPresenter# */
		overrides: {
			_onCreateView: function () {
				var presentersPanel = new StackPanel({
					orientation: StackPanel.Orientation.HORIZONTAL,
					alignment: StackPanel.Alignment.CENTER,
					items: [
						this._buildCenter(),
						this._buildLinkName(),
					]});

				if (PermissionHelper.userHasEditPermission()) {
					presentersPanel.add(this._buildEditButton());
					presentersPanel.add(this._buildDeleteButton());
				}

				return presentersPanel;
			}
		},
		static: {
			AutomationIds: Object.freeze({
				LINK_TEXT_PREFIX: "manage-spa-configuration-center-link-list-",
				CENTER_TEXT_PREFIX: "manage-spa-configuration-center-link-list-center-",
				EDIT_BUTTON_PREFIX: "manage-spa-configuration-center-link-list-edit-",
				DELETE_BUTTON_PREFIX: "manage-spa-configuration-center-link-list-delete-"
			}),
			Constants: Object.freeze({
				CENTER_SEPARATOR: ": "
			})
		}
	});

	var Constants = CenterLinkListItemPresenter.Constants;
	var AutomationIds = CenterLinkListItemPresenter.AutomationIds;

	return CenterLinkListItemPresenter;
});