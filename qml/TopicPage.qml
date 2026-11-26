import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.mauikit.controls as Maui

ColumnLayout {
    id: topics
    required property var entries
    required property string guideTitle
    required property url guideUrl
    spacing: Maui.Style.space.medium

    GridLayout {
        Layout.fillWidth: true
        columns: Math.min(4, Math.max(1, Math.floor(topics.width / (Maui.Style.units.gridUnit * 22))))
        columnSpacing: Maui.Style.space.medium
        rowSpacing: Maui.Style.space.medium

        Repeater {
            model: topics.entries
            delegate: Rectangle {
                required property var modelData
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: Maui.Style.units.gridUnit * 18
                implicitHeight: topicLayout.implicitHeight + Maui.Style.contentMargins * 2
                radius: Maui.Style.radiusV
                color: Maui.Theme.alternateBackgroundColor
                border.color: Maui.Theme.backgroundColor
                border.width: 1

                ColumnLayout {
                    id: topicLayout
                    anchors.fill: parent
                    anchors.margins: Maui.Style.contentMargins
                    spacing: Maui.Style.space.small

                    Maui.SectionHeader {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignTop
                        text1: modelData.title
                        text2: modelData.description
                        label1.wrapMode: Text.Wrap
                        label2.wrapMode: Text.Wrap
                    }
                }
            }
        }
    }

    Button {
        display: AbstractButton.TextOnly

        text: topics.guideTitle
        onClicked: Qt.openUrlExternally(topics.guideUrl)
    }
}
