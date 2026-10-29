pragma ComponentBehavior: Bound

import QtQuick
import qs.Common
import qs.Services
import qs.DCommon.Widgets
import qs.DCommon.FileBrowser

FilePlaceSection {
    id: section

    property string busyId: ""

    signal navigateRequested(string path)
    signal tabRequested(string path)
    signal dropRequested(string path, var drop)
    signal connectRequested

    readonly property bool sectionVisible: !SettingsData.hiddenSidebarSections.includes("network") || SettingsData.showHiddenSidebarSections
    visible: sectionVisible
    isHiddenSection: SettingsData.hiddenSidebarSections.includes("network")
    onHeaderClicked: {
        if (SettingsData.hiddenSidebarSections.includes("network"))
            SettingsData.hiddenSidebarSections = SettingsData.hiddenSidebarSections.filter(s => s !== "network");
        else
            SettingsData.hiddenSidebarSections = SettingsData.hiddenSidebarSections.concat(["network"]);
    }

    title: I18n.tr("Network", "sidebar section listing remote locations")
    iconName: "language"
    emptyText: {
        if (NetworkService.available)
            return "";
        if (!SandboxService.loaded)
            return "";
        if (!SandboxService.available("network"))
            return FilesFormat.featureUnavailable(SandboxService.reason("network"));
        return I18n.tr("Network locations are unavailable because gvfs is not running", "sidebar explanation when the network service is missing");
    }
    showEmpty: true

    Repeater {
        model: NetworkService.networkMounts

        FilePlaceRow {
            required property var modelData
            required property int index

            isFirstInGroup: index === 0
            isLastInGroup: !NetworkService.available && index === NetworkService.networkMounts.length - 1
            label: modelData.name
            iconName: modelData.iconName
            actionIcon: "eject"
            actionTooltip: I18n.tr("Disconnect", "network mount action")
            busy: section.busyId === modelData.id
            dropPath: modelData.path
            onClicked: section.navigateRequested(modelData.path)
            onMiddleClicked: section.tabRequested(modelData.path)
            onDropped: drop => section.dropRequested(modelData.path, drop)
            onSpringLoaded: section.navigateRequested(modelData.path)
            onActionTriggered: {
                section.busyId = modelData.id;
                NetworkService.disconnect(modelData.id, () => section.busyId = "");
            }
        }
    }

    FilePlaceRow {
        visible: NetworkService.available
        isFirstInGroup: NetworkService.networkMounts.length === 0
        isLastInGroup: true
        label: I18n.tr("Connect to Server…", "sidebar entry opening the connect to server dialog")
        iconName: "folder-remote"
        busy: NetworkService.connecting
        onClicked: section.connectRequested()
    }
}
