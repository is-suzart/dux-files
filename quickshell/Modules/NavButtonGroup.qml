pragma ComponentBehavior: Bound

import QtQuick
import qs.Common
import qs.DCommon.Common
import qs.DCommon.Widgets
import qs.DCommon.FileBrowser

Row {
    id: navGroup

    property bool backEnabled: false
    property bool forwardEnabled: false
    property bool upEnabled: false

    signal backRequested
    signal forwardRequested
    signal upRequested

    spacing: FileBrowserMetrics.navPairGap
    LayoutMirroring.enabled: I18n.isRtl
    LayoutMirroring.childrenInherit: true

    component Segment: StyledButton {
        id: segment

        focusPolicy: Qt.TabFocus
        property int position: 0 // 0: leading, 1: middle, 2: trailing
        property string iconName: ""
        property string tooltipText: ""
        readonly property real outerRadius: Style.fullRadius(FileBrowserMetrics.navPairSegmentWidth, FileBrowserMetrics.controlSize)
        readonly property real innerRadius: FileBrowserMetrics.navPairInnerRadius

        readonly property real leftRad: position === 0 ? outerRadius : innerRadius
        readonly property real rightRad: position === 2 ? outerRadius : innerRadius

        width: FileBrowserMetrics.navPairSegmentWidth
        height: FileBrowserMetrics.controlSize
        color: enabled ? Style.chipSurface : Style.onSurface_12
        topLeftRadius: mirrored ? rightRad : leftRad
        bottomLeftRadius: mirrored ? rightRad : leftRad
        topRightRadius: mirrored ? leftRad : rightRad
        bottomRightRadius: mirrored ? leftRad : rightRad
        Accessible.name: tooltipText

        StateLayer {
            control: segment
            disabled: !segment.enabled
            stateColor: Style.surfaceText
            tooltipText: segment.tooltipText
        }

        DIcon {
            anchors.centerIn: parent
            name: segment.iconName
            size: Style.iconSizeMedium
            color: segment.enabled ? Style.surfaceText : Style.onSurface_38
        }

        FocusRing {
            visible: segment.visualFocus
            radius: segment.outerRadius
        }
    }

    Segment {
        position: 0
        enabled: navGroup.backEnabled
        iconName: I18n.isRtl ? "arrow_forward" : "arrow_back"
        tooltipText: I18n.tr("Back", "tooltip on the button going to the previous location")
        onClicked: navGroup.backRequested()
    }

    Segment {
        position: 1
        enabled: navGroup.forwardEnabled
        iconName: I18n.isRtl ? "arrow_back" : "arrow_forward"
        tooltipText: I18n.tr("Forward", "tooltip on the button going to the next location")
        onClicked: navGroup.forwardRequested()
    }

    Segment {
        position: 2
        enabled: navGroup.upEnabled
        iconName: "arrow_upward"
        tooltipText: I18n.tr("Go to the parent folder", "keyboard shortcut")
        onClicked: navGroup.upRequested()
    }
}

