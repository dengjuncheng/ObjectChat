import QtQuick 2.0

Rectangle {
    id:container;
    property var friendData;
    signal sendMsg(var friendInfo);
    onFriendDataChanged: {
        nameText.text = friendData.nickName;
        sexImg.source = friendData.sex === '女' ? "qrc:/icon/icon/woman.png" : "qrc:/icon/icon/man.png"
        declaText.text = friendData.declaration;
        headPic.source = friendData.headPic;
        birthText.text = getDateString(friendData.birthday);
        lastLoginText.text = getDateString(friendData.lastestLogin);
        stateText.text = friendData.isOnline ? "在线" : "离线";
        stateText.color = friendData.isOnline ? "#43CD80" : "black";
        introductionText.text = friendData.personalIntroduction;
    }
    function getDateString(timeStamp){
        if(timeStamp === null || timeStamp === 0){
            return "";
        }
        return interactionCenter.getDateString(timeStamp / 1000, "yyyy-MM-dd");
    }

    function readyToSend(){
        sendMsg(friendData);
    }

    //分割线
    Rectangle{
        id:line;
        color:"#aaa"
        width:parent.width - 140;
        height:1;
        anchors.horizontalCenter: parent.horizontalCenter;
        anchors.top:parent.top;
        anchors.topMargin: 150;
    }

    Text{
        id:nameText;
        anchors.left: line.left;
        anchors.bottom: line.top;
        anchors.bottomMargin: 50;
        text:"王柔璇";
        font.bold: true;
        font.pixelSize: 30;
    }
    Image{
        id:sexImg;
        source:"qrc:/icon/icon/woman.png";
        anchors.left: nameText.right;
        anchors.leftMargin: 5;
        anchors.bottom: nameText.bottom;
        anchors.bottomMargin: 4;
        width:27;
        height:27;
    }

    Text{
        id:declaText;
        anchors.left: line.left;
        anchors.top:nameText.bottom;
        anchors.topMargin: 10;
        color:"#aaa";
        text:"但我不懂说将来";
    }
    Image{
        id:headPic;
        anchors.right: line.right;
        anchors.bottom: line.top;
        anchors.bottomMargin: 15;
        width:75;
        height:75;
        source:"qrc:/icon/icon/head-default.jpg";
    }

    Text{
        id:birthT;
        anchors.left: line.left;
        anchors.top: line.bottom;
        anchors.topMargin: 20;
        color:"#aaa";
        text:"生 日";
    }
    Text{
        id:birthText;
        anchors.left: birthT.right;
        anchors.leftMargin: 15;
        anchors.bottom: birthT.bottom;
        text:"1994-12-20";
    }
    Text{
        id:lastLoginT;
        anchors.left: line.left;
        anchors.top:birthT.bottom;
        anchors.topMargin: 10;
        text:"最 近";
        color:"#aaa";
    }
    Text{
        id:lastLoginText;
        anchors.left: lastLoginT.right;
        anchors.leftMargin: 15;
        anchors.bottom: lastLoginT.bottom;
        text:"2019-12-21";
    }
    Text{
        id:stateT;
        anchors.left: line.left;
        anchors.top: lastLoginT.bottom;
        anchors.topMargin: 10;
        text:"状 态";
        color:"#aaa";
    }

    Text{
        id:stateText;
        anchors.left: stateT.right;
        anchors.leftMargin: 15;
        anchors.bottom: stateT.bottom;
        text:"在线";
    }

    Text{
        id:introductionT;
        anchors.left: line.left;
        anchors.top: stateT.bottom;
        anchors.topMargin: 10;
        text:"说 明";
        color:"#aaa";
    }
    TextEdit{
        id:introductionText;
        width:199;
        anchors.left: introductionT.right;
        anchors.leftMargin: 15;
        anchors.top:introductionT.top;
        wrapMode: TextEdit.Wrap;
        enabled: false;
        text:""
    }

    //发送信息按钮
    Rectangle{
        id:sendBtn;
        anchors.horizontalCenter: parent.horizontalCenter;
        anchors.top:introductionText.bottom;
        anchors.topMargin: 40;

        color:"#43CD80";
        height:45;
        width:135;
        radius: 5;
        Text{
            anchors.centerIn: parent;
            color:"white";
            text:"发消息";
            font.pixelSize: 15;
        }
        MouseArea{
            id:mouseArea;
            anchors.fill: parent;
            onPressed: sendBtn.color = "#3CB371";
            onReleased: sendBtn.color = "#43CD80";
            onClicked: sendMsg(friendData);
        }
    }

}
