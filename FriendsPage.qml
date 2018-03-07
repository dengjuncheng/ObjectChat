import QtQuick 2.0
import QtQuick.Controls 1.4

Rectangle {
    id:container;
    property var friendsData;
    signal readyToSend(var friendData);
    onFriendsDataChanged: {
        friendModel.clear();
        friendModel.append(friendsData);
    }

    Rectangle{
        id:friendRec;
        height:parent.height;
        width:260;
        color:"#FCFCFC";
        //搜索框
        TextInput{
            id:searchText;
            height :23;
            width: 220;
            anchors.top: parent.top;
            anchors.topMargin: 15;
            anchors.horizontalCenter: parent.horizontalCenter;
            font.pixelSize: 12;
            font.bold: true;
            font.letterSpacing: 0.5;
            selectByMouse: true;
            selectionColor: "#DCDCDC"
            clip:true;
            verticalAlignment: Text.AlignVCenter;
            property string placeholderText: "搜索";
            Rectangle{
                id:back;
                color:"#cccccc";
                anchors.fill: parent;
                opacity: 0.5;
                radius: 4;
            }

            Text {
                text: searchText.placeholderText;
                color: "#aaa";
                visible: !searchText.text
                anchors.fill: parent;
                verticalAlignment: Text.AlignVCenter;
                horizontalAlignment: Text.AlignHCenter;
                font.pixelSize: 15;
            }
        }
        //好友列表
        ListView{
            id:friendList;
            width:parent.width;
            height:parent.height - searchText.height - 35;
            anchors.top:searchText.bottom;
            anchors.topMargin: 15;
            model:friendModel;
            delegate:friendDelegate;
            clip: true;
            onCurrentIndexChanged: {
                infoPage.friendData = friendModel.get(currentIndex);
            }
            ListModel{
                id:friendModel;
            }

            Component{
                id:friendDelegate;
                Rectangle{
                    id:delegateRec;
                    width:ListView.view.width;
                    height: 70;
                    color:ListView.isCurrentItem ? "#EDEDED" : "#FCFCFC";
                    //每一个聊天框下面的横线
                    Rectangle{
                        width:parent.width - 20;
                        height: 1;
                        color:"#EDEDED";
                        anchors.bottom: parent.bottom;
                        anchors.horizontalCenter: parent.horizontalCenter;
                    }
                    MouseArea{
                        anchors.fill: parent;
                        onClicked: delegateRec.ListView.view.currentIndex = index;
                        onDoubleClicked: infoPage.readyToSend();
                    }

                    Image{
                        id:headImg;
                        source:headPic;
                        width:50;
                        height:50;
                        anchors.verticalCenter: parent.verticalCenter;
                        anchors.left: parent.left;
                        anchors.leftMargin: 10;
                    }
                    Text{
                        id:nameText;
                        anchors.left: headImg.right;
                        anchors.leftMargin: 10;
                        anchors.verticalCenter: parent.verticalCenter;
                        font.bold: true;
                        font.pixelSize: 15;
                        text:nickName;
                    }
                }
            }
        }
    }
    FriendInfo{
        id:infoPage;
        anchors.left: friendRec.right;
        anchors.top:parent.top;
        width:parent.width - friendRec.width;
        height:parent.height;
        onSendMsg: container.readyToSend(friendInfo);
    }

}
