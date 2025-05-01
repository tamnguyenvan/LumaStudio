import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

Column {
    id: root
    spacing: 24

    property string icon: ""
    property string title: ""
    property string description: ""
    property string buttonText: ""
    signal buttonClicked()

    Rectangle {
        width: 80
        height: 80
        radius: 40
        color: "#F5F5F7"
        border.color: "#E5E5E5"
        border.width: 1
        anchors.horizontalCenter: parent.horizontalCenter

        Image {
            anchors.centerIn: parent
            source: root.icon
            sourceSize: Qt.size(32, 32)
            opacity: 0.6
        }
    }

    Column {
        spacing: 8
        anchors.horizontalCenter: parent.horizontalCenter

        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.title
            font.pixelSize: 20
            font.weight: Font.Medium
            color: "#1C1C1E"
        }

        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.description
            font.pixelSize: 14
            color: "#666666"
        }
    }

    Button {
        anchors.horizontalCenter: parent.horizontalCenter
        text: root.buttonText
        icon.source: "qrc:/icons/upload.svg"
        icon.width: 16
        icon.height: 16
        padding: 12
        onClicked: root.buttonClicked()
        
        background: Rectangle {
            implicitWidth: 120
            implicitHeight: 36
            radius: 8
            color: parent.hovered ? "#F5F5F7" : "transparent"
            border.color: "#E5E5E5"
            border.width: 1
            
            Behavior on color {
                ColorAnimation { duration: 100 }
            }
        }
    }
}
