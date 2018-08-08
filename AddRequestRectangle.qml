import QtQuick 2.0

Rectangle {
    id:container;
    signal showUserInfo(var userInfo);
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
            text:"好友验证消息";
        }
    }
    ListView{
        id:requestList;
        anchors.top:titleRec.bottom;
        anchors.topMargin: 20;
        anchors.bottom: parent.bottom;
        anchors.bottomMargin: 20;
        width:parent.width;
        anchors.left: parent.left;
        anchors.leftMargin: 20;
        clip: true;
        model:requestModel;
        delegate: delegate;
        spacing: 50;
    }
    ListModel{
        id:requestModel
    }
    Component{
        id:delegate;
        Rectangle{
            id:rec;
            height:75;
            width:ListView.view.width - 40;
            border.color: "#f0f0f0";
            border.width: 1;
            radius: 5;
            HeadNormal{
                id:headImg;
                width: 35;
                height:35;
                anchors.verticalCenter: parent.verticalCenter;
                anchors.left: parent.left;
                anchors.leftMargin: 30;
                source:headPic;
                cursorShape: Qt.OpenHandCursor;
                onClicked: showUserInfo(requestModel.get(index));
            }
            Text{
                id:nameText;
                anchors.left: headImg.right;
                anchors.leftMargin: 10;
                anchors.verticalCenter: parent.verticalCenter;
                text:nickName + "(" + stuId + ")"
                color:"#4DB3ED";
                MouseArea{
                    anchors.fill: parent;
                    cursorShape: Qt.OpenHandCursor;
                    onClicked: {
                        showUserInfo(requestModel.get(index));
                    }
                }
            }
            Text{
                id:info;
                anchors.left: nameText.right;
                anchors.leftMargin: 10;
                anchors.verticalCenter: parent.verticalCenter;
                text:"请求加为好友";
            }
            Rectangle{
                id:refuseBtn;
                width:50;
                height: 20;
                color : "#4390F6";
                anchors.right: parent.right;
                anchors.rightMargin: 10;
                anchors.verticalCenter: parent.verticalCenter;
                radius: 4;
                visible: complete == 0;
                Text{
                    anchors.centerIn: parent;
                    color: "white";
                    text:"拒 绝";
                }
                MouseArea{
                    anchors.fill: parent;
                    onClicked: {
                        var id = requestModel.get(index).id
                        var value = {"id":id, "operation":0}
                        interactionCenter.modifyAddRequestState(JSON.stringify(value))
                    }
                    onPressed: refuseBtn.opacity = 0.7;
                    onReleased: refuseBtn.opacity = 1;
                }
            }
            Rectangle{
                id:acceptBtn;
                width:50;
                height: 20;
                color : "#4390F6";
                anchors.right: refuseBtn.left;
                anchors.rightMargin: 10;
                anchors.verticalCenter: parent.verticalCenter;
                radius: 4;
                visible: complete == 0 ;
                Text{
                    anchors.centerIn: parent;
                    color: "white";
                    text:"接 受";
                }
                MouseArea{
                    anchors.fill: parent;
                    onClicked: {
                        var id = requestModel.get(index).id;
                        var value = {"id":id, "operation":1}
                        interactionCenter.modifyAddRequestState(JSON.stringify(value))
                    }
                    onPressed: acceptBtn.opacity = 0.7;
                    onReleased: acceptBtn.opacity = 1;
                }
            }
            Text{
                id:stateText;
                anchors.right:parent.right;
                anchors.rightMargin: 10;
                anchors.verticalCenter:  parent.verticalCenter;
                color: "#CCCFD7";
                text:isRead == 1 ? "已接受" :"已拒绝";
                visible: complete == 1
            }

        }
    }
    Component.onCompleted: {
        var id = JSON.parse(loginController.getUser()).stuId;
        interactionCenter.getAddRequest(id);
    }

    Connections{
        target: interactionCenter
        onAllAddRequest:{
            var requestList = JSON.parse(msg);
            for(var i = 0; i < requestList.length ; i++){
                requestModel.append(requestList[i]);
            }
        }
        onModifyAddRequestStateResult:{
            var response = JSON.parse(msg);
            if(response.code !== 0){
                return;
            }
            var id = response.id;
            for(var i = 0; i < requestModel.count ; i++){
                var item =requestModel.get(i);
                if(item.id === id){
                    requestModel.get(i).isRead = response.operation;
                    requestModel.get(i).complete = 1;
                    break;
                }
            }
        }
        onNewAddRequest:{
            var info = JSON.parse(msg);
            requestModel.insert(0, info);
        }
    }
}
