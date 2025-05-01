import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

SpinBox {
    id: control

    property bool updateOnType: true
    signal textEdited(int value)

    from: 1
    to: 10000
    value: 800
    editable: true
    Layout.fillWidth: true
    
    // Hide decimal separator
    locale: Qt.locale("C")
    wheelEnabled: true

    background: Rectangle {
        implicitWidth: 120
        implicitHeight: 24
        radius: 4
        color: control.enabled ? "#FFFFFF" : "#F5F5F7"
        border.color: control.activeFocus ? "#007AFF" : (control.hovered ? "#999999" : "#E5E5E5")
        border.width: control.activeFocus ? 2 : 1

        Behavior on border.color {
            ColorAnimation { duration: 100 }
        }
    }

    contentItem: TextInput {
        text: control.textFromValue(control.value, control.locale)
        font.pixelSize: 13
        color: control.enabled ? "#000000" : "#999999"
        selectionColor: "#007AFF"
        selectedTextColor: "#FFFFFF"
        horizontalAlignment: Qt.AlignLeft
        verticalAlignment: Qt.AlignVCenter
        readOnly: !control.editable
        validator: control.validator
        inputMethodHints: Qt.ImhFormattedNumbersOnly
        leftPadding: 8
        rightPadding: up.indicator ? up.indicator.width + 8 : 8

        onTextEdited: {
            if (!control.updateOnType) return
            const newValue = parseInt(text)
            if (!isNaN(newValue) && newValue >= control.from && newValue <= control.to) {
                control.textEdited(newValue)
            }
        }
    }

    up.indicator: Rectangle {
        x: parent.width - width
        height: parent.height
        implicitWidth: 24
        color: "transparent"

        Rectangle {
            anchors.centerIn: parent
            width: 1
            height: parent.height
            color: control.up.pressed ? "#007AFF" : "#E5E5E5"
        }

        Text {
            text: "+"
            font.pixelSize: 13
            color: control.up.pressed ? "#007AFF" : (control.enabled ? "#666666" : "#999999")
            anchors.centerIn: parent
        }

        MouseArea {
            anchors.fill: parent
            onPressed: control.up.pressed = true
            onReleased: control.up.pressed = false
            onCanceled: control.up.pressed = false
            onClicked: control.increase()
        }
    }

    down.indicator: Rectangle {
        x: parent.width - width * 2
        height: parent.height
        implicitWidth: 24
        color: "transparent"

        Text {
            text: "−"
            font.pixelSize: 13
            color: control.down.pressed ? "#007AFF" : (control.enabled ? "#666666" : "#999999")
            anchors.centerIn: parent
        }

        MouseArea {
            anchors.fill: parent
            onPressed: control.down.pressed = true
            onReleased: control.down.pressed = false
            onCanceled: control.down.pressed = false
            onClicked: control.decrease()
        }
    }
}