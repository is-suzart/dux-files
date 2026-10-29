import QtQuick
import qs.Common
import qs.Services
import qs.DCommon.FileBrowser

FileMenu {
    id: menu

    property var device: null

    signal tabRequested(string path)
    signal windowRequested(string path)
    signal activateRequested(var device)
    signal detachRequested(var device)

    function present(targetDevice, source, pointX, pointY) {
        device = targetDevice;
        const point = source.mapToItem(anchorItem, pointX, pointY);
        openAt(point.x, point.y);
    }

    FileMenuItem {
        visible: Boolean(menu.device && menu.device.mounted && menu.device.mountPoint)
        text: I18n.tr("Open in new tab", "context menu entry opening a folder in a new tab")
        iconName: "tab"
        onClicked: {
            menu.close();
            if (menu.device && menu.device.mountPoint)
                menu.tabRequested(menu.device.mountPoint);
        }
    }

    FileMenuItem {
        visible: Boolean(menu.device && menu.device.mounted && menu.device.mountPoint)
        text: I18n.tr("Open in new window", "context menu entry opening a folder in another window")
        iconName: "open_in_new"
        onClicked: {
            menu.close();
            if (menu.device && menu.device.mountPoint)
                menu.windowRequested(menu.device.mountPoint);
        }
    }

    FileMenuDivider {
        visible: Boolean(menu.device && menu.device.mounted && menu.device.mountPoint)
    }

    FileMenuItem {
        visible: Boolean(menu.device && !menu.device.mounted && (!menu.device.encrypted || menu.device.unlocked))
        text: I18n.tr("Mount", "device action")
        iconName: "play_arrow"
        onClicked: {
            menu.close();
            menu.activateRequested(menu.device);
        }
    }

    FileMenuItem {
        visible: Boolean(menu.device && menu.device.encrypted && !menu.device.unlocked)
        text: I18n.tr("Unlock", "unlock dialog header for an encrypted device")
        iconName: "lock_open"
        onClicked: {
            menu.close();
            menu.activateRequested(menu.device);
        }
    }

    FileMenuItem {
        visible: Boolean(menu.device && menu.device.encrypted && menu.device.unlocked)
        text: I18n.tr("Lock", "device action")
        iconName: "lock"
        onClicked: {
            menu.close();
            menu.detachRequested(menu.device);
        }
    }

    FileMenuItem {
        visible: Boolean(menu.device && (menu.device.ejectable || menu.device.canPowerOff))
        text: I18n.tr("Eject", "device action")
        iconName: "eject"
        onClicked: {
            menu.close();
            menu.detachRequested(menu.device);
        }
    }

    FileMenuItem {
        visible: Boolean(menu.device && menu.device.mounted && !menu.device.system && !menu.device.protected && !menu.device.ejectable && !menu.device.canPowerOff)
        text: I18n.tr("Unmount", "device action")
        iconName: "stop_circle"
        onClicked: {
            menu.close();
            menu.detachRequested(menu.device);
        }
    }

    FileMenuDivider {}

    FileMenuItem {
        readonly property string key: menu.device?.id || menu.device?.mountPoint || ""
        visible: Boolean(key && !SettingsData.hiddenSidebarPlaces.includes(key))
        text: I18n.tr("Hide from sidebar", "sidebar place context menu action to hide item")
        iconName: "visibility_off"
        onClicked: {
            menu.close();
            if (key && !SettingsData.hiddenSidebarPlaces.includes(key))
                SettingsData.hiddenSidebarPlaces = SettingsData.hiddenSidebarPlaces.concat([key]);
        }
    }

    FileMenuItem {
        readonly property string key: menu.device?.id || menu.device?.mountPoint || ""
        visible: Boolean(key && SettingsData.hiddenSidebarPlaces.includes(key))
        text: I18n.tr("Unhide from sidebar", "sidebar place context menu action to unhide item")
        iconName: "visibility"
        onClicked: {
            menu.close();
            if (key)
                SettingsData.hiddenSidebarPlaces = SettingsData.hiddenSidebarPlaces.filter(p => p !== key && p !== menu.device?.id && p !== menu.device?.mountPoint);
        }
    }
}
