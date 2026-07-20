#pragma once

#include <QObject>
#include <QString>
#include <QProcess>

class DownloadController : public QObject
{
    Q_OBJECT
    Q_PROPERTY(double progress READ progress NOTIFY progressChanged)
    Q_PROPERTY(QString status READ status NOTIFY statusChanged)
    Q_PROPERTY(QString logOutput READ logOutput NOTIFY logOutputChanged)

public:
    explicit DownloadController(QObject *parent = nullptr);
    ~DownloadController();

    double progress() const { return m_progress; }
    QString status() const { return m_status; }
    QString logOutput() const { return m_logOutput; }

    Q_INVOKABLE void startDownload(const QString &rawUrl, const QString &outputFolder, bool onlyAudio);

signals:
    void progressChanged();
    void statusChanged();
    void logOutputChanged();

private slots:
    void handleProcessOutput();
    void handleProcessFinished(int exitCode, QProcess::ExitStatus exitStatus);

private:
    void updateStatus(const QString &newStatus);
    void updateProgress(double newProgress);
    void appendLog(const QString &text);

    QProcess *m_process;
    double m_progress;
    QString m_status;
    QString m_logOutput;
};