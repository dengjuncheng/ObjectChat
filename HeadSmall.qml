import QtQuick 2.0
import QtGraphicalEffects 1.0
import QtQuick.Controls 2.2

Rectangle {
    id: container;
    width: 40;
    height: 40;
    radius: width / 2;
    color: "white";
    //opacity: mouseArea.containsMouse ? 0.5 : 1.0;
    //color: mouseArea.containsMouse ? "#00ffffff" : "#ffffffff"
    property var userData;
    property alias source : image.source;
    property var order_number;
    signal clicked(var order);
    signal deleteClicked(var order);
    Image{
        id :image;
        smooth: true;
        visible: false;
        anchors.fill: parent;
        source: "qrc:/icon/icon/head-default.jpg";
        sourceSize: Qt.size(parent.size, parent.size);
        antialiasing: true;
        opacity: mouseArea.containsMouse ? 0.5 : 1;
    }

    Rectangle{
        id: mask;
        color: "white";
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

    ParallelAnimation{
        id:allAnimation;

        NumberAnimation {
            id:xAni
            target: container
            property: "x"
            duration: 500
            easing.type: Easing.InOutQuad
        }
        NumberAnimation {
            id: yAni;
            target: container
            property: "y"
            duration: 500
            easing.type: Easing.InOutQuad
        }

        NumberAnimation {
            id: wAni
            target: container
            property: "width"
            duration: 500
            easing.type: Easing.InOutQuad
        }

        NumberAnimation {
            id:hAni
            target: container
            property: "height"
            duration: 500
            easing.type: Easing.InOutQuad
        }
        onStopped: {
//            var x = 15 + order_number % 3 * 25 + order_number % 3 * 40;
//            var y = order_number > 2 ? 60 : 10;
            container.x = 15 + order_number % 3 * 25 + order_number % 3 * 40;
            container.y = order_number > 2 ? 60 : 10;
            container.width = 40;
            container.height = 40;
            container.z = 0;
            container.clicked(order_number);
        }
    }

    MouseArea{
        id: mouseArea;
        anchors.fill: parent;
        hoverEnabled: true;
        onClicked: {
            container.z = 3
            xAni.to = 50;
            yAni.to = 10;
            wAni.to = 100;
            hAni.to = 100;
            allAnimation.running = true;
            //parent.clicked(order_number);
        }
    }
    ToolTip{
        id:tip
        text:userData.nickName === "default" ? "添加" : userData.nickName;
        visible: mouseArea.containsMouse ? true : false;
    }
    Rectangle{
        id: closeBtn;
        width: 15;
        height: 15;
        radius: 8;
        color: "#FF6347";
        anchors.left: parent.left;
        anchors.top: parent.top;
        visible: userData.nickName === "default" ? false : (mouseArea.containsMouse ? true : false);
        Image{
            width:15;
            height:15;
            anchors.centerIn: parent;
            source:"qrc:/icon/icon/close.png";
            fillMode: Image.PreserveAspectFit;
        }
       MouseArea{
           anchors.fill: parent;
           onPressed: closeBtn.color = "#FF4500";
           onReleased: closeBtn.color = "#FF6347";
           onClicked: {
               container.deleteClicked(order_number);
           }
       }
    }
}
