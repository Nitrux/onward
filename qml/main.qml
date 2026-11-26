import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.mauikit.controls as Maui

Maui.ApplicationWindow {
    id: root

    title: qsTr("Onward")
    color: "transparent"
    background: null

    property int currentSection: -1
    property real pageTransition: 1
    onCurrentSectionChanged: {
        if (contentScrollView)
            contentScrollView.contentY = 0
        pageTransition = 0
        pageTransitionAnimation.restart()
    }

    NumberAnimation {
        id: pageTransitionAnimation
        target: root
        property: "pageTransition"
        to: 1
        duration: Maui.Style.enableEffects ? Maui.Style.units.longDuration : 0
        easing.type: Easing.InOutCubic
    }
    readonly property var stepTitles: [
        qsTr("The Workspace Environment"),
        qsTr("Workspace Keybinds"),
        qsTr("Nitrux Architecture"),
        qsTr("Apps and Software"),
        qsTr("Settings, Security and Performance"),
        qsTr("Get Involved")
    ]
    readonly property var stepDescriptions: [
        qsTr("A quick tour of the panel, launcher dock, and the places you’ll use most."),
        qsTr("Press Super—the Windows key—together with these keys to control your workspace."),
        qsTr("See where your files and apps live, how Nitrux starts, and how to recover a previous release."),
        qsTr("Nitrux keeps its base system read-only. Use AppFinder to add apps to your account or install development tools inside a container."),
        qsTr("Make the workspace your own and discover the protections and performance settings already at work."),
        qsTr("Meet the Nitrux community, share what you learn, and help shape the next release.")
    ]
    readonly property int totalSteps: stepTitles.length
    function keycapSource(key, aspect, pressed, maxLegendSize) {
        const width = aspect > 0 ? 30 * aspect : Math.max(32, key.length * 9 + 16)
        const fontSize = aspect > 0 ? Math.min(10, maxLegendSize, (width - 8) / Math.max(1, key.length * 0.8)) : 15
        const baseline = aspect > 0 ? 11.5 + fontSize * 0.34 : 16.5
        const face = pressed ? Maui.Theme.highlightColor.toString() : "#ffffff"
        const ink = pressed ? Maui.Theme.highlightedTextColor.toString() : "#37434a"
        const svg = '<svg xmlns="http://www.w3.org/2000/svg" width="' + width + '" height="30" viewBox="0 0 ' + width + ' 30">'
                  + '<rect x="0.75" y="1.75" width="' + (width - 1.5) + '" height="27.5" rx="5" ry="5" fill="#f8f8f8" stroke="#bdbdbd"/>'
                  + '<rect x="2" y="1" width="' + (width - 4) + '" height="25" rx="4" ry="4" fill="#d9d9d9"/>'
                  + '<rect x="2" y="0.75" width="' + (width - 4) + '" height="21.5" rx="4" ry="4" fill="' + face + '" stroke="#b9c2c7"/>'
                  + '<text x="' + (width / 2) + '" y="' + baseline + '" text-anchor="middle" font-family="sans-serif" font-size="' + fontSize + '" fill="' + ink + '">' + key.replace(/–/g, "&#8211;") + '</text></svg>'
        return "data:image/svg+xml," + encodeURIComponent(svg)
    }

    function formatShortcut(keyString, height) {
        return keyString.split(" + ").map(function(key) {
            const width = Math.round(height * Math.max(32, key.length * 9 + 16) / 30)
            return '<img align="middle" src="' + keycapSource(key) + '" width="' + width + '" height="' + height + '" alt="' + key + '"/>'
        }).join("&nbsp;+&nbsp;")
    }

    function goPrevious() {
        if (currentSection >= 0)
            currentSection--
    }

    function goNext() {
        if (currentSection < totalSteps - 1)
            currentSection++
        else
            root.close()
    }

    Maui.WindowBlur {
        view: root
        geometry: Qt.rect(0, 0, root.width, root.height)
        windowRadius: Maui.Style.radiusV
        enabled: true
    }

    Rectangle {
        anchors.fill: parent
        color: Maui.Theme.backgroundColor
        opacity: 0.76
        radius: Maui.Style.radiusV
    }

    Maui.Page {
        id: page
        anchors.fill: parent
        background: null
        Maui.Theme.colorSet: Maui.Theme.View
        title: qsTr("Onward")
        headerMargins: Maui.Handy.isMobile ? 0 : Maui.Style.contentMargins
        footerMargins: headerMargins
        headBar.visible: false
        footerContainer.visible: root.currentSection >= 0
        footBar.visible: root.currentSection >= 0
        footBar.preferredHeight: Maui.Style.rowHeightAlt
        footBar.topPadding: Maui.Style.defaultPadding
        footBar.bottomPadding: Maui.Style.defaultPadding

        footBar.leftContent: Button {
            display: AbstractButton.TextOnly
            text: qsTr("Previous")

            visible: root.currentSection >= 0
            onClicked: root.goPrevious()
        }

        footBar.middleContent: PageIndicator {
            id: stepIndicator
            visible: root.currentSection >= 0
            count: root.totalSteps
            currentIndex: root.currentSection
            Layout.alignment: Qt.AlignHCenter

            delegate: Rectangle {
                implicitWidth: Maui.Style.iconSizes.small / 2
                implicitHeight: implicitWidth
                radius: width / 2
                color: index === stepIndicator.currentIndex
                       ? Maui.Theme.highlightColor
                       : Maui.Theme.textColor
                opacity: index === stepIndicator.currentIndex ? 1 : 0.4
            }
        }

        footBar.rightContent: Button {
            display: AbstractButton.TextOnly
            visible: root.currentSection >= 0
            text: root.currentSection === root.totalSteps - 1 ? qsTr("Finish") : qsTr("Continue")
            onClicked: root.goNext()
        }

        WelcomePage {
            anchors.fill: parent
            visible: root.currentSection < 0
            opacity: root.pageTransition
            transform: Translate { y: (1 - root.pageTransition) * Maui.Style.units.gridUnit }
            onDiscover: root.goNext()
        }

        Flickable {
            id: contentScrollView
            visible: root.currentSection >= 0
            opacity: root.pageTransition
            transform: Translate { y: (1 - root.pageTransition) * Maui.Style.units.gridUnit }
            anchors.fill: parent
            anchors.margins: Maui.Style.contentMargins
            contentWidth: width
            contentHeight: tourLayout.implicitHeight
            flickableDirection: Flickable.VerticalFlick
            clip: true
            ScrollBar.vertical: ScrollBar {}

            ColumnLayout {
                id: tourLayout
                width: contentScrollView.width
                spacing: Maui.Style.space.medium

                WorkspacePage {
                    visible: root.currentSection === 0
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    viewportHeight: contentScrollView.height
                    viewportMargin: contentScrollView.anchors.margins
                    wide: root.isWide
                    formatShortcut: root.formatShortcut
                }

                KeybindsPage {
                    visible: root.currentSection === 1
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    viewportHeight: contentScrollView.height
                    viewportMargin: contentScrollView.anchors.margins
                    wide: root.isWide
                    keycapSource: root.keycapSource
                }

                SystemPage {
                    visible: root.currentSection === 2
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    viewportHeight: contentScrollView.height
                    viewportMargin: contentScrollView.anchors.margins
                    wide: root.isWide
                    title: root.stepTitles[2]
                    description: root.stepDescriptions[2]
                }

                AppsPage {
                    visible: root.currentSection === 3
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    viewportHeight: contentScrollView.height
                    viewportMargin: contentScrollView.anchors.margins
                    wide: root.isWide
                    title: root.stepTitles[3]
                    description: root.stepDescriptions[3]
                }

                SettingsPage {
                    visible: root.currentSection === 4
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    viewportHeight: contentScrollView.height
                    viewportMargin: contentScrollView.anchors.margins
                    wide: root.isWide
                    title: root.stepTitles[4]
                    description: root.stepDescriptions[4]
                }

                CommunityPage {
                    visible: root.currentSection === 5
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    viewportHeight: contentScrollView.height
                    Layout.topMargin: Math.max(0, (viewportHeight - implicitHeight) / 2)
                    title: root.stepTitles[5]
                    description: root.stepDescriptions[5]
                }
            }
        }
    }
}
