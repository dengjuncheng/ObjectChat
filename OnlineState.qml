import QtQuick 2.0

Rectangle {
    id: container;
    property var onlineState: "online";
    width: 5;
    height: 5;
    radius: width / 2;
    color: onlineState === "online" ? "#32CD32" : "#FFD700";
    Image{
        id: iamge;
        anchors.centerIn: parent;
        width: parent.width * 0.7;
        height: parent.height * 0.7;
        source: onlineState === "online" ? "" : "qrc:/icon/icon/hidden.png";
        fillMode: Image.PreserveAspectFit;
    }

    MouseArea{
        anchors.fill: parent;
        onClicked: container.onlineState = container.onlineState === "online" ? "hidden" : "online";
    }
}
