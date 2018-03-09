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
    property var userData;

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
        userData = loginData.user;
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
    Connections{
        target: interactionCenter;
        onVoiceChatRequestResult:{
            var info = JSON.parse(msg);
            infoText.text = info.msg;
            if(info.code !== 0){
                showAnimation.start();
                //return;
            }
            //显示语音聊天窗口
            voiceChatWindow.openWindow(info.command.friendId, true);
        }

        onNewVoiceChatRequest:{
            var info = JSON.parse(msg);
            voiceChatWindow.openWindow(info.friendId, false);
        }

        onCancleVoiceChat:{
            //当请求方取消语音消息时
            var info = JSON.parse(msg);
            if(!voiceChatWindow.visible){
                return;
            }
            voiceChatWindow.visible = false;
            infoText.text = "对方已取消";
            showAnimation.start();
        }

        onStartVoiceChat:{
            var info = JSON.parse(msg);
            var userId = info.userId;
            var friendId = info .friendId;
            if(userId !== userData.stuId || friendId !== voiceChatWindow.stuId || !voiceChatWindow.visible){
                return;
            }
            stateText.text = "正在语音通话";
            cancleBtn.visible = false;
            acceptBtn.visible = false;
            refuseBtn.visible = false;
            breakBtn.visible = true;
            interactionCenter.onStartVoiceChat(info.targetIp);
        }

        onVoiceChatRefused:{
            var info = JSON.parse(msg);
            var userId = info.userId;
            var friendId = info .friendId;
            if(userId !== userData.stuId || friendId !== voiceChatWindow.stuId || !voiceChatWindow.visible){
                return;
            }

            infoText.text = "对方已拒绝";
            voiceChatWindow.visible = false;
            showAnimation.start();
        }

        onVoiceChatBreak:{
            var info = JSON.parse(msg);
            var userId = info.userId;
            var friendId = info .friendId;
            if(userId !== userData.stuId || friendId !== voiceChatWindow.stuId || !voiceChatWindow.visible){
                return;
            }
            infoText.text = "对方取消了通话";
            voiceChatWindow.visible = false;
            showAnimation.start();
        }
    }

    Rectangle{
        id:errorInfoRec;
        height: 50;
        width:150;
        color: "red";
        radius: 5;
        opacity: 0;
        anchors.centerIn: parent;
        Text{
            id:infoText;
            anchors.fill: parent;
            text:"对方未在线";
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pointSize: 15;
        }

        NumberAnimation {
            id:showAnimation;
            target: errorInfoRec
            property: "opacity"
            duration: 1000
            easing.type: Easing.InOutQuad
            from:0;
            to:0.5;
            onStopped: {
                showTimer.start();
            }
        }

        NumberAnimation {
            id:closeAnimation
            target: errorInfoRec
            property: "opacity"
            duration: 100
            easing.type: Easing.InOutQuad
            from:0.5;
            to:0;
        }
        Timer{
            id:showTimer;
            interval: 3000;
            repeat: false;
            triggeredOnStart: false;
            onTriggered: {
                closeAnimation.start();
            }
        }
    }

    Window{
        id:voiceChatWindow;
        visible:false;
        modality: Qt.ApplicationModal;
        width: 250
        height: 320
        maximumHeight: 320
        maximumWidth: 250
        minimumHeight: 320
        minimumWidth: 250
        property var stuId;
        property string headDefault: "qrc:/icon/icon/head-default.jpg";
        property alias source: head.source;
        property string stateValue: "正在等待对方接受邀请";
        property string nameValue: "default"
        onVisibilityChanged: {
            if(!visible){
                source = headDefault;
                nameText.text = nameValue;
                stateText.text = stateValue;
                //这里有大问题！！！！！！！！！！
                //TODO:需要根据窗口当前状态来判断
                interactionCenter.cancleVoiceRequest(userData.stuId, voiceChatWindow.stuId);
            }
        }
        function openWindow(friendId, derection){
            stuId = friendId;
            var allFriends = JSON.parse(loginController.getFriends());
            var size = allFriends.length;
            var friendInfo = null;
            for(var i = 0 ; i < size ; ++i){
                if(allFriends[i].stuId === friendId){
                    friendInfo = allFriends[i];
                    break;
                }
            }

            if(i === size){
                return;
            }

            nameText.text = friendInfo.nickName;
            source = friendInfo.headPic;

            if(derection){
                stateText.text = voiceChatWindow.stateValue;
                acceptBtn.visible = false;
                refuseBtn.visible = false;
                breakBtn.visible = false;
                cancleBtn.visible = true;
            }else{
                nameText.text = friendInfo.nickName;
                stateText.text = "邀请与您语音通话";
                acceptBtn.visible = true;
                refuseBtn.visible = true;
                cancleBtn.visible = false;
                breakBtn.visible = false;
            }
            voiceChatWindow.visible = true;
        }

        HeadNormal{
            id:head;
            x:(parent.width - width) / 2;
            y:30;
        }
        Text{
            id:nameText;
            anchors.horizontalCenter: head.horizontalCenter;
            anchors.top: head.bottom;
            anchors.topMargin: 20;
            text: voiceChatWindow.nameValue;
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            font.pointSize: 25;
            color: "red";
        }

        Text{
            id:stateText;
            anchors.horizontalCenter: head.horizontalCenter;
            anchors.top:nameText.bottom;
            anchors.topMargin: 20;
            text:voiceChatWindow.stateValue;
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            font.pointSize: 15;
            color: "red";
        }
        MediaButton{
            id:acceptBtn;
            color: "#00cc99";
            anchors.top:stateText.bottom;
            anchors.topMargin: 20;
            anchors.left: parent.left;
            anchors.leftMargin: 50;
            source: "qrc:/icon/icon/connect.png";
            onClick: {
                stateText.text = "正在连接...";
                //这里需要改成动画
                cancleBtn.visible = false;
                acceptBtn.visible = false;
                refuseBtn.visible = false;
                breakBtn.visible = true;
                interactionCenter.accepteVoiceRequest(userData.stuId, voiceChatWindow.stuId);
            }
        }
        MediaButton{
            id:refuseBtn;
            color:"#FF6666";
            anchors.top:acceptBtn.top;
            anchors.right: parent.right;
            anchors.rightMargin: 50;
            source:"qrc:/icon/icon/disconnect.png";
            onClick: {
                interactionCenter.refuseVoiceChat(userData.stuId, voiceChatWindow.stuId);
                voiceChatWindow.visible = false;
            }
        }
        MediaButton{
            id:cancleBtn;
            color:"#FF6666";
            anchors.horizontalCenter: head.horizontalCenter;
            anchors.top:refuseBtn.top;
            source:"qrc:/icon/icon/disconnect.png";
            onClick: {
                voiceChatWindow.visible = false;
                //发送信号，取消语音聊天；
                interactionCenter.cancleVoiceRequest(userData.stuId, voiceChatWindow.stuId);
            }
        }
        MediaButton{
            id:breakBtn;
            color:"#FF6666";
            anchors.horizontalCenter: head.horizontalCenter;
            anchors.top:refuseBtn.top;
            source:"qrc:/icon/icon/disconnect.png";
            visible: false;
            onClick: {
                interactionCenter.breakVoiceChat(userData.stuId, voiceChatWindow.stuId);
            }
        }
    }
}
