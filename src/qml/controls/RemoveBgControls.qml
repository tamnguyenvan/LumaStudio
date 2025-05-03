
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components/ui"

ColumnLayout {
    id: root
    spacing: 24

    property bool isProcessing: false
    property bool updatingValues: false
    property int originalWidth: 0
    property int originalHeight: 0

    Connections {
        target: appController
        function onImageLoaded(width, height, size) {
            console.log("Remove bg tools Image loaded:", width, "x", height)
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

    GroupBox {
        title: "Remove Background Options"
        Layout.fillHeight: true
        Layout.fillWidth: true

        ColumnLayout {
            anchors.fill: parent
            spacing: 10

            Label {
                text: "Background Color"
                color: "#666666"
            }

            // Background color
            CustomColorPicker {
                id: bgColorPicker
                Layout.fillWidth: true
                enabled: !root.isProcessing
                color: "#ffffff"
                onColorChanged: {
                    root.updatingValues = true
                    bgColorPicker.color = color
                    root.updatingValues = false
                }
            }

            // Crop
            CheckBox {
                id: cropCheckBox
                text: "Crop"
                checked: false
                onCheckedChanged: {
                    root.updatingValues = true
                    cropCheckBox.checked = checked
                    root.updatingValues = false
                }
            }

            Item { Layout.fillHeight: true }
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
                xSpinBox.value = 0
                ySpinBox.value = 0
                widthSpinBox.value = root.originalWidth
                heightSpinBox.value = root.originalHeight
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
                appController.removeBgImage(
                    bgColorPicker.color,
                    cropCheckBox.checked
                )
            }
        }
    }
}
