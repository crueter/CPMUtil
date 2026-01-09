// SPDX-FileCopyrightText: Copyright 2026 crueter
// SPDX-License-Identifier: LGPL-3.0-or-later

#include <QApplication>
#include <QMainWindow>
#include <QLabel>
#include <QCamera>
#include <QMediaCaptureSession>
#include <QMediaDevices>
#include <QVideoWidget>
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

    QWidget *centralWidget = new QWidget(&window);
    QHBoxLayout *mainLayout = new QHBoxLayout(centralWidget);

    QLabel *contentLabel = new QLabel("Loading content...");
    contentLabel->setWordWrap(true);
    contentLabel->setAlignment(Qt::AlignTop);
    contentLabel->setStyleSheet("QLabel { background-color: black; padding: 10px; font-size: 18px; }");
    contentLabel->setFixedWidth(250);

    mainLayout->addWidget(contentLabel);

    QWidget *rightWidget = new QWidget();
    QVBoxLayout *rightLayout = new QVBoxLayout(rightWidget);
    QLabel *helloLabel = new QLabel("Hello World");
    helloLabel->setAlignment(Qt::AlignCenter);
    helloLabel->setStyleSheet("font-size: 32px;");
    rightLayout->addWidget(helloLabel);
    mainLayout->addWidget(rightWidget);

    window.setCentralWidget(centralWidget);

    QCamera *camera = new QCamera(QMediaDevices::defaultVideoInput(), &window);
    QMediaCaptureSession *captureSession = new QMediaCaptureSession(&window);
    captureSession->setCamera(camera);

    QVideoWidget *cameraPreview = new QVideoWidget(&window);
    cameraPreview->setFixedSize(240, 180);
    cameraPreview->setStyleSheet("background-color: black; border: 2px solid white;");
    captureSession->setVideoOutput(cameraPreview);

    cameraPreview->setParent(&window);
    cameraPreview->move(window.width() - cameraPreview->width() - 20, 20);
    cameraPreview->show();

    camera->start();

    QNetworkAccessManager *networkManager = new QNetworkAccessManager(&window);
    QUrl url("https://wttr.in/Nuremberg?format=3&T&d");
    QNetworkRequest request(url);

    QNetworkReply *reply = networkManager->get(request);
    QObject::connect(reply, &QNetworkReply::finished, [&window, reply, contentLabel, cameraPreview]() {
        if (reply->error() == QNetworkReply::NoError) {
            QString content = QString::fromUtf8(reply->readAll()).trimmed();
            contentLabel->setText("<b>Fetched Content:</b><br>" + content);
        } else {
            contentLabel->setText("Error loading content:<br>" + reply->errorString());
        }
        reply->deleteLater();

        cameraPreview->move(window.width() - cameraPreview->width() - 20, 20);
    });

    window.show();

    return app.exec();
}