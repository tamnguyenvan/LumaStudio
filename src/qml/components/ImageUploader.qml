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
        spacing: 16
        visible: !root.source

        // 
        Image {
            source: "qrc:/icons/upload.svg"
            anchors.horizontalCenter: parent.horizontalCenter
            sourceSize.width: 64
            sourceSize.height: 64
            width: 64
            height: 64
        }

        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Drop image here or click to upload"
            font.pixelSize: 15
            color: "#666666"
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
