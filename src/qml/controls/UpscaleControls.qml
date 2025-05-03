
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components/ui"

ColumnLayout {
    id: root
    spacing: 24

    property bool isProcessing: false
    property bool updatingValues: false
    property int scale: 2
    property int originalWidth: 0
    property int originalHeight: 0

    Connections {
        target: appController
        function onImageLoaded(width, height, size) {
            console.log("Crop tools Image loaded:", width, "x", height)
            root.originalWidth = width
            root.originalHeight = height
            
        }

        function onProcessorChanged(processorName) {
            console.log("Processor changed:", processorName)
            var loadedImageInfo = appController.loadedImageInfo
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
            // TODO: Show error message
            console.error("Processing failed:", error)
        }
    }

    // Presets upscale
    Column {
        Layout.fillWidth: true
        spacing: 16

        Label {
            text: "Upscale"
            font.pixelSize: 13
            font.weight: Font.Medium
            color: "#333333"
        }

        Flow {
            width: parent.width
            spacing: 8

            Button {
                text: "2x"
                flat: true
                onClicked: {
                    root.updatingValues = true
                    root.scale = 2
                    root.updatingValues = false
                }
            }

            Button {
                text: "3x"
                flat: true
                onClicked: {
                    root.updatingValues = true
                    root.scale = 3
                    root.updatingValues = false
                }
            }

            Button {
                text: "4x"
                flat: true
                onClicked: {
                    root.updatingValues = true
                    root.scale = 4
                    root.updatingValues = false
                }
            }
        }
    }

    Item { Layout.fillHeight: true }

    // Action buttons
    RowLayout {
        Layout.fillWidth: true
        spacing: 12

        Button {
            text: "Reset"
            enabled: !root.isProcessing
            onClicked: {
                root.updatingValues = true
                root.scale = 2
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
                appController.upscaleImage(root.scale)
            }
        }
    }
}
