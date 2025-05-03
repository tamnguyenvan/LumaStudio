import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components/ui"

ColumnLayout {
    id: root
    spacing: 20

    property real aspectRatio: 1.0
    property bool updatingValues: false
    property int originalWidth: 0
    property int originalHeight: 0
    property bool isProcessing: false

    // Timer for delayed aspect ratio updates
    Timer {
        id: aspectRatioTimer
        interval: 300 // Wait 300ms after user stops typing
        property bool updateHeight: true
        property int pendingValue: 0

        onTriggered: {
            if (keepAspectRatio.checked && !root.updatingValues) {
                root.updatingValues = true
                if (updateHeight) {
                    heightSpinBox.value = Math.round(pendingValue / aspectRatio)
                } else {
                    widthSpinBox.value = Math.round(pendingValue * aspectRatio)
                }
                root.updatingValues = false
            }
        }
    }

    Component.onCompleted: {
        if (originalWidth > 0) {
            widthSpinBox.value = originalWidth
            heightSpinBox.value = originalHeight
            aspectRatio = originalWidth / originalHeight
        }
    }

    Connections {
        target: appController
        function onImageLoaded(width, height, size) {
            console.log("Image loaded:", width, "x", height)
            root.originalWidth = width
            root.originalHeight = height
            root.aspectRatio = width / height
            
            root.updatingValues = true
            widthSpinBox.value = width
            heightSpinBox.value = height
            root.updatingValues = false
        }

        function onProcessorChanged(processorName) {
            console.log("Processor changed:", processorName)
            var loadedImageInfo = JSON.parse(appController.loadedImageInfo)
            root.originalWidth = loadedImageInfo.width
            root.originalHeight = loadedImageInfo.height
            
            root.updatingValues = true
            widthSpinBox.value = root.originalWidth
            heightSpinBox.value = root.originalHeight
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
            // TODO: Show error message
            console.error("Processing failed:", error)
        }
    }

    // Dimensions section
    Column {
        Layout.fillWidth: true
        spacing: 16

        Label {
            text: "Dimensions"
            font.pixelSize: 13
            font.weight: Font.Medium
            color: "#333333"
        }

        GridLayout {
            width: parent.width
            columns: 2
            columnSpacing: 12
            rowSpacing: 12

            Label {
                text: "Width"
                Layout.alignment: Qt.AlignRight
                color: "#666666"
            }

            CustomSpinBox {
                id: widthSpinBox
                from: 1
                to: 10000
                value: 800
                Layout.fillWidth: true
                onValueModified: {
                    if (!root.updatingValues) {
                        aspectRatioTimer.updateHeight = true
                        aspectRatioTimer.pendingValue = value
                        aspectRatioTimer.restart()
                    }
                }
                onTextEdited: (value) => {
                    if (!root.updatingValues) {
                        aspectRatioTimer.updateHeight = true
                        aspectRatioTimer.pendingValue = value
                        aspectRatioTimer.restart()
                    }
                }
            }

            Label {
                text: "Height"
                Layout.alignment: Qt.AlignRight
                color: "#666666"
            }

            CustomSpinBox {
                id: heightSpinBox
                from: 1
                to: 10000
                value: 600
                Layout.fillWidth: true
                onValueModified: {
                    if (!root.updatingValues) {
                        aspectRatioTimer.updateHeight = false
                        aspectRatioTimer.pendingValue = value
                        aspectRatioTimer.restart()
                    }
                }
                onTextEdited: (value) => {
                    if (!root.updatingValues) {
                        aspectRatioTimer.updateHeight = false
                        aspectRatioTimer.pendingValue = value
                        aspectRatioTimer.restart()
                    }
                }
            }
        }

        CheckBox {
            text: "Maintain aspect ratio"
            checked: true
            id: keepAspectRatio
            onCheckedChanged: {
                if (checked && !root.updatingValues) {
                    aspectRatioTimer.updateHeight = true
                    aspectRatioTimer.pendingValue = widthSpinBox.value
                    aspectRatioTimer.restart()
                }
            }
        }
    }

    // Preset section
    Column {
        Layout.fillWidth: true
        spacing: 16

        Label {
            text: "Presets"
            font.pixelSize: 13
            font.weight: Font.Medium
            color: "#333333"
        }

        Flow {
            width: parent.width
            spacing: 8

            Button {
                text: "HD (1280×720)"
                flat: true
                onClicked: {
                    root.updatingValues = true
                    widthSpinBox.value = 1280
                    heightSpinBox.value = 720
                    root.updatingValues = false
                }
            }

            Button {
                text: "Full HD (1920×1080)"
                flat: true
                onClicked: {
                    root.updatingValues = true
                    widthSpinBox.value = 1920
                    heightSpinBox.value = 1080
                    root.updatingValues = false
                }
            }

            Button {
                text: "4K (3840×2160)"
                flat: true
                onClicked: {
                    root.updatingValues = true
                    widthSpinBox.value = 3840
                    heightSpinBox.value = 2160
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
            flat: true
            enabled: !root.isProcessing
            onClicked: {
                root.updatingValues = true
                widthSpinBox.value = originalWidth
                heightSpinBox.value = originalHeight
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
            enabled: !root.isProcessing
            onClicked: {
                appController.resizeImage(
                    widthSpinBox.value,
                    heightSpinBox.value
                )
            }
        }
    }
}
