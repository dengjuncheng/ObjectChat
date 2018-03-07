#ifndef CAPTURESCREEN_H
#define CAPTURESCREEN_H

#include <QWidget>
#include <QPixmap>
#include <QPainter>

enum CaptureState{
    InitCapture = 0,
    BeginCaptureImage,
    FinishCaptureImage,
    BeginMoveCaptureArea,
    FinishMoveCaptureArea,
    BeginMoveStretchRect,
    FinishMoveStretchRect
};

enum StretchRectState{
    NotSelect = 0,
    TopLeftRect,
    TopRightRect,
    BottomLeftRect,
    BottomRightRect,
    LeftCenterRect,
    TopCenterRect,
    RightCenterRect,
    BottomCenterRect
};

class CaptureScreen : public QWidget
{
    Q_OBJECT
public:
    CaptureScreen(QWidget *parent = nullptr);

signals:
    void  signalCompleteCature(QString filePath);
public slots:
    void captureScreen();
private:
    void initWindow();
    void initStretchRect();
    void loadBackgroundPixmap();
    QRect getRect(const QPoint &beginPoint, const QPoint &endPoint);
    QRect getMoveRect();
    QRect getStretchRect();
    bool isPressPointInSelectRect(QPoint mousePressPoint);
    QRect getSelectRect();
    QPoint getMovePoint();
    StretchRectState getStrethRectState(QPoint point);
    void setStretchCursorStyle(StretchRectState stretchRectState);

    void drawCaptureImage();
    void drawStretchRect();

    void mousePressEvent(QMouseEvent *event);
    void mouseMoveEvent(QMouseEvent* event);
    void mouseReleaseEvent(QMouseEvent *event);
    void keyPressEvent(QKeyEvent *event);
    void paintEvent(QPaintEvent *event);
    QString saveImg();
private:
    QPixmap m_loadPixmap, m_capturePixmap;
    int m_screenwidth;
    int m_screenheight;
    // 保存确定选区的坐标点;
    QPoint m_beginPoint, m_endPoint , m_beginMovePoint , m_endMovePoint;
    QPainter m_painter;
    // 保存当前截图状态;
    CaptureState m_currentCaptureState;
    // 当前选择区域矩形;
    QRect m_currentSelectRect;
    // 选中矩形8个顶点小矩形;
    QRect m_topLeftRect, m_topRightRect, m_bottomLeftRect, m_bottomRightRect;
    QRect m_leftCenterRect, m_topCenterRect, m_rightCenterRect, m_bottomCenterRect;
    // 当前鼠标所在顶点状态;
    StretchRectState m_stretchRectState;
    int width;
    int height;
};

#endif // CAPTURESCREEN_H
