import sys
import os
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from backend.app_controller import AppController
from backend.models.tool_model import ToolModel

def compile_resources():
    base_path = os.path.dirname(__file__)
    os.system(rf"pyside6-rcc -o {base_path}/resources_rc.py {base_path}/resources.qrc")

def main():
    compile_resources()
    import resources_rc

    app = QGuiApplication(sys.argv)
    engine = QQmlApplicationEngine()

    # Register models
    tool_model = ToolModel()
    engine.rootContext().setContextProperty("toolModel", tool_model)

    # Register image processor
    app_controller = AppController()
    engine.rootContext().setContextProperty("appController", app_controller)

    # Load QML
    qml_file = os.path.join(os.path.dirname(__file__), "qml/main.qml")
    engine.load(os.path.abspath(qml_file))

    if not engine.rootObjects():
        sys.exit(-1)

    sys.exit(app.exec())

if __name__ == "__main__":
    main()