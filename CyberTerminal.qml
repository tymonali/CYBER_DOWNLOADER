import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: terminalRoot

    // ОБЯЗАТЕЛЬНЫЕ ОБЪЯВЛЕНИЯ СВОЙСТВ:
    property alias logText: logArea.text
    property var cyberTheme
    property bool isMobile: false

    color: "#050608"
    border.color: cyberTheme ? cyberTheme.neonCyan : "#00ffcc"
    border.width: 1
    radius: 4
    clip: true

    // Шапка консоли
    Rectangle {
        id: consoleHeader
        width: parent.width
        height: 22
        color: cyberTheme ? cyberTheme.bgCard : "#121420"
        border.color: cyberTheme ? cyberTheme.neonCyan : "#00ffcc"
        border.width: 1

        Text {
            text: " SYSTEM TERMINAL LOG // REALTIME_MONITOR"
            anchors.verticalCenter: parent.verticalCenter
            color: cyberTheme ? cyberTheme.neonCyan : "#00ffcc"
            font.pointSize: 8
            font.family: cyberTheme ? cyberTheme.fontHack : "Courier New"
            font.bold: true
        }
    }

    // Прокручиваемая область с текстом
    Flickable {
        id: logFlickable
        anchors.top: consoleHeader.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 6
        contentWidth: logArea.width
        contentHeight: logArea.height
        clip: true

        onContentHeightChanged: {
            logFlickable.contentY = Math.max(0, logFlickable.contentHeight - logFlickable.height)
        }

        TextEdit {
            id: logArea
            width: logFlickable.width
            color: "#00ff66"
            readOnly: true
            selectByMouse: true
            wrapMode: TextEdit.WrapAnywhere
            font.pointSize: terminalRoot.isMobile ? 10 : 8
            font.family: cyberTheme ? cyberTheme.fontHack : "Courier New"
        }
    }

    // Меню по правой кнопке мыши
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton
        onClicked: (mouse) => {
            if (mouse.button === Qt.RightButton) {
                logContextMenu.popup()
            }
        }
    }

    Menu {
        id: logContextMenu

        MenuItem {
            text: "Копировать выделенное"
            enabled: logArea.selectedText.length > 0
            onTriggered: logArea.copy()
        }

        MenuItem {
            text: "Копировать весь лог"
            enabled: logArea.text.length > 0
            onTriggered: {
                logArea.selectAll()
                logArea.copy()
                logArea.deselect()
            }
        }
    }
}