from PySide6.QtCore import QAbstractListModel, Qt

class Tool:
    def __init__(self, tool_id, code_name, name, icon):
        self.tool_id = tool_id
        self.code_name = code_name
        self.name = name
        self.icon = icon

TOOLS = [
    Tool("Resize", "resize", "Resize", "qrc:/icons/resize.svg"),
    Tool("Crop", "crop", "Crop", "qrc:/icons/crop.svg"),
    Tool("Compress", "compress", "Compress", "qrc:/icons/compress.svg"),
    Tool("Convert", "convert", "Convert", "qrc:/icons/convert.svg"),
    Tool("Blur Face", "blur_face", "Blur Face", "qrc:/icons/blur_face.svg"),
    Tool("Remove Background", "remove_bg", "Remove Bg", "qrc:/icons/remove_bg.svg"),
    Tool("Upscale", "upscale", "Upscale", "qrc:/icons/upscale.svg")
]

class ToolModel(QAbstractListModel):
    IdRole = Qt.UserRole + 1
    CodeNameRole = Qt.UserRole + 2
    NameRole = Qt.UserRole + 3
    IconRole = Qt.UserRole + 4

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
        elif role == self.CodeNameRole:
            return tool.code_name
        elif role == self.NameRole:
            return tool.name
        elif role == self.IconRole:
            return tool.icon

    def roleNames(self):
        return {
            self.IdRole: b"toolId",
            self.CodeNameRole: b"toolCodeName",
            self.NameRole: b"toolName",
            self.IconRole: b"toolIcon"
        }
    
    @staticmethod
    def get_tools() -> list:
        return TOOLS
    
    @staticmethod
    def get_tool_by_id(tool_id: str) -> Tool:
        for tool in TOOLS:
            if tool.tool_id == tool_id:
                return tool
        return None