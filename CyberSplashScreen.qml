import QtQuick 2.15

Rectangle {
    id: splashRoot
    anchors.fill: parent
    color: cyberTheme ? cyberTheme.bgDeep : "#0a0b10"
    opacity: isSplashing ? 1.0 : 0.0
    enabled: isSplashing
    z: 100

    // ОБЯЗАТЕЛЬНЫЕ ОБЪЯВЛЕНИЯ СВОЙСТВ:
    property bool isSplashing: true
    property var cyberTheme
    property bool isMobile: false

    Behavior on opacity {
        NumberAnimation { duration: 600; easing.type: Easing.InOutQuad }
    }

    Column {
        anchors.centerIn: parent
        width: parent.width * 0.95
        spacing: splashRoot.isMobile ? 15 : 10

        // --- СТРОКА 1: CYBER ---
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: splashRoot.isMobile ? 8 : 5

            Repeater {
                model: "CYBER".split("")

                CyberLetterBox {
                    targetChar: modelData
                    letterIndex: index
                    isSplashing: splashRoot.isSplashing
                    cyberThemeRef: splashRoot.cyberTheme
                    isMobileRef: splashRoot.isMobile
                }
            }
        }

        // --- СТРОКА 2: DOWNLOADER ---
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: splashRoot.isMobile ? 6 : 4

            Repeater {
                model: "DOWNLOADER".split("")

                CyberLetterBox {
                    targetChar: modelData
                    letterIndex: index + 5
                    isSplashing: splashRoot.isSplashing
                    cyberThemeRef: splashRoot.cyberTheme
                    isMobileRef: splashRoot.isMobile
                }
            }
        }
    }

    component CyberLetterBox: Rectangle {
        id: box
        property string targetChar: ""
        property int letterIndex: 0
        property bool isSplashing: false
        property var cyberThemeRef
        property bool isMobileRef: false

        property bool isFixed: false
        property bool isPassed: false

        width: isMobileRef ? 48 : 38
        height: isMobileRef ? 60 : 48

        color: cyberThemeRef ? cyberThemeRef.bgCard : "#121420"
        border.color: isPassed ? (cyberThemeRef ? cyberThemeRef.neonCyan : "#00ffcc") : (opacity > 0 ? "#ffff00" : "transparent")
        border.width: isPassed ? 1 : 2
        radius: 4

        opacity: 0.0
        scale: 0.3

        property string currentChar: "?"
        readonly property string randomChars: "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ#$%"

        SequentialAnimation {
            running: box.isSplashing
            PauseAnimation { duration: box.letterIndex * 120 }

            ParallelAnimation {
                NumberAnimation { target: box; property: "opacity"; to: 1.0; duration: 150 }
                NumberAnimation { target: box; property: "scale"; to: 1.0; duration: 200; easing.type: Easing.OutBack }
                ScriptAction { script: hackTimer.start() }
            }

            PauseAnimation { duration: 100 }
            ScriptAction { script: box.isPassed = true }
        }

        Timer {
            id: hackTimer
            interval: 35
            repeat: true
            triggeredOnStart: true

            property int ticks: 0
            readonly property int maxTicks: 25

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

        Text {
            anchors.centerIn: parent
            text: box.currentChar
            color: box.isPassed ? "#ffff00" : (cyberThemeRef ? cyberThemeRef.neonPink : "#ff007f")
            font.family: cyberThemeRef ? cyberThemeRef.fontHack : "Courier New"
            font.bold: true
            font.pointSize: box.isMobileRef ? 22 : 16
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: false
        onTriggered: splashRoot.isSplashing = false
    }
}