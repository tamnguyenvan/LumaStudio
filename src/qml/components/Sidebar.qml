import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

Rectangle {
    id: root
    Layout.preferredWidth: 240
    Layout.fillHeight: true
    color: "#F5F5F7"

    signal toolSelected(string toolId)

    Rectangle {
        id: header
        width: parent.width
        height: 48
        color: "transparent"

        Label {
            anchors {
                left: parent.left
                leftMargin: 16
                verticalCenter: parent.verticalCenter
            }
            text: "Tools"
            font.pixelSize: 13
            font.weight: Font.Medium
            color: "#666666"
        }
    }

    ListView {
        id: toolList
        anchors {
            top: header.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            leftMargin: 8
            rightMargin: 8
        }
        model: toolModel
        spacing: 2
        currentIndex: -1

        delegate: ItemDelegate {
            id: delegate
            width: parent.width
            height: 32
            highlighted: ListView.isCurrentItem

            background: Rectangle {
                color: delegate.highlighted ? Qt.rgba(0, 0, 0, 0.1) : (delegate.hovered ? Qt.rgba(0, 0, 0, 0.04) : "transparent")
                radius: 6

                Behavior on color {
                    ColorAnimation { duration: 100 }
                }
            }

            RowLayout {
                anchors {
                    fill: parent
                    leftMargin: 12
                    rightMargin: 12
                }
                spacing: 8

                Image {
                    source: toolIcon
                    sourceSize: Qt.size(16, 16)
                    opacity: delegate.highlighted ? 1 : 0.7
                }

                Label {
                    text: toolName
                    font.pixelSize: 13
                    // color: delegate.highlighted ? "#FFFFFF" : "#1C1C1E"
                    color: "#1C1C1E"
                    Layout.fillWidth: true
                }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    toolList.currentIndex = index
                    root.toolSelected(toolId)
                }
            }
        }
    }

    // Subtle shadow on the right edge
    Rectangle {
        width: 1
        height: parent.height
        anchors.right: parent.right
        color: "#E5E5E5"
    }
}
