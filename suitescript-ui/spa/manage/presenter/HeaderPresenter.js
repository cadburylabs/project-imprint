define('n/suitescript-ui/spa/manage/presenter/HeaderPresenter', [
	'n/ui/classes/Class',
	'n/ui/classes/Object',
	'n/ui/compounds/app/Presenter',
	'n/ui/widgets/image/SystemIcon',
	'n/ui/widgets/toolkit/Button',
	'n/ui/widgets/toolkit/Heading',
	'n/ui/widgets/toolkit/StackPanel',
	'n/suitescript-ui/spa/RouteList',
	'n/suitescript-ui/spa/ServiceList',
	'n/ui/widgets/toolkit/Image'
], function (
	Class,
	Object,
	Presenter,
	SystemIcon,
	Button,
	Heading,
	StackPanel,
	RouteList,
	ServiceList,
	Image
) {
	'use strict';

	var HeaderPresenter = Class.create({
		extend: Presenter,

		/**
		 * @class HeaderPresenter
		 * @extends Presenter
		 */
		initialize: function HeaderPresenter(options) {
			HeaderPresenter.$super.call(this, options);
		},

		/** @lends HeaderPresenter# */
		properties: {},

		/** @lends HeaderPresenter# */
		methods: {
			_createHeader: function () {
				this._panel = new StackPanel({
					orientation: StackPanel.Orientation.HORIZONTAL,
					alignment: StackPanel.Alignment.CENTER,
					items: []
				});
				this._textComponent = this._createTextComponent();
				this._backButtonComponent = this._createBackButton();


				this._panel.add(this._backButtonComponent);
				this._panel.add(this._textComponent);

				this._updateLockImageComponent();

				return this._panel;
			},

			_updateLockImageComponent: function () {
				if (this.state.manage.spa.locked) {
					this._lockImageComponent = this._createLockImageComponent();
					this._panel.add({
						component: this._lockImageComponent
					});
				} else if (this._lockImageComponent) {
					this._panel.remove(this._lockImageComponent);
					this._lockImageComponent = null;
				}
			},

			_createTextComponent: function () {
				return new Heading({
					type: Heading.Type.PAGE_TITLE,
					content: this.state.manage.spa.name,
					automationId: AutomationIds.HEADER_ID
				});
			},

			_createLockImageComponent: function () {
				return new Image({
					image: SystemIcon.LOCK,
					presentation: true
				})
			},

			_createBackButton: function () {
				var that = this;
				return new Button({
					ariaLabel: AutomationIds.BACK_BUTTON_ID,
					type: Button.Type.PURE,
					icon: SystemIcon.CHEVRON_LEFT,
					automationId: AutomationIds.BACK_BUTTON_ID,
					action: function (args) {
						var router = that.services.get(ServiceList.ROUTER);
						router.routeTo(RouteList.LIST);
					}
				});
			}
		},

		/** @lends HeaderPresenter# */
		overrides: {
			_onCreateView: function () {
				return this._createHeader();
			},
			_onStateChanged: function (old, current) {
				if (old.manage.spa.name !== current.manage.spa.name) {
					this._textComponent.content = this.state.manage.spa.name;
				}
				if (old.manage.spa.locked !== current.manage.spa.locked) {
					this._updateLockImageComponent();
				}
			}
		},
		static: {
			AutomationIds: Object.freeze({
				HEADER_ID: "manage-spa-header",
				BACK_BUTTON_ID: "manage-spa-back-button"
			})
		}
	});

	var AutomationIds = HeaderPresenter.AutomationIds;

	return HeaderPresenter;
});