import QtQuick 2.0
import QtGraphicalEffects 1.0

Rectangle {
    id: container;
    width: 100;
    height: 100;
    radius: width / 2;
    color: "black";
    opacity: mouseArea.containsMouse ? 0.5 : 1.0;
    property alias source : image.source;
    signal clicked;
    Image{
        id :image;
        smooth: true;
        visible: false;
        anchors.fill: parent;
        source: "qrc:/icon/icon/head-default.jpg";
        sourceSize: Qt.size(parent.size, parent.size);
        antialiasing: true;
    }

    Rectangle{
        id: mask;
        color: "black";
        anchors.fill: parent;
        radius: width / 2;
        visible: false;
        antialiasing: true;
        smooth: true;
    }
    OpacityMask{
        id: mask_image;
        anchors.fill: image;
        source: image;
        maskSource: mask;
        visible: true;
        antialiasing: true;
    }

    MouseArea{
        id: mouseArea;
        anchors.fill: parent;
        hoverEnabled: true;
        onClicked: parent.clicked();
    }
}
