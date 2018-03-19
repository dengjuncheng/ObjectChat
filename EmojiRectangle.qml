import QtQuick 2.0

Rectangle {
    id:container;
    property var value;
    width:40;
    height:40;
    radius: 4;
    color:mouseArea.containsMouse ? "#F0F0F0" : "#FFFFFF";
    signal clicked(var value);
    Text {
        id: text
        anchors.centerIn: parent;
        horizontalAlignment: Text.AlignHCenter;
        verticalAlignment: Text.AlignVCenter;
        text:value;
    }
    MouseArea{
        id:mouseArea;
        anchors.fill: parent;
        hoverEnabled: true;
        onClicked: {
            container.clicked(value);
            mouse.accepted = true;
        }
        onPressed: container.color = "#D1D1D1";
        onReleased: container.color = "#FFFFFF";
    }
}
