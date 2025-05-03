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
    property int originalSize: 0

    Component.onCompleted: {
        if (originalWidth > 0) {
            qualitySlider.value = 85  // Default quality
        }
    }

    Connections {
        target: appController
        function onImageLoaded(width, height, size) {
            root.originalWidth = width
            root.originalHeight = height
            
            root.updatingValues = true
            qualitySlider.value = 85  // Reset to default
            root.updatingValues = false
        }

        function onProcessorChanged(processorName) {
            var loadedImageInfo = JSON.parse(appController.loadedImageInfo)
            root.originalWidth = loadedImageInfo.width
            root.originalHeight = loadedImageInfo.height
            
            root.updatingValues = true
            qualitySlider.value = 85  // Reset to default
            root.updatingValues = false
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

    // Quality section
    Column {
        Layout.fillWidth: true
        spacing: 16

        Label {
            text: "Quality Settings"
            font.pixelSize: 13
            font.weight: Font.Medium
            color: "#333333"
        }

        Column {
            width: parent.width
            spacing: 8

            Label {
                text: "Image Quality: " + qualitySlider.value + "%"
                color: "#666666"
            }

            Slider {
                id: qualitySlider
                from: 1
                to: 100
                stepSize: 1
                value: 85
                width: parent.width
            }

            Label {
                text: "Lower quality = smaller file size"
                font.pixelSize: 12
                color: "#999999"
            }
        }
    }

    // Format section
    Column {
        Layout.fillWidth: true
        spacing: 16

        Label {
            text: "Output Format"
            font.pixelSize: 13
            font.weight: Font.Medium
            color: "#333333"
        }

        Flow {
            width: parent.width
            spacing: 8

            Button {
                text: "JPEG"
                checkable: true
                checked: true
                autoExclusive: true
                palette.buttonText: checked ? "white" : "black"
                // flat: !checked
            }

            Button {
                text: "WebP"
                checkable: true
                autoExclusive: true
                palette.buttonText: checked ? "white" : "black"
                // flat: !checked
            }

            Button {
                text: "PNG"
                checkable: true
                autoExclusive: true
                palette.buttonText: checked ? "white" : "black"
                // flat: !checked
                enabled: false
                ToolTip.visible: hovered
                ToolTip.text: "Coming soon"
            }
        }
    }

    // Optimization section
    Column {
        Layout.fillWidth: true
        spacing: 16

        Label {
            text: "Optimizations"
            font.pixelSize: 13
            font.weight: Font.Medium
            color: "#333333"
        }

        Column {
            width: parent.width
            spacing: 8

            CheckBox {
                text: "Strip metadata"
                checked: true
                enabled: false
                ToolTip.visible: hovered
                ToolTip.text: "Coming soon"
            }

            CheckBox {
                text: "Progressive loading"
                checked: false
                enabled: false
                ToolTip.visible: hovered
                ToolTip.text: "Coming soon"
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
                qualitySlider.value = 85
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
                appController.compressImage(
                    qualitySlider.value
                )
            }
        }
    }
}