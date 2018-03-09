import QtQuick 2.0
//#232323
Rectangle {
    id:container;
    property var parentWindow;
    property var userData;
    color:"#003366";
    signal headClicked(var userData);
    signal currentIndexChange(var index);

    function setCurrentIndex(index){
        listView.currentIndex = index;
    }

    MouseArea { //为窗口添加鼠标事件
        anchors.fill: parent;
        acceptedButtons: Qt.LeftButton;
        property point clickPos: "0,0";
        onPressed: {
            clickPos  = Qt.point(mouse.x,mouse.y);
        }

        onPositionChanged: {
            //鼠标偏移量
            var delta = Qt.point(mouse.x-clickPos.x, mouse.y-clickPos.y);
            //如果mainwindow继承自QWidget,用setPos
            parentWindow.setX(parentWindow.x+delta.x);
            parentWindow.setY(parentWindow.y+delta.y);
        }
    }
    //关闭按钮
    Rectangle{
        id:closeBtn;
        anchors.top:parent.top;
        anchors.topMargin: 15;
        anchors.left: parent.left;
        anchors.leftMargin: 14;
        width:13;
        height:13;
        radius: 10;
        color:"#FF6666";
        Image{
            id:closeImg;
            anchors.fill: parent;
            anchors.margins: 3;
            source: "qrc:/icon/icon/chat-close.png";
            visible: closeArea.containsMouse || minArea.containsMouse;
        }
        MouseArea{
            id:closeArea;
            hoverEnabled: true;
            anchors.fill: parent;
            onClicked: Qt.quit();
        }
    }
    //最小化按钮
    Rectangle{
        id:minBtn;
        anchors.top:parent.top;
        anchors.topMargin: 15;
        anchors.left: closeBtn.right;
        anchors.leftMargin: 14;
        width:13;
        height:13;
        radius: 10;
        color:"#66CC00";
        Image{
            id:minImg;
            anchors.fill: parent;
            anchors.margins: 3;
            source: "qrc:/icon/icon/chat-min.png";
            visible: closeArea.containsMouse || minArea.containsMouse;
        }
        MouseArea{
            id:minArea;
            hoverEnabled: true;
            anchors.fill: parent;
            onClicked: Qt.quit();
        }
    }
    Rectangle{
        id:headRec;
        width:45;
        height:45;
        anchors.horizontalCenter: parent.horizontalCenter;
        anchors.top:minBtn.bottom;
        anchors.topMargin: 40;
        Image{
            id:headImg;
            anchors.fill: parent;
            source:userData.headPic;
        }
        MouseArea{
            anchors.fill: parent;
            onClicked: headClicked(userData);
        }
    }
    ListModel{
        id:model;
        ListElement{
            source_1:"qrc:/icon/icon/chat-1.png";
            source_2:"qrc:/icon/icon/chat-2.png";
        }
        ListElement{
            source_1:"qrc:/icon/icon/contact-1.png";
            source_2:"qrc:/icon/icon/contact-2.png";
        }
        ListElement{
            source_1:"qrc:/icon/icon/forum-1.png";
            source_2:"qrc:/icon/icon/forum-2.png";
        }
    }

   Component{
       id:delegate;
       Rectangle{
           id:delegateRec
           width:ListView.view.width;
           height:30;
           color:"#00000000";
           Image{
               id: delegateImg;
               source:delegateRec.ListView.isCurrentItem ? source_1 : source_2
               anchors.fill: parent;
               opacity: 0.8;
           }
           MouseArea{
               anchors.fill: parent;
               onClicked: delegateRec.ListView.view.currentIndex = index;
               onPressed: delegateImg.opacity = 0.4;
               onReleased: delegateImg.opacity = 0.8;
           }
       }
   }

    //三个列表按钮
    ListView{
        id:listView;
        height:200;
        width:30;
        anchors.top: headRec.bottom;
        anchors.topMargin: 40;
        anchors.horizontalCenter: parent.horizontalCenter;
        model:model;
        delegate: delegate;
        spacing: 25;
        focus: true;
        interactive: false;
        onCurrentIndexChanged: {
            currentIndexChange(currentIndex);
        }
    }

    Rectangle{
        id:optionBtn;
        width:20;
        height:20;
        anchors.bottom: parent.bottom;
        anchors.bottomMargin: 15;
        anchors.horizontalCenter: parent.horizontalCenter;
        color:"#00000000";
        Image{
            id: optionImg;
            source:"qrc:/icon/icon/option-2.png";
            anchors.fill: parent;
            opacity: 0.8;
        }
        MouseArea{
            anchors.fill: parent;
            onPressed: optionImg.opacity = 0.4;
            onReleased: optionImg.opacity = 0.8;
        }
    }
}
