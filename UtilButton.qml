import QtQuick 2.0

Rectangle{
    id:container;
    signal clicked(var mouse);
    signal pressed;
    signal released;
    property var pressSource;
    property var normalSource;
    color: "#00000000";
    Image{
        id:image;
        anchors.fill: parent;
        source: normalSource;
    }
    MouseArea{
        anchors.fill: parent;
        onClicked: container.clicked(mouse);
        onPressed: image.source = pressSource;
        onReleased: image.source = normalSource;
    }
}
