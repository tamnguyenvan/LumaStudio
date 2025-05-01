from PySide6.QtCore import QAbstractListModel, Qt

class Tool:
    def __init__(self, tool_id, name, icon):
        self.tool_id = tool_id
        self.name = name
        self.icon = icon

TOOLS = [
    Tool("Resize", "Resize", "qrc:/icons/resize.svg"),
    Tool("Crop", "Crop", "qrc:/icons/crop.svg"),
]

class ToolModel(QAbstractListModel):
    IdRole = Qt.UserRole + 1
    NameRole = Qt.UserRole + 2
    IconRole = Qt.UserRole + 3

    def __init__(self):
        super().__init__()
        self._tools = TOOLS

    def rowCount(self, parent=None):
        return len(self._tools)

    def data(self, index, role=Qt.DisplayRole):
        if not index.isValid():
            return None

        tool = self._tools[index.row()]
        if role == self.IdRole:
            return tool.tool_id
        elif role == self.NameRole:
            return tool.name
        elif role == self.IconRole:
            return tool.icon

    def roleNames(self):
        return {
            self.IdRole: b"toolId",
            self.NameRole: b"toolName",
            self.IconRole: b"toolIcon"
        }