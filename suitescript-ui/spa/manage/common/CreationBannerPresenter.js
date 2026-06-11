define('n/suitescript-ui/spa/manage/common/CreationBannerPresenter', [
	'n/ui/classes/Class',
	'n/ui/classes/Object',
	'n/ui/compounds/app/Presenter',
	'n/ui/widgets/image/SystemIcon',
	'n/ui/widgets/toolkit/Button',
	'n/ui/widgets/toolkit/Link',
	'n/ui/widgets/toolkit/StackPanel',
	'n/ui/widgets/toolkit/Text',
	'n/suitescript-ui/spa/manage/TranslationKeys',
	'n/suitescript-ui/spa/manage/common/UrlHelper'
], function (
	Class,
	Object,
	Presenter,
	SystemIcon,
	Button,
	Link,
	StackPanel,
	Text,
	TranslationKeys,
	UrlHelper
) {
	'use strict';

	var CreationBannerPresenter = Class.create({
		extend: Presenter,

		/**
		 * @class CreationBannerPresenter
		 * @extends Presenter
		 */
		initialize: function CreationBannerPresenter(options) {
			CreationBannerPresenter.$super.call(this, options);
		},

		/** @lends CreationBannerPresenter# */
		properties: {},

		/** @lends CreationBannerPresenter# */
		methods: {
			_createBannerContent: function () {
				var spaContent = this._spaUrlContent();
				var fileCabinetContent = this._fileCabinetContent();
				return new StackPanel({
					orientation: StackPanel.Orientation.VERTICAL,
					justification: StackPanel.Justification.LEFT,
					alignment: StackPanel.Alignment.START,
					wrappedContentAlignment: StackPanel.WrappedContentAlignment.START,
					items: [
						spaContent,
						fileCabinetContent
					]
				});
			},
			_spaUrlContent: function () {
				var that = this;

				var spaName = this.state.manage.spa.name;
				var congratulationsText = this.i18n.get({
					key: TranslationKeys.SPA_MANAGE_BANNER_CONGRATULATIONS_MESSAGE,
					params: {1: spaName}
				});

				var text = new Text({
					text: congratulationsText,
					automationId: AutomationIds.SPA_CONGRATULATIONS_FIELD
				});

				var link = new Link({
					classList: [CssClass.MARGIN],
					content: 'here',
					url: UrlHelper.getSpaUrl(this.state.manage.spa.url, this.state.manage.spa.suiteAppId),
					target: Link.Target.BLANK,
					automationId: AutomationIds.SPA_URL_LINK
				});

				var linkButton = new Button({
					ariaLabel: UrlHelper.getSpaUrl(that.state.manage.spa.url, this.state.manage.spa.suiteAppId),
					visible: true,
					type: Button.Type.PURE,
					icon: SystemIcon.OPEN_NEW,
					automationId: AutomationIds.SPA_URL_BUTTON,
					action: function (btnArgs) {
						window.open(UrlHelper.getSpaUrl(that.state.manage.spa.url, that.state.manage.spa.suiteAppId), '_blank');
					}
				});

				return new StackPanel({
					orientation: StackPanel.Orientation.HORIZONTAL,
					justification: StackPanel.Justification.START,
					alignment: StackPanel.Alignment.CENTER,
					items: [
						text,
						link,
						linkButton
					]
				});
			},
			_fileCabinetContent: function () {
				var that = this;
				var fileCabinetStartText = new Text({
					text: this.i18n.get(TranslationKeys.SPA_MANAGE_BANNER_FILECABINET_MESSAGE_START),
					automationId: AutomationIds.SPA_FILE_CABINET_MESSAGE_START
				});

				var fileCabinetDescriptionText = new Text({
					text: this.i18n.get(TranslationKeys.SPA_MANAGE_BANNER_FILECABINET_DESCRIPTION),
					classList: [CssClass.PADDING],
					type: Text.Type.STRONG,
					automationId: AutomationIds.SPA_FILE_CABINET_DESCRIPTION
				});

				var fileCabinetlinkButton = new Button({
					ariaLabel: this.i18n.get(TranslationKeys.SPA_MANAGE_BANNER_FILECABINET_DESCRIPTION),
					type: Button.Type.PURE,
					icon: SystemIcon.OPEN_NEW,
					iconPosition: Button.IconPosition.RIGHT,
					automationId: AutomationIds.SPA_FILE_CABINET_BUTTON,
					action: function (btnArgs) {
						window.open(UrlHelper.getFolderUrl(that.state.manage.spa.spaFolder.id), '_blank');
					}
				});

				var fileCabinetEndText = new Text({
					text: this.i18n.get(TranslationKeys.SPA_MANAGE_BANNER_FILECABINET_MESSAGE_END),
					automationId: AutomationIds.SPA_FILE_CABINET_MESSAGE_END
				});

				return new StackPanel({
					orientation: StackPanel.Orientation.HORIZONTAL,
					justification: StackPanel.Justification.START,
					alignment: StackPanel.Alignment.CENTER,
					items: [
						fileCabinetStartText,
						fileCabinetDescriptionText,
						fileCabinetlinkButton,
						fileCabinetEndText
					]
				});
			}
		},

		/** @lends CreationBannerPresenter# */
		overrides: {
			_onCreateView: function () {
				return this._createBannerContent();
			}
		},
		static: {
			AutomationIds: Object.freeze({
				SPA_CONGRATULATIONS_FIELD: "manage-spa-banner-spa-congratulations-field",
				SPA_URL_LINK: "manage-spa-banner-spa-url-link",
				SPA_URL_BUTTON: "manage-spa-banner-spa-url-button",
				SPA_FILE_CABINET_MESSAGE_START: "manage-spa-banner-spa-file-cabinet-message_start",
				SPA_FILE_CABINET_DESCRIPTION: "manage-spa-banner-spa-file-cabinet-description",
				SPA_FILE_CABINET_BUTTON: "manage-spa-banner-spa-file-cabinet-button",
				SPA_FILE_CABINET_MESSAGE_END: "manage-spa-banner-spa-file-cabinet-message_end"

			}),
			CssClass: Object.freeze({
				PADDING: 'n-ssui-spa-manage-banner-padding',
				MARGIN: 'n-ssui-spa-manage-banner-margin'
			})
		}
	});

	var AutomationIds = CreationBannerPresenter.AutomationIds;
	var CssClass = CreationBannerPresenter.CssClass;

	return CreationBannerPresenter;
});