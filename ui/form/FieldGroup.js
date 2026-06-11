/*
 * Copyright © 2026, Oracle and/or its affiliates.
 */

/**
 * Description:
 *
 * Copyright:    Copyright (c) 1999-2015
 * Company:      NetLedger, Inc.
 *
 * @author       vsara
 */
define('n/ui/form/FieldGroup', [
    'n/ui/classes/Array',
    'n/ui/classes/Class',
    'n/ui/classes/Number',
    'n/ui/classes/Object',
    'n/ui/classes/Type',
    'n/ui/widgets/Component',
    'n/ui/widgets/helper/Dom',
    'n/ui/widgets/toolkit/StackPanel',
    'n/ui/widgets/toolkit/FieldGroup',
	'n/ui/classes/Function',
], function (
    Array,
    Class,
    Number,
    NObject,
    Type,
    Component,
    Dom,
    StackPanel,
    FieldGroupUIF,
    Function
) {
    'use strict';

    var defaultOptions = NObject.freeze({
        label: null,
        focusable: false,
        responsiveColumns: false,
        classList: ['n-w-group', 'n-f-fieldgroup'],
	    onExpanded: Function.VOID,
	    collapsed: false,
    });

    var FieldGroup = Class.create({
        automationId: 'FieldGroup',
        extend: Component,
        /**
         * @class FieldGroup
         * @extends Component
         * @param {Object} options
         */
        initialize: function FieldGroup(options) {
            var settings = NObject.deepExtend({}, defaultOptions, options);
            FieldGroup.$super.call(this, settings);
            this._responsiveColumns = settings.responsiveColumns;
            this._label = settings.label;
            this._columnContainer = new StackPanel({
                orientation: StackPanel.Orientation.HORIZONTAL,
                alignment: StackPanel.Alignment.STRETCH,
                classList: ['n-w-group-content', 'n-f-fieldgroup-content']
            });
            this._placeHolderColumns = [];
            this.addColumn();
            this._headerElement = Function.VOID;
			this._onExpanded = settings.onExpanded;
			this._collapsed = settings.collapsed;
        },

        /** @lends FieldGroup */
        properties: {
            currentColumn: {
                set: function (column) {
                    var columns = this._columnContainer.components;
                    if (NObject.isNumber(column) && Number.isValidIndex(column, columns.length)) {
                        this._currentColumn = columns[column];
                    } else if (columns.indexOf(column) !== -1) {
                        this._currentColumn = column;
                    }
                }
            },

            headerElement: {}
        },

        /** @lends FieldGroup */
        methods: {
            /**
             * Create new column
             * @returns {StackPanel}
             * @private
             */
            _createColumn: function () {
                return new StackPanel({
                    // alignment must be STRETCH (default value) to keep element panel width in FG column
                    orientation: StackPanel.Orientation.VERTICAL,
                    onDecorateWrapper: function (args) {
                        if (Type.Value.is(args.layoutOptions.elementClass)) {
                            args.wrapper.classList.add(args.layoutOptions.elementClass);
                        }
                    },
                    classList: 'n-f-fieldgroup-column',
                });
            },


            /**
             * Create and add new column to group
             * @returns {StackPanel}
             */
            addColumn: function () {
                this._currentColumn = this._createColumn();
                this._columnContainer.add({
                    component: this._currentColumn,
                    options: {grow: 1, basis: '0px'}
                });
                return this._currentColumn;
            },

            /**
             * Add item to current column
             * @param {Object} desc
             */
            add: function (desc) {
                var that = this;
                if (desc.createNewColumn) {
                    this.addColumn();
                }
                this._currentColumn.add(desc.component);
                var currentColumn = this._currentColumn;

                if (this._responsiveColumns) {
                    desc.component.onPropertyChanged('visible', function (args) {
                        that._onItemVisibilityChanged(currentColumn);
                    });
                }
            },

            changeColumnVisibility: function (column, visible) {
                var itemToChange = null;
                if (Component.is(column)) {
                    itemToChange = column;
                } else if (Type.NonNegativeInteger.is(column) && column < this._columnContainer.components.length) {
                    itemToChange = this._columnContainer.components[column];
                }

                if (Type.Value.is(itemToChange) && itemToChange.visible !== visible) {
                    itemToChange.visible = visible;

                    if (visible) {
                        var placeHolderToRemove = this._placeHolderColumns.pop();
                        if (Type.Value.is(placeHolderToRemove)) {
                            this._columnContainer.remove(placeHolderToRemove);
                        }
                    } else {
                        this._placeHolderColumns.push(this.addColumn());
                    }
                }
            },

            _onItemVisibilityChanged: function (column) {
                var hasVisibleItem = Array.findFirst(column.components, function (item) {
                    return item.visible === true;
                }).found;

                // has visible at alest one item
                if (hasVisibleItem && !column.visible) {
                    this.changeColumnVisibility(column, true);
                } else if (!hasVisibleItem && column.visible) {
                    this.changeColumnVisibility(column, false);
                }
            }
        },

        /** @lends FieldGroup */
        overrides: {
            _onRender: function _onRender() {
	            let component = null;
                if (Type.Value.is(this._label)) {
                    component = new FieldGroupUIF({
                        title: this._label,
                        content: this._columnContainer,
                        rootAttributes: {
                            'data-walkthrough': 'FieldGroup:' + this._label
                        },
	                    collapsible: true,
	                    collapsed: this._collapsed,
	                    onExpanded: this._onExpanded,
                    });
	                this._headerElement = () => component.rootElement.querySelector("[data-widget-section='title']");
                } else {
	                component = Dom.div(null, this._columnContainer);
	                this._headerElement = () => component;
                }

				return component;
            }
        }
    });

    return FieldGroup;
});
