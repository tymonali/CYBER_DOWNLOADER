#include "downloadcontroller.h"
#include <QCoreApplication>
#include <QRegularExpression>
#include <QDebug>
#include <QDir>

DownloadController::DownloadController(QObject *parent)
    : QObject(parent), m_process(new QProcess(this)), m_progress(0.0), m_status("> ОЖИДАНИЕ ИНИЦИАЛИЗАЦИИ...")
{
    // Подключаем чтение вывода утилиты в реальном времени
    connect(m_process, &QProcess::readyReadStandardOutput, this, &DownloadController::handleProcessOutput);
    connect(m_process, &QProcess::readyReadStandardError, this, &DownloadController::handleProcessOutput);

    // Подключаем отслеживание завершения процесса
    //connect(m_process, &QProcess::obsolete_finished, this, &DownloadController::handleProcessFinished);
    connect(m_process, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished),
            this, &DownloadController::handleProcessFinished);
}

DownloadController::~DownloadController()
{
    if (m_process->state() == QProcess::Running) {
        m_process->terminate();
        m_process->waitForFinished(3000);
    }
}

void DownloadController::startDownload(const QString &url, const QString &outputFolder)
{
    if (url.isEmpty()) {
        updateStatus("> ОШИБКА: ССЫЛКА ПУСТА");
        return;
    }

    if (m_process->state() == QProcess::Running) {
        updateStatus("> ОШИБКА: ПРОЦЕСС УЖЕ ЗАПУЩЕН");
        return;
    }

    updateProgress(0.0);
    updateStatus("> АНАЛИЗ ВИДЕОПОТОКА...");

    // Формируем шаблон имени файла (сохраняем оригинальное название видео)
    QString outputTemplate = QDir(outputFolder).filePath("%(title)s.%(ext)s");

    //// Аргументы для запуска yt-dlp
    //QStringList arguments;
    //arguments << "--newline"
    //          // --- ИЗМЕНЯЕМ СТРАТЕГИЮ ВЫБОРА ФОРМАТА ---
    //          // Качаем лучшее видео, но аудио СТРОГО в формате m4a (кодек AAC)
    //          << "-f" << "bv*+ba[ext=m4a]/b[ext=mp4]/bv*+ba"
    //          // -----------------------------------------

    //          << "--merge-output-format" << "mp4"
    //          << "--ffmpeg-location" << "C:/ffmpeg/bin"
    //          << "--cookies" << "D:/cookies.txt"
    //          << "-o" << outputTemplate
    //          << url;

    // Получаем путь к папке, где лежит запущенный exe-файл приложения
    QString appDir = QCoreApplication::applicationDirPath();

    QStringList arguments;
    arguments << "--newline"
              // Наша проверенная стратегия выбора совместимого формата видео + аудио (AAC)
              << "-f" << "bv*+ba[ext=m4a]/b[ext=mp4]/bv*+ba"
              << "--merge-output-format" << "mp4"

              // --- ДИНАМИЧЕСКИЕ ПУТИ ДЛЯ ПЕРЕНОСИМОСТИ СИСТЕМЫ ---
              // Говорим yt-dlp искать ffmpeg.exe в той же папке, где лежит само приложение
              << "--ffmpeg-location" << appDir

              // Указываем искать файл cookies.txt прямо рядом с нашим exe
              << "--cookies" << appDir + "/cookies.txt"
              // ----------------------------------------------------

              << "-o" << outputTemplate
              << url;
    // Имя исполняемого файла (на Windows — yt-dlp.exe, на Android настроим позже)
#ifdef Q_OS_WIN
    QString program = "yt-dlp.exe";
#else
    QString program = "yt-dlp";
#endif

    m_process->start(program, arguments);
}

void DownloadController::handleProcessOutput()
{
    // Читаем СЫРОЙ вывод из стандартного потока и потока ошибок целиком
    QString stdOut = QString::fromUtf8(m_process->readAllStandardOutput()).trimmed();
    QString stdErr = QString::fromUtf8(m_process->readAllStandardError()).trimmed();

    if (!stdOut.isEmpty()) {
        qDebug() << "=== YT-DLP OUTPUT ===" << Qt::endl << stdOut;

        // Оставляем нашу регулярку для процентов, проверяя весь кусок текста
        static QRegularExpression progressRegex(R"(\[download\]\s+(\d+\.\d+)%)");
        QRegularExpressionMatchIterator it = progressRegex.globalMatch(stdOut);
        while (it.hasNext()) {
            QRegularExpressionMatch match = it.next();
            double percent = match.captured(1).toDouble();
            updateProgress(percent / 100.0);
            updateStatus(QString("> СКАЧИВАНИЕ ВИДЕОПОТОКА: %1%").arg(percent, 0, 'f', 1));
        }

        if (stdOut.contains("[Merger]")) {
            updateStatus("> КВАНТОВАЯ СКЛЕЙКА ПОТОКОВ (FFMPEG)...");
        }
    }

    if (!stdErr.isEmpty()) {
        // Вот здесь мы наконец-то увидим настоящую ошибку от YouTube!
        qDebug() << "=== YT-DLP ERROR ===" << Qt::endl << stdErr;
    }
}

void DownloadController::handleProcessFinished(int exitCode, QProcess::ExitStatus exitStatus)
{
    if (exitCode == 0 && exitStatus == QProcess::NormalExit) {
        updateProgress(1.0);
        updateStatus("> СОХРАНЕНИЕ ФАЙЛА УСПЕШНО ЗАВЕРШЕНО!");
    } else {
        updateStatus("> КРИТИЧЕСКИЙ СБОЙ ПРИ СКАЧИВАНИИ");
    }
}

void DownloadController::updateStatus(const QString &newStatus)
{
    if (m_status != newStatus) {
        m_status = newStatus;
        emit statusChanged();
    }
}

void DownloadController::updateProgress(double newProgress)
{
    if (!qFuzzyCompare(m_progress, newProgress)) {
        m_progress = newProgress;
        emit progressChanged();
    }
}