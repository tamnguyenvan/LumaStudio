import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
 
Button {
    id: sequoiaButton
 
    // Button variant property
    property string variant: "default" // Possible values: "default", "primary", "secondary", "outline", "accent", "destructive"
 
    // Default properties
    property color primaryColor: getButtonColor()
    property color hoverColor: Qt.lighter(primaryColor, 1.1)
    property color pressedColor: Qt.darker(primaryColor, 1.05)
    property color disabledColor: "#e5e5e5"
    property color textColor: getTextColor()
    property color disabledTextColor: "#a1a1a1"
    property real cornerRadius: 4
    property int hozPadding: 16
    property int vertPadding: 4
    property bool isDefaultButton: variant === "default" || variant === "primary"
 
    // Function to determine the button color based on variant
    function getButtonColor() {
        switch(variant) {
            case "default":
            case "primary":
                return "#1083fd"; // Sequoia blue
            case "secondary":
                return "#e2e2e7"; // Light gray
            case "outline":
                return "transparent";
            case "accent":
                return "#34c759"; // Green
            case "destructive":
                return "#ff3b30"; // Red
            default:
                return "#1083fd"; // Default to blue
        }
    }
 
    // Function to determine the text color based on variant
    function getTextColor() {
        switch(variant) {
            case "default":
            case "primary":
            case "accent":
            case "destructive":
                return "white";
            case "secondary":
                return "#ffffff"; // Dark text on light buttons
            case "outline":
                return "#1083fd"; // Blue text for outline style
            default:
                return "white";
        }
    }
 
    // Button dimensions
    implicitWidth: contentItem.implicitWidth + (hozPadding * 2)
    implicitHeight: contentItem.implicitHeight + (vertPadding * 2)
 
    // Padding
    topPadding: vertPadding
    bottomPadding: vertPadding
    leftPadding: hozPadding
    rightPadding: hozPadding
 
    // Focus policy
    focusPolicy: Qt.StrongFocus
 
    // Content item (text)
    contentItem: Text {
        text: sequoiaButton.text
        font.pixelSize: 13
        font.family: "SF Pro"  // macOS system font
        font.weight: Font.Medium
        color: sequoiaButton.enabled ? textColor : disabledTextColor
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
 
        // Apply a slight drop shadow for the text on default (blue) buttons for better contrast
        layer.enabled: sequoiaButton.isDefaultButton
        layer.effect: DropShadow {
            verticalOffset: 1
            radius: 1
            samples: 3
            color: "#40000000"
        }
    }
 
    // Background
    background: Rectangle {
        id: buttonBackground
        radius: cornerRadius
 
        gradient: Gradient {
            GradientStop { 
                position: 0.0
                color: {
                    if (!sequoiaButton.enabled) {
                        return disabledColor;
                    } else if (sequoiaButton.pressed) {
                        return pressedColor;
                    } else if (sequoiaButton.hovered) {
                        return hoverColor;
                    } else {
                        return primaryColor;
                    }
                }
            }
            GradientStop { 
                position: 1.0
                color: {
                    if (!sequoiaButton.enabled) {
                        return Qt.darker(disabledColor, 1.05);
                    } else if (sequoiaButton.pressed) {
                        return Qt.darker(pressedColor, 1.05);
                    } else if (sequoiaButton.hovered) {
                        return Qt.darker(hoverColor, 1.05);
                    } else {
                        return Qt.darker(primaryColor, 1.05);
                    }
                }
            }
        }
 
        // Border for non-default or outline buttons
        border.width: (!isDefaultButton || variant === "outline") ? 1 : 0
        border.color: {
            if (!sequoiaButton.enabled) {
                return "#d1d1d1";
            } else if (variant === "outline") {
                return sequoiaButton.hovered ? Qt.darker("#0056d6", 1.1) : "#0056d6";
            } else if (!isDefaultButton) {
                return sequoiaButton.hovered ? Qt.darker(primaryColor, 1.1) : Qt.darker(primaryColor, 1.05);
            } else {
                return "transparent";
            }
        }
 
        // Drop shadow effect
        layer.enabled: sequoiaButton.enabled
        layer.effect: DropShadow {
            transparentBorder: true
            horizontalOffset: 0
            verticalOffset: isDefaultButton ? 1 : 0.5
            radius: isDefaultButton ? 3 : 1.5
            samples: 5
            color: isDefaultButton ? "#40000000" : "#20000000"
        }
    }
 
    // State transitions for smooth animations
    transitions: Transition {
        ColorAnimation { 
            properties: "color";
            easing.type: Easing.OutQuad;
            duration: 150
        }
    }
 
    // Key handling - space/return activates the button
    Keys.onPressed: function(event) {
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Space) {
            sequoiaButton.clicked();
            event.accepted = true;
        }
    }
 
    // Accessibility
    Accessible.role: Accessible.Button
    Accessible.name: text
    Accessible.onPressAction: clicked()
 
    // Tooltip
    ToolTip.visible: hovered && ToolTip.text
    ToolTip.delay: 1000
}