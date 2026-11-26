import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.mauikit.controls as Maui

Flickable {
    id: welcomeScroll
    signal discover()
    clip: true
    contentWidth: width
    contentHeight: Math.max(height, welcomeLayout.implicitHeight + Maui.Style.contentMargins * 2)
    flickableDirection: Flickable.VerticalFlick
    ScrollBar.vertical: ScrollBar {}

    ColumnLayout {
        id: welcomeLayout
        anchors.centerIn: parent
        width: Math.min(parent.width - Maui.Style.contentMargins * 2, Maui.Style.units.gridUnit * 36)
        spacing: Maui.Style.space.big

        property real reveal: 0
        NumberAnimation on reveal {
            running: welcomeScroll.visible && welcomeScroll.Window.window && welcomeScroll.Window.window.visible
            from: 0
            to: 6
            duration: Maui.Style.enableEffects ? Maui.Style.units.longDuration * 18 : 0
        }

        Image {
            id: logo
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 128
            Layout.preferredHeight: 128
            source: "nitrux-logo.svg"
            fillMode: Image.PreserveAspectFit
            transform: Translate {
                readonly property real progress: Math.max(0, Math.min(1, welcomeLayout.reveal - 1))
                readonly property real centerOffset: welcomeScroll.contentY + welcomeScroll.height / 2
                                                     - welcomeLayout.y - logo.y - logo.height / 2
                y: centerOffset * (1 - progress * progress * (3 - 2 * progress))
            }
            NumberAnimation on opacity {
                running: welcomeScroll.visible && welcomeScroll.Window.window && welcomeScroll.Window.window.visible
                from: 0
                to: 1
                duration: Maui.Style.enableEffects ? Maui.Style.units.longDuration * 3 : 0
                easing.type: Easing.InOutQuad
            }
        }

        Maui.SectionHeader {
            id: welcomeHeader
            Layout.fillWidth: true
            text1: distributionRelease.length > 0
                   ? qsTr("Welcome to Nitrux %1").arg(distributionRelease)
                   : qsTr("Welcome to Nitrux")
            text2: qsTr("Nitrux pairs a tiling Hyprland desktop with Maui applications and a read-only system image. Arrange windows across workspaces, find applications in AppFinder, and update the operating system separately from your apps and personal files.")
            // label1.font.bold: true
            label1.font.pointSize: Maui.Style.fontSizes.enormous * 2
            label1.horizontalAlignment: Text.AlignHCenter
            label1.wrapMode: Text.Wrap
            label2.horizontalAlignment: Text.AlignHCenter
            label2.wrapMode: Text.Wrap
            opacity: Math.max(0, Math.min(1, welcomeLayout.reveal - 2))
        }

        Rectangle {
            opacity: Math.max(0, Math.min(1, welcomeLayout.reveal - 3))
            enabled: opacity > 0
            Layout.fillWidth: true
            implicitHeight: introCard.implicitHeight + Maui.Style.contentMargins * 2
            radius: Maui.Style.radiusV
            color: Maui.Theme.alternateBackgroundColor
            border.color: Maui.Theme.backgroundColor
            ColumnLayout {
                id: introCard
                anchors.fill: parent
                anchors.margins: Maui.Style.contentMargins
                spacing: Maui.Style.space.small
                Maui.SectionHeader {
                    Layout.fillWidth: true
                    text1: qsTr("Take the Tour")
                    text2: qsTr("Start the tour to try the dock, learn Hyprland keybinds, and explore how Nitrux manages apps and system updates.")
                    label2.wrapMode: Text.Wrap
                }
                Maui.FlexSectionItem {
                    id: loginRow
                    Layout.fillWidth: true
                    flat: true
                    label1.text: qsTr("Start Onward at Login")
                    label2.text: qsTr("Open the tour when you sign in to Nitrux.")
                    label2.wrapMode: Text.Wrap
                    template.content: Switch {
                        Accessible.name: loginRow.label1.text
                        checked: loginService.enabled()
                        onClicked: {
                            loginError.visible = !loginService.setEnabled(checked)
                            checked = loginService.enabled()
                        }
                    }
                }
                Label {
                    id: loginError
                    visible: false
                    Layout.fillWidth: true
                    wrapMode: Text.Wrap
                    text: qsTr("Could not change the OpenRC login service.")
                }
            }
        }

        Label {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            textFormat: Text.StyledText
            opacity: Math.max(0, welcomeLayout.reveal - 4)
            text: qsTr("© 2017-%1 Some Rights Reserved, made with <font color='red'><b>♥</b></font> by Nitrux Latinoamericana S.C.").arg(new Date().getFullYear())
        }

        Button {
            id: discoverButton
            Layout.alignment: Qt.AlignHCenter
            display: AbstractButton.TextOnly
            text: qsTr("Discover Nitrux")
            opacity: Math.max(0, Math.min(1, welcomeLayout.reveal - 5))
            enabled: opacity >= 1
            onClicked: welcomeScroll.discover()


        }


    }

}
