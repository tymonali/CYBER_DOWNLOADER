import QtQuick
import QtQuick.Controls

Window {
    id: window
    //width: 400
    //height: 600
    visible: true
    title: "YouTube Downloader"
    color: "#ffffff" // Делаем базовый фон белым, чтобы не было серых вспышек

    // 1. Опеределяем платформу
    readonly property bool isMobile: Qt.platform.os === "android" || Qt.platform.os === "ios"

    // 2. Умное управление размером окна
    // Если это мобилка — раскрываем на весь экран. Если Windows — задаем стартовый удобный размер.
    visibility: isMobile ? Window.FullScreen : Window.AutomaticVisibility

    // Задаем размеры по умолчанию для десктопа (на мобильных они просто проигнорируются)
    width: isMobile ? Screen.width : 450
    height: isMobile ? Screen.height : 750

    // Ограничиваем минимальный размер на Windows, чтобы пользователь не свернул приложение в микро-точку
    minimumWidth: 360
    minimumHeight: 600

    // ==========================================
    // 1. ГЛАВНЫЙ ИНТЕРФЕЙС (Базовый слой)
    // ==========================================
    Item {
        id: mainContent
        anchors.fill: parent

        Rectangle {
            anchors.fill: parent
            color: "#f8f9fa" // Красивый мягкий белый цвет для будущего загрузчика

            Text {
                anchors.centerIn: parent
                text: "Здесь будет загрузчик видео"
                font.pointSize: 16
                color: "#333333"
            }
        }
    }

    // ==========================================
    // 2. ЭКРАН ЗАСТАВКИ (Лежит ПОВЕРХ интерфейса)
    // ==========================================
    Item {
        id: splashScreen
        anchors.fill: parent

        // Управляем прозрачностью: если флаг true - 1.0 (видно), если false - 0.0 (невидимо)
        opacity: window.isSplashing ? 1.0 : 0.0

        // Анимация: при изменении opacity плавно менять его в течение 500 миллисекунд
        Behavior on opacity {
            NumberAnimation {
                duration: 500
                easing.type: Easing.InOutQuad // Плавный разгон и замедление анимации
            }
        }

        // Чтобы после исчезновения заставка не перехватывала клики мышки,
        // полностью отключаем её интерактивность, когда она прозрачная
        enabled: window.isSplashing

        Image {
            anchors.fill: parent
            source: "images/Natalie.jpg"
            fillMode: Image.PreserveAspectCrop
        }
    }

    // ==========================================
    // 3. УПРАВЛЕНИЕ ВРЕМЕНЕМ
    // ==========================================
    property bool isSplashing: true

    Timer {
        interval: 2500 // Держать фото 2.5 секунды + 0.5 секунды на плавное таяние = итого 3 секунды
        running: true
        repeat: false
        onTriggered: {
            window.isSplashing = false
        }
    }
}