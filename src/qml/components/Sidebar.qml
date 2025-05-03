import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import QtQuick.Effects

Rectangle {
    id: root
    Layout.preferredWidth: 240
    Layout.fillHeight: true
    
    // Properties for customization
    property string accentColor: "#0066CC"
    property string backgroundColor: "#F5F5F7"
    property string textColor: "#1C1C1E"
    property string secondaryTextColor: "#666666"
    
    // Signals
    signal toolSelected(var tool)
    
    // Background with subtle gradient
    gradient: Gradient {
        GradientStop { position: 0.0; color: backgroundColor }
        GradientStop { position: 1.0; color: Qt.darker(backgroundColor, 1.03) }
    }

    // Enhanced header
    Rectangle {
        id: header
        width: parent.width
        height: 54
        color: "transparent"

        RowLayout {
            anchors {
                fill: parent
                leftMargin: 16
                rightMargin: 16
            }
            spacing: 8
            
            Label {
                text: "Tools"
                font.pixelSize: 14
                font.weight: Font.Medium
                color: secondaryTextColor
                Layout.fillWidth: true
            }
            
            // Optional button for tool settings
            Rectangle {
                width: 28
                height: 28
                radius: 4
                color: settingsButton.hovered ? Qt.rgba(0, 0, 0, 0.05) : "transparent"
                
                Image {
                    id: settingsButton
                    anchors.centerIn: parent
                    source: "qrc:/icons/settings.svg" // Add your own icon
                    sourceSize: Qt.size(16, 16)
                    opacity: 0.7
                    
                    property bool hovered: settingsArea.containsMouse
                    
                    MouseArea {
                        id: settingsArea
                        anchors.fill: parent
                        anchors.margins: -6
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                    }
                }
            }
        }
    }
    
    // Search field
    Rectangle {
        id: searchBox
        anchors {
            top: header.bottom
            left: parent.left
            right: parent.right
            margins: 12
        }
        height: 36
        color: Qt.lighter(backgroundColor, 1.02)
        radius: 6
        border.width: 1
        border.color: "#E0E0E0"
        
        RowLayout {
            anchors {
                fill: parent
                margins: 8
            }
            spacing: 8
            
            Image {
                source: "qrc:/icons/search.svg" // Add your own icon
                sourceSize: Qt.size(16, 16)
                opacity: 0.6
            }
            
            TextField {
                id: searchField
                Layout.fillWidth: true
                placeholderText: "Find tool..."
                background: null
                font.pixelSize: 13
                selectByMouse: true
                color: textColor
                
                // Optional: Hook up to model filtering
                onTextChanged: {
                    // Filter the toolModel based on text
                    // toolModel.filterText = text
                }
            }
            
            Image {
                source: "qrc:/icons/clear.svg" // Add your own icon
                sourceSize: Qt.size(16, 16)
                opacity: searchField.text.length > 0 ? 0.6 : 0
                visible: opacity > 0
                
                Behavior on opacity { NumberAnimation { duration: 100 } }
                
                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -4
                    onClicked: searchField.text = ""
                    cursorShape: Qt.PointingHandCursor
                }
            }
        }
    }

    // Enhanced tool list
    ListView {
        id: toolList
        anchors {
            top: searchBox.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            topMargin: 12
            leftMargin: 8
            rightMargin: 8
        }
        model: toolModel
        spacing: 2
        currentIndex: -1
        clip: true
        
        delegate: ItemDelegate {
            id: delegate
            width: toolList.width
            height: 40
            highlighted: ListView.isCurrentItem

            background: Rectangle {
                color: delegate.highlighted ? 
                       Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.15) : 
                       (delegate.hovered ? Qt.rgba(0, 0, 0, 0.04) : "transparent")
                radius: 8
            }

            RowLayout {
                anchors {
                    fill: parent
                    leftMargin: 12
                    rightMargin: 12
                }
                spacing: 12
                
                // Tool icon with background
                Item {
                    Layout.preferredWidth: 28
                    Layout.preferredHeight: 28
                    
                    Rectangle {
                        anchors.fill: parent
                        color: delegate.highlighted ? 
                               Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.2) : 
                               Qt.rgba(0, 0, 0, 0.03)
                        radius: 6
                    }
                    
                    Image {
                        anchors.centerIn: parent
                        source: toolIcon
                        sourceSize: Qt.size(18, 18)
                        opacity: delegate.highlighted ? 1 : 0.75
                    }
                }

                Label {
                    text: toolName
                    font.pixelSize: 13
                    font.weight: delegate.highlighted ? Font.Medium : Font.Normal
                    color: textColor
                    Layout.fillWidth: true
                }
                
                // Optional shortcut key indicator (if available in your model)
                Label {
                    text: model.shortcut || ""
                    font.pixelSize: 11
                    font.family: "Menlo"
                    color: secondaryTextColor
                    padding: 4
                    visible: model.shortcut !== undefined && model.shortcut !== ""
                    background: Rectangle {
                        color: "#EEEEEE"
                        radius: 3
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    toolList.currentIndex = index
                    var tool = {
                        toolId: model.toolId,
                        toolCodeName: model.toolCodeName,
                        toolName: model.toolName,
                        toolIcon: model.toolIcon
                    }
                    root.toolSelected(tool)
                }
            }
        }
    }

    // Subtle shadow on right edge
    Item {
        width: 16
        height: parent.height
        anchors.right: parent.right
        
        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowBlur: 0.4
            shadowHorizontalOffset: -1
            shadowVerticalOffset: 0
            shadowColor: "#20000000"
        }
    }
}