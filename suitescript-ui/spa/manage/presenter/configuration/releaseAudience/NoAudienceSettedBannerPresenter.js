define('n/suitescript-ui/spa/manage/presenter/configuration/releaseAudience/NoAudienceSettedBannerPresenter', [
	'n/ui/classes/Class',
	'n/ui/classes/Object',
	'n/ui/compounds/app/Presenter',
	'n/ui/widgets/image/SystemIcon',
	'n/ui/widgets/toolkit/Image',
	'n/ui/widgets/toolkit/StackPanel',
	'n/ui/widgets/toolkit/Text',
	'n/ui/widgets/toolkit/layout/GapSize',
	'n/suitescript-ui/spa/manage/TranslationKeys',
], function (
	Class,
	Object,
	Presenter,
	SystemIcon,
	Image,
	StackPanel,
	Text,
	GapSize,
	TranslationKeys
) {
	'use strict';

	var NoAudienceSettedBannerPresenter = Class.create({
		extend: Presenter,

		/**
		 * @class NoAudienceSettedBannerPresenter
		 * @extends Presenter
		 */
		initialize: function NoAudienceSettedBannerPresenter(options) {
			NoAudienceSettedBannerPresenter.$super.call(this, options);
		},

		/** @lends NoAudienceSettedBannerPresenter# */
		properties: {},

		/** @lends NoAudienceSettedBannerPresenter# */
		methods: {
			_updateBanner: function (audience) {
				if (this._component) {
					this._component.visible = (!audience.roles.allRoles && audience.roles.roles.length === 0);
				}
			}
		},

		/** @lends NoAudienceSettedBannerPresenter# */
		overrides: {
			_onCreateView: function () {
				this._message = new Text({
					text: this.i18n.get(TranslationKeys.SPA_MANAGEMENT_CONFIGURATION_AUDIENCE_NO_AUDIENCE_SELECTED),
					automationId: AutomationIds.BANNER
				});
				this._icon = new Image({
					image: SystemIcon.ALERT.withCaption(this.i18n.get(TranslationKeys.SPA_MANAGEMENT_CONFIGURATION_AUDIENCE_NO_AUDIENCE_SELECTED)),
					automationId: AutomationIds.ICON,
					classList: [CssClass.ERROR_COMPONENT]
				});
				this._component = new StackPanel({
					orientation: StackPanel.Orientation.HORIZONTAL,
					items: [this._icon, this._message],
					alignment: StackPanel.Alignment.CENTER,
					itemGap: GapSize.SMALL
				});
				return this._component;
			},
			_onStateChanged: function (oldState, currentState) {
				if (!Object.equals(oldState.manage.spa.audience.original, currentState.manage.spa.audience.original)) {
					this._updateBanner(currentState.manage.spa.audience.original);
				}
			}
		},
		static: {
			AutomationId: Object.freeze({
				BANNER: 'manage-spa-configuration-audience-no-audience-banner',
				ICON: 'manage-spa-configuration-audience-no-audience-banner-icon',
			}),
			CssClass: Object.freeze({
				ERROR_COMPONENT: 'n-ssui-spa-manage-warning-component',
			})
		}
	});

	var AutomationIds = NoAudienceSettedBannerPresenter.AutomationId;
	var CssClass = NoAudienceSettedBannerPresenter.CssClass;

	return NoAudienceSettedBannerPresenter;
});