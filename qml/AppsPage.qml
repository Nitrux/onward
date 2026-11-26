import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.mauikit.controls as Maui

ColumnLayout {
    id: appsPage
    required property real viewportHeight
    required property real viewportMargin
    required property bool wide
    required property string title
    required property string description
    spacing: Maui.Style.space.medium

    Maui.SectionHeader {
        id: appsHeader
        Layout.alignment: Qt.AlignHCenter
        Layout.fillWidth: true
        Layout.maximumWidth: Maui.Style.units.gridUnit * 36
        Layout.topMargin: Math.max(0, Maui.Style.units.gridUnit * 3 - appsPage.viewportMargin)
        text1: appsPage.title
        text2: appsPage.description
        label1.font.pointSize: Maui.Style.fontSizes.enormous * 2
        label1.horizontalAlignment: Text.AlignHCenter
        label1.wrapMode: Text.Wrap
        label2.horizontalAlignment: Text.AlignHCenter
        label2.wrapMode: Text.Wrap
        property real reveal: 0
        NumberAnimation on reveal {
            running: appsHeader.visible && appsPage.Window.window && appsPage.Window.window.visible
            from: 0
            to: 3
            duration: Maui.Style.enableEffects ? Maui.Style.units.longDuration * 9 : 0
        }
        opacity: Math.min(1, reveal)
        transform: Translate {
            readonly property real travel: Math.max(0, (appsPage.viewportHeight - appsHeader.height) / 2 - appsHeader.y)
            readonly property real progress: Math.max(0, Math.min(1, appsHeader.reveal - 1))
            y: travel * (1 - progress * progress * (3 - 2 * progress))
        }
    }

    AnnotatedSlideshow {
        id: preview
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignHCenter
        Layout.maximumWidth: Math.max(Maui.Style.units.gridUnit * 42, appsPage.viewportHeight * 0.7 * preview.aspectRatio)
        aspectRatio: 1206 / 992
        imageFolder: "apps"
        playing: appsHeader.reveal >= 3
        opacity: Math.max(0, appsHeader.reveal - 2)

        frames: [
            { image: "apphub", title: qsTr("Browse Recipes"), tip: qsTr("Choose a category to find AppBoxes for a particular task."), target: Qt.point(0.69, 0.47), label: Qt.point(0.52, 0.71) },
            { image: "builder", title: qsTr("Personal Bundle Builder"), tip: qsTr("Give your recipe a project ID so you can save it and return to it later."), target: Qt.point(0.89, 0.20), label: Qt.point(0.59, 0.40) },
            { image: "flathub", title: qsTr("Search Flathub"), tip: qsTr("Type the name of an app here to find its Flatpak."), target: Qt.point(0.57, 0.026), label: Qt.point(0.37, 0.24) },
            { image: "distrobox", title: qsTr("Create a Container"), tip: qsTr("Use the plus button to set up a development environment."), target: Qt.point(0.944, 0.93), label: Qt.point(0.65, 0.70) }
        ]
    }

    GridLayout {
        Layout.alignment: Qt.AlignHCenter
        Layout.fillWidth: true
        Layout.topMargin: appsHeader.bottomPadding
        Layout.maximumWidth: Math.max(Maui.Style.units.gridUnit * 42, appsPage.viewportHeight * 0.7 * 16 / 9)
        columns: appsPage.wide ? 2 : 1
        rowSpacing: Maui.Style.space.medium
        columnSpacing: rowSpacing
        opacity: Math.max(0, appsHeader.reveal - 2)

        Repeater {
            model: [
                {
                    title: qsTr("AppFinder"),
                    description: qsTr("Choose how to add software."),
                    body: qsTr("Open AppFinder and pick a source in the sidebar. You can also open the Personal Bundle Builder from NX AppHub to save a recipe and build your own AppImage.")
                },
                {
                    title: qsTr("NX AppHub"),
                    description: qsTr("Build an AppBox from a recipe."),
                    body: qsTr("Browse a category, open a recipe, and build an AppBox with the tools it needs. Your personal AppBoxes live in your home directory and persist across restarts.")
                },
                {
                    title: qsTr("Flatpak"),
                    description: qsTr("Find a desktop app on Flathub."),
                    body: qsTr("Select Flathub and search for an app or explore what’s trending. Open its details to install it for your account. AppFinder also lets you update or remove it later.")
                },
                {
                    title: qsTr("Distrobox"),
                    description: qsTr("Give a project its own Linux environment."),
                    body: qsTr("Create a rootless container and use its distribution’s package manager for compilers, libraries, or command-line tools. Those packages stay inside the container while your project files remain accessible from home.")
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
