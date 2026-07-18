#pragma once

#include <QObject>
#include <QString>
#include <QProcess>

class DownloadController : public QObject
{
    Q_OBJECT
    // Регистрируем свойства, к которым QML сможет обращаться напрямую
    Q_PROPERTY(double progress READ progress NOTIFY progressChanged)
    Q_PROPERTY(QString status READ status NOTIFY statusChanged)

public:
    explicit DownloadController(QObject *parent = nullptr);
    ~DownloadController();

    // Инвокабельный метод — его можно будет вызвать прямо по нажатию кнопки в QML
    Q_INVOKABLE void startDownload(const QString &url, const QString &outputFolder);

    double progress() const { return m_progress; }
    QString status() const { return m_status; }

signals:
    void progressChanged();
    void statusChanged();

private slots:
    void handleProcessOutput();
    void handleProcessFinished(int exitCode, QProcess::ExitStatus exitStatus);

private:
    void updateStatus(const QString &newStatus);
    void updateProgress(double newProgress);

    QProcess *m_process;
    double m_progress;
    QString m_status;
};