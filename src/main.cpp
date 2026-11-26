/*
 * SPDX-License-Identifier: BSD-3-Clause
 * Copyright 2026 Nitrux Latinoamericana S.C.
 */

#include <QApplication>
#include <QDate>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QProcess>
#include <QStandardPaths>
#include <cstdlib>
#include <QIcon>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QSurfaceFormat>
#include <QUrl>

#include <KAboutData>
#include <KLocalizedQmlContext>
#include <KLocalizedString>
#include <MauiKit4/Core/mauiapp.h>

class LoginService : public QObject
{
    Q_OBJECT
    const QString directory = QStandardPaths::writableLocation(QStandardPaths::GenericConfigLocation) + QStringLiteral("/rc");
public:
    Q_INVOKABLE bool enabled() const
    {
        return QFileInfo::exists(directory + QStringLiteral("/runlevels/desktop/onward"));
    }

    Q_INVOKABLE bool setEnabled(bool enable)
    {
        const QString init = directory + QStringLiteral("/init.d");
        const QString link = init + QStringLiteral("/onward");
        const QString service = QStandardPaths::locate(QStandardPaths::GenericDataLocation, QStringLiteral("onward/onward"));
        const bool create = enable && !QFileInfo::exists(link);
        if (create && (service.isEmpty() || !QDir().mkpath(init) || !QFile::link(service, link)))
            return false;
        const auto status = QProcess::execute(QStringLiteral("rc-update"),
            {QStringLiteral("-U"), enable ? QStringLiteral("add") : QStringLiteral("del"),
             QStringLiteral("onward"), QStringLiteral("desktop")});
        if (status != 0 && create)
            QFile::remove(link);
        if (status == 0 && !enable && QFileInfo(link).symLinkTarget() == service && !service.isEmpty())
            QFile::remove(link);
        return status == 0 && enabled() == enable;
    }
};

static QString distributionRelease()
{
    QFile file(QStringLiteral("/etc/lsb-release"));
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
        return {};

    while (!file.atEnd()) {
        const QByteArray line = file.readLine().trimmed();
        const auto separator = line.indexOf('=');
        if (separator < 0 || line.left(separator).trimmed() != "DISTRIB_RELEASE")
            continue;

        QByteArray value = line.mid(separator + 1).trimmed();
        if (value.size() >= 2 && (value.front() == '"' || value.front() == '\'') && value.back() == value.front())
            value = value.mid(1, value.size() - 2);
        return QString::fromUtf8(value).trimmed();
    }
    return {};
}

int main(int argc, char *argv[])
{
    QSurfaceFormat format;
    format.setAlphaBufferSize(8);
    QSurfaceFormat::setDefaultFormat(format);

    QApplication application(argc, argv);
    application.setApplicationName(QStringLiteral("onward"));
    application.setApplicationDisplayName(QStringLiteral("Onward"));
    application.setApplicationVersion(QStringLiteral("0.1.0"));
    application.setDesktopFileName(QStringLiteral("org.nitrux.onward"));
    application.setOrganizationName(QStringLiteral("Nitrux"));
    application.setOrganizationDomain(QStringLiteral("nxos.org"));
    application.setWindowIcon(QIcon::fromTheme(QStringLiteral("nx-logo")));

    KLocalizedString::setApplicationDomain(QByteArrayLiteral("onward"));

    KAboutData about(QStringLiteral("onward"),
                     i18n("Onward"),
                     QStringLiteral("0.1.0"),
                     i18n("A guide to using Nitrux."),
                     KAboutLicense::BSD_3_Clause,
                     i18n("© %1 Made by Nitrux | Built with MauiKit", QString::number(QDate::currentDate().year())));
    about.addAuthor(QStringLiteral("Uri Herrera"), i18n("Developer"), QStringLiteral("uri_herrera@nxos.org"));
    about.setHomepage(QStringLiteral("https://nxos.org/documentation/"));
    about.setProductName(QByteArrayLiteral("nitrux/onward"));
    about.setBugAddress(QByteArrayLiteral("https://github.com/Nitrux/onward/issues"));
    about.setProgramLogo(application.windowIcon());
    about.setDesktopFileName(QStringLiteral("org.nitrux.onward"));
    about.setOrganizationDomain(QByteArrayLiteral("org.nitrux.onward"));
    KAboutData::setApplicationData(about);

    MauiApp::instance()->setIconName(QStringLiteral("nx-logo"));

    LoginService loginService;
    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty(QStringLiteral("distributionRelease"), distributionRelease());
    engine.rootContext()->setContextProperty(QStringLiteral("loginService"), &loginService);
    engine.rootContext()->setContextObject(new KLocalizedQmlContext(&engine));
    engine.load(QUrl(QStringLiteral("qrc:/org/nitrux/onward/main.qml")));

    if (engine.rootObjects().isEmpty())
        return EXIT_FAILURE;

    return application.exec();
}

#include "main.moc"
