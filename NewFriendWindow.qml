import QtQuick 2.7
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4

Rectangle {
    id:container
    anchors.fill: parent;
    visible: false;
    color:"#00000000";
    property var resultValue: null;
    MouseArea{
        id:emptyArea;
        anchors.fill: parent;
        propagateComposedEvents: true;
        onClicked: {
            infoText.visible = false;
            line.visible = false;
            inputText.text = "";
            busyBox.running = false;
            resultValue = null;
            addInfoText.visible = false;
            closeAni.start();
            mouse.accepted = false;
        }
    }

    Rectangle{
        id:mainRec;
        height:260;
        width: 450;
        anchors.top:parent.top;
        anchors.horizontalCenter: parent.horizontalCenter;
        border.width: 1;
        border.color: "#ccffffff";
        radius: 5;
        color:"#ECECEC";
        MouseArea{
            id:mainArea;
            anchors.fill: parent;
            onClicked: {
                mouse.accepted = true;
            }
        }
        Rectangle{
            id:childRec;
            width:parent.width - 40;
            height:parent.height -70;
            anchors.horizontalCenter: parent.horizontalCenter;
            anchors.top:parent.top;
            anchors.topMargin: 20;
            color:"#E3E3E3";
            radius:5;
            Text{
                id: headText;
                anchors.top:parent.top;
                anchors.topMargin: 15
                anchors.left: parent.left;
                anchors.leftMargin: 10;
                width: 150;
                height:mainRec.height / 13;
                text: "通过账号查找联系人";
            }
            Rectangle{
                id:searchText;
                anchors.top: headText.bottom;
                anchors.topMargin: 10;
                anchors.left: parent.left;
                anchors.leftMargin: 10;
                height:mainRec.height / 13;
                width: parent.width * 0.75;
                radius: 2;
                property alias text: inputText.text;
                TextInput{
                    id:inputText;
                    anchors.fill: parent;
                    anchors.leftMargin: 10
                    maximumLength: 16;
                    selectByMouse: true;
                    selectionColor: "#DCDCDC"
                    clip:true;
                    verticalAlignment: Text.AlignVCenter;
                    validator:  RegExpValidator{regExp: /[0-9]+/}
                }
            }

            Rectangle{
                id:searchBtn;
                width:70;
                height: mainRec.height / 13;
                color : "#4390F6";
                anchors.right: parent.right;
                anchors.rightMargin: 10;
                anchors.top:searchText.top;
                radius: 4;
                Text{
                    anchors.centerIn: parent;
                    color: "white";
                    text:"查 找";
                }
                MouseArea{
                    anchors.fill: parent;
                    onClicked: {
                        if(inputText.text.trim() === ""){
                            return;
                        }
                        addInfoText.visible = false;
                        resultValue = null;
                        busyBox.running = true;
                        interactionCenter.searchUser(inputText.text.trim());
                    }
                    onPressed: searchBtn.opacity = 0.7;
                    onReleased: searchBtn.opacity = 1;
                }
            }
            Rectangle{
                id:line;
                width:parent.width;
                height:1;
                color:"#aaa";
                anchors.top:searchBtn.bottom;
                anchors.topMargin: 30;
            }
            Image {
                id: headImage;
                anchors.top:line.bottom;
                anchors.topMargin: 25;
                anchors.left: parent.left;
                anchors.leftMargin: 120;
                width:parent.height -140;
                height:parent.height - 140;   //190
                source: resultValue == null ? "qrc:/icon/icon/head-default.jpg" : resultValue.headPic;
                visible:resultValue != null
            }
            Text{
                id:nameText;
                text:resultValue == null ? "default(0000000000)" : resultValue.nickName + "(" + resultValue.stuId + ")";
                width: 200;
                height: 15;
                anchors.left: headImage.right;
                anchors.leftMargin: 10;
                anchors.top:headImage.top;
                elide: Text.ElideRight;
                visible:resultValue != null
            }
            Text{
                id:sexText;
                text:resultValue == null ? "男" : resultValue.sex;
                width: 40;
                height: 15;
                anchors.left: headImage.right;
                anchors.leftMargin: 10;
                anchors.top:nameText.bottom;
                anchors.topMargin: 5;
                elide: Text.ElideRight;
                visible:resultValue != null
            }
            Text{
                id:personText;
                text:resultValue == null ? "默认个个性签名😂 🤣 🤣" : resultValue.declaration;
                width: 200;
                height: 20;
                anchors.left: headImage.right;
                anchors.leftMargin: 10;
                anchors.top:sexText.bottom;
                anchors.topMargin: 5;
                elide: Text.ElideRight;
                visible: resultValue != null
            }
            BusyIndicator{
                id:busyBox;
                anchors.top:line.bottom;
                height:50;
                width:50;
                running: false;
                anchors.topMargin: 25;
                anchors.horizontalCenter: parent.horizontalCenter;
                style: BusyIndicatorStyle {
                    indicator: Image {
                        visible: control.running
                        source: "qrc:/icon/icon/loading.png"
                        RotationAnimator on rotation {
                            running: control.running
                            loops: Animation.Infinite
                            duration: 1000
                            from: 0 ; to: 360
                        }
                    }
                }
            }

            Text{
                id: infoText;
                height:40;
                horizontalAlignment: Text.AlignHCenter
                width:60;
                anchors.horizontalCenter: parent.horizontalCenter;
                anchors.top:line.bottom;
                anchors.topMargin: 40;
                visible: false;
            }
        }
        Rectangle{
            id:titleRec;
            width:80;
            height:parent.height - 250;
            anchors.horizontalCenter: parent.horizontalCenter;
            anchors.top:parent.top;
            anchors.topMargin: 10;
            radius: 4;
            color:"#4893F6";
            Text{
                text:"添加联系人";
                font.pointSize: 13
                anchors.centerIn: parent;
                color: "white";
            }
        }
        Text{
            id:addInfoText;
            height:20;
            horizontalAlignment: Text.AlignHCenter
            width:60;
            anchors.horizontalCenter: parent.horizontalCenter;
            anchors.bottom: parent.bottom;
            anchors.bottomMargin: 20;
            visible: false;
        }
        Rectangle{
            id:addBtn;
            width:70;
            height: mainRec.height / 13;
            color : resultValue == null ? "#E3E3E3" :"#4390F6";
            anchors.right: parent.right;
            anchors.rightMargin: 10;
            anchors.bottom: parent.bottom;
            anchors.bottomMargin: 20;
            radius: 4;
            Text{
                anchors.centerIn: parent;
                color: "white";
                text:"添 加";
            }
            MouseArea{
                anchors.fill: parent;
                enabled: resultValue != null;
                onClicked: {
                    var id = JSON.parse(loginController.getUser()).stuId;
                    interactionCenter.addUser(id, resultValue.stuId);
                }
                onPressed: addBtn.opacity = 0.7;
                onReleased: addBtn.opacity = 1;
            }
        }

    }

    Connections{
        target: interactionCenter;
        onSearchUserResult:{
            busyBox.running = false;
            var result = JSON.parse(msg);
            if(result.code !== 0){
                infoText.text = result.msg;
                infoText.visible = true;
                return;
            }
            infoText.visible = false;
            resultValue = result.msg;
        }
        onAddFriendResult:{
            var result = JSON.parse(msg);
            addInfoText.text = result.msg;
            addInfoText.visible = true;
        }
    }

    NumberAnimation {
        id:closeAni
        target: mainRec
        property: "height"
        duration: 500;
        from:260;
        to: 0;
        easing.type: Easing.InOutQuad
        onStopped: {
            container.visible = false;
        }
    }

    NumberAnimation {
        id:openAni
        target: mainRec
        property: "height"
        duration: 500;
        from:0;
        to: 270;
        easing.type: Easing.InOutQuad
        onStopped: {
            line.visible = true;
        }
    }
    onVisibleChanged: {
        if(visible == true)
            openAni.start();
    }
}
