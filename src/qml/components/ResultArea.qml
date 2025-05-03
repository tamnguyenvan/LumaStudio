import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

Rectangle {
    id: root
    color: "#FFFFFF"

    property string source: ""
    property var imageInfo: ({ width: 0, height: 0, size: "0 KB" })
    property var originalInfo: ({ width: 0, height: 0, size: "0 KB", source: "" })
    signal newImageRequested()

    // Save file dialog
    FileDialog {
        id: saveDialog
        title: "Save Image"
        nameFilters: ["PNG files (*.png)", "JPEG files (*.jpg *.jpeg)"]
        fileMode: FileDialog.SaveFile
        onAccepted: {
            appController.saveImage(saveDialog.selectedFile)
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        // Header
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Label {
                text: "Result"
                font.pixelSize: 20
                font.weight: Font.Medium
                Layout.fillWidth: true
            }

            Button {
                text: "New Image"
                icon.source: "qrc:/icons/upload.svg"
                icon.width: 16
                icon.height: 16
                onClicked: root.newImageRequested()
            }

            Button {
                text: "Save"
                palette.buttonText: "white"
                icon.source: "qrc:/icons/save.svg"
                icon.width: 16
                icon.height: 16
                highlighted: true
                onClicked: saveDialog.open()
            }
        }

        // Image info
        GridLayout {
            Layout.fillWidth: true
            columns: 2
            rowSpacing: 4
            columnSpacing: 20

            Label {
                text: "Original:"
                font.pixelSize: 13
                font.weight: Font.Medium
                color: "#666666"
            }

            Label {
                text: originalInfo.width + " × " + originalInfo.height + " px"
                font.pixelSize: 13
                color: "#666666"
            }

            Label {
                text: "Result:"
                font.pixelSize: 13
                font.weight: Font.Medium
                color: "#666666"
            }

            Label {
                text: imageInfo.width + " × " + imageInfo.height + " px"
                font.pixelSize: 13
                color: "#666666"
            }

            Label {
                text: "File size:"
                font.pixelSize: 13
                font.weight: Font.Medium
                color: "#666666"
            }

            Label {
                text: imageInfo && imageInfo.size ? imageInfo.size : ""
                font.pixelSize: 13
                color: "#666666"
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#E5E5E5"
        }

        // Image preview
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            Image {
                source: root.source
                fillMode: Image.PreserveAspectFit
                width: parent.width
                height: parent.height
                smooth: true
                mipmap: true

                Rectangle {
                    anchors.fill: parent
                    color: "#F5F5F7"
                    visible: parent.status === Image.Loading
                    z: -1

                    BusyIndicator {
                        anchors.centerIn: parent
                        running: parent.visible
                    }
                }
            }
        }
    }
}
