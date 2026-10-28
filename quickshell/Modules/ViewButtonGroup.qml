pragma ComponentBehavior: Bound

import QtQuick
import qs.Common
import qs.DCommon.Common
import qs.DCommon.Widgets
import qs.DCommon.FileBrowser

Row {
    id: group

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

    spacing: FileBrowserMetrics.navPairGap
    LayoutMirroring.enabled: I18n.isRtl
    LayoutMirroring.childrenInherit: true

    component Segment: StyledButton {
        id: segment

        focusPolicy: Qt.TabFocus
        property int position: 0 // 0: leading, 1: middle, 2: trailing
        property bool selected: false
        property string iconName: ""
        property string tooltipText: ""
        readonly property real outerRadius: Style.fullRadius(FileBrowserMetrics.navPairSegmentWidth, FileBrowserMetrics.controlSize)
        readonly property real innerRadius: FileBrowserMetrics.navPairInnerRadius

        readonly property real leftRad: position === 0 ? outerRadius : innerRadius
        readonly property real rightRad: position === 2 ? outerRadius : innerRadius

        width: FileBrowserMetrics.navPairSegmentWidth
        height: FileBrowserMetrics.controlSize
        color: selected ? Style.selectedContainer : Style.chipSurface
        topLeftRadius: mirrored ? rightRad : leftRad
        bottomLeftRadius: mirrored ? rightRad : leftRad
        topRightRadius: mirrored ? leftRad : rightRad
        bottomRightRadius: mirrored ? leftRad : rightRad
        Accessible.name: tooltipText

        StateLayer {
            control: segment
            disabled: !segment.enabled
            stateColor: segment.selected ? Style.onSelectedContainer : Style.surfaceText
            tooltipText: segment.tooltipText
        }

        DIcon {
            anchors.centerIn: parent
            name: segment.iconName
            size: Style.iconSizeMedium
            color: segment.selected ? Style.onSelectedContainer : Style.surfaceText
        }

        FocusRing {
            visible: segment.visualFocus
            radius: segment.outerRadius
        }
    }

    Repeater {
        model: group.modes

        Segment {
            required property int index
            required property var modelData

            position: index === 0 ? 0 : (index === group.modes.length - 1 ? 2 : 1)
            selected: group.viewMode === modelData.value
            iconName: modelData.icon
            tooltipText: modelData.label
            onClicked: group.viewModeSelected(modelData.value)
        }
    }
}

