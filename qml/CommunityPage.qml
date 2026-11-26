import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.mauikit.controls as Maui

ColumnLayout {
    id: communityPage
    required property real viewportHeight
    required property string title
    required property string description
    spacing: Maui.Style.space.medium

    Maui.SectionHeader {
        id: communityHeader
        Layout.alignment: Qt.AlignHCenter
        Layout.fillWidth: true
        Layout.maximumWidth: Maui.Style.units.gridUnit * 36
        text1: communityPage.title
        text2: communityPage.description
        label1.font.pointSize: Maui.Style.fontSizes.enormous * 2
        label1.horizontalAlignment: Text.AlignHCenter
        label1.wrapMode: Text.Wrap
        label2.horizontalAlignment: Text.AlignHCenter
        label2.wrapMode: Text.Wrap
        property real reveal: 0
        NumberAnimation on reveal {
            running: communityHeader.visible && communityPage.Window.window && communityPage.Window.window.visible
            from: 0
            to: 3
            duration: Maui.Style.enableEffects ? Maui.Style.units.longDuration * 9 : 0
        }
        opacity: Math.min(1, reveal)
        transform: Translate {
            readonly property real travel: Math.max(0, (communityPage.viewportHeight - communityHeader.height) / 2 - communityPage.y - communityHeader.y)
            readonly property real progress: Math.max(0, Math.min(1, communityHeader.reveal - 1))
            y: travel * (1 - progress * progress * (3 - 2 * progress))
        }
    }

    ColumnLayout {
        Layout.alignment: Qt.AlignHCenter
        Layout.fillWidth: true
        Layout.maximumWidth: Maui.Style.units.gridUnit * 44
        spacing: Maui.Style.space.medium
        opacity: Math.max(0, communityHeader.reveal - 2)

        Image {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: Maui.Style.units.gridUnit * 8
            Layout.preferredHeight: Layout.preferredWidth
            source: "nx_logo.svg"
            sourceSize.width: Math.ceil(width * Screen.devicePixelRatio)
            fillMode: Image.PreserveAspectFit
            Accessible.name: qsTr("Nitrux Latinoamericana")
            Accessible.role: Accessible.Graphic
        }

        Repeater {
            model: [
                {
                    title: qsTr("Contribute"),
                    description: qsTr("Translate a message, design artwork, test a release, or package an AppBox. Use the issue templates to report a bug or request a feature."),
                    links: [
                        [qsTr("Contribution Guide"), "https://nxos.org/documentation/resources/get-involved/"],
                        [qsTr("Bug Tracker"), "https://github.com/Nitrux/nitrux-bug-tracker/issues"],
                        [qsTr("AppBox Packaging"), "https://github.com/Nitrux/nx-apphub/wiki"]
                    ]
                },
                {
                    title: qsTr("Community"),
                    description: qsTr("Ask a question, join a conversation, or follow project news."),
                    links: [
                        [qsTr("Discussions"), "https://github.com/orgs/Nitrux/discussions"],
                        ["X", "https://x.com/Nitrux_NX"], ["Bluesky", "https://bsky.app/profile/nitrux.bsky.social"],
                        ["Facebook", "https://www.facebook.com/Nitrux"], ["YouTube", "https://www.youtube.com/c/NitruxInside"],
                        ["GitHub", "https://github.com/Nitrux/"], ["Instagram", "https://instagram.com/nitrux_nx"],
                        ["Telegram", "https://t.me/nitrux_eng"], ["Mastodon", "https://floss.social/@Nitrux_NX"],
                        ["Threads", "https://www.threads.net/@nitrux_nx"], ["Gitter", "https://gitter.im/Nitrux/public"],
                        ["Reddit", "https://www.reddit.com/r/Nitrux_NX/"], [qsTr("E-mail"), "mailto:hello@nxos.org"]
                    ]
                },
                {
                    title: qsTr("Resources"),
                    description: qsTr("Check known issues for your release or follow a tutorial at your own pace."),
                    links: [
                        [qsTr("Documentation"), "https://nxos.org/documentation/"], [qsTr("Changelog"), "https://nxos.org/changelog/"],
                        [qsTr("Known Issues"), "https://nxos.org/issues/"], [qsTr("Tutorial"), "https://nxos.org/tutorial/"],
                        [qsTr("PSA"), "https://nxos.org/psa/"], [qsTr("Blog"), "https://nxos.org/blog/"]
                    ]
                }
            ]

            Rectangle {
                id: card
                required property var modelData
                Layout.fillWidth: true
                implicitHeight: content.implicitHeight + Maui.Style.contentMargins * 2
                color: Maui.Theme.alternateBackgroundColor
                border.color: Maui.Theme.backgroundColor
                radius: Maui.Style.radiusV
                ColumnLayout {
                    id: content
                    anchors.fill: parent
                    anchors.margins: Maui.Style.contentMargins
                    spacing: Maui.Style.space.small
                    Maui.SectionHeader {
                        Layout.fillWidth: true
                        text1: card.modelData.title
                        text2: card.modelData.description
                        label2.wrapMode: Text.Wrap
                    }
                    Flow {
                        Layout.fillWidth: true
                        Layout.leftMargin: Maui.Style.contentMargins
                        Layout.rightMargin: Maui.Style.contentMargins
                        spacing: Maui.Style.space.small
                        Repeater {
                            model: card.modelData.links
                            Button {
                                required property var modelData
                                text: modelData[0]
                                flat: true
                                onClicked: Qt.openUrlExternally(modelData[1])
                            }
                        }
                    }
                }
            }
        }

        Label {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            text: qsTr("Trademarks and logos belong to their respective owners.")
        }
        Button {
            Layout.alignment: Qt.AlignHCenter
            flat: true
            font.underline: true
            text: qsTr("Website Privacy Policy")
            onClicked: Qt.openUrlExternally("https://nxos.org/privacy/")
        }
    }
}
