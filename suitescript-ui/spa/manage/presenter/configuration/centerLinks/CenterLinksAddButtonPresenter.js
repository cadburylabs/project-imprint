define('n/suitescript-ui/spa/manage/presenter/configuration/centerLinks/CenterLinksAddButtonPresenter', [
	'n/ui/classes/Class',
	'n/ui/classes/Object',
	'n/ui/compounds/app/Presenter',
	'n/ui/widgets/toolkit/Button',
	'n/suitescript-ui/spa/manage/TranslationKeys',
	'n/suitescript-ui/spa/manage/presenter/configuration/centerLinks/popup/CenterLinkModal',
	'n/suitescript-ui/spa/manage/presenter/configuration/centerLinks/popup/CenterLinkModalContentPresenter',
	'n/suitescript-ui/spa/manage/presenter/configuration/centerLinks/popup/CenterLinkModalSaveButtonPresenter',
	'n/suitescript-ui/spa/manage/reducer/ManageMainReducer'
], function (
	Class,
	Object,
	Presenter,
	Button,
	TranslationKeys,
	CenterLinkModal,
	CenterLinkModalContentPresenter,
	CenterLinkModalSaveButtonPresenter,
	ManageMainReducer
) {
	'use strict';

	var CenterLinksAddButton = Class.create({
		extend: Presenter,

		/**
		 * @class CenterLinksAddButton
		 * @extends Presenter
		 */
		initialize: function CenterLinksAddButton(options) {
			this.constructor.$super.call(this, options);
		},

		/** @lends CenterLinksAddButton# */
		properties: {},

		/** @lends CenterLinksAddButton# */
		methods: {
			_buttonAction: function (args) {
				this.dispatchAction(ManageMainReducer.Action.ADD_BUTTON_CLICKED);

				var centerLinkModal = new CenterLinkModal({
					owner: this._button,
					translationService: this.i18n,
					saveButtonPresenter: this._createChild(CenterLinkModalSaveButtonPresenter),
					contentPresenter: this._createChild(CenterLinkModalContentPresenter)
				});
				centerLinkModal.open();
			}
		},

		/** @lends CenterLinksAddButton# */
		overrides: {
			_onCreateView:function () {
				this._button = new Button({
					automationId: AutomationIds.ADD_BUTTON,
					ariaLabel: this.i18n.get(TranslationKeys.SPA_MANAGEMENT_CONFIGURATION_CENTER_LINK_ADD_BUTTON),
					type: Button.Type.GHOST,
					label: this.i18n.get(TranslationKeys.SPA_MANAGEMENT_CONFIGURATION_CENTER_LINK_ADD_BUTTON),
					size: Button.Size.SMALL,
					action: this._buttonAction.bind(this)
				});

				return this._button;
			}
		},

		static: {
			AutomationIds: Object.freeze({
				ADD_BUTTON: "manage-spa-configuration-center-links-add",
			})
		}
	});

	var AutomationIds = CenterLinksAddButton.AutomationIds;

	return CenterLinksAddButton;
});