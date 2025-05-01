import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "components"

ApplicationWindow {
    id: window
    visible: true
    width: 1280
    height: 800
    title: "LumaStudio"
    color: "#F5F5F7"

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Sidebar {
            onToolSelected: (toolId) => {
                workspace.state = "edit"
                workspace.currentTool = toolId
                appController.setProcessor(toolId)
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#FFFFFF"
            
            Workspace {
                id: workspace
                anchors.fill: parent
            }
        }
    }
}
