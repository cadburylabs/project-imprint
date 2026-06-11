define('n/suitescript-ui/spa/manage/common/FieldWithHelp', [
	'n/ui/classes/Class',
	'n/ui/classes/Object',
	'n/ui/classes/immutable/ImmutableObject',
	'n/ui/widgets/Component',
	'n/ui/widgets/helper/Dom',
	'n/ui/widgets/toolkit/Text'
], function (
	Class,
	Object,
	ImmutableObject,
	Component,
	Dom,
	Text
) {
	'use strict';

	var FieldWithHelp = Class.create({
		extend: Component,
		automationId: 'FieldHeader',

		/**
		 * @typedef {Component.Options} FieldWithHelp.Options
		 */

		/**
		 * @class FieldWithHelp
		 * @extends Component
		 * @param {FieldWithHelp.Options} [options] FieldHeader options
		 * @param {String} options.text
		 * @param {FieldHelpService} options.helpService
		 * @param {String} options.fieldId
		 * @param {String} options.parentId
		 * @param {String} options.variantId
		 * @param {String} options.automationId
		 * @param {FieldWithHelp.TYPE} [options.type = FieldHeader.TYPE.TEXT] text/label
		 */
		initialize: function FieldWithHelp(options) {
			options = ImmutableObject.merge(defaultOptions, options || {});
			FieldWithHelp.$super.call(this, options);
			this._text = options.text;
			this._helpService = options.helpService;
			this._fieldId = options.fieldId;
			this._parentId = options.parentId;
			this._variantId = options.variantId;
			this._type = options.type;
			this._automationId = options.automationId;
		},

		/** @lends FieldWithHelp# */
		properties: {},

		/** @lends FieldWithHelp# */
		methods: {
			getFieldLevelHelpOptions: function () {
				return {
					fieldId: this._fieldId,
					parentId: this._parentId
				};
			},
			_fieldLevelHelpResolved: function (fieldLevelHelp) {
				fieldLevelHelp.show(this._headerText);
			},
			_fieldLevelHelpFailed: function (args) {
				console.error("Field Level Help failed to load", args);
			},
			_buildText: function () {
				var text = this._text;
				if (this._type === FieldWithHelp.TYPE.LABEL) text = text.toUpperCase();
				return new Text({
					text: text,
					automationId: this._automationId,
					ariaLabel: this._automationId
				});
			}
		},

		/** @lends FieldWithHelp# */
		overrides: {
			_onRender: function () {
				this._headerText = this._buildText();
				var comp = Dom.div(undefined, this._headerText);

				if (this._fieldId) {
					comp.style.cursor = CURSOR.HELP;
				}
				return comp;
			},
			_onClick: function (args) {
				if (this._fieldId) {
					var fieldLevelHelpPromise = this._helpService.getFieldLevelHelp(this.getFieldLevelHelpOptions());
					fieldLevelHelpPromise.then(this._fieldLevelHelpResolved.bind(this)).catch(this._fieldLevelHelpFailed.bind(this));
				}
			}
		},
		static: {
			CURSOR: Object.freeze({
				HELP: 'help'
			}),
			TYPE: Object.freeze({
				TEXT: 'TEXT',
				LABEL: 'LABEL'
			})
		}
	});

	var defaultOptions = Object.freeze({
		variantId: undefined,
		type: FieldWithHelp.TYPE.TEXT,
		automationid: undefined
	});
	var CURSOR = FieldWithHelp.CURSOR;

	return FieldWithHelp;
});