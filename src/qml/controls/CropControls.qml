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

    Component.onCompleted: {
        if (originalWidth > 0) {
            widthSpinBox.value = originalWidth
            heightSpinBox.value = originalHeight
        }
    }

    Connections {
        target: appController
        function onImageLoaded(width, height, size) {
            console.log("Crop tools Image loaded:", width, "x", height)
            root.originalWidth = width
            root.originalHeight = height
            
            root.updatingValues = true
            widthSpinBox.value = width
            heightSpinBox.value = height
            root.updatingValues = false
        }

        function onProcessorChanged(processorName) {
            console.log("Processor changed:", processorName)
            var loadedImageInfo = appController.loadedImageInfo
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
            text: "Crop Area"
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
                text: "X Position"
                Layout.alignment: Qt.AlignRight
                color: "#666666"
            }

            CustomSpinBox {
                id: xSpinBox
                from: 0
                to: root.originalWidth
                value: 0
                Layout.fillWidth: true
            }

            Label {
                text: "Y Position"
                Layout.alignment: Qt.AlignRight
                color: "#666666"
            }

            CustomSpinBox {
                id: ySpinBox
                from: 0
                to: root.originalHeight
                value: 0
                Layout.fillWidth: true
            }

            Label {
                text: "Width"
                Layout.alignment: Qt.AlignRight
                color: "#666666"
            }

            CustomSpinBox {
                id: widthSpinBox
                from: 1
                to: root.originalWidth - xSpinBox.value
                value: root.originalWidth - xSpinBox.value
                Layout.fillWidth: true
                onValueModified: {
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
                to: root.originalHeight - ySpinBox.value
                value: root.originalHeight - ySpinBox.value
                Layout.fillWidth: true
                onValueModified: {
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
            checked: false
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

    // Aspect ratio timer
    Timer {
        id: aspectRatioTimer
        interval: 100
        property bool updateHeight: true
        property real pendingValue: 0
        property real aspectRatio: root.originalWidth / root.originalHeight

        onTriggered: {
            if (!keepAspectRatio.checked) return

            root.updatingValues = true
            if (updateHeight) {
                heightSpinBox.value = Math.round(pendingValue / aspectRatio)
            } else {
                widthSpinBox.value = Math.round(pendingValue * aspectRatio)
            }
            root.updatingValues = false
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
                text: "Square (1:1)"
                flat: true
                onClicked: {
                    root.updatingValues = true
                    let size = Math.min(root.originalWidth, root.originalHeight)
                    widthSpinBox.value = size
                    heightSpinBox.value = size
                    root.updatingValues = false
                }
            }

            Button {
                text: "16:9"
                flat: true
                onClicked: {
                    root.updatingValues = true
                    if (root.originalWidth > root.originalHeight) {
                        heightSpinBox.value = root.originalHeight
                        widthSpinBox.value = Math.round(root.originalHeight * (16/9))
                    } else {
                        widthSpinBox.value = root.originalWidth
                        heightSpinBox.value = Math.round(root.originalWidth * (9/16))
                    }
                    root.updatingValues = false
                }
            }

            Button {
                text: "4:3"
                flat: true
                onClicked: {
                    root.updatingValues = true
                    if (root.originalWidth > root.originalHeight) {
                        heightSpinBox.value = root.originalHeight
                        widthSpinBox.value = Math.round(root.originalHeight * (4/3))
                    } else {
                        widthSpinBox.value = root.originalWidth
                        heightSpinBox.value = Math.round(root.originalWidth * (3/4))
                    }
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
                appController.cropImage(
                    xSpinBox.value,
                    ySpinBox.value,
                    widthSpinBox.value,
                    heightSpinBox.value
                )
            }
        }
    }
}
