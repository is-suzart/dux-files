pragma ComponentBehavior: Bound

import QtQuick
import qs.Common
import qs.DCommon.Common
import qs.DCommon.Widgets
import qs.DCommon.FileBrowser

Item {
    id: control

    property string viewMode: "list"
    signal viewModeSelected(string mode)

    readonly property var modes: [
        {
            "value": "list",
            "icon": "view_list",
            "label": I18n.tr("List view", "view mode showing one row per item")
        },
        {
            "value": "grid",
            "icon": "grid_view",
            "label": I18n.tr("Grid view", "view mode showing items as tiles")
        },
        {
            "value": "columns",
            "icon": "view_column",
            "label": I18n.tr("Column view", "view mode showing folders side by side")
        }
    ]

    readonly property var current: modes.find(entry => entry.value === viewMode) ?? modes[0]
    readonly property bool menuOpen: menu.menuVisible

    function openMenu() {
        menu.currentValue = current.label;
        menu.openDropdownMenu();
    }

    implicitWidth: FileBrowserMetrics.controlSize
    implicitHeight: FileBrowserMetrics.controlSize

    StyledButton {
        id: button

        anchors.fill: parent
        focusPolicy: Qt.TabFocus
        color: Style.chipSurface
        border.width: Style.layerOutlineWidth
        border.color: Style.outlineMedium
        radius: Style.fullRadius(width, height)
        Accessible.name: I18n.tr("View", "keyboard shortcut group")
        Accessible.description: control.current.label
        onClicked: control.openMenu()

        Keys.onDownPressed: event => {
            control.openMenu();
            event.accepted = true;
        }

        Rectangle {
            anchors.fill: parent
            visible: control.menuOpen
            radius: button.radius
            color: Style.withAlpha(Style.surfaceText, Style.stateLayerPressed)
        }

        StateLayer {
            control: button
            stateColor: Style.surfaceText
            tooltipText: button.tooltipText
        }

        DIcon {
            anchors.centerIn: parent
            name: control.current.icon
            size: Style.iconSizeMedium
            color: Style.surfaceText
        }

        FocusRing {
            visible: button.visualFocus
            radius: button.radius
        }

        DDropdown {
            id: menu

            showTrigger: false
            popupAnchorItem: control
            focusReturnTarget: button
            alignPopupRight: !I18n.isRtl
            popupWidth: FileBrowserMetrics.menuWidth
            options: control.modes.map(entry => entry.label)
            optionIcons: control.modes.map(entry => entry.icon)
            onValueChanged: value => {
                const index = options.indexOf(value);
                if (index < 0)
                    return;
                control.viewModeSelected(control.modes[index].value);
            }
        }
    }
}
