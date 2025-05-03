import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components/ui"

Item {
    id: root
    property bool isProcessing: false
    property bool updatingValues: false
    property int originalWidth: 0
    property int originalHeight: 0
    property double defaultOpacity: 0.95
    property string defaultMaskColor: "#3b82f6"
    property string defaultShape: "Rectangle"
    property string maskColor: defaultMaskColor
    property string shape: defaultShape

    Connections {
        target: appController
        function onImageLoaded(width, height, size) {
            root.originalWidth = width
            root.originalHeight = height
        }

        function onProcessorChanged(processorName) {
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

    ColumnLayout {
        anchors.fill: parent
        spacing: 24

        GroupBox {
            title: "Blur Options"
            Layout.fillWidth: true

            ColumnLayout {
                anchors.fill: parent
                spacing: 10

                Label {
                    text: "Blur Opacity: " + opacitySlider.value.toFixed(1)
                    color: "#666666"
                }

                Slider {
                    id: opacitySlider
                    from: 0
                    to: 1.0
                    value: root.defaultOpacity
                    stepSize: 0.1
                    Layout.fillWidth: true
                    enabled: !root.isProcessing
                }

                Label {
                    text: "Mask Color"
                    color: "#666666"
                }

                CustomColorPicker {
                    Layout.fillWidth: true
                    enabled: !root.isProcessing
                    color: root.maskColor
                    onColorChanged: root.maskColor = selectedColor
                }

                Label {
                    text: "Mask Shape"
                    color: "#666666"
                }

                ComboBox {
                    id: shapeCombo
                    model: ["Rectangle", "Circle"]
                    currentIndex: 0
                    Layout.fillWidth: true
                    enabled: !root.isProcessing
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
                    opacitySlider.value = root.defaultOpacity
                    root.maskColor = root.defaultMaskColor
                    shapeCombo.currentIndex = root.defaultShape
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
                    appController.blurFaces(
                        opacitySlider.value,
                        root.maskColor,
                        shapeCombo.currentText.toLowerCase()
                    )
                }
            }
        }
    }
}
