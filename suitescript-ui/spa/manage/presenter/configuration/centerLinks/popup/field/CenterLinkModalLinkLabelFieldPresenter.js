define('n/suitescript-ui/spa/manage/presenter/configuration/centerLinks/popup/field/CenterLinkModalLinkLabelFieldPresenter', [
	'n/ui/classes/Class',
	'n/ui/classes/Object',
	'n/ui/widgets/toolkit/TextBox',
	'n/suitescript-ui/spa/manage/TranslationKeys',
	'n/suitescript-ui/spa/manage/common/Constants',
	'n/suitescript-ui/spa/manage/presenter/configuration/centerLinks/popup/field/CenterLinkModalFieldPresenter',
	'n/suitescript-ui/spa/manage/reducer/CenterLinkModalReducer'
], function (
	Class,
	Object,
	TextBox,
	TranslationKeys,
	Constants,
	CenterLinkModalFieldPresenter,
	CenterLinkModalReducer
) {
	'use strict';

	var CenterLinkModalLinkLabelFieldPresenter = Class.create({
		extend: CenterLinkModalFieldPresenter,

		/**
		 * @class CenterLinkModalLinkLabelFieldPresenter
		 * @extends CenterLinkModalFieldPresenter
		 */
		initialize: function CenterLinkModalLinkLabelFieldPresenter(options) {
			CenterLinkModalLinkLabelFieldPresenter.$super.call(this, options);
		},

		/** @lends CenterLinkModalLinkLabelFieldPresenter# */
		properties: {},

		/** @lends CenterLinkModalLinkLabelFieldPresenter# */
		methods: {
			_linkLabelTextBoxChanged: function (args) {
				this.dispatchAction(CenterLinkModalReducer.Action.SET_LINK_LABEL, args.currentText);
			},
			_createLinkLabelTextBox: function () {
				this._linkLabelTextBox = new TextBox({
					text: this.state.manage.centerLinkModal.originalSelection.linkLabel,
					maxLength: 30,
					maxLengthIndicator: false,
					automationId: AutomationIds.LINK_LABEL_TEXTBOX,
					ariaLabel: AutomationIds.LINK_LABEL_TEXTBOX
				});
				this._linkLabelTextBox.on(TextBox.Event.TEXT_ACCEPTED, this._linkLabelTextBoxChanged.bind(this));

				return this._linkLabelTextBox;
			},
			_createLinkLabelField: function () {
				this._linkLabelField = this._createField(
					this.i18n.get(TranslationKeys.SPA_MANAGEMENT_CONFIGURATION_CENTER_LINK_MODAL_LINK_LABEL_HEADER),
					this._createLinkLabelTextBox(),
					AutomationIds.LINK_LABEL_ID,
					Constants.FLH.FIELD.SPA_LINK_LABEL);
				return this._linkLabelField;
			}
		},

		/** @lends CenterLinkModalLinkLabelFieldPresenter# */
		overrides: {
			_onCreateView: function () {
				return this._createLinkLabelField();

			},
			_onStateChanged: function (old, current) {
				if (old.manage.centerLinkModal.linkLabelError !== current.manage.centerLinkModal.linkLabelError){
					this._setFieldError(current.manage.centerLinkModal.linkLabelError);
				}

				if (old.manage.centerLinkModal.linkLabel !== current.manage.centerLinkModal.linkLabel){
					this._linkLabelTextBox.text = current.manage.centerLinkModal.linkLabel;
				}
			}
		},
		static: {
			AutomationIds: Object.freeze({
				LINK_LABEL_TEXTBOX: "manage-spa-configuration-center-link-modal-label-editable-field",
				LINK_LABEL_ID: "link-label"
			})
		}
	});

	var AutomationIds = CenterLinkModalLinkLabelFieldPresenter.AutomationIds;

	return CenterLinkModalLinkLabelFieldPresenter;
});