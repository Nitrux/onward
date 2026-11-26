import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.mauikit.controls as Maui

ColumnLayout {
    id: systemPage
    required property real viewportHeight
    required property real viewportMargin
    required property bool wide
    required property string title
    required property string description
    spacing: Maui.Style.space.medium

    Maui.SectionHeader {
        id: systemHeader
        Layout.alignment: Qt.AlignHCenter
        Layout.fillWidth: true
        Layout.maximumWidth: Maui.Style.units.gridUnit * 36
        Layout.topMargin: Math.max(0, 52 - systemPage.viewportMargin)
        text1: systemPage.title
        text2: systemPage.description
        label1.font.pointSize: Maui.Style.fontSizes.enormous * 2
        label1.horizontalAlignment: Text.AlignHCenter
        label1.wrapMode: Text.Wrap
        label2.horizontalAlignment: Text.AlignHCenter
        label2.wrapMode: Text.Wrap
        property real reveal: 0
        NumberAnimation on reveal {
            running: systemHeader.visible && systemPage.Window.window && systemPage.Window.window.visible
            from: 0
            to: 3
            duration: Maui.Style.enableEffects ? Maui.Style.units.longDuration * 9 : 0
        }
        opacity: Math.min(1, reveal)
        transform: Translate {
            readonly property real travel: Math.max(0, (systemPage.viewportHeight - systemHeader.height) / 2 - systemHeader.y)
            readonly property real progress: Math.max(0, Math.min(1, systemHeader.reveal - 1))
            y: travel * (1 - progress * progress * (3 - 2 * progress))
        }
    }

    Image {
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignHCenter
        Layout.maximumWidth: Maui.Style.units.gridUnit * 54
        Layout.preferredHeight: width * 490 / 880
        source: "system-architecture.svg"
        sourceSize.width: Math.max(1, Math.ceil(width * Screen.devicePixelRatio))
        fillMode: Image.PreserveAspectFit
        opacity: Math.max(0, systemHeader.reveal - 2)
        Accessible.role: Accessible.Graphic
        Accessible.name: qsTr("Nitrux filesystem architecture")
        Accessible.description: qsTr("The root mount merges a temporary writable layer in RAM with the read-only NX_ROOT filesystem. Home directories and service data use separate persistent filesystems, NX_HOME and NX_VAR_LIB.")
    }

    Image {
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignHCenter
        Layout.maximumWidth: Maui.Style.units.gridUnit * 54
        Layout.preferredHeight: width * 304 / 880
        source: "aesthetic-fhs.svg"
        sourceSize.width: Math.max(1, Math.ceil(width * Screen.devicePixelRatio))
        fillMode: Image.PreserveAspectFit
        opacity: Math.max(0, systemHeader.reveal - 2)
        Accessible.role: Accessible.Graphic
        Accessible.name: qsTr("Browsing with Aesthetic FHS")
        Accessible.description: qsTr("Browse /Applications, /System and /Users in Index. The kernel filters selected entries from directory listings. Apps can still open traditional paths such as /etc and /home directly.")
    }

    GridLayout {
        Layout.alignment: Qt.AlignHCenter
        Layout.fillWidth: true
        Layout.topMargin: systemHeader.bottomPadding
        Layout.maximumWidth: Math.max(Maui.Style.units.gridUnit * 42, systemPage.viewportHeight * 0.7 * 16 / 9)
        columns: systemPage.wide ? 2 : 1
        rowSpacing: Maui.Style.space.medium
        columnSpacing: rowSpacing
        opacity: Math.max(0, systemHeader.reveal - 2)

        Repeater {
            model: [
                {
                    title: qsTr("Immutable Architecture"),
                    description: qsTr("Know what survives a restart."),
                    body: qsTr("Your documents and preferences stay in your home folder. Nitrux keeps the operating system’s files read-only and stores persistent service data, such as Bluetooth pairings, in /var/lib.")
                },
                {
                    title: qsTr("Rootless App Model"),
                    description: qsTr("Make the workspace your own."),
                    body: qsTr("Install an AppBox or a user Flatpak in your home directory. For development tools that need a traditional package manager, create a rootless Distrobox container.")
                },
                {
                    title: qsTr("Aesthetic FHS"),
                    description: qsTr("Find your way around the filesystem."),
                    body: qsTr("Look in /Users for home folders and /Applications for system-wide bundles. Under /System, names like Configuration and Boot tell you what each folder holds.")
                },
                {
                    title: qsTr("OpenRC"),
                    description: qsTr("Meet the service manager."),
                    body: qsTr("At startup, OpenRC checks which services depend on each other. It starts prerequisites first and can start independent services in parallel.")
                },
                {
                    title: qsTr("Nitrux Update Tool System"),
                    description: qsTr("Update with a way back."),
                    body: qsTr("Open NUTS and choose Update to install a new release. It backs up the current root partition first, so you can use Rescue to restore that version offline.")
                },
                {
                    title: qsTr("NX Overlayroot"),
                    description: qsTr("Understand temporary system changes."),
                    body: qsTr("During a session, writes to the protected root go into a layer in memory. Restarting clears that layer. Save work you want to keep in your home folder.")
                },
                {
                    title: qsTr("Nitrux GRUB Modes"),
                    description: qsTr("Recover from the boot menu."),
                    body: qsTr("If an update leaves Nitrux unable to start, Rescue Mode can restore the root partition from a verified NUTS backup. On supported Intel graphics hardware, Intel Xe Mode lets you try the Xe driver.")
                },
                {
                    title: qsTr("Language Stratification"),
                    description: qsTr("See which languages power Nitrux."),
                    body: qsTr("Nitrux uses C++ for performance-critical components, Python to coordinate system tools, and shell scripts for startup and maintenance. Its native graphical tools use MauiKit for a familiar interface.")
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
                        text: modelData.body
                    }
                }
            }
        }
    }
}
