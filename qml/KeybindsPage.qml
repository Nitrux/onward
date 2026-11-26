import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.mauikit.controls as Maui

ColumnLayout {
    id: keybinds
    required property real viewportHeight
    required property real viewportMargin
    required property bool wide
    required property var keycapSource
    readonly property var shortcutGroups: [
        {
            title: qsTr("Launch Apps"),
            description: qsTr("Open common applications from anywhere in the workspace."),
            items: [
                { keys: "Super + Q", action: qsTr("Open Station, the terminal") },
                { keys: "Super + E", action: qsTr("Open Index, the file manager") },
                { keys: "Super + W", action: qsTr("Open Fiery, the web browser") },
                { keys: "Super + R", action: qsTr("Open Vicinae, the application launcher") }
            ]
        },
        {
            title: qsTr("Manage Windows"),
            description: qsTr("Arrange, focus, and control the current window."),
            items: [
                { keys: "Super + C", action: qsTr("Close the focused window") },
                { keys: "Super + V", action: qsTr("Toggle floating mode") },
                { keys: "Super + F", action: qsTr("Toggle fullscreen") },
                { keys: "Super + P", action: qsTr("Toggle pseudotiling") },
                { keys: "Super + J", action: qsTr("Toggle the window split") },
                { keys: "Super + Arrow keys", action: qsTr("Move focus between windows") },
                { keys: "Super + LMB drag", action: qsTr("Move a window") },
                { keys: "Super + RMB drag", action: qsTr("Resize a window") }
            ]
        },
        {
            title: qsTr("Move between Workspaces"),
            description: qsTr("Switch workspaces, move a window, or use the launcher keybinds."),
            items: [
                { keys: "Super + 1–0", action: qsTr("Switch to workspaces 1–10") },
                { keys: "Super + Shift + 1–0", action: qsTr("Move the focused window to workspaces 1–10") },
                { keys: "Super + Ctrl + 1–0", action: qsTr("Activate Marina launcher slots 1–10") },
                { keys: "Super + F12", action: qsTr("Hold the Marina launcher") },
                { keys: "Three-finger swipe", action: qsTr("Switch workspaces with three fingers"), gesture: true }
            ]
        },
        {
            title: qsTr("Session and Screenshots"),
            description: qsTr("Reach session actions, screenshots, and clipboard history."),
            items: [
                { keys: "Super + L", action: qsTr("Lock the screen") },
                { keys: "Super + M", action: qsTr("End the session") },
                { keys: "Super + Shift + P", action: qsTr("Open session options") },
                { keys: "Super + Shift + V", action: qsTr("Show clipboard history") },
                { keys: "Print", action: qsTr("Capture the full screen") },
                { keys: "Super + Print", action: qsTr("Capture a selected area") },
                { keys: "Shift + Print", action: qsTr("Capture the focused window") }
            ]
        }
    ]

    spacing: Maui.Style.space.medium
    readonly property var demos: shortcutGroups.reduce((all, group) => all.concat(group.items), [])
    property int demoIndex: 0
    property int phase: 0
    readonly property var demo: demos[demoIndex]
    readonly property var parts: demo.keys.split(" + ")
    readonly property bool released: phase >= parts.length + 2
    readonly property var pressed: released ? [] : parts.slice(0, phase + 1).map(key =>
        key === "Arrow keys" ? "↑" : key === "1–0" ? "1" : key)

    onVisibleChanged: {
        demoIndex = 0
        phase = 0
    }

    Timer {
        running: keybinds.visible && keybindHeader.reveal >= 3
        interval: 650
        repeat: true
        onTriggered: {
            if (keybinds.released) {
                keybinds.demoIndex = (keybinds.demoIndex + 1) % keybinds.demos.length
                keybinds.phase = 0
            } else {
                keybinds.phase++
            }
        }
    }

    Maui.SectionHeader {
        id: keybindHeader
        Layout.alignment: Qt.AlignHCenter
        Layout.fillWidth: true
        Layout.maximumWidth: Maui.Style.units.gridUnit * 36
        Layout.topMargin: Math.max(0, 52 - keybinds.viewportMargin)
        text1: qsTr("Workspace Keybinds")
        text2: qsTr("Follow the highlighted keys to see each shortcut. Super is the Windows key.")
        label1.font.pointSize: Maui.Style.fontSizes.enormous * 2
        label1.horizontalAlignment: Text.AlignHCenter
        label1.wrapMode: Text.Wrap
        label2.horizontalAlignment: Text.AlignHCenter
        label2.wrapMode: Text.Wrap
        property real reveal: 0
        NumberAnimation on reveal {
            running: keybindHeader.visible && keybinds.Window.window && keybinds.Window.window.visible
            from: 0
            to: 3
            duration: Maui.Style.enableEffects ? Maui.Style.units.longDuration * 9 : 0
        }
        opacity: Math.min(1, reveal)
        transform: Translate {
            readonly property real travel: Math.max(0, (keybinds.viewportHeight - keybindHeader.height) / 2 - keybindHeader.y)
            readonly property real progress: Math.max(0, Math.min(1, keybindHeader.reveal - 1))
            y: travel * (1 - progress * progress * (3 - 2 * progress))
        }
    }

    ColumnLayout {
        id: demonstration
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignHCenter
        Layout.maximumWidth: Math.max(Maui.Style.units.gridUnit * 42, keybinds.viewportHeight * 0.7 * 16 / 9)
        opacity: Math.max(0, keybindHeader.reveal - 2)
        spacing: Maui.Style.space.medium

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: keyboard.height + Maui.Style.contentMargins * 2
            radius: Maui.Style.radiusV
            color: Maui.Theme.alternateBackgroundColor
            Item {
                id: keyboard
                anchors.centerIn: parent
                width: Math.max(0, parent.width - Maui.Style.contentMargins * 2)
                FontMetrics { id: legendMetrics; font: demoCaption.font }
                readonly property real unit: width / 23
                height: unit * 6.5
                // Positions and spans are measured in standard keyboard key units.
                readonly property var keys: {
                    const result = []
                    function row(x, y, entries) {
                        for (let i = 0; i < entries.length; ++i) {
                            const entry = entries[i]
                            const spec = Array.isArray(entry) ? entry : [entry]
                            const widthUnits = spec.length > 1 ? spec[1] : 1
                            result.push({
                                legend: spec[0],
                                token: spec.length > 3 ? spec[3] : spec[0],
                                x: x,
                                y: y,
                                widthUnits: widthUnits,
                                heightUnits: spec.length > 2 ? spec[2] : 1
                            })
                            x += widthUnits
                        }
                    }
                    row(0, 0, ["Esc"])
                    for (let group = 0; group < 3; group++)
                        row(2 + group * 4.5, 0, [1, 2, 3, 4].map(n => "F" + (group * 4 + n)))
                    row(15.5, 0, ["Print", "Scroll", "Pause"])
                    row(0, 1.5, ["`", ..."1234567890", "-", "=", ["Backspace", 2]])
                    row(0, 2.5, [["Tab", 1.5], ..."QWERTYUIOP", "[", "]", ["\\", 1.5]])
                    row(0, 3.5, [["Caps Lock", 1.75], ..."ASDFGHJKL", ";", "'", ["Enter", 2.25]])
                    row(0, 4.5, [["Shift", 2.25], ..."ZXCVBNM", ",", ".", "/", ["Shift", 2.75, 1, "Right Shift"]])
                    row(0, 5.5, [["Ctrl", 1.25], ["Super", 1.25], ["Alt", 1.25], ["", 6.25],
                                 ["Alt", 1.25, 1, "Right Alt"], ["Super", 1.25, 1, "Right Super"], ["Menu", 1.25], ["Ctrl", 1.25, 1, "Right Ctrl"]])
                    row(15.5, 1.5, ["Insert", "Home", "PgUp"])
                    row(15.5, 2.5, ["Delete", "End", "PgDn"])
                    row(16.5, 4.5, ["↑"])
                    row(15.5, 5.5, ["←", "↓", "→"])
                    return result
                }

                Repeater {
                    model: keyboard.keys
                    Image {
                        required property var modelData
                        readonly property real gap: keyboard.unit * 0.07
                        readonly property bool down: keybinds.pressed.includes(modelData.token)
                        x: modelData.x * keyboard.unit
                        y: modelData.y * keyboard.unit + (down ? gap : 0)
                        width: modelData.widthUnits * keyboard.unit - gap
                        height: modelData.heightUnits * keyboard.unit - gap
                        source: keybinds.keycapSource(modelData.legend, modelData.widthUnits, down,
                                                      30 * legendMetrics.height / Math.max(1, height))
                        sourceSize.width: Math.ceil(width * Screen.devicePixelRatio)
                        sourceSize.height: Math.ceil(height * Screen.devicePixelRatio)
                        Accessible.role: Accessible.StaticText
                        Accessible.name: modelData.legend || qsTr("Space")
                    }
                }

                Rectangle {
                    id: touchpad
                    x: keyboard.unit * 19
                    y: keyboard.unit * 1.5
                    width: keyboard.width - x
                    height: keyboard.height - y
                    radius: Maui.Style.radiusV
                    color: Maui.Theme.backgroundColor
                    border.color: Qt.alpha(Maui.Theme.textColor, 0.3)
                    readonly property bool leftDrag: keybinds.pressed.includes("LMB drag")
                    readonly property bool rightDrag: keybinds.pressed.includes("RMB drag")
                    readonly property bool swipe: keybinds.demo.gesture === true && !keybinds.released
                    readonly property bool touching: swipe || leftDrag || rightDrag
                    property real travel: 0

                    NumberAnimation on travel {
                        running: touchpad.touching && Maui.Style.enableEffects
                        from: 0
                        to: 1
                        duration: 1300
                        easing.type: Easing.InOutQuad
                    }

                    Row {
                        visible: touchpad.touching
                        x: (parent.width - width) * (0.18 + 0.64 * touchpad.travel)
                        y: (buttons.y - height) * (touchpad.swipe ? 0.5 : 0.68 - 0.36 * touchpad.travel)
                        spacing: keyboard.unit * 0.1
                        Repeater {
                            model: touchpad.swipe ? 3 : 1
                            Rectangle {
                                width: keyboard.unit * 0.38
                                height: width
                                radius: width / 2
                                color: Maui.Theme.highlightColor
                            }
                        }
                    }

                    Row {
                        id: buttons
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: keyboard.unit
                        Repeater {
                            model: [qsTr("LMB"), qsTr("RMB")]
                            Rectangle {
                                required property int index
                                required property string modelData
                                readonly property bool down: index === 0 ? touchpad.leftDrag : touchpad.rightDrag
                                width: buttons.width / 2
                                height: buttons.height
                                radius: height * 0.12
                                color: down ? Maui.Theme.highlightColor : Maui.Theme.alternateBackgroundColor
                                border.color: touchpad.border.color
                                Label {
                                    anchors.centerIn: parent
                                    text: modelData
                                    color: parent.down ? Maui.Theme.highlightedTextColor : Maui.Theme.textColor
                                }
                            }
                        }
                    }
                }
            }
        }

        Label {
            id: demoCaption
            Layout.topMargin: Maui.Style.space.medium
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            text: keybinds.demo.keys + "  •  " + keybinds.demo.action
        }
    }

    GridLayout {
        Layout.fillWidth: true
        Layout.maximumWidth: demonstration.Layout.maximumWidth
        Layout.alignment: Qt.AlignHCenter
        Layout.topMargin: keybindHeader.bottomPadding + Maui.Style.contentMargins
        columns: keybinds.wide ? 2 : 1
        columnSpacing: Maui.Style.space.medium
        rowSpacing: columnSpacing
        opacity: demonstration.opacity
        Repeater {
            model: keybinds.shortcutGroups
            Rectangle {
                id: keybindCard
                required property var modelData
                readonly property var group: modelData
                Layout.alignment: Qt.AlignTop
                Layout.fillWidth: true
                color: Maui.Theme.alternateBackgroundColor
                radius: Maui.Style.radiusV
                border.color: Maui.Theme.backgroundColor
                border.width: 1
                implicitHeight: shortcutCardLayout.implicitHeight + Maui.Style.contentMargins * 2

                ColumnLayout {
                    id: shortcutCardLayout
                    anchors.fill: parent
                    anchors.margins: Maui.Style.contentMargins
                    spacing: Maui.Style.space.small

                    Maui.SectionHeader {
                        Layout.fillWidth: true
                        text1: keybindCard.group.title
                        text2: keybindCard.group.description
                        label2.wrapMode: Text.Wrap
                    }

                    Repeater {
                        model: keybindCard.group.items

                        delegate: Maui.FlexSectionItem {
                            id: shortcutEntry
                            required property var modelData
                            property var keyParts: String(modelData.keys).split(" + ")
                            Layout.fillWidth: true
                            flat: true
                            spacing: Maui.Style.space.medium
                            label1.text: modelData.action
                            label1.font.bold: keybinds.demo.keys === modelData.keys
                            label1.font.pointSize: Maui.Style.fontSizes.medium
                            label1.wrapMode: Text.Wrap

                            RowLayout {
                                spacing: Maui.Style.space.tiny

                                Repeater {
                                    model: shortcutEntry.keyParts

                                    delegate: RowLayout {
                                        required property int index
                                        required property var modelData
                                        spacing: Maui.Style.space.tiny

                                        Image {
                                            visible: !shortcutEntry.modelData.gesture && !modelData.endsWith(" drag")
                                            source: visible ? keybinds.keycapSource(modelData) : ""
                                            Layout.preferredHeight: keyMetrics.height + Maui.Style.space.small
                                            Layout.preferredWidth: Layout.preferredHeight * Math.max(32, modelData.length * 9 + 16) / 30
                                            sourceSize.width: Math.ceil(Layout.preferredWidth * Screen.devicePixelRatio)
                                            Accessible.role: Accessible.StaticText
                                            Accessible.name: modelData
                                            FontMetrics { id: keyMetrics; font: gestureLabel.font }
                                        }

                                        Label {
                                            id: gestureLabel
                                            visible: shortcutEntry.modelData.gesture === true || modelData.endsWith(" drag")
                                            leftPadding: Maui.Style.space.medium / 2
                                            rightPadding: leftPadding
                                            topPadding: Maui.Style.space.small / 2
                                            bottomPadding: topPadding
                                            background: Rectangle {
                                                radius: Maui.Style.space.tiny
                                                color: shortcutEntry.modelData.gesture ? Qt.alpha(Maui.Theme.highlightColor, 0.12) : Maui.Theme.backgroundColor
                                                border.color: shortcutEntry.modelData.gesture ? Maui.Theme.highlightColor : Qt.alpha(Maui.Theme.textColor, 0.24)
                                            }
                                            font.family: "monospace"
                                            font.weight: Font.DemiBold
                                            text: modelData
                                            font.pointSize: Maui.Style.fontSizes.small
                                        }

                                        Label {
                                            visible: index < shortcutEntry.keyParts.length - 1
                                            text: "+"
                                            color: Maui.Theme.disabledTextColor
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
