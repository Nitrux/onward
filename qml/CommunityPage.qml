import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.mauikit.controls as Maui

ColumnLayout {
    id: communityPage
    required property real viewportHeight
    required property string title
    required property string description
    Layout.maximumWidth: Maui.Style.units.gridUnit * 36
    spacing: Maui.Style.space.big

    Image {
        opacity: Math.max(0, communityHeader.reveal - 2)
        Layout.alignment: Qt.AlignHCenter
        Layout.preferredWidth: Maui.Style.units.gridUnit * 8
        Layout.preferredHeight: Layout.preferredWidth
        source: "nx_logo.svg"
        sourceSize.width: Math.ceil(width * Screen.devicePixelRatio)
        fillMode: Image.PreserveAspectFit
        Accessible.name: qsTr("Nitrux Latinoamericana")
        Accessible.role: Accessible.Graphic
    }

    Maui.SectionHeader {
        id: communityHeader
        Layout.alignment: Qt.AlignHCenter
        Layout.fillWidth: true
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
        spacing: Maui.Style.space.big
        opacity: Math.max(0, communityHeader.reveal - 2)

        Repeater {
            model: [
                {
                    title: qsTr("Contribute"),
                    description: qsTr("Translate a message, design artwork, test a release, or package an AppBox. Use the issue templates to report a bug or request a feature."),
                    links: [
                        [qsTr("Contribution Guide"), "https://nxos.org/documentation/resources/get-involved/"],
                        [qsTr("Bug Tracker"), "https://github.com/Nitrux/nitrux-bug-tracker"],
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
                        ["Reddit", "https://www.reddit.com/r/Nitrux_NX/"]
                    ]
                },
                {
                    title: qsTr("Resources"),
                    description: qsTr("Browse the documentation, follow a tutorial, or read the Nitrux blog."),
                    links: [
                        [qsTr("Documentation"), "https://nxos.org/documentation/"],
                        [qsTr("Tutorials"), "https://nxos.org/documentation/resources/tutorials/"],
                        [qsTr("Blog"), "https://nxos.org/blog/"]
                    ]
                }
            ]

            ColumnLayout {
                id: section
                required property var modelData
                Layout.fillWidth: true
                spacing: Maui.Style.space.small

                Maui.SectionHeader {
                    Layout.fillWidth: true
                    text1: section.modelData.title
                    text2: section.modelData.description
                    label1.horizontalAlignment: Text.AlignHCenter
                    label1.wrapMode: Text.Wrap
                    label2.horizontalAlignment: Text.AlignHCenter
                    label2.wrapMode: Text.Wrap
                }

                Flow {
                    id: linkFlow
                    Layout.fillWidth: true
                    Layout.leftMargin: Maui.Style.contentMargins
                    Layout.rightMargin: Maui.Style.contentMargins
                    spacing: Maui.Style.space.small

                    Repeater {
                        id: links
                        model: section.modelData.links
                        Button {
                            id: linkButton
                            required property int index
                            required property var modelData
                            text: modelData[0]
                            flat: true
                            font.underline: true
                            HoverHandler { cursorShape: Qt.PointingHandCursor }
                            onClicked: Qt.openUrlExternally(modelData[1])

                            // Shift each wrapped row by half its unused width.
                            transform: Translate {
                                x: {
                                    let last = linkButton
                                    for (let i = linkButton.index + 1; i < links.count; ++i) {
                                        const next = links.itemAt(i)
                                        if (!next || next.y !== linkButton.y)
                                            break
                                        last = next
                                    }
                                    return linkFlow.effectiveLayoutDirection === Qt.RightToLeft
                                        ? -last.x / 2
                                        : (linkFlow.width - last.x - last.width) / 2
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
