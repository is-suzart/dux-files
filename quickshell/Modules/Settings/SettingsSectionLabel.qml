import QtQuick
import qs.Common
import qs.DCommon.Widgets

Item {
    id: root

    readonly property bool isSettingsSectionLabel: true

    property string text: ""
    property string iconName: ""

    Accessible.role: Accessible.StaticText
    Accessible.name: text

    width: parent?.width ?? 0
    height: Math.max(label.implicitHeight, icon.implicitHeight) + SettingsMetrics.sectionLabelTopGap + SettingsMetrics.sectionLabelBottomGap

    Row {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: (SettingsMetrics.sectionLabelTopGap - SettingsMetrics.sectionLabelBottomGap) / 2
        spacing: Theme.spacingS

        DIcon {
            id: icon
            anchors.verticalCenter: parent.verticalCenter
            visible: root.iconName !== ""
            name: root.iconName
            size: Theme.iconSizeSmall
            color: Theme.primary
        }

        StyledText {
            id: label
            anchors.verticalCenter: parent.verticalCenter
            width: root.iconName !== "" ? parent.width - icon.width - parent.spacing : parent.width
            text: root.text
            font.pixelSize: Theme.fontSizeMedium
            font.weight: Theme.fontWeightMedium
            color: Theme.primary
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignLeft
        }
    }
}
