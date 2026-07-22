#include "downloadcontroller.h"
#include <QCoreApplication>
#include <QRegularExpression>
#include <QDebug>
#include <QDir>
#include <QDateTime>

DownloadController::DownloadController(QObject *parent)
    : QObject(parent), m_process(new QProcess(this)), m_progress(0.0), m_status("> ОЖИДАНИЕ ИНИЦИАЛИЗАЦИИ...")
{
    connect(m_process, &QProcess::readyReadStandardOutput, this, &DownloadController::handleProcessOutput);
    connect(m_process, &QProcess::readyReadStandardError, this, &DownloadController::handleProcessOutput);
    connect(m_process, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished),
            this, &DownloadController::handleProcessFinished);

    appendLog("[SYSTEM] CYBER_DOWNLOADER KERNEL INITIALIZED...");
}

DownloadController::~DownloadController()
{
    if (m_process->state() == QProcess::Running) {
        m_process->terminate();
        m_process->waitForFinished(3000);
    }
}

void DownloadController::appendLog(const QString &text)
{
    QString timeStamp = QDateTime::currentDateTime().toString("hh:mm:ss");
    m_logOutput += QString("[%1] %2\n").arg(timeStamp, text);
    emit logOutputChanged();
}

void DownloadController::startDownload(const QString &rawUrl, const QString &outputFolder, bool onlyAudio)
{
    if (rawUrl.isEmpty()) {
        updateStatus("> ОШИБКА: ССЫЛКА ПУСТА");
        appendLog("[ERROR] URL input string is empty!");
        return;
    }

    if (m_process->state() == QProcess::Running) {
        updateStatus("> ОШИБКА: ПРОЦЕСС УЖЕ ЗАПУЩЕН");
        appendLog("[WARN] Process is already active.");
        return;
    }

    // Очистка лога перед новым запуском
    m_logOutput.clear();
    emit logOutputChanged();

    appendLog("[INIT] Preparing download stream...");

    QString cleanUrl = rawUrl.trimmed();

    if (cleanUrl.contains("tiktok.com")) {
        int queryIndex = cleanUrl.indexOf('?');
        if (queryIndex != -1) cleanUrl = cleanUrl.left(queryIndex);
    } else if (cleanUrl.contains("youtube.com") || cleanUrl.contains("youtu.be")) {
        int listIndex = cleanUrl.indexOf("&list=");
        if (listIndex != -1) cleanUrl = cleanUrl.left(listIndex);
        int indexIndex = cleanUrl.indexOf("&index=");
        if (indexIndex != -1) cleanUrl = cleanUrl.left(indexIndex);
        int featureIndex = cleanUrl.indexOf("&feature=");
        if (featureIndex != -1) cleanUrl = cleanUrl.left(featureIndex);
    }

    appendLog(QString("[TARGET] Target URL: %1").arg(cleanUrl));
    updateProgress(0.0);
    updateStatus("> АНАЛИЗ ВИДЕОПОТОКА...");

    QString extensionTemplate = onlyAudio ? "%(title)s.mp3" : "%(title)s.%(ext)s";
    QString outputTemplate = QDir(outputFolder).filePath(extensionTemplate);
    QString appDir = QCoreApplication::applicationDirPath();

    QStringList arguments;
    arguments << "--newline";

    if (onlyAudio) {
        arguments << "-x" << "--audio-format" << "mp3" << "--audio-quality" << "0";
        appendLog("[MODE] Audio extraction active (MP3, 320k)");
    } else {
        arguments << "-S" << "vcodec:h264,res,acodec:m4a"
                  << "--merge-output-format" << "mp4"
                  << "--recode-video" << "mp4";
        appendLog("[MODE] Video stream capture active (H.264/MP4 Enforcement)");
    }

    arguments << "--geo-bypass"
              << "--encoding" << "utf-8"  // Force UTF-8 encoding
              //<< "--no-cookies-update"
              << "--extractor-args" << "youtube:player_client=web,mweb"
              << "--user-agent" << "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36"
              << "--ffmpeg-location" << appDir
              << "--cookies" << appDir + "/cookies.txt"

              << "-o" << outputTemplate
              << cleanUrl;

    appendLog("[EXEC] Launching yt-dlp binary backend...");

#ifdef Q_OS_WIN
    QString program = "yt-dlp.exe";
#else
    QString program = "yt-dlp";
#endif
    QProcessEnvironment env = QProcessEnvironment::systemEnvironment();
    env.insert("PYTHONIOENCODING", "utf-8");
    m_process->setProcessEnvironment(env);

    m_process->start(program, arguments);
}

void DownloadController::handleProcessOutput()
{
    QString stdOut = QString::fromUtf8(m_process->readAllStandardOutput()).trimmed();
    QString stdErr = QString::fromUtf8(m_process->readAllStandardError()).trimmed();

    if (!stdOut.isEmpty()) {
        // Записываем каждый чистый вывод утилиты в наш лог
        appendLog(stdOut);

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
        appendLog("[STDERR] " + stdErr);
    }
}

void DownloadController::handleProcessFinished(int exitCode, QProcess::ExitStatus exitStatus)
{
    if (exitCode == 0 && exitStatus == QProcess::NormalExit) {
        updateProgress(1.0);
        updateStatus("> СОХРАНЕНИЕ ФАЙЛА УСПЕШНО ЗАВЕРШЕНО!");
        appendLog("[SUCCESS] Process completed with code 0. File saved.");
    } else {
        updateStatus("> КРИТИЧЕСКИЙ СБОЙ ПРИ СКАЧИВАНИИ");
        appendLog(QString("[FAIL] Process crashed or aborted with exit code: %1").arg(exitCode));
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