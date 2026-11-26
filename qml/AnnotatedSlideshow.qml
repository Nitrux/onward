import QtQuick
import QtQuick.Shapes
import QtQuick.Effects
import QtQuick.Controls
import QtQuick.Layouts
import org.mauikit.controls as Maui

Item {
    id: preview
    required property var frames
    required property string imageFolder
    required property real aspectRatio
    required property bool playing
    implicitHeight: Math.max(0, width - Maui.Style.contentMargins * 2) / aspectRatio + Maui.Style.contentMargins * 2
    readonly property int nextFrame: (frame + 1) % frames.length
    property int frame: 0
    onVisibleChanged: if (!visible) frame = 0

    Item {
        id: slideArea
        anchors.fill: parent
        anchors.margins: Maui.Style.contentMargins
    }

    RectangularShadow {
        id: shadowSurface
        anchors.centerIn: slideArea
        width: currentImage.paintedWidth
        height: currentImage.paintedHeight
        opacity: 1 - incomingFrame.opacity
        radius: Maui.Style.radiusV
        offset: Qt.vector2d(0, Maui.Style.space.medium)
        blur: Maui.Style.contentMargins * 2
        color: Qt.rgba(0, 0, 0, 0.32)
    }

    RectangularShadow {
        anchors.centerIn: slideArea
        width: incomingFrame.paintedWidth
        height: incomingFrame.paintedHeight
        opacity: incomingFrame.opacity
        visible: opacity > 0
        radius: shadowSurface.radius
        offset: shadowSurface.offset
        blur: shadowSurface.blur
        color: shadowSurface.color
    }

    Rectangle {
        id: cornerMask
        anchors.fill: slideArea
        radius: shadowSurface.radius
        visible: false
        layer.enabled: true
    }

    Item {
        anchors.fill: slideArea
        layer.enabled: true
        layer.effect: MultiEffect {
            maskEnabled: true
            maskSource: cornerMask
            autoPaddingEnabled: false
        }

        Image {
            id: currentImage
            anchors.fill: parent
            source: preview.visible ? preview.imageFolder + "/" + preview.frames[preview.frame].image + ".png" : ""
            fillMode: Image.PreserveAspectFit
            mipmap: false
        }

        Image {
            id: incomingFrame
            anchors.fill: parent
            source: preview.visible
                    ? preview.imageFolder + "/" + preview.frames[preview.nextFrame].image + ".png" : ""
            asynchronous: true
            fillMode: Image.PreserveAspectFit
            mipmap: false
            opacity: 0
        }
    }

    Item {
        id: annotation
        anchors.fill: slideArea
        readonly property var slide: preview.frames[preview.frame]
        readonly property real targetX: (width - currentImage.paintedWidth) / 2 + currentImage.paintedWidth * slide.target.x
        readonly property real targetY: (height - currentImage.paintedHeight) / 2 + currentImage.paintedHeight * slide.target.y
        opacity: 1 - incomingFrame.opacity

        Item {
            id: pointer
            readonly property real dx: annotation.targetX - (callout.x + callout.width / 2)
            readonly property real dy: annotation.targetY - (callout.y + callout.height / 2)
            readonly property real edge: Math.max(Math.abs(dx) / (callout.width / 2),
                                                   Math.abs(dy) / (callout.height / 2))
            visible: edge > 1
            x: callout.x + callout.width / 2 + dx / Math.max(1, edge)
            y: callout.y + callout.height / 2 + dy / Math.max(1, edge)
            width: Math.hypot(annotation.targetX - x, annotation.targetY - y)
            readonly property real bend: Math.min(width / 3, Maui.Style.units.gridUnit * 2)
            readonly property real head: Math.min(width / 4, Maui.Style.space.medium * 1.5)
            height: bend + head
            rotation: Math.atan2(dy, dx) * 180 / Math.PI
            transformOrigin: Item.TopLeft

            Shape {
                anchors.fill: parent
                preferredRendererType: Shape.CurveRenderer
                ShapePath {
                    strokeColor: "#eff5f5"
                    strokeWidth: Maui.Style.space.tiny
                    strokeStyle: ShapePath.DashLine
                    dashPattern: [3, 3]
                    capStyle: ShapePath.RoundCap
                    fillColor: "transparent"
                    PathCubic {
                        control1X: pointer.width * 0.3; control1Y: -pointer.bend
                        control2X: pointer.width * 0.55; control2Y: 0
                        x: pointer.width - pointer.head / 2; y: 0
                    }
                }
                ShapePath {
                    strokeWidth: -1
                    fillColor: "#eff5f5"
                    startX: pointer.width; startY: 0
                    PathLine { x: pointer.width - pointer.head; y: -pointer.head / 2 }
                    PathLine { x: pointer.width - pointer.head * 0.7; y: 0 }
                    PathLine { x: pointer.width - pointer.head; y: pointer.head / 2 }
                    PathLine { x: pointer.width; y: 0 }
                }
            }
        }

        Rectangle {
            id: callout
            readonly property real inset: Maui.Style.contentMargins
            readonly property real captionInset: inset + Maui.Style.space.small + Maui.Style.space.medium
            width: Math.min(annotation.width - inset * 2, Maui.Style.units.gridUnit * 16)
            height: caption.implicitHeight + captionInset * 2
            x: Math.max(inset, Math.min(annotation.width - width - inset, annotation.width * annotation.slide.label.x - width / 2))
            y: Math.max(inset, Math.min(annotation.height - height - inset, annotation.height * annotation.slide.label.y - height / 2))
            radius: Maui.Style.radiusV + Maui.Style.space.small
            color: Maui.Theme.backgroundColor
            border.color: Qt.alpha(Maui.Theme.textColor, 0.10)

            Rectangle {
                anchors.fill: parent
                anchors.margins: Maui.Style.space.small
                radius: Maui.Style.radiusV
                color: Maui.Theme.alternateBackgroundColor
                border.color: Qt.alpha(Maui.Theme.textColor, 0.25)
            }

            ColumnLayout {
                id: caption
                anchors.centerIn: parent
                width: parent.width - callout.captionInset * 2
                spacing: Maui.Style.space.small
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Maui.Style.space.small
                    Maui.IconItem {
                        iconSource: "dialog-information"
                        iconSizeHint: Maui.Style.iconSizes.small
                    }
                    Label {
                        Layout.fillWidth: true
                        text: annotation.slide.title
                        color: Maui.Theme.textColor
                        font.weight: Font.DemiBold
                        wrapMode: Text.Wrap
                    }
                }
                Label {
                    Layout.fillWidth: true
                    text: annotation.slide.tip
                    color: Qt.alpha(Maui.Theme.textColor, 0.87)
                    wrapMode: Text.Wrap
                }
            }
        }
    }

    Timer {
        interval: 6000
        repeat: true
        running: preview.visible && preview.playing
        onTriggered: {
            if (incomingFrame.status === Image.Ready)
                fade.start()
        }
    }

    SequentialAnimation {
        id: fade
        NumberAnimation {
            target: incomingFrame
            property: "opacity"
            to: 1
            duration: Maui.Style.enableEffects ? Maui.Style.units.longDuration : 0
        }
        ScriptAction { script: if (preview.visible) preview.frame = preview.nextFrame }
        PropertyAction { target: incomingFrame; property: "opacity"; value: 0 }
    }
}
