pragma ComponentBehavior: Bound

import QtQuick
import qs.Common
import qs.Services
import qs.DCommon.Widgets
import qs.DCommon.FileBrowser
import "../DCommon/FileBrowser/PathCompletion.js" as PathCompletion

Item {
    id: topbar

    property bool splitView: false
    property bool backEnabled: false
    property bool forwardEnabled: false
    property bool upEnabled: false
    property bool compact: false
    property string viewMode: "list"
    property bool previewOpen: false
    property bool previewExpandable: false
    property string sortKey: "name"
    property bool sortDescending: false
    property bool trashActive: false
    property bool recentActive: false
    property string filterText: ""
    property string currentPath: ""
    property bool searchFocused: false
    property bool editing: false
    readonly property bool pathInput: isLocation(search.text)
    property var completions: []
    property int completionRequest: 0
    readonly property var completionTarget: editing && pathInput ? PathCompletion.target(search.text, currentPath, FilePaths.home) : null
    readonly property var pathSuggestions: completionTarget ? PathCompletion.rank(completions, completionTarget, FilePaths.home, FileBrowserMetrics.suggestionCap) : []

    onCompletionTargetChanged: fetchCompletions()

    function fetchCompletions() {
        const request = ++completionRequest;
        completions = [];
        const target = completionTarget;
        if (!target)
            return;
        DirectoryService.list(target.dir, {
            limit: FileBrowserMetrics.completionLimit,
            includeHidden: target.prefix.startsWith("."),
            dirsFirst: true,
            sortKey: "name"
        }, result => {
            if (request === completionRequest)
                completions = result.error ? [] : (result.entries || []).filter(entry => entry.isDir);
        });
    }

    function isLocation(text) {
        const value = text.trim();
        return value.startsWith("/") || value === "~" || value.startsWith("~/") || value === "." || value === ".." || value.startsWith("./") || value.startsWith("../") || PathCompletion.isUri(value);
    }

    function focusLocation() {
        editing = true;
        search.text = currentPath;
        search.forceActiveFocus();
        search.selectAll();
    }
    property bool folderRemembered: false
    property bool folderHasSettings: false

    readonly property bool virtualActive: trashActive || recentActive
    readonly property var viewModes: [
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
    readonly property string previewLabel: I18n.tr("Preview", "view menu entry and shortcut showing or hiding the preview drawer")
    readonly property string previewExpandLabel: I18n.tr("Open the preview in a large view", "keyboard shortcut opening the preview overlay")
    readonly property string useForAllLabel: I18n.tr("Use these settings for all folders", "view menu entry making this folder's sort and view the defaults")
    readonly property string resetFolderLabel: I18n.tr("Reset this folder", "view menu entry dropping this folder's own sort and view")
    readonly property var currentViewMode: viewModes.find(mode => mode.value === viewMode) ?? viewModes[0]
    property bool resultsActive: false
    readonly property var resultSortKeys: [
        {
            "key": "",
            "icon": "sort",
            "label": I18n.tr("Relevance", "sort criterion for search results, best match first")
        },
        {
            "key": "name",
            "icon": "sort_by_alpha",
            "label": FileColumns.label("name")
        },
        {
            "key": "mtime",
            "icon": "history",
            "label": FileColumns.label("modified")
        },
        {
            "key": "size",
            "icon": "straighten",
            "label": FileColumns.label("size")
        },
        {
            "key": "location",
            "icon": "folder_open",
            "label": FileColumns.label("location")
        }
    ]
    readonly property var sortKeys: sortButton.defaultKeys
    readonly property var trashSortKeys: [
        {
            "key": "deleted",
            "icon": "delete",
            "label": FileColumns.label("deleted")
        },
        {
            "key": "name",
            "icon": "sort_by_alpha",
            "label": FileColumns.label("name")
        },
        {
            "key": "origin",
            "icon": "folder_open",
            "label": FileColumns.label("origin")
        },
        {
            "key": "size",
            "icon": "straighten",
            "label": FileColumns.label("size")
        }
    ]
    readonly property var recentSortKeys: [
        {
            "key": "used",
            "icon": "schedule",
            "label": FileColumns.label("used")
        },
        {
            "key": "name",
            "icon": "sort_by_alpha",
            "label": FileColumns.label("name")
        },
        {
            "key": "location",
            "icon": "folder_open",
            "label": FileColumns.label("location")
        },
        {
            "key": "mtime",
            "icon": "history",
            "label": FileColumns.label("modified")
        },
        {
            "key": "size",
            "icon": "straighten",
            "label": FileColumns.label("size")
        }
    ]
    readonly property var activeSortKeys: {
        switch (true) {
        case resultsActive:
            return resultSortKeys;
        case trashActive:
            return trashSortKeys;
        case recentActive:
            return recentSortKeys;
        default:
            return sortKeys;
        }
    }
    readonly property var recentSuggestions: searchFocused && search.text === "" ? FolderHistory.top(FileBrowserMetrics.suggestionRows, currentPath).map(match => PathCompletion.row(match, "visited")) : []

    signal sidebarToggled
    signal backRequested
    signal forwardRequested
    signal upRequested
    signal splitToggled
    signal viewModeSelected(string mode)
    signal zoomRequested(int step)
    signal previewToggled
    signal previewExpandRequested
    signal sortKeySelected(string key)
    signal sortDirectionToggled
    signal useForAllFoldersRequested
    signal resetFolderRequested
    signal propertiesRequested
    signal newWindowRequested
    signal copyPathRequested
    signal reloadRequested
    signal terminalRequested
    signal settingsRequested
    signal shortcutsRequested
    signal filterChanged(string text)
    signal searchRequested(string query)
    signal searchCleared
    signal locationRequested(var location)
    signal tabRequested(string path)
    signal resultsRequested

    function focusSearch() {
        editing = true;
        search.forceActiveFocus();
        search.selectAll();
    }

    function openFilter(text) {
        search.text = filterText + text;
        focusFilter();
    }

    function focusFilter() {
        editing = true;
        search.forceActiveFocus();
        search.cursorPosition = search.text.length;
    }

    function searchContains(x, y) {
        return search.contains(search.mapFromItem(topbar, x, y));
    }

    function resetInput() {
        editing = false;
        search.text = "";
        filterChanged("");
    }

    function clearSearch() {
        resetInput();
        searchCleared();
    }

    onCurrentPathChanged: resetInput()

    function openRecent(path) {
        DirectoryService.resolveLocation(path, currentPath, result => {
            if (result.error) {
                if (result.code === "ENOENT")
                    FolderHistory.forget(path);
                ToastService.info(FileFormat.operationError(result.code, result.error));
                return;
            }
            topbar.editing = false;
            search.text = "";
            topbar.locationRequested(result.location);
        });
    }

    function cycleSortKey() {
        const keys = activeSortKeys;
        const index = keys.findIndex(entry => entry.key === sortKey);
        sortKeySelected(keys[(index + 1) % keys.length].key);
    }

    onRecentSuggestionsChanged: {
        if (recentSuggestions.length > 0)
            FolderHistory.verify(recentSuggestions.map(row => row.path));
    }

    onFilterTextChanged: {
        if (!pathInput && search.text !== filterText)
            search.text = filterText;
    }

    implicitHeight: FilesMetrics.topbarControlSize
    LayoutMirroring.enabled: I18n.isRtl
    LayoutMirroring.childrenInherit: true

    Row {
        id: leftActions

        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        spacing: FilesMetrics.topbarGroupSpacing

        NavButtonGroup {
            anchors.verticalCenter: parent.verticalCenter
            backEnabled: topbar.backEnabled
            forwardEnabled: topbar.forwardEnabled
            upEnabled: topbar.upEnabled
            onBackRequested: topbar.backRequested()
            onForwardRequested: topbar.forwardRequested()
            onUpRequested: topbar.upRequested()
        }
    }

    Row {
        id: rightActions

        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: FilesMetrics.topbarSpacing

        FlatButton {
            anchors.verticalCenter: parent.verticalCenter
            visible: !topbar.compact
            iconName: "refresh"
            tooltipText: I18n.tr("Reload", "menu entry re-reading the current folder")
            onClicked: topbar.reloadRequested()
        }

        ViewButtonGroup {
            anchors.verticalCenter: parent.verticalCenter
            visible: !topbar.compact
            viewMode: topbar.viewMode
            onViewModeSelected: mode => topbar.viewModeSelected(mode)
        }

        FileSortButton {
            id: sortButton

            anchors.verticalCenter: parent.verticalCenter
            keys: topbar.activeSortKeys
            sortKey: topbar.sortKey
            descending: topbar.sortDescending
            showLabel: false
            onSortKeySelected: key => topbar.sortKeySelected(key)
            onDirectionToggled: topbar.sortDirectionToggled()
        }

        FlatButton {
            id: overflowButton

            anchors.verticalCenter: parent.verticalCenter
            iconName: "more_vert"
            tooltipText: I18n.tr("More actions", "tooltip on the overflow menu button")
            onClicked: menu.toggle(overflowButton, "more")
        }

        FileMenu {
            id: menu

            property Item anchor: overflowButton
            property string section: "more"

            readonly property bool viewOnly: section === "view"
            readonly property bool viewRows: viewOnly || topbar.compact
            readonly property bool moreRows: section === "more"
            readonly property bool compactRows: moreRows && topbar.compact
            readonly property bool folderRows: viewRows && topbar.folderRemembered

            x: anchor.x + anchor.width - width
            y: anchor.y + anchor.height + Theme.spacingXS

            function toggle(button, which) {
                if (visible && section === which) {
                    close();
                    return;
                }
                anchor = button;
                section = which;
                open();
            }

            function pick(action) {
                close();
                action();
            }

            Repeater {
                model: topbar.viewModes

                FileMenuItem {
                    required property var modelData

                    visible: menu.viewRows
                    text: modelData.label
                    iconName: modelData.icon
                    checked: topbar.viewMode === modelData.value
                    onClicked: menu.pick(() => topbar.viewModeSelected(modelData.value))
                }
            }

            FileMenuDivider {
                visible: menu.viewOnly
            }

            FileMenuItem {
                visible: menu.viewRows
                text: I18n.tr("Zoom in", "menu entry making the file view bigger")
                iconName: "zoom_in"
                onClicked: topbar.zoomRequested(1)
            }

            FileMenuItem {
                visible: menu.viewRows
                text: I18n.tr("Zoom out", "menu entry making the file view smaller")
                iconName: "zoom_out"
                onClicked: topbar.zoomRequested(-1)
            }

            FileMenuDivider {
                visible: menu.viewOnly
            }

            FileMenuItem {
                visible: menu.viewRows
                text: topbar.previewLabel
                iconName: "view_sidebar"
                checked: topbar.previewOpen
                onClicked: menu.pick(() => topbar.previewToggled())
            }

            FileMenuItem {
                visible: menu.viewRows && topbar.previewExpandable
                text: topbar.previewExpandLabel
                iconName: "open_in_full"
                onClicked: menu.pick(() => topbar.previewExpandRequested())
            }

            FileMenuItem {
                visible: menu.compactRows
                text: I18n.tr("Split view", "tooltip on the button showing a second pane")
                iconName: "splitscreen_vertical_add"
                checked: topbar.splitView
                onClicked: menu.pick(() => topbar.splitToggled())
            }

            FileMenuDivider {
                visible: menu.viewOnly && topbar.folderRemembered
            }

            FileMenuItem {
                visible: menu.folderRows
                text: topbar.useForAllLabel
                iconName: "done_all"
                onClicked: menu.pick(() => topbar.useForAllFoldersRequested())
            }

            FileMenuItem {
                visible: menu.folderRows
                enabled: topbar.folderHasSettings
                text: topbar.resetFolderLabel
                iconName: "restart_alt"
                onClicked: menu.pick(() => topbar.resetFolderRequested())
            }

            FileMenuItem {
                visible: menu.moreRows
                text: I18n.tr("New window", "menu entry opening another file manager window")
                iconName: "open_in_new"
                onClicked: menu.pick(() => topbar.newWindowRequested())
            }

            FileMenuItem {
                visible: menu.moreRows
                enabled: !topbar.virtualActive
                text: I18n.tr("Properties", "menu entry showing details about the current folder")
                iconName: "info"
                onClicked: menu.pick(() => topbar.propertiesRequested())
            }

            FileMenuItem {
                visible: menu.moreRows
                enabled: !topbar.virtualActive
                text: I18n.tr("Copy location path", "menu entry copying the current path to the clipboard")
                iconName: "content_copy"
                onClicked: menu.pick(() => topbar.copyPathRequested())
            }

            FileMenuItem {
                visible: menu.moreRows
                text: I18n.tr("Reload", "menu entry re-reading the current folder")
                iconName: "refresh"
                onClicked: menu.pick(() => topbar.reloadRequested())
            }

            FileMenuItem {
                visible: menu.moreRows && SandboxService.available("terminal")
                enabled: !topbar.virtualActive
                text: I18n.tr("Open in terminal", "context menu entry opening a terminal")
                iconName: "terminal"
                onClicked: menu.pick(() => topbar.terminalRequested())
            }

            FileMenuItem {
                visible: menu.moreRows
                text: I18n.tr("Keyboard shortcuts", "overlay listing every keyboard shortcut")
                iconName: "keyboard"
                onClicked: menu.pick(() => topbar.shortcutsRequested())
            }

            FileMenuItem {
                visible: menu.moreRows
                text: I18n.tr("Settings", "settings window header title")
                iconName: "settings"
                onClicked: menu.pick(() => topbar.settingsRequested())
            }
        }
    }

    readonly property bool searchExpanded: topbar.editing || topbar.searchFocused || topbar.filterText !== ""

    Rectangle {
        id: breadcrumbContainer

        anchors.left: leftActions.right
        anchors.right: search.left
        anchors.leftMargin: FilesMetrics.topbarSpacing
        anchors.rightMargin: FilesMetrics.topbarSpacing
        anchors.verticalCenter: parent.verticalCenter
        height: FilesMetrics.topbarControlSize
        radius: Theme.fullRadius(width, height)
        color: Theme.surfaceContainerHigh
        clip: true

        Row {
            id: breadcrumbContent
            anchors.fill: parent
            anchors.leftMargin: Theme.spacingM
            anchors.rightMargin: Theme.spacingM
            spacing: Theme.spacingS

            DIcon {
                anchors.verticalCenter: parent.verticalCenter
                name: "folder"
                size: Theme.iconSizeMedium
                color: Theme.primary
            }

            PathBar {
                id: breadcrumb
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - Theme.iconSizeMedium - Theme.spacingS
                path: topbar.currentPath
                editable: false
                flat: true
                onEditRequested: topbar.focusLocation()
                onNavigated: target => topbar.openRecent(target)
                onTabRequested: target => topbar.tabRequested(target)
            }
        }
    }

    DSearchField {
        id: search

        anchors.right: rightActions.left
        anchors.rightMargin: FilesMetrics.topbarSpacing
        anchors.verticalCenter: parent.verticalCenter
        readonly property real availableWidth: topbar.width - leftActions.width - rightActions.width - FilesMetrics.topbarSpacing * 3
        readonly property real collapsedWidth: Math.min(220, Math.max(160, availableWidth * 0.28))
        readonly property real expandedWidth: Math.min(450, Math.max(260, availableWidth * 0.65))
        width: topbar.searchExpanded ? expandedWidth : collapsedWidth
        controlHeight: FilesMetrics.topbarControlSize
        leftIconSize: Theme.iconSizeMedium
        backgroundColor: Theme.surfaceContainerHigh
        placeholderText: I18n.tr("Search in Files", "placeholder in the search field")
        keyForwardTargets: [topbar]

        Behavior on width {
            enabled: Theme.animationsEnabled
            NumberAnimation {
                duration: Theme.expressiveDurations.expressiveFastSpatial
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Theme.expressiveCurves.expressiveFastSpatial
            }
        }
        onFocusStateChanged: hasFocus => topbar.searchFocused = hasFocus
        onTextChanged: {
            recentPopup.highlightIndex = -1;
            if (text === "" && topbar.editing) {
                topbar.clearSearch();
                return;
            }
            const query = topbar.pathInput ? "" : text;
            if (query !== topbar.filterText)
                topbar.filterChanged(query);
        }
        onCleared: topbar.clearSearch()
        onAccepted: {
            const picked = recentPopup.highlightedRow();
            if (picked) {
                topbar.openRecent(picked.path);
                return;
            }
            if (topbar.pathInput) {
                topbar.openRecent(text.trim());
                return;
            }
            if (text.trim() !== "")
                topbar.searchRequested(text.trim());
        }
    }

    Keys.onPressed: event => {
        switch (event.key) {
        case Qt.Key_Escape:
            topbar.clearSearch();
            break;
        case Qt.Key_Tab: {
            if (!topbar.pathInput)
                return;
            const next = PathCompletion.tab(search.text, recentPopup.rows, recentPopup.highlightIndex);
            if (!next)
                return;
            search.text = next.text;
            search.cursorPosition = search.text.length;
            recentPopup.highlightIndex = next.highlight;
            break;
        }
        case Qt.Key_Down:
            if (recentPopup.rows.length > 0) {
                recentPopup.move(1);
                break;
            }
            if (topbar.filterText === "")
                return;
            topbar.resultsRequested();
            break;
        case Qt.Key_Up:
            if (recentPopup.rows.length === 0)
                return;
            recentPopup.move(-1);
            break;
        default:
            return;
        }
        event.accepted = true;
    }

    PathSuggestions {
        id: recentPopup

        anchorItem: search
        rows: topbar.pathInput ? topbar.pathSuggestions : topbar.recentSuggestions
        visible: topbar.editing && topbar.searchFocused && rows.length > 0
        onChosen: row => topbar.openRecent(row.path)
    }
}
