import QtCore // <-- ДОБАВИТЬ ЭТУ СТРОКУ
import CyberCore 1.0
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
    DownloadController {
        id: downloader
    }
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

            // ==========================================
            // ОПЦИИ ЗАГРУЗКИ (ТОЛЬКО АУДИО)
            // ==========================================
            CheckBox {
                id: audioOnlyCheck
                text: "СКАЧАТЬ ТОЛЬКО ЗВУК (MP3)"
                checked: false

                // Расширяем на всю ширину колонки, чтобы текст не прижимался
                width: parent.width
                implicitHeight: window.isMobile ? 50 : 35

                // Обнуляем лишние стандартные отступы самого компонента
                leftPadding: 0
                spacing: 12 // Фиксированное расстояние между квадратиком и текстом

                // Кастомизация текста под наш киберпанк-стиль[cite: 5]
                contentItem: Text {
                    text: audioOnlyCheck.text
                    font.pointSize: window.isMobile ? 13 : 11
                    font.family: cyberTheme.fontHack
                    color: audioOnlyCheck.checked ? cyberTheme.neonPink : cyberTheme.textMain
                    verticalAlignment: Text.AlignVCenter

                    // Текст автоматически встанет ПРАВЕЕ индикатора на величину spacing
                    leftPadding: audioOnlyCheck.indicator.width + audioOnlyCheck.spacing
                }

                // Кастомизация квадратика чекбокса[cite: 5]
                indicator: Rectangle {
                    implicitWidth: window.isMobile ? 28 : 20
                    implicitHeight: window.isMobile ? 28 : 20

                    // Прижимаем ровно к левому краю и центрируем по вертикали
                    x: 0
                    y: parent.height / 2 - height / 2

                    radius: 3
                    color: cyberTheme.bgCard
                    border.color: audioOnlyCheck.checked ? cyberTheme.neonPink : cyberTheme.neonCyan
                    border.width: 2

                    // Неоновая точка внутри при активации[cite: 5]
                    Rectangle {
                        width: parent.width - 8
                        height: parent.height - 8
                        anchors.centerIn: parent
                        radius: 2
                        color: cyberTheme.neonPink
                        visible: audioOnlyCheck.checked
                    }
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
                    // Передаем третьим аргументом состояние нашего чекбокса[cite: 5]
                    downloader.startDownload(urlInput.text, pathText.text, audioOnlyCheck.checked) //[cite: 5]
                }
            }

            // Статусная строка процесса (Показывает, что происходит под капотом)
            Text {
                id: statusText
                // Теперь текст летит напрямую из C++ свойства status
                text: downloader.status
                color: cyberTheme.neonCyan
                font.pointSize: window.isMobile ? 12 : 10
                font.family: cyberTheme.fontHack
                anchors.left: parent.left
                bottomPadding: -5
            }

            // Шкала прогресса
            ProgressBar {
                id: downloadProgress
                width: parent.width
                // Теперь значение (от 0.0 до 1.0) берется из C++ свойства progress
                value: downloader.progress

                implicitHeight: window.isMobile ? 12 : 8

                background: Rectangle {
                    anchors.fill: parent
                    color: cyberTheme.bgCard
                    radius: 2
                }

                contentItem: Item {
                    anchors.fill: parent
                    Rectangle {
                        width: downloadProgress.visualPosition * parent.width
                        height: parent.height
                        radius: 2
                        color: cyberTheme.neonCyan
                    }
                }
            }
            // ==========================================
            // КИБЕРПАНК ТЕРМИНАЛ ЛОГОВ (Заполняет всё свободное место)
            // ==========================================
            Rectangle {
                width: parent.width
                // Автоматически растягиваем терминал до самого низа окна
                height: window.height - y - (window.isMobile ? 30 : 20)
                color: "#050608"
                border.color: cyberTheme.neonCyan
                border.width: 1
                radius: 4
                clip: true // Обрезаем текст за пределами рамки

                // Шапка консоли
                Rectangle {
                    id: consoleHeader
                    width: parent.width
                    height: 22
                    color: cyberTheme.bgCard
                    border.color: cyberTheme.neonCyan
                    border.width: 1

                    Text {
                        text: " SYSTEM TERMINAL LOG // REALTIME_MONITOR"
                        anchors.verticalCenter: parent.verticalCenter
                        color: cyberTheme.neonCyan
                        font.pointSize: 8
                        font.family: cyberTheme.fontHack
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

                    // Автоскролл вниз при поступлении новых строчек
                    onContentHeightChanged: {
                        logFlickable.contentY = Math.max(0, logFlickable.contentHeight - logFlickable.height)
                    }

                    TextEdit {
                        id: logArea
                        width: logFlickable.width
                        text: downloader.logOutput
                        color: "#00ff66" // Киберпанк матрично-зеленый цвет логов
                        readOnly: true
                        selectByMouse: true
                        wrapMode: TextEdit.WrapAnywhere
                        font.pointSize: window.isMobile ? 10 : 8
                        font.family: cyberTheme.fontHack
                    }
                }

                // Область перехвата клика правой кнопки мыши
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.RightButton
                    onClicked: (mouse) => {
                        if (mouse.button === Qt.RightButton) {
                            logContextMenu.popup()
                        }
                    }
                }

                // Контекстное меню лога
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
        }
    }
    // ==========================================
    // ЭКРАН 2: ЗАСТАВКА (Верхний слой)
    // ==========================================
    //Item {
    //    id: splashScreen
    //    anchors.fill: parent
    //    opacity: window.isSplashing ? 1.0 : 0.0
    //    enabled: window.isSplashing

    //    Behavior on opacity {
    //        NumberAnimation { duration: 500; easing.type: Easing.InOutQuad }
    //    }

    //    Image {
    //        anchors.fill: parent
    //        source: "images/Natalie.jpg"
    //        fillMode: Image.PreserveAspectCrop
    //    }
    //}

    //// Таймер заставки
    //Timer {
    //    interval: 2500
    //    running: true
    //    repeat: false
    //    onTriggered: window.isSplashing = false
    //}

    // ==========================================
    // ЭКРАН 2: КИБЕРПАНК ЗАСТАВКА (Верхний слой)
    // ==========================================
    Rectangle {
        id: splashScreen
        anchors.fill: parent
        color: cyberTheme.bgDeep
        opacity: window.isSplashing ? 1.0 : 0.0
        enabled: window.isSplashing
        z: 100

        Behavior on opacity {
            NumberAnimation { duration: 600; easing.type: Easing.InOutQuad }
        }

        // Две строки по центру
        // Две строки по центру
        Column {
            anchors.centerIn: parent
            width: parent.width * 0.95 // Ограничиваем ширину 95% от окна, чтобы точно не вылезало
            spacing: window.isMobile ? 15 : 10

            // --- СТРОКА 1: CYBER ---
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: window.isMobile ? 8 : 5

                Repeater {
                    model: "CYBER".split("")

                    CyberLetterBox {
                        targetChar: modelData
                        letterIndex: index
                        isSplashing: window.isSplashing
                        cyberThemeRef: cyberTheme
                        isMobileRef: window.isMobile
                    }
                }
            }

            // --- СТРОКА 2: DOWNLOADER ---
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: window.isMobile ? 6 : 4 // Чуть уплотняем межбуквенный интервал для длинного слова

                Repeater {
                    model: "DOWNLOADER".split("")

                    CyberLetterBox {
                        targetChar: modelData
                        letterIndex: index + 5
                        isSplashing: window.isSplashing
                        cyberThemeRef: cyberTheme
                        isMobileRef: window.isMobile
                    }
                }
            }
        }
    }

    // Вспомогательный компонент плитки с анимацией цвета и прокрутки
        component CyberLetterBox: Rectangle {
        id: box
        property string targetChar: ""
        property int letterIndex: 0
        property bool isSplashing: false
        property var cyberThemeRef
        property bool isMobileRef: false

        // Флаги состояний для управления цветом
        property bool isFixed: false      // Буква зафиксировалась
        property bool isPassed: false     // Волна пошла дальше (следующая буква начала подгружаться)

        // Размеры плитки
        width: isMobileRef ? 48 : 38
        height: isMobileRef ? 60 : 48

        // --- ЦВЕТ ФОНА И РАМОК ПЛИТКИ ---
        // Если зафиксировалась и волна ушла дальше -> Циан. Если сейчас крутится -> Ядовито-желтый (#ffff00).
        color: cyberThemeRef.bgCard
        border.color: isPassed ? cyberThemeRef.neonCyan : (opacity > 0 ? "#ffff00" : "transparent")
        border.width: isPassed ? 1 : 2
        radius: 4

        opacity: 0.0
        scale: 0.3

        property string currentChar: "?"
        readonly property string randomChars: "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ#$%"

        // Анимация вылета и переключения состояний
        SequentialAnimation {
            running: box.isSplashing
            PauseAnimation { duration: box.letterIndex * 120 } // Время вылета этой буквы

            ParallelAnimation {
                NumberAnimation { target: box; property: "opacity"; to: 1.0; duration: 150 }
                NumberAnimation { target: box; property: "scale"; to: 1.0; duration: 200; easing.type: Easing.OutBack }
                ScriptAction { script: hackTimer.start() }
            }

            // Как только эта буква закончила появление, через 100мс передаем эстафету (она становится циановой)
            PauseAnimation { duration: 100 }
            ScriptAction { script: box.isPassed = true }
        }

        // Таймер "хакерской" прокрутки букв
        Timer {
            id: hackTimer
            interval: 35 // Скорость смены символов (мс)
            repeat: true
            triggeredOnStart: true

            property int ticks: 0
            readonly property int maxTicks: 25 // <-- Количество кадров прокрутки

            onTriggered: {
                ticks++
                if (ticks >= maxTicks) {
                    hackTimer.stop()
                    box.currentChar = box.targetChar
                    box.isFixed = true
                } else {
                    var randomIndex = Math.floor(Math.random() * box.randomChars.length)
                    box.currentChar = box.randomChars.charAt(randomIndex)
                }
            }
        }

        // --- ЦВЕТ БУКВЫ ВНУТРИ ---
        // Когда волна ушла (isPassed) -> Желтый (#ffff00). Пока крутится/появляется -> Ядовито-розовый.
        Text {
            anchors.centerIn: parent
            text: box.currentChar
            color: box.isPassed ? "#ffff00" : cyberThemeRef.neonPink
            font.family: cyberThemeRef.fontHack
            font.bold: true
            font.pointSize: box.isMobileRef ? 22 : 16
        }
    }

    // Таймер закрытия заставки (увеличен, чтобы успеть насладиться эффектом)
    Timer {
        interval: 5000
        running: true
        repeat: false
        onTriggered: window.isSplashing = false
    }
}