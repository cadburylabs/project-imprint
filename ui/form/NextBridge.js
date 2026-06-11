/*
 * Copyright © 2026, Oracle and/or its affiliates.
 */

define('n/ui/form/NextBridge', [
	'n/ui/form/actions/ActionContext',
	'N/currentRecord'
], function (
	ActionContext,
	currentRecord
) {
	'use strict';

	class NextBridge {
		constructor(options) {
			const { formDefinition, actionService } = options;
			this._formDefinition = formDefinition;
			this._actionService = actionService;
			this._listeners = {};
			this._eventQueue = {};
		}

		initialize() {
			window.NS?.NextBridge?.initialize(this);
		}

		getMetadata() {
			const {recordId, recordType, recordScriptId, formMode, copy: isCopy, title, actionsDefinition} = this._formDefinition;
			const FORM = {
				recordId,
				recordType,
				recordScriptId,
				formMode,
				isCopy,
				title,
				actionsDefinition,
			};

			return { FORM };
		}

		getCurrentRecord(){
			return currentRecord.get();
		}

		runAction(id) {
			const sections = this._formDefinition.actionsDefinition?.sections ?? [];
			const actions = sections.flatMap((section) => section.actions);

			for (const action of actions) {
				if (action.buttonName === id) {
					this.#invokeAction(action);
				}

				for (const child of action.children ?? []) {
					if (child.buttonName === id) {
						this.#invokeAction(child);
					}
				}
			}
		}

		#invokeAction(action) {
			const context = new ActionContext({
				triggerType: ActionContext.TriggerType.FORM_ACTION
			});
			this._actionService.executeAction(action, context);
		}

		notify(eventName, payload) {
			if (this._listeners[eventName] && this._listeners[eventName].length > 0) {
				this._listeners[eventName].forEach((listener) => listener(payload));
			} else {
				if (!this._eventQueue[eventName]) {
					this._eventQueue[eventName] = [];
				}
				this._eventQueue[eventName].push(payload);
			}
		}

		addEventListener(eventName, listener) {
			const eventListeners = this._listeners[eventName];
			if (!eventListeners) {
				this._listeners[eventName] = [listener];
			} else {
				this._listeners[eventName] = [...eventListeners, listener];
			}

			// Flush any queued events for this eventName
			if (this._eventQueue[eventName] && this._eventQueue[eventName].length > 0) {
				this._eventQueue[eventName].forEach((queuedPayload) => setTimeout(() => listener(queuedPayload), 0));
				delete this._eventQueue[eventName];
			}

			return () => this.removeEventListener(eventName, listener);
		}

		removeEventListener(eventName, listener) {
			this._listeners[eventName] = this._listeners[eventName]?.filter(
				(registeredHandler) => registeredHandler !== listener
			);
		}
	}

	return NextBridge;
});
