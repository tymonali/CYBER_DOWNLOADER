#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>         // Добавили для работы с контекстом
#include "downloadcontroller.h" // Подключили наш контроллер

int main(int argc, char *argv[])
{
    // Принудительно включаем базовый стиль для поддержки кастомного UI
    qputenv("QT_QUICK_CONTROLS_STYLE", "Basic");

    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    // Регистрация C++ класса для использования в QML как обычного компонента
    qmlRegisterType<DownloadController>("CyberCore", 1, 0, "DownloadController");

    const QUrl url(QStringLiteral("qrc:/qt/qml/YouTubeDownloaderForNatalie/Main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
                         if (!obj && url == objUrl)
                             QCoreApplication::exit(-1);
                     }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}