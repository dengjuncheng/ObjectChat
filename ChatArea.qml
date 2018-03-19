import QtQuick 2.5
import QtQuick.Layouts 1.3
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4

Rectangle{
    id:container;
    property var friendData: null;
    property var userData;
    signal lastMsgChanged(var msg);
    signal emojiClick();
    color:"#F5F5F5";
    visible: friendData != null;
    function arriveToBotton(){
        chatList.positionViewAtEnd();
    }

    Component.onCompleted: {
        userData = JSON.parse(loginController.getUser());
    }

    onFriendDataChanged: {
        if(friendData === null){
            return;
        }

        chatModel.clear();
        //加载聊天记录;
        var userId = userData.stuId;
        var friendId = friendData.stuId;
        var chatRecord = interactionCenter.getChatRecordByUserId(userId, friendId);
        var chatJson = JSON.parse(chatRecord);
        var chatSize = chatJson.length;
        for(var i = 0 ; i < chatSize ; i++)
        {
            chatModel.append(chatJson[i]);
            if(chatJson[i].isRead === false && chatJson[i].direction === false){
                interactionCenter.msgStateChanged(chatJson[i].uuid);
            }
        }
    }

    /**
      *添加emoji到文本框
      *
      **/
    function appendEmoji(value){
        inputText.insert(inputText.cursorPosition,value + " ");
        //inputText.append(value);
    }

    //标题
    Rectangle{
        id:titleRec;
        height:53;
        width:parent.width;
        anchors.left: parent.left;
        anchors.top:parent.top;
        color: "#f0f0f0";
        Text{
            id:titleText;
            anchors.left: parent.left;
            anchors.leftMargin: 20;
            anchors.verticalCenter: parent.verticalCenter;
            font.bold: true;
            font.pixelSize: 17;
            text:friendData === null ? "" : friendData.nickName;
        }
    }

    //外层输入框
    Rectangle{
        id:inputRec;
        anchors.bottom: parent.bottom;
        anchors.left: parent.left;
        height: 159;
        width:parent.width;
        border.color: "#DCDCDC";
        border.width: 0.5;
        color:"#F5F5F5";
        RowLayout{
            id:utilsRow;
            anchors.top:parent.top;
            anchors.topMargin: 10;
            anchors.left: parent.left;
            anchors.leftMargin: 20;
            width:200;
            height:30;
            UtilButton{
                id:iconBtn;
                Layout.fillWidth: true
                Layout.minimumWidth: 20
                Layout.preferredWidth: 20
                Layout.maximumWidth: 20
                Layout.minimumHeight: 20
                pressSource: "qrc:/icon/icon/emoji-btn-2.png";
                normalSource:"qrc:/icon/icon/emoji-btn-1.png";
                onClicked: emojiClick();
            }
            UtilButton{
                id:fileBtn;
                Layout.fillWidth: true
                Layout.minimumWidth: 20
                Layout.preferredWidth: 20
                Layout.maximumWidth: 20
                Layout.minimumHeight: 20
                pressSource: "qrc:/icon/icon/file-btn-2.png";
                normalSource:"qrc:/icon/icon/file-btn-1.png";
            }
            UtilButton{
                id:cutBtn;
                Layout.fillWidth: true
                Layout.minimumWidth: 20
                Layout.preferredWidth: 20
                Layout.maximumWidth: 20
                Layout.minimumHeight: 20
                pressSource: "qrc:/icon/icon/cut-btn-2.png";
                normalSource:"qrc:/icon/icon/cut-btn-1.png";
                onClicked: {
                    interactionCenter.capture();
                }
                Connections{
                    target: interactionCenter
                    onSignalCompleteCature:{
                        var text = "<img src='"+filePath+"' height ='50' />"
                        inputText.append(text);
                        chatWindow.requestActivate();
                        requestActivate();
                    }
                }
            }
            UtilButton{
                id:phoneBtn;
                Layout.fillWidth: true
                Layout.minimumWidth: 20
                Layout.preferredWidth: 20
                Layout.maximumWidth: 20
                Layout.minimumHeight: 20
                pressSource: "qrc:/icon/icon/phone-btn-2.png";
                normalSource:"qrc:/icon/icon/phone-btn-1.png";
                onClicked: {
                    interactionCenter.readyVoiceChat(userData.stuId, friendData.stuId);
                }
            }
            UtilButton{
                id:videoBtn;
                Layout.fillWidth: true
                Layout.minimumWidth: 20
                Layout.preferredWidth: 20
                Layout.maximumWidth: 20
                Layout.minimumHeight: 20
                pressSource: "qrc:/icon/icon/video-btn-2.png";
                normalSource:"qrc:/icon/icon/video-btn-1.png";
                onClicked: {
                    interactionCenter.voiceChatRequest("133", "223")
                }
            }
        }
        TextArea{
            id:inputText;
            width:parent.width - 40;
            height: 120;
            anchors.left: parent.left;
            anchors.leftMargin: 15;
            anchors.top:utilsRow.bottom;
            anchors.right: parent.right;
            anchors.rightMargin: 20;
            textFormat: Text.RichText;
            selectByMouse: true;
            wrapMode: TextEdit.Wrap;
            frameVisible: false;
            style: TextAreaStyle{
                selectionColor: "#6ca7f6";
                backgroundColor: "#F5F5F5";
            }
            Keys.enabled: true;
            Keys.onPressed: {
                if((event.modifiers & Qt.ShiftModifier) && event.key === 16777220){ //这里不用Qt.Key_Enter枚举值是因为枚举值与获取按键的值不一致
                    event.accepted = true;
                    inputText.append("\n");
                    return;
                }
                if(event.key === 16777220){
                    event.accepted = true;
                    if(inputText.text.toString().trim().length === 0){
                        return;
                    }
                    var text = inputText.getText(0, inputText.text.length);
                    interactionCenter.sendMsg(userData.stuId, friendData.stuId, inputText.text.toString(), text);
                    inputText.text = "";
                }
            }
        }
    }

    Connections{
        target: interactionCenter;
        onMsgHasBeenSent:{
            var jsonValue = JSON.parse(msg);
            var lastMsg = jsonValue.msg;
            jsonValue.msgType = Number(jsonValue.msgType);
            switch (jsonValue.msgType){
            case 2:
                jsonValue.msg = "<img src='file:///" + jsonValue.filePath +  "' width ='100' />";
                lastMsg = "[图片]";
            }
            lastMsgChanged(lastMsg);
            //返回来的数据有两行数据的值bool和int 变成了字符串，所以需要转换回来。
            if(jsonValue.direction === "true"){
                jsonValue.direction = true;
            }else if(jsonValue.direction === "false"){
                jsonValue.direction = false;
            }
            chatModel.append(jsonValue);
            chatList.positionViewAtEnd();
        }
    }

    ListView{
        id: chatList;
        anchors.top:titleRec.bottom;
        anchors.bottom: inputRec.top;
        width:parent.width;
        model:chatModel;
        delegate: chatDelegate;
        clip: true;
    }
    ListModel{
        id:chatModel;
    }
    Component{
        id: chatDelegate;
        Rectangle{
            id: chatRec;
            width: ListView.view.width;
            //height: msgText.lineCount * 20 + 20;//这里需要修改啊啊啊 啊啊啊啊啊
            height: msgType === 1 ? msgText.lineCount * 20 + 20 : msgText.paintedHeight + 30
            color: "#F5F5F5";
            Image{
                id:headPic;
                anchors.top: parent.top;
                anchors.topMargin: 5;
                width:30;
                height:30;
                source: "qrc:/icon/icon/head-default.jpg";
                Component.onCompleted: {
                    //通过消息的方向来设置消息的from to
                    var dir = direction;
                    if(dir){
                        anchors.left = parent.left;
                        anchors.leftMargin = 20;
                        source = userData.headPic;
                    }else{
                        anchors.right = parent.right;
                        anchors.rightMargin = 20;
                        source = friendData.headPic;
                    }
                }
            }
            Rectangle{
                anchors.top: headPic.top;
                anchors.bottom: parent.bottom;
                anchors.bottomMargin: 10;
                width:10000;
                height: parent.height;
                //color:"#90EE90";
                radius: 5;
                TextEdit{
                    id:msgText;
                    anchors.fill: parent;
                    anchors.margins: 4;
                    textFormat: Text.RichText;
                    readOnly: true;
                    wrapMode: TextEdit.WrapAnywhere;
                    selectByMouse: true;
                    baseUrl: ""
                    text:msg;
                }

                Component.onCompleted:{
                    //var paintedW = textMetrics.tightBoundingRect.width;
                    //显示聊天记录随字的长度变化而变化
                    var paintedW = msgText.paintedWidth;
                    width = paintedW > parent.width * 0.7 ? parent.width * 0.7 : paintedW + 10;
                    height = msgText.paintedHeight;
                    var dir = direction;
                    if(dir){
                        anchors.left = headPic.right;
                        anchors.leftMargin = 4;
                        color = "#ffffff";
                    }else{
                        anchors.right = headPic.left;
                        anchors.rightMargin = 4;
                        color = "#B0E36E";
                    }
                }
            }
        }
    }

}
