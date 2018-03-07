#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <dbhelper.h>
#include <logincontroller.h>
#include <QQmlContext>
#include <connectioncenter.h>
#include <capturescreen.h>
#include <QApplication>
#include <interactioncenter.h>
#include <filehelper.h>

int main(int argc, char *argv[])
{
#if defined(Q_OS_WIN)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif

    QApplication app(argc, argv);
    app.setQuitOnLastWindowClosed(false);//防止截图窗口关闭时整个程序退出

    ConnectionCenter c;
    LoginController loginController(&c);
    CaptureScreen *captureScreen = new CaptureScreen;
    FileHelper fileHelper;
    InteractionCenter interactionCenter(captureScreen, &fileHelper, &c);

    QQmlApplicationEngine engine;
    //把这两个对象注册到qml上下文
    engine.rootContext()->setContextProperty("loginController", &loginController);
    engine.rootContext()->setContextProperty("interactionCenter", &interactionCenter);
    //加载qml入口文件
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;
    return app.exec();
}
