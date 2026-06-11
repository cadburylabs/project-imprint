define('n/suitescript-ui/spa/manage/presenter/MenuPresenter', [
    'n/ui/classes/Class',
    'n/ui/classes/Object',
    'n/ui/compounds/app/Presenter',
    'n/ui/compounds/component/NavigationDrawer',
    'n/ui/widgets/image/SystemIcon',
    'n/suitescript-ui/spa/manage/TranslationKeys',
    'n/suitescript-ui/spa/RouteList',
    'n/suitescript-ui/spa/ServiceList',
    'n/suitescript-ui/spa/manage/Navigation',
], function (
    Class,
    Object,
    Presenter,
    NavigationDrawer,
    SystemIcon,
    TranslationKeys,
    RouteList,
    ServiceList,
    Navigation,
) {
    'use strict';

    /**
     * @class
     * @extends Presenter
     */
    class MenuPresenter extends Presenter {

        constructor(options) {
            super(options);
        }

        _onCreateView() {
            const router = this.services.get(ServiceList.ROUTER);
            this._navigation = new NavigationDrawer({
                selectedValue: this.state.router.tab,
                items: [
                    {
                        value: Navigation.BASIC_INFO,
                        label: this.i18n.get(TranslationKeys.SPA_MANAGE_MENU_ITEM_BASIC_INFO),
                        icon: SystemIcon.LIST,
                        action: () => {
                            router.routeTo(RouteList.MANAGE_BASIC_INFO, router._activeParams);
                        },
                        automationId: AutomationId.BASIC_INFO,
                    },
                    {
                        value: Navigation.CONFIGURATION,
                        label: this.i18n.get(TranslationKeys.SPA_MANAGE_MENU_ITEM_CONFIGURATION),
                        icon: SystemIcon.SETTINGS,
                        action: () => {
                            router.routeTo(RouteList.MANAGE_CONFIGURATION, router._activeParams);
                        },
                        automationId: AutomationId.CONFIGURATION,
                    },
                    {
                        value: Navigation.LOGS,
                        label: this.i18n.get(TranslationKeys.SPA_MANAGE_MENU_ITEM_LOGS),
                        icon: SystemIcon.ALERT,
                        action: () => {
                            router.routeTo(RouteList.MANAGE_LOGS, router._activeParams);
                        },
                        automationId: AutomationId.LOGS,
                    },
                    {
                        value: Navigation.AUDIT_TRAIL,
                        label: this.i18n.get(TranslationKeys.SPA_MANAGE_MENU_ITEM_AUDIT_TRAIL),
                        icon: SystemIcon.EDIT_LOG,
                        action: () => {
                            router.routeTo(RouteList.MANAGE_AUDIT_TRAIL, router._activeParams);
                        },
                        automationId: AutomationId.AUDIT_TRAIL,
                    }
                ]
            });

            return this._navigation;
        }

        _onStateChanged(oldState, currentState) {
            if (oldState.router.tab !== currentState.router.tab) {
                this._navigation.selectedValue = currentState.router.tab;
            }
        }
    }

    const AutomationId = {
        BASIC_INFO: "manage-spa-menu-item-button-dashboard",
        CONFIGURATION: "manage-spa-menu-item-button-configuration",
        LOGS: "manage-spa-menu-item-button-logs",
        AUDIT_TRAIL: "manage-spa-menu-item-button-audit-trail"
    };

    return MenuPresenter;
});
