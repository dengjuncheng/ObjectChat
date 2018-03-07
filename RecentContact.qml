import QtQuick 2.0

Rectangle {
    id:container;
    function addContact(friendData){
        addNewMsgContact(friendData);
        contactList.currentIndex = -1;
        contactList.currentIndex = 0;
    }
    function addNewMsgContact(friendData){
        var size = listModel.count;
        var userId = JSON.parse(loginController.getUser()).stuId;
        var i = 0
        for(; i < size ;i++){
            if(listModel.get(i).stuId === friendData.stuId){
                listModel.remove(i);
                break;
            }
        }
        var stuId = JSON.parse(loginController.getUser()).stuId;
        var msgJson = JSON.parse(interactionCenter.getLastMsg(stuId, friendData.stuId));
        //friendObj[j].lastMsg = msgJson.msgType === 1 ? msgJson.lastMsg : "[图片]";
        switch (msgJson.msgType){
        case 1:
            friendData.lastMsg = msgJson.lastMsg;
            break;
        case 2:
            friendData.lastMsg = "[图片]";
            break;
        default:
            friendData.lastMsg = "";
        }
        friendData.addTime = interactionCenter.getCurrentDateTime("yy-MM-dd");
        friendData.unreadCount = interactionCenter.getUnreadCount(userId, friendData.stuId);
        listModel.insert(0,friendData);
        //如果列表中存在，那么更新数据库中该条记录的添加时间，否则添加到数据库
        if(i === size){
            interactionCenter.addContact(stuId, friendData.stuId);
        }else{
            interactionCenter.updateContactAddTime(stuId, friendData.stuId);
        }
    }

    Component.onCompleted: {
        contactList.currentIndex = -1;
        //从数据库读取最近联系人
        var friendObj = JSON.parse(loginController.getFriends());
        var userId = JSON.parse(loginController.getUser()).stuId;
        var friendString = interactionCenter.getContactByUserId(userId);
        var fObj = JSON.parse(friendString);
        var friendSize = friendObj.length;
        var fSize = fObj.length;
        for(var i = 0; i < fSize ; i++){
            for(var j = 0 ; j <friendSize ; j++){
                if(fObj[i].stuId === friendObj[j].stuId){
                    friendObj[j].addTime = fObj[i].addTime;
                    friendObj[j].unreadCount = interactionCenter.getUnreadCount(userId, friendObj[j].stuId);
                    var msgJson = JSON.parse(interactionCenter.getLastMsg(userId, friendObj[j].stuId));
                    //friendObj[j].lastMsg = msgJson.msgType === 1 ? msgJson.lastMsg : "[图片]";
                    switch (msgJson.msgType){
                    case 1:
                        friendObj[j].lastMsg = msgJson.lastMsg;
                        break;
                    case 2:
                        friendObj[j].lastMsg = "[图片]";
                        break;
                    default:
                        friendObj[j].lastMsg = "";
                    }
                    listModel.append(friendObj[j]);
                    break;
                }
            }
        }
    }

    Connections{
        target: interactionCenter;
        onNewMsg:{
            var userId = JSON.parse(loginController.getUser()).stuId;
            var msgInfo = JSON.parse(msg);
            //校验消息的接受方是否为当前用户
            if(userId !== msgInfo.userId){
                console.log("newMsg:" + "接收到的信息错误:" + msg);
                return;
            }

            var friendsObj = JSON.parse(loginController.getFriends());
            var contactString  = interactionCenter.getContactByUserId(userId);
            var contactObj = JSON.parse(contactString);
            //校验接收方是否有发送方这个好友
            var fSize = friendsObj.length;
            var friendObj;
            var i = 0
            for(; i < fSize ; i++){
                if(msgInfo.friendId === friendsObj[i].stuId){
                    friendObj = friendsObj[i];
                    break;
                }
            }
            if(i === fSize){
                console.log("接收方没有此好友,消息接受失败");
                return;
            }
            var sizeTemp = listModel.rowCount();
            var tempIndex = contactList.currentIndex;
            var tempId = tempIndex === -1 ? "0000000000" : listModel.get(tempIndex).stuId;
            addNewMsgContact(friendObj);
//            listModel.get(0).unreadCount = listModel.get(0).unreadCount + 1;
//            console.log(listModel.get(0).unreadCount)
            if(contactList.currentIndex != -1 && tempId === msgInfo.friendId){
                contactList.currentIndex = 0;
            }else{
                if(sizeTemp !== listModel.rowCount() && tempIndex !== -1){
                    contactList.currentIndex += 1;
                }
            }
        }
    }

    Rectangle{
        id:contactRec;
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
        //选中的背景颜色 EDEDED；
        ListView{
            id:contactList;
            anchors.top:searchText.bottom;
            anchors.topMargin: 15;
            width:parent.width;
            height:parent.height - searchText.height - 35;
            model:listModel;
            delegate:listDelegate;
            clip: true;
            onCurrentIndexChanged: {
                if(currentIndex === -1){
                    return;
                }

                var fData = listModel.get(currentIndex);
                chatArea.friendData = fData;
                //去掉头像上的未读数字
                listModel.get(currentIndex).unreadCount = 0;
                chatArea.arriveToBotton();
                //下面需要发送消息给服务器，把未读信息的状态修改为已读
            }
        }
        ListModel{
            id:listModel;

        }

        Component{
            id:listDelegate;
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
                Rectangle{
                    id:unreadRec;
                    height: 15;
                    width:15;
                    radius: 15;
                    color: "#FF6A6A";
                    anchors.left: headImg.right;
                    anchors.top: headImg.top;
                    anchors.leftMargin: -8;
                    anchors.topMargin: -7;
                    visible: unreadCountText.text !== "0";
                    Text{
                        id:unreadCountText;
                        color:"white";
                        anchors.centerIn: parent;
                        text: unreadCount;
                    }
                }

                Text{
                    id:nameText;
                    text:nickName;
                    anchors.top :headImg.top;
                    anchors.left: headImg.right;
                    anchors.leftMargin: 10;
                    font.bold: true;
                    font.pixelSize: 15;
                }
                Text{
                    id:dateText;
                    text:addTime;
                    anchors.bottom: nameText.bottom;
                    anchors.right: parent.right;
                    anchors.rightMargin: 10;
                    font.pixelSize: 12;
                    color:"#999999";
                }
                Text{
                    id:lastMsgText;
                    text:lastMsg;
                    anchors.bottom: headImg.bottom;
                    anchors.left: headImg.right;
                    anchors.leftMargin: 10;
                    font.pixelSize: 12;
                    color:"#999999";
                }
            }
        }
    }
    ChatArea{
        id:chatArea;
        width: parent.width - contactRec.width;
        height:parent.height;
        anchors.left: contactRec.right;
        anchors.top:parent.top;
        border.color: "#DCDCDC";
        border.width: 0.5;
        onLastMsgChanged: {
            listModel.get(contactList.currentIndex).lastMsg = msg;
        }
    }
}
