import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

Item {
    id: root
    height: 30
    
    property string color: "#000000"
    property alias selectedColor: colorDialog.selectedColor
    property bool enabled: true
    
    RowLayout {
        anchors.fill: parent
        spacing: 8
        
        // Color preview square
        Rectangle {
            id: colorPreview
            width: root.height
            height: root.height
            color: root.color
            border.color: "#CCCCCC"
            border.width: 1
            radius: 4
            
            MouseArea {
                anchors.fill: parent
                enabled: root.enabled
                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                onClicked: colorDialog.open()
            }
        }
        
        // Color text field
        TextField {
            id: colorField
            Layout.fillWidth: true
            text: root.color
            enabled: root.enabled
            validator: RegularExpressionValidator {
                regularExpression: /^#[0-9A-Fa-f]{6}$/
            }
            onTextChanged: {
                if (text.match(/^#[0-9A-Fa-f]{6}$/)) {
                    root.color = text
                    root.colorChanged()
                }
            }
            
            // Auto-add # if missing
            onEditingFinished: {
                if (text.match(/^[0-9A-Fa-f]{6}$/)) {
                    text = "#" + text
                }
            }
        }
    }
    
    ColorDialog {
        id: colorDialog
        title: "Choose a color"
        onAccepted: {
            root.color = colorDialog.selectedColor
            root.colorChanged()
        }
    }
}
