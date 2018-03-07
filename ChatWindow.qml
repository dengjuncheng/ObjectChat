import QtQuick 2.0
import QtQuick.Window 2.2
import QtQuick.Controls 1.4

//聊天窗口主窗体
Window {
    id:chatWindow;
    height:600;
    width:900;
    flags:Qt.FramelessWindowHint| Qt.Window;
    visible:true;
    property var loginData;

    NumberAnimation{
        id:showAni;
        target: chatWindow;
        duration: 400;
        property: "opacity";
        from:0;
        to:1;
    }
    Component.onCompleted: {
        showAni.start();
        leftTitleBar.userData = loginData.user;
        var userJson = JSON.stringify(loginData.user)
        loginController.setUser(userJson);
        loginController.setFriends(JSON.stringify(loginData.friend));
        interactionCenter.getUnreadMsg(loginData.user.stuId);
    }
    //左边栏
    LeftTitleBar{
        id:leftTitleBar;
        anchors.left: parent.left;
        height:parent.height;
        width:70;
        parentWindow: chatWindow;
        onHeadClicked: {
            //TODO 添加头像点击后显示个人信息
            console.log(JSON.stringify(userData));
        }

        onCurrentIndexChange: {
            tableView.currentIndex = index;
        }
    }

    TabView{
        id:tableView;
        anchors.left:leftTitleBar.right;
        width:parent.width - leftTitleBar.width;
        height: parent.height;
        tabsVisible: false;

        Tab{
            id:tab1;
            RecentContact{
                id:contact;
                anchors.fill: parent;
            }
        }
        Tab{
            id:tab2;
            FriendsPage{
                anchors.fill: parent;
                Component.onCompleted: {
                    friendsData = loginData.friend;
                }
                onReadyToSend: {
                    //Tab继承Loader，调用item
                    tab1.item.addContact(friendData);
                    leftTitleBar.setCurrentIndex(0);
                }
            }
        }
        Tab{
            id:tab3;
            Rectangle{
                anchors.fill: parent;
                color:"green";
            }
        }
    }
    Connections{
        target: loginController;
        onFriendStateChanged:{
            var info = JSON.parse(msg);
            var friendList = JSON.parse(loginController.getFriends());
            var size = friendList.length;
            for(var i = 0; i < size ; i++){
                if(friendList[i].stuId === info.stuId){
                    friendList[i].isOnline = info.isOnline;
                    break;
                }
            }
            loginController.setFriends(JSON.stringify(friendList));
        }
    }
    Rectangle{
        id:errorInfoRec;
        height: 50;
        width:150;
        color: "red";
        radius: 5;
        visible: true;
        opacity: 0.1;
        anchors.centerIn: parent;
        Text{
            id:infoText;
            anchors.fill: parent;
            text:"提示信息未在线";
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pointSize: 15;
        }

    }
}
