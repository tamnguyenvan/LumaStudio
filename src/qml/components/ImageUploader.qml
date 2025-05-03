import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

Rectangle {
    id: root
    color: "#FFFFFF"
    border.color: dropArea.containsDrag || mouseArea.containsMouse ? "#007AFF" : "#E5E5E5"
    border.width: 2
    radius: 8

    property string source: ""
    signal imageLoaded(string imageUrl)

    // Reset
    function reset() {
        root.source = ""
    }

    // Semi-transparent overlay
    Rectangle {
        anchors.fill: parent
        color: "#007AFF"
        opacity: (dropArea.containsDrag || mouseArea.containsMouse) ? 0.1 : 0
        radius: parent.radius

        Behavior on opacity {
            NumberAnimation { duration: 150 }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: fileDialog.open()
        cursorShape: Qt.PointingHandCursor
    }

    DropArea {
        id: dropArea
        anchors.fill: parent
        onDropped: (drop) => {
            if (drop.hasUrls) {
                const result = appController.loadImage(drop.urls[0])
                if (result) {
                    root.source = result
                    root.imageLoaded(result)
                }
            }
        }
    }

    // Upload placeholder
    Column {
        anchors.centerIn: parent
        spacing: 24
        visible: !root.source

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 96
            height: 96
            radius: width / 2
            color: "#F5F5F7"
            border.color: "#E5E5E5"
            border.width: 1

            Image {
                source: "qrc:/icons/upload.svg"
                anchors.centerIn: parent
                sourceSize.width: 48
                sourceSize.height: 48
                width: 48
                height: 48
                opacity: 0.6
            }
        }

        Column {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 8

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Drop image here"
                font.pixelSize: 16
                font.weight: Font.Medium
                color: "#333333"
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "or click to browse"
                font.pixelSize: 14
                color: "#666666"
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "JPG, PNG or GIF up to 10MB"
                font.pixelSize: 12
                color: "#999999"
                topPadding: 4
            }
        }
    }

    // Drag & Drop overlay
    Rectangle {
        id: dropOverlay
        anchors.fill: parent
        color: "#F5F5F7"
        opacity: dropArea.containsDrag ? 1 : 0
        visible: opacity > 0
        border.color: "#007AFF"
        border.width: 2
        radius: 8

        Column {
            anchors.centerIn: parent
            spacing: 16

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Release to Upload"
                font.pixelSize: 16
                font.weight: Font.Medium
                color: "#007AFF"
            }

            Image {
                source: "qrc:/icons/upload.svg"
                anchors.horizontalCenter: parent.horizontalCenter
                sourceSize.width: 48
                sourceSize.height: 48
                width: 48
                height: 48
                opacity: 0.6
            }
        }

        // Fade animation
        Behavior on opacity {
            NumberAnimation { duration: 150 }
        }
    }

    // Image preview
    Image {
        anchors.fill: parent
        anchors.margins: 20
        source: root.source
        fillMode: Image.PreserveAspectFit
        visible: root.source !== ""
        
        Rectangle {
            anchors.fill: parent
            color: "transparent"
            border.color: "#E5E5E5"
            border.width: 1
            visible: parent.status === Image.Ready
        }
    }

    FileDialog {
        id: fileDialog
        title: "Choose an image"
        nameFilters: ["Image files (*.jpg *.jpeg *.png *.gif)"]
        onAccepted: {
            const result = appController.loadImage(fileDialog.selectedFile)
            root.source = fileDialog.selectedFile
            root.imageLoaded(fileDialog.selectedFile)
        }
    }

    Behavior on border.color {
        ColorAnimation { duration: 150 }
    }
}
