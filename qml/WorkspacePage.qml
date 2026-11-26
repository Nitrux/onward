import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.mauikit.controls as Maui

ColumnLayout {
    id: workspace
    required property real viewportHeight
    required property real viewportMargin
    required property bool wide
    required property var formatShortcut
    spacing: Maui.Style.space.medium

    Maui.SectionHeader {
        id: workspaceHeader
        Layout.alignment: Qt.AlignHCenter
        Layout.fillWidth: true
        Layout.maximumWidth: Maui.Style.units.gridUnit * 36
        Layout.topMargin: Math.max(0, 52 - workspace.viewportMargin)
        text1: qsTr("The Workspace Environment")
        text2: qsTr("Open two apps and Hyprland tiles them side by side. Give your next task a workspace of its own, and use the panel, dock, or keyboard to move between them.")
        label1.font.pointSize: Maui.Style.fontSizes.enormous * 2
        label1.horizontalAlignment: Text.AlignHCenter
        label1.wrapMode: Text.Wrap
        label2.horizontalAlignment: Text.AlignHCenter
        label2.wrapMode: Text.Wrap
        property real reveal: 0
        NumberAnimation on reveal {
            running: workspaceHeader.visible && workspace.Window.window && workspace.Window.window.visible
            from: 0
            to: 3
            duration: Maui.Style.enableEffects ? Maui.Style.units.longDuration * 9 : 0
        }
        opacity: Math.min(1, reveal)
        transform: Translate {
            readonly property real travel: Math.max(0, (workspace.viewportHeight - workspaceHeader.height) / 2 - workspaceHeader.y)
            readonly property real progress: Math.max(0, Math.min(1, workspaceHeader.reveal - 1))
            y: travel * (1 - progress * progress * (3 - 2 * progress))
        }
    }

    AnnotatedSlideshow {
        id: preview
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignHCenter
        Layout.maximumWidth: Math.max(Maui.Style.units.gridUnit * 42, workspace.viewportHeight * 0.7 * 16 / 9)
        aspectRatio: 16 / 9
        imageFolder: "workspace"
        playing: workspaceHeader.reveal >= 3
        opacity: Math.max(0, workspaceHeader.reveal - 2)

        frames: [
            { image: "desktop", title: qsTr("Workspace switcher"), tip: qsTr("Use the arrows to move between workspaces."), target: Qt.point(0.036, 0.022), label: Qt.point(0.16, 0.19) },
            { image: "volume", title: qsTr("Volume indicator"), tip: qsTr("NudgeOSD shows the level as you adjust the volume."), target: Qt.point(0.50, 0.90), label: Qt.point(0.50, 0.68) },
            { image: "calendar", title: qsTr("Calendar and forecast"), tip: qsTr("Click the clock to see the month and local weather."), target: Qt.point(0.50, 0.06), label: Qt.point(0.28, 0.18) },
            { image: "launcher", title: qsTr("Vicinae launcher"), tip: qsTr("Type an app’s name here to launch it."), target: Qt.point(0.36, 0.38), label: Qt.point(0.28, 0.56) },
            { image: "controls", title: qsTr("Control Center"), tip: qsTr("Adjust sound, wireless connections, and more from this panel."), target: Qt.point(0.85, 0.24), label: Qt.point(0.65, 0.36) },
            { image: "notifications", title: qsTr("Notification center"), tip: qsTr("Click the bell to revisit recent notifications."), target: Qt.point(0.923, 0.022), label: Qt.point(0.71, 0.23) },
            { image: "tiled", title: qsTr("Tiled windows"), tip: qsTr("Hyprland arranges apps side by side so each has its own space."), target: Qt.point(0.50, 0.52), label: Qt.point(0.29, 0.66) },
            { image: "floating", title: qsTr("Floating windows"), tip: qsTr("Move windows freely and let them overlap."), target: Qt.point(0.51, 0.31), label: Qt.point(0.72, 0.18) },
            { image: "lock-screen", title: qsTr("Lock screen media controls"), tip: qsTr("Pause or skip a track while your session is locked."), target: Qt.point(0.55, 0.925), label: Qt.point(0.54, 0.72) }
        ]
    }

    GridLayout {
        visible: preview.visible
        Layout.alignment: Qt.AlignHCenter
        Layout.fillWidth: true
        Layout.topMargin: workspaceHeader.bottomPadding
        Layout.maximumWidth: preview.Layout.maximumWidth
        columns: workspace.wide ? 2 : 1
        rowSpacing: Maui.Style.space.medium
        columnSpacing: rowSpacing
        opacity: preview.opacity

        Repeater {
            model: [
                {
                    title: "Valenz", description: qsTr("Explore the top panel."),
                    body: qsTr("Click the clock for the calendar and a three-day forecast. When you have several windows open, click a window tab on the left to bring it into focus.")
                },
                {
                    title: "Marina", description: qsTr("Keep your favorite apps on the dock."),
                    body: qsTr("Click an app in the dock to launch it or return to its window. Right-click a running app to pin it, then drag its icon where you want it.")
                },
                {
                    title: "Vicinae", description: qsTr("Launch an app by typing its name."),
                    body: qsTr("Press Super + R and start typing. The same launcher can help you find a file or switch windows. To retrieve something you copied earlier, press Super + Shift + V.")
                },
                {
                    title: "NudgeOSD", description: qsTr("See what your media keys just changed."),
                    body: qsTr("Tap a volume or brightness key. A small on-screen indicator shows the new level, then fades so you can keep watching or reading.")
                },
                {
                    title: "Desklock", description: qsTr("Step away and keep your place."),
                    body: qsTr("Press Super + L to lock your screens. You can pause a track from the lock screen, then unlock to return to the windows you left open.")
                },
                {
                    title: "QMLogout", description: qsTr("Choose how to leave your workspace."),
                    body: qsTr("Press Super + Shift + P to open the session menu. Choose Suspend for a break, or log out, restart, or shut down when you’re finished.")
                },
                {
                    title: "greetd + QMLGreet", description: qsTr("Sign in to your workspace."),
                    body: qsTr("QMLGreet is the login screen you see when you start Nitrux. Enter your credentials there and greetd checks them, then starts your Hyprland session.")
                },
                {
                    title: "Nitrux Workspace Session Manager", description: qsTr("Let your session start up in order."),
                    body: qsTr("After you sign in, nwsm waits until Hyprland is ready before starting your workspace services. When you log out, it stops those services for you.")
                }
            ]

            Rectangle {
                required property var modelData
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: Maui.Style.units.gridUnit * 20
                implicitHeight: workspaceCopy.implicitHeight + Maui.Style.contentMargins * 2
                color: Maui.Theme.alternateBackgroundColor
                radius: Maui.Style.radiusV
                border.color: Maui.Theme.backgroundColor

                ColumnLayout {
                    id: workspaceCopy
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: Maui.Style.contentMargins
                    spacing: Maui.Style.space.small
                    Maui.SectionHeader {
                        Layout.fillWidth: true
                        text1: modelData.title
                        text2: modelData.description
                        label2.wrapMode: Text.Wrap
                    }
                    Label {
                        Layout.fillWidth: true
                        Layout.leftMargin: Maui.Style.contentMargins
                        Layout.rightMargin: Maui.Style.contentMargins
                        wrapMode: Text.Wrap
                        id: cardBody
                        textFormat: Text.StyledText
                        Accessible.name: modelData.body
                        FontMetrics { id: bodyMetrics; font: cardBody.font }
                        text: modelData.body.replace(/Super(?: \+ (?:Shift|[A-Z]))+/g,
                            shortcut => workspace.formatShortcut(shortcut, Math.ceil(bodyMetrics.height * 1.3)))
                    }
                }
            }
        }
    }
}
