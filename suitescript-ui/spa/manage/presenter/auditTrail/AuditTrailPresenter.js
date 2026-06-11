define('n/suitescript-ui/spa/manage/presenter/auditTrail/AuditTrailPresenter', [
	'n/ui/classes/Class',
	'n/ui/classes/Object',
	'n/ui/classes/app/Reducer',
	'n/ui/classes/app/Store',
	'n/ui/compounds/app/Presenter',
	'n/ui/widgets/toolkit/ContentPanel',
	'n/platform/systemnotes2/presenter/SnPresenter',
	'n/suitescript-ui/spa/manage/Navigation',
], function (
	Class,
	Object,
	Reducer,
	Store,
	Presenter,
	ContentPanel,
	SnPresenter,
	Navigation
) {
	'use strict';

	var AuditTrailPresenter = Class.create({
		extend: Presenter,

		/**
		 * @class AuditTrailPresenter
		 * @extends Presenter
		 */
		initialize: function AuditTrailPresenter(options) {
			AuditTrailPresenter.$super.call(this, options);
		},

		/** @lends AuditTrailPresenter# */
		properties: {},

		/** @lends AuditTrailPresenter# */
		methods: {
			_createPageContext: function () {
				if (this._snContext === undefined) {

					this._snContext = this.context.createChild({
						name: 'rootSnPresenter',
						state: {},
					});
				}

				return this._snContext;
			},
			_createSnPresenterView: function (scriptId) {
				this._snPresenter = new SnPresenter({
					context: this._createPageContext(),
					eid: Constants.SPA_ELEMENT_ID,
					nkey1: scriptId
				});
				return this._snPresenter.createView();
			},
			_createContentPanel: function (content) {
				this._contentPanel = new ContentPanel({
					content: content,
					outerGap: ContentPanel.GapSize.MEDIUM
				});
				return this._contentPanel;
			},
			_scriptIdChanged: function (nKey) {
				this._contentPanel.content = this._createSnPresenterView(nKey);
			},
			_hasAuditTrailTabBeenAccessed: function (oldState, newState) {
			 	return ((oldState.router.tab !== newState.router.tab) && (newState.router.tab === Navigation.AUDIT_TRAIL))
			}
		},

		/** @lends AuditTrailPresenter# */
		overrides: {
			_onCreateView: function () {
				return this._createContentPanel(this._createSnPresenterView(this.state.manage.spa.scriptId));
			},
			_onStateChanged: function (oldState, newState) {
				if ((oldState.manage.spa.scriptId !== newState.manage.spa.scriptId)
						|| this._hasAuditTrailTabBeenAccessed(oldState, newState)
				//Audit trail loaded everytime Audit trail menu item is clicked
				) {
					this._scriptIdChanged(newState.manage.spa.scriptId);
				}
			}
		},
		static: {
			Constants: Object.freeze({
				SPA_ELEMENT_ID: -1920
			})
		}
	});

	var Constants = AuditTrailPresenter.Constants;

	return AuditTrailPresenter;
});