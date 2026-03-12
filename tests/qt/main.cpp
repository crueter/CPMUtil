// SPDX-FileCopyrightText: Copyright 2026 crueter
// SPDX-License-Identifier: LGPL-3.0-or-later

#include <QApplication>
#include <QMainWindow>
#include <QLabel>
#include <QCamera>
#include <QMediaCaptureSession>
#include <QMediaDevices>
#include <QVideoWidget>
#include <QMediaPlayer>
#include <QAudioOutput>
#include <QVBoxLayout>
#include <QHBoxLayout>
#include <QWidget>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkRequest>

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    QMainWindow window;
    window.setWindowTitle("Hello World");
    window.resize(800, 600);

    // network pane
    QWidget *centralWidget = new QWidget(&window);
    QHBoxLayout *mainLayout = new QHBoxLayout(centralWidget);

    QLabel *contentLabel = new QLabel("Loading content...");
    contentLabel->setWordWrap(true);
    contentLabel->setAlignment(Qt::AlignTop);
    contentLabel->setStyleSheet("QLabel { background-color: black; padding: 10px; font-size: 18px; }");
    contentLabel->setFixedWidth(250);

    mainLayout->addWidget(contentLabel);

    // multimedia pane
    QWidget *rightWidget = new QWidget();
    QVBoxLayout *rightLayout = new QVBoxLayout(rightWidget);

    // big buck bunny :)
    QLabel *titleLabel = new QLabel("Video");
    titleLabel->setStyleSheet("font-size: 18px; font-weight: bold;");
    rightLayout->addWidget(titleLabel);

    QVideoWidget *videoWidget = new QVideoWidget();
    QMediaPlayer *player = new QMediaPlayer(&window);
    QAudioOutput *audioOutput = new QAudioOutput(&window);

    player->setAudioOutput(audioOutput);
    player->setVideoOutput(videoWidget);
    player->setSource(QUrl("https://download.blender.org/peach/bigbuckbunny_movies/big_buck_bunny_720p_h264.mov"));

    // floating camera
    QCamera *camera = new QCamera(QMediaDevices::defaultVideoInput(), &window);
    QMediaCaptureSession *captureSession = new QMediaCaptureSession(&window);
    captureSession->setCamera(camera);

    QVideoWidget *cameraPreview = new QVideoWidget(&window);
    cameraPreview->setFixedSize(200, 150);
    cameraPreview->setStyleSheet("border: 2px solid #00ff00; background-color: black;");
    captureSession->setVideoOutput(cameraPreview);

    // start media
    cameraPreview->raise();
    cameraPreview->show();

    camera->start();
    player->play();

    // layout
    rightLayout->addWidget(videoWidget);
    mainLayout->addWidget(rightWidget);
    window.setCentralWidget(centralWidget);

    // network stuff
    QNetworkAccessManager *networkManager = new QNetworkAccessManager(&window);
    QUrl url("https://example.com");
    QNetworkRequest request(url);

    QNetworkReply *reply = networkManager->get(request);
    QObject::connect(reply, &QNetworkReply::finished, [&window, reply, contentLabel, cameraPreview]() {
        if (reply->error() == QNetworkReply::NoError) {
            QString content = QString::fromUtf8(reply->readAll()).trimmed();
            contentLabel->setText("<b>Fetched Content:</b><br>" + content);
            qDebug() << "Fetched content:" << content;
        } else {
            contentLabel->setText("Error loading content:<br>" + reply->errorString());
            qDebug() << "Failed to fetch content:" << reply->errorString();
        }
        reply->deleteLater();

        cameraPreview->move(window.width() - cameraPreview->width() - 20, 20);
    });

    window.show();

    return app.exec();
}