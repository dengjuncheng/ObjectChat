import QtQuick 2.0

Rectangle {
    id:container;
    width:50;
    height:50;
    property alias source: image.source;
    signal click(var mouse);
    radius: 25
    Image{
        id:image;
        anchors.fill: parent;
        source:"qrc:/icon/icon/connect.png";
        anchors.margins: 5;
    }
    MouseArea{
        id:mouseArea;
        anchors.fill: parent;
        onClicked: container.click(mouse);
        onPressed: {
            container.opacity = 0.5;
        }
        onReleased: container.opacity = 1;
    }
}
