import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "ui"

Item {
    id: root
    Layout.fillWidth: true
    Layout.fillHeight: true

    property string currentTool: ""
    property string currentImage: ""
    property var imageInfo: ({ width: 0, height: 0, size: "0 KB" })
    property string processedImage: ""

    state: "empty"

    states: [
        State {
            name: "empty"
            PropertyChanges { target: root; currentImage: "" }
            PropertyChanges { target: root; currentTool: "" }
            PropertyChanges { target: root; processedImage: "" }
        },
        State {
            name: "edit"
        },
        State {
            name: "result"
            PropertyChanges { target: root; currentTool: "" }
        }
    ]

    Connections {
        target: appController
        function onImageLoaded(width, height, size) {
            root.imageInfo = {
                width: width,
                height: height,
                size: size
            }
        }

        function onProcessingCompleted(result) {
            console.log("processing completed:", result)
            root.processedImage = result
            root.state = "result"
        }

        function onProcessingFailed(error) {
            errorDialog.text = error
            errorDialog.open()
        }
    }

    // Empty state
    EmptyState {
        anchors.centerIn: parent
        visible: root.state === "empty"
        icon: "qrc:/icons/resize.svg"
        title: "Welcome to Luma Studio"
        description: "Select a tool from the sidebar to get started"
        buttonText: "Open Image"
        onButtonClicked: imageUploader.openFileDialog()
    }

    // Tool state
    SplitView {
        anchors.fill: parent
        visible: root.state === "edit"

        // Image area
        Item {
            SplitView.fillWidth: true
            SplitView.minimumWidth: 400

            ImageUploader {
                id: imageUploader
                anchors.fill: parent
                anchors.margins: 20
                source: root.currentImage
                onImageLoaded: (imageUrl) => {
                    root.currentImage = imageUrl
                    root.state = "edit"
                }
            }
        }

        // Tool controls panel
        Rectangle {
            SplitView.preferredWidth: 300
            SplitView.minimumWidth: 240
            SplitView.maximumWidth: 400
            color: "#FFFFFF"
            visible: root.state === "edit" && root.currentImage !== ""

            Rectangle {
                anchors {
                    left: parent.left
                    top: parent.top
                    bottom: parent.bottom
                }
                width: 1
                color: "#E5E5E5"
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 20

                // Tool header
                Column {
                    Layout.fillWidth: true
                    spacing: 4

                    Label {
                        text: currentTool
                        font.pixelSize: 20
                        font.weight: Font.Medium
                    }

                    Label {
                        text: "Original dimensions: " + imageInfo.width + " × " + imageInfo.height
                        font.pixelSize: 13
                        color: "#666666"
                    }

                    Label {
                        text: "File size: " + imageInfo.size
                        font.pixelSize: 13
                        color: "#666666"
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: "#E5E5E5"
                }

                // Tool controls
                Loader {
                    id: toolControls
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    source: {
                        console.log("current tool:", root.currentTool)
                        return root.currentTool ? 
                        "qrc:/qml/controls/" + root.currentTool + "Controls.qml" : ""
                    }
                }
            }
        }
    }

    // Result state
    ResultArea {
        anchors.fill: parent
        visible: root.state === "result"
        source: root.processedImage 
        imageInfo: appController && appController.processedImageInfo
        originalInfo: {
            return {
                width: root.imageInfo.width,
                height: root.imageInfo.height,
                size: root.imageInfo.size,
                source: root.currentImage
            }
        }
        onNewImageRequested: {
            imageUploader.reset()
            root.currentImage = ""
            root.processedImage = ""
            root.currentTool = "Resize"  
            root.state = "edit"
        }
    }

    // Error dialog
    Dialog {
        id: errorDialog
        title: "Error"
        modal: true
        standardButtons: Dialog.Ok
        anchors.centerIn: parent
        
        property alias text: messageLabel.text

        contentItem: ColumnLayout {
            spacing: 20

            Image {
                source: "qrc:/icons/error.svg"
                sourceSize: Qt.size(32, 32)
                Layout.alignment: Qt.AlignHCenter
            }

            Label {
                id: messageLabel
                wrapMode: Text.Wrap
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
            }
        }

        background: Rectangle {
            radius: 8
            color: "#FFFFFF"
            border.color: "#E5E5E5"
            border.width: 1
        }
    }
}
