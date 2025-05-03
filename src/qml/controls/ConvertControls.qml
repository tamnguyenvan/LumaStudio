import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    property var imageInfo: null
    property string selectedFormat: "JPEG"
    property bool isProcessing: false
    property bool updatingValues: false

    Connections {
        target: appController
        function onImageLoaded(width, height, size) {
            console.log("Convert tools Image loaded:", width, "x", height)
            root.originalWidth = width
            root.originalHeight = height
        }

        function onProcessorChanged(processorName) {
            console.log("Processor changed:", processorName)
            var loadedImageInfo = JSON.parse(appController.loadedImageInfo)
            root.originalWidth = loadedImageInfo.width
            root.originalHeight = loadedImageInfo.height
        }

        function onProcessingStarted(operation) {
            root.isProcessing = true
        }

        function onProcessingCompleted(result) {
            root.isProcessing = false
            if (result) {
                workspace.currentImage = result
            }
        }

        function onProcessingFailed(error) {
            root.isProcessing = false
            console.error("Processing failed:", error)
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 20

        GroupBox {
            title: "Format"
            Layout.fillWidth: true
            Layout.topMargin: 10

            ColumnLayout {
                anchors.fill: parent
                spacing: 10

                Label {
                    text: "Convert image to:"
                    color: "#666666"
                }

                ComboBox {
                    id: formatCombo
                    model: ["JPEG", "PNG", "WebP"]
                    currentIndex: 0
                    onCurrentTextChanged: root.selectedFormat = currentText
                    Layout.fillWidth: true
                    enabled: !root.isProcessing
                }

                Label {
                    text: "Current format: " + (imageInfo ? imageInfo.format || "Unknown" : "Unknown")
                    font.pixelSize: 12
                    color: "#999999"
                }
            }
        }

        GroupBox {
            title: "Options"
            Layout.fillWidth: true

            ColumnLayout {
                anchors.fill: parent
                spacing: 10

                CheckBox {
                    text: "Strip metadata"
                    checked: true
                    enabled: false
                    ToolTip.visible: hovered
                    ToolTip.text: "Coming soon"
                }

                CheckBox {
                    text: "Optimize for web"
                    checked: true
                    enabled: false
                    ToolTip.visible: hovered
                    ToolTip.text: "Coming soon"
                }
            }
        }

        // Action buttons
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Button {
                text: "Reset"
                enabled: !root.isProcessing
                onClicked: {
                    root.updatingValues = true
                    root.selectedFormat = "JPEG"
                    root.updatingValues = false
                }
            }

            Item { Layout.fillWidth: true }

            BusyIndicator {
                running: root.isProcessing
                visible: running
            }

            Button {
                text: "Apply"
                highlighted: true
                palette.buttonText: "white"
                enabled: !root.isProcessing
                onClicked: {
                    appController.convertImage(root.selectedFormat)
                }
            }
        }

        Item {
            Layout.fillHeight: true
        }
    }
}