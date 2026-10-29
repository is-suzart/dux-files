pragma ComponentBehavior: Bound

import QtQuick
import qs.Common
import qs.DCommon.Widgets

StyledButton {
    id: tab

    focusPolicy: Qt.TabFocus

    property string label: ""
    property bool current: false
    property bool closable: true
    property bool dragging: false

    signal closeRequested
    signal dropHovered
    signal dropped(var drop)
    signal menuRequested(real pointX, real pointY)

    readonly property color contentColor: current ? Theme.surfaceText : Theme.onSurfaceVariant

    implicitWidth: Math.max(FilesMetrics.tabMinWidth, Math.min(FilesMetrics.tabMaxWidth, title.implicitWidth + closeButton.width + Theme.spacingM * 2 + Theme.spacingS))
    implicitHeight: FilesMetrics.tabHeight
    topLeftRadius: Theme.cornerRadiusM
    topRightRadius: Theme.cornerRadiusM
    bottomLeftRadius: 0
    bottomRightRadius: 0
    border.width: Theme.layerOutlineWidth
    border.color: current ? Theme.outlineMedium : Theme.withAlpha(Theme.outlineMedium, 0.5)
    color: dragging ? Theme.surfaceContainerHighest : dropZone.containsDrag ? Theme.primaryContainer : current ? Theme.surfaceContainerLowest : "transparent"
    Accessible.role: Accessible.PageTab
    Accessible.name: label
    Accessible.selected: current

    StateLayer {
        control: tab
        stateColor: tab.contentColor
    }

    DropArea {
        id: dropZone

        anchors.fill: parent
        onEntered: hoverSwitch.restart()
        onExited: hoverSwitch.stop()
        onDropped: drop => {
            hoverSwitch.stop();
            tab.dropped(drop);
        }
    }

    Timer {
        id: hoverSwitch

        interval: FilesMetrics.tabHoverDelay
        onTriggered: tab.dropHovered()
    }

    TapHandler {
        acceptedButtons: Qt.MiddleButton
        onTapped: {
            if (tab.closable)
                tab.closeRequested();
        }
    }

    TapHandler {
        acceptedButtons: Qt.RightButton
        onTapped: point => tab.menuRequested(point.position.x, point.position.y)
    }

    Keys.onPressed: event => {
        const shifted = (event.modifiers & Qt.ShiftModifier) !== 0;
        if (event.key !== Qt.Key_Menu && !(event.key === Qt.Key_F10 && shifted))
            return;
        event.accepted = true;
        tab.menuRequested(tab.width / 2, tab.height / 2);
    }

    FocusRing {
        visible: tab.visualFocus
    }

    StyledText {
        id: title

        anchors.left: parent.left
        anchors.leftMargin: Theme.spacingM
        anchors.right: closeButton.left
        anchors.rightMargin: Theme.spacingXXS
        anchors.verticalCenter: parent.verticalCenter
        text: tab.label
        color: tab.contentColor
        font.pixelSize: Theme.fontSizeSmall
        font.weight: tab.current ? Theme.fontWeightMedium : Theme.fontWeight
        elide: Text.ElideMiddle
    }

    DActionButton {
        id: closeButton

        anchors.right: parent.right
        anchors.rightMargin: Theme.spacingXXS
        anchors.verticalCenter: parent.verticalCenter
        visible: tab.closable
        width: visible ? Theme.buttonHeightXXS : 0
        buttonSize: Theme.buttonHeightXXS
        iconName: "close"
        iconSize: Theme.iconSizeSmall
        iconColor: tab.contentColor
        tooltipText: I18n.tr("Close tab", "tooltip on the button closing a tab")
        onClicked: tab.closeRequested()
    }

}
