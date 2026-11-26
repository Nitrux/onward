import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.mauikit.controls as Maui

ColumnLayout {
    id: settingsPage
    required property real viewportHeight
    required property real viewportMargin
    required property bool wide
    required property string title
    required property string description
    spacing: Maui.Style.space.medium

    Maui.SectionHeader {
        id: settingsHeader
        Layout.alignment: Qt.AlignHCenter
        Layout.fillWidth: true
        Layout.maximumWidth: Maui.Style.units.gridUnit * 36
        Layout.topMargin: Math.max(0, Maui.Style.units.gridUnit * 3 - settingsPage.viewportMargin)
        text1: settingsPage.title
        text2: settingsPage.description
        label1.font.pointSize: Maui.Style.fontSizes.enormous * 2
        label1.horizontalAlignment: Text.AlignHCenter
        label1.wrapMode: Text.Wrap
        label2.horizontalAlignment: Text.AlignHCenter
        label2.wrapMode: Text.Wrap
        property real reveal: 0
        NumberAnimation on reveal {
            running: settingsHeader.visible && settingsPage.Window.window && settingsPage.Window.window.visible
            from: 0
            to: 3
            duration: Maui.Style.enableEffects ? Maui.Style.units.longDuration * 9 : 0
        }
        opacity: Math.min(1, reveal)
        transform: Translate {
            readonly property real travel: Math.max(0, (settingsPage.viewportHeight - settingsHeader.height) / 2 - settingsHeader.y)
            readonly property real progress: Math.max(0, Math.min(1, settingsHeader.reveal - 1))
            y: travel * (1 - progress * progress * (3 - 2 * progress))
        }
    }

    AnnotatedSlideshow {
        id: preview
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignHCenter
        Layout.maximumWidth: Math.max(Maui.Style.units.gridUnit * 42, settingsPage.viewportHeight * 0.7 * preview.aspectRatio)
        aspectRatio: 1329 / 938
        imageFolder: "settings"
        playing: settingsHeader.reveal >= 3
        opacity: Math.max(0, settingsHeader.reveal - 2)

        frames: [
            { image: "settings", title: qsTr("Workspace Settings"), tip: qsTr("Open Network to manage Wi-Fi, DNS encryption, and VPN connections."), target: Qt.point(0.07, 0.70), label: Qt.point(0.43, 0.53) },
            { image: "cinderward", title: qsTr("Cinderward"), tip: qsTr("Choose the firewall profile for the network whose rules you want to edit."), target: Qt.point(0.23, 0.028), label: Qt.point(0.73, 0.25) },
            { image: "wirecloak", title: qsTr("Wirecloak"), tip: qsTr("Add a WireGuard configuration here, then select the tunnel to connect."), target: Qt.point(0.04, 0.028), label: Qt.point(0.71, 0.27) }
        ]
    }

    GridLayout {
        Layout.alignment: Qt.AlignHCenter
        Layout.fillWidth: true
        Layout.topMargin: settingsHeader.bottomPadding
        Layout.maximumWidth: Math.max(Maui.Style.units.gridUnit * 42, settingsPage.viewportHeight * 0.7 * 16 / 9)
        columns: settingsPage.wide ? 2 : 1
        rowSpacing: Maui.Style.space.medium
        columnSpacing: rowSpacing
        opacity: Math.max(0, settingsHeader.reveal - 2)

        Repeater {
            model: [
                {
                    title: qsTr("Workspace Settings"),
                    description: qsTr("Make the desktop feel like yours."),
                    body: qsTr("Open Workspace Settings to change the wallpaper, choose default apps, or adjust the dock. Its Network page brings wired connections, Wi-Fi, and encrypted DNS together.")
                },
                {
                    title: qsTr("Application Security"),
                    description: qsTr("Limit what an app can access."),
                    body: qsTr("AppBoxes and Flatpaks use sandboxes. AppArmor profiles and Firejail also limit what supported programs can read or change.")
                },
                {
                    title: qsTr("Identity and Access"),
                    description: qsTr("Use your own account for administration."),
                    body: qsTr("Sign in as yourself and use sudo when a task needs administrative access. Repeated failed sign-ins trigger a temporary lockout.")
                },
                {
                    title: qsTr("Kernel and Memory Hardening"),
                    description: qsTr("Protect data between processes."),
                    body: qsTr("Nitrux clears released memory and restricts access to kernel addresses. These defaults help keep information from one process from leaking into another.")
                },
                {
                    title: qsTr("Network Privacy"),
                    description: qsTr("Share less when you connect."),
                    body: qsTr("Encrypted DNS protects queries on their way to the resolver. Randomized hardware addresses and temporary IPv6 addresses make a device harder to track across networks.")
                },
                {
                    title: qsTr("Firewall and VPN"),
                    description: qsTr("Choose how you connect."),
                    body: qsTr("Use Cinderward to review which services a firewall profile allows. If you have a WireGuard configuration, import it in Wirecloak and switch the tunnel on when you need it.")
                },
                {
                    title: qsTr("Session Hardening"),
                    description: qsTr("Know what ends when you log out."),
                    body: qsTr("Each login gets a session keyring. Logging out revokes its keys. Default file permissions also keep other users from writing to newly created files.")
                },
                {
                    title: qsTr("Bluetooth Security"),
                    description: qsTr("Confirm the devices you pair."),
                    body: qsTr("Nitrux requires secure pairing and limits how long your computer advertises itself. Confirm the pairing request when connecting a new device.")
                },
                {
                    title: qsTr("XFS System Storage"),
                    description: qsTr("Know where the base system lives."),
                    body: qsTr("The recommended layout uses XFS for NX_ROOT. XFS can place a file’s metadata near its contents so the drive can read them together.")
                },
                {
                    title: qsTr("F2FS Personal Storage"),
                    description: qsTr("Reduce writes to flash storage."),
                    body: qsTr("Home folders and persistent service data use F2FS in the recommended layout. Compression on supported volumes reduces writes, and checksums verify compressed blocks.")
                },
                {
                    title: qsTr("Memory Management"),
                    description: qsTr("Give demanding apps room to work."),
                    body: qsTr("A higher memory mapping limit supports large games and development workloads. When graphics memory is tight, foreground apps get priority over background processes on supported hardware.")
                },
                {
                    title: qsTr("Performance and I/O"),
                    description: qsTr("Keep storage responsive under load."),
                    body: qsTr("The ADIOS disk scheduler balances competing requests. When RAM comes under pressure, zswap compresses pages in memory to reduce writes to swap.")
                }
            ]

            Rectangle {
                required property var modelData
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: Maui.Style.units.gridUnit * 20
                implicitHeight: cardCopy.implicitHeight + Maui.Style.contentMargins * 2
                color: Maui.Theme.alternateBackgroundColor
                radius: Maui.Style.radiusV
                border.color: Maui.Theme.backgroundColor

                ColumnLayout {
                    id: cardCopy
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
                        text: modelData.body
                    }
                }
            }
        }
    }
}
