import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs // Необходим для работы с FolderDialog

Window {
    id: window
    visible: true
    title: "CYBER_DOWNLOADER v1.0"
    color: cyberTheme.bgDeep

    // 1. Определение платформы
    readonly property bool isMobile: Qt.platform.os === "android" || Qt.platform.os === "ios"

    // 2. Адаптивные размеры окна
    visibility: isMobile ? Window.FullScreen : Window.AutomaticVisibility
    width: isMobile ? Screen.width : 450
    height: isMobile ? Screen.height : 750
    minimumWidth: 360
    minimumHeight: 600

    // ==========================================
    // ГЛОБАЛЬНАЯ КИБЕРПАНК ПАЛИТРА (Управление стилем)
    // ==========================================
    QtObject {
        id: cyberTheme
        readonly property color bgDeep: "#0a0b10"      // Глубокий черный
        readonly property color bgCard: "#121420"      // Элементы ввода
        readonly property color neonCyan: "#00ffcc"    // Основной неон (Циан)
        readonly property color neonPink: "#ff007f"    // Акцентный неон (Розовый)
        readonly property color textMain: "#ffffff"    // Главный текст
        readonly property color textDark: "#4a4d5a"    // Подсказки / Плейсхолдеры
        readonly property string fontHack: "Courier New"
    }

    // Переменная-флаг для заставки
    property bool isSplashing: true

    // ==========================================
    // ЭКРАН 1: ГЛАВНЫЙ ИНТЕРФЕЙС (Базовый слой)
    // ==========================================
    Item {
        id: mainContent
        anchors.fill: parent

        // Сетка на заднем фоне
        Grid {
            anchors.fill: parent
            opacity: 0.04
            rows: 20; columns: 20
            Repeater {
                model: 400
                Rectangle {
                    width: 40; height: 40;
                    color: "transparent";
                    border.color: cyberTheme.neonCyan;
                    border.width: 1
                }
            }
        }

        Column {
            id: contentColumn
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: window.isMobile ? 30 : 20
            spacing: 25

            // Хакерский заголовок
            Text {
                text: "CYBER_DOWNLOADER v1.0"
                font.pointSize: window.isMobile ? 22 : 16
                font.bold: true
                font.family: cyberTheme.fontHack
                color: cyberTheme.neonCyan
                anchors.horizontalCenter: parent.horizontalCenter
            }

            // Поле ввода ссылки (Кастомизация QtQuick.Controls)
            TextField {
                id: urlInput
                width: parent.width
                placeholderText: "> Вставьте ссылку на видео..."
                color: cyberTheme.textMain
                placeholderTextColor: cyberTheme.textDark
                font.pointSize: window.isMobile ? 14 : 12
                font.family: cyberTheme.fontHack
                selectByMouse: true

                background: Rectangle {
                    implicitHeight: window.isMobile ? 60 : 45
                    color: cyberTheme.bgCard
                    radius: 4
                    border.color: urlInput.activeFocus ? cyberTheme.neonPink : cyberTheme.neonCyan
                    border.width: urlInput.activeFocus ? 2 : 1
                }
            }

            // ==========================================
            // БЛОК ВЫБОРА ПУТИ СОХРАНЕНИЯ
            // ==========================================

            // Объявляем невидимый диалог выбора папки
            FolderDialog {
                id: folderDialog
                title: "Выберите директорию для сохранения видео"
                // По умолчанию открываем домашнюю папку пользователя
                currentFolder: StandardPaths.writableLocation(StandardPaths.DownloadLocation)

                onAccepted: {
                    // Преобразуем URL папки в удобный локальный путь text
                    var path = folderDialog.selectedFolder.toString();
                    // Очищаем префикс "file:///" для Windows/Android, если он есть
                    if (path.startsWith("file:///")) {
                        path = path.substring(8);
                    }
                    pathText.text = path;
                }
            }

            // Визуальный контейнер для поля пути и кнопки "Обзор"
            Row {
                width: parent.width
                spacing: 10

                // Информационное поле с путем
                TextField {
                    id: pathText
                    // Кнопка займет фиксированное место, поле заберет всё оставшееся пространство
                    width: parent.width - browseButton.width - parent.spacing
                    text: StandardPaths.writableLocation(StandardPaths.DownloadLocation).toString().substring(8) // Путь по умолчанию
                    readOnly: true // Защищаем от случайного ручного ввода
                    color: cyberTheme.textMain
                    font.pointSize: window.isMobile ? 12 : 11
                    font.family: cyberTheme.fontHack

                    background: Rectangle {
                        implicitHeight: window.isMobile ? 55 : 40
                        color: cyberTheme.bgCard
                        radius: 4
                        border.color: cyberTheme.neonCyan
                        opacity: 0.8 // Чуть приглушаем, так как поле только для чтения
                    }
                }

                // Кнопка вызова диалога [ ОБЗОР ]
                Button {
                    id: browseButton
                    text: "ОБЗОР"

                    contentItem: Text {
                        text: browseButton.text
                        font.pointSize: window.isMobile ? 13 : 11
                        font.bold: true
                        font.family: cyberTheme.fontHack
                        color: browseButton.pressed ? cyberTheme.bgDeep : cyberTheme.neonCyan
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    background: Rectangle {
                        implicitWidth: window.isMobile ? 100 : 80
                        implicitHeight: window.isMobile ? 55 : 40
                        color: browseButton.pressed ? cyberTheme.neonCyan : "transparent"
                        radius: 4
                        border.color: cyberTheme.neonCyan
                        border.width: 1
                    }

                    onClicked: folderDialog.open() // Открываем проводник/галерею
                }
            }

            // Кнопка скачивания
            Button {
                id: downloadButton
                width: parent.width
                text: "ЗАПУСТИТЬ ЗАХВАТ"

                contentItem: Text {
                    text: downloadButton.text
                    font.pointSize: window.isMobile ? 15 : 12
                    font.bold: true
                    font.family: cyberTheme.fontHack
                    color: downloadButton.pressed ? cyberTheme.bgDeep : cyberTheme.textMain
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    implicitHeight: window.isMobile ? 65 : 50
                    color: downloadButton.pressed ? cyberTheme.neonPink : "transparent"
                    radius: 4
                    border.color: cyberTheme.neonPink
                    border.width: 2
                }

                onClicked: {
                    console.log("Квантовый мост запущен для ссылки:", urlInput.text)
                }
            }

            // Индикатор выполнения (Хакерская шкала прогресса)
            ProgressBar {
                id: downloadProgress
                width: parent.width
                value: 0.65 // 65% для теста (потом свяжем с C++)

                // Задаем явную высоту для всего компонента
                implicitHeight: window.isMobile ? 12 : 8

                background: Rectangle {
                    anchors.fill: parent
                    color: cyberTheme.bgCard
                    radius: 2
                }

                contentItem: Item {
                    anchors.fill: parent

                    Rectangle {
                        // Растягиваем полосу в зависимости от прогресса (от 0.0 до 1.0)
                        width: downloadProgress.visualPosition * parent.width
                        height: parent.height
                        radius: 2
                        color: cyberTheme.neonCyan // Прогресс горит неоновым цианом
                    }
                }
            }
        }
    }

    // ==========================================
    // ЭКРАН 2: ЗАСТАВКА (Верхний слой)
    // ==========================================
    Item {
        id: splashScreen
        anchors.fill: parent
        opacity: window.isSplashing ? 1.0 : 0.0
        enabled: window.isSplashing

        Behavior on opacity {
            NumberAnimation { duration: 500; easing.type: Easing.InOutQuad }
        }

        Image {
            anchors.fill: parent
            source: "images/Natalie.jpg"
            fillMode: Image.PreserveAspectCrop
        }
    }

    // Таймер заставки
    Timer {
        interval: 2500
        running: true
        repeat: false
        onTriggered: window.isSplashing = false
    }
}