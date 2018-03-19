import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Controls 1.2
Rectangle {
    id:container;
    anchors.fill: parent;
    color:"#00000000";
    visible: true;
    property var userInfo:  null
    MouseArea{
        id:emptyArea;
        anchors.fill: parent;
        propagateComposedEvents: true;
        onClicked: {
            mouse.accepted = true;
        }
    }
    function init(user) {
        userInfo = user;
        mainRec.x = 300;
        mainRec.y = 100;
        line1.visible = false;
        line2.visible = false;
        nameText.readOnly = true;
        signatureText.readOnly = true;
        editBtn.visible = true;
        sexText.enabled = false;
        dateBtn.visible = false;
    }

    function updateUserInfo(user){
        userInfo = user;
        line1.visible = false;
        line2.visible = false;
        nameText.readOnly = true;
        signatureText.readOnly = true;
        editBtn.visible = true;
        sexText.enabled = false;
        dateBtn.visible = false;
    }

    Rectangle{
        id:mainRec;
        height: 420;
        width: 300;
        x:300;
        y:100;
        border.width: 1;
        border.color: "#DCDCDC";
        radius: 5;
        color:"#ffffff";
        Image{
            id:backImg;
            width:parent.width;
            height:160;
            anchors.top:parent.top;
            source:"qrc:/icon/icon/personal-back3.jpg";
            visible: true;
        }

        Text{
            id:editBtn;
            text:"编辑";
            font.pointSize: 15
            color:editArea.containsMouse ? "#5BC5F2" : "#ffffff";
            anchors.horizontalCenter: parent.horizontalCenter;
            anchors.bottom: backImg.bottom;
            MouseArea{
                id:editArea;
                hoverEnabled: true;
                anchors.fill: parent;
                onClicked: {
                    editBtn.visible = false;
                    line1.visible = true;
                    line2.visible = true;
                    nameText.readOnly = false;
                    signatureText.readOnly = false;
                    sexText.enabled = true;
                    dateBtn.visible = true;
                }
            }
        }
        Text{
            id:submitBtn;
            text:"完成";
            font.pointSize: 15
            color:submitArea.containsMouse ? "#5BC5F2" : "#ffffff";
            anchors.horizontalCenter: parent.horizontalCenter;
            anchors.bottom: backImg.bottom;
            visible: !editBtn.visible
            MouseArea{
                id:submitArea;
                hoverEnabled: true;
                anchors.fill: parent;
                onClicked: {
                    if(nameText.text.trim() === ""){
                        return;
                    }
                    var newObj = JSON.parse(JSON.stringify(userInfo));
                    newObj.nickName = nameText.text;
                    newObj.sex = sexText.currentText;
                    newObj.declaration = signatureText.text;
                    var timeStr = birthText.text;
                    var dateArr = timeStr.split("-");
                    if(dateArr[1].length === 1){
                        dateArr[1] = "0" + dateArr[1];
                    }
                    if(dateArr[2].length === 1){
                        dateArr[2] = "0" + dateArr[2];
                    }
                    var str = dateArr[0] + "-" + dateArr[1] + "-" + dateArr[2];
                    console.log(str);
                    newObj.birthday = (new Date(str)).getTime();
                    console.log(JSON.stringify(newObj))
                    interactionCenter.updatePersonalInfo(JSON.stringify(newObj));
                }
            }
        }

        HeadNormal{
            id:headImg;
            source: userInfo == null ? "qrc:/icon/icon/head-default.jpg" : userInfo.headPic;
            anchors.horizontalCenter: parent.horizontalCenter;
            y:-20;
        }

        Text{
            id:bigNameText;
            text:userInfo == null ? "丷熊大" : userInfo.nickName;
            font.family: "Hannotate SC"
            font.bold: true
            font.pointSize: 25
            verticalAlignment: Text.AlignBottom
            anchors.left: parent.left;
            anchors.leftMargin: 20;
            anchors.top: backImg.bottom;
            anchors.topMargin: 30;
            elide: Text.ElideRight;
            maximumLineCount: 10;
            //width:100;
            height:15;
        }
        Text{
            id:bigDescText
            anchors.left: bigNameText.left;
            anchors.leftMargin: 20
            anchors.top: bigNameText.bottom;
            anchors.topMargin: 5;
            anchors.right: parent.right;
            anchors.rightMargin: 20;
            font.family: "Hannotate SC";
            elide: Text.ElideRight;
            text:userInfo == null ?"你还是删了我吧 不然我总是想和你说话--------------" : userInfo.declaration;
            MouseArea{
                id:descArea;
                hoverEnabled: true;
                anchors.fill: parent;
            }
        }
        ToolTip{
            id: descTip;
            x:bigDescText.x + bigDescText.height;
            y:bigDescText.y + bigDescText.height;
            text:bigDescText.text;
            visible: descArea.containsMouse
        }

        Rectangle{
            id:line;
            width:parent.width-40;
            height: 1;
            anchors.horizontalCenter: parent.horizontalCenter;
            anchors.top:bigDescText.bottom;
            anchors.topMargin: 15;
            color:"#474747"
        }
        //
        Text{
            id:idT;
            text:"用户";
            anchors.left: parent.left;
            anchors.leftMargin: 20;
            anchors.top:line.bottom;
            anchors.topMargin: 15;
            color:"#DCDCDC"
        }
        Text{
            id: idText;
            text:userInfo == null ? "14310320631" : userInfo.stuId;
            anchors.left: idT.right;
            anchors.leftMargin: 10
            anchors.top:idT.top;
        }
        //
        Text{
            id:nameT;
            anchors.left: idT.left;
            anchors.top:idT.bottom;
            anchors.topMargin: 10;
            color:"#DCDCDC";
            text:"昵称";
        }
        TextInput{
            id:nameText;
            anchors.left: nameT.right
            anchors.leftMargin: 10;
            anchors.top:nameT.top;
            anchors.right: parent.right;
            anchors.rightMargin: 20;
            height:20
            clip: true;
            selectByMouse: true;
            text:userInfo == null ? "丷熊大" : userInfo.nickName;
        }
        Rectangle{
            id:line1
            height:1;
            color:"#C0C0C0";
            anchors.left: nameText.left;
            anchors.right: nameText.right;
            anchors.top: nameText.bottom;
            //anchors.topMargin: 2;
        }
        Text{
            id:sexT;
            anchors.left: idT.left;
            anchors.top:nameT.bottom;
            anchors.topMargin: 10;
            color:"#DCDCDC";
            text:"性别";
        }

        ComboBox{
            id:sexText;
            anchors.left: sexT.right
            anchors.leftMargin: 10;
            anchors.top:sexT.top;
            currentIndex: userInfo == null ? 0 :(userInfo.sex === "男" ? 0 :1)
            model:ListModel{
                ListElement{
                    text:"男";
                }
                ListElement{
                    text:"女"
                }
            }
        }

        Text{
            id:signatureT;
            anchors.left: idT.left;
            anchors.top:sexT.bottom;
            anchors.topMargin: 10;
            color:"#DCDCDC";
            text:"签名";
        }
        TextInput{
            id:signatureText;
            anchors.left: signatureT.right
            anchors.leftMargin: 10;
            anchors.top:signatureT.top;
            anchors.right: parent.right;
            anchors.rightMargin: 20;
            height:20;
            clip: true;
            selectByMouse: true;
            text:userInfo == null ? "你还是删了我吧 不然我总是想和你说话--------------" : userInfo.declaration;
        }
        Rectangle{
            id:line2
            height:1;
            color:"#C0C0C0";
            anchors.left: signatureText.left;
            anchors.right: signatureText.right;
            anchors.top: signatureText.bottom;
            //anchors.topMargin: 2;
        }
        Text{
            id:birthT;
            anchors.left: idT.left;
            anchors.top:signatureT.bottom;
            anchors.topMargin: 10;
            color:"#DCDCDC";
            text:"生日";
        }
        //interactionCenter.getDateString(timeStamp / 1000, "yyyy-MM-dd");
        TextInput{
            id:birthText;
            anchors.left: birthT.right
            anchors.leftMargin: 10;
            anchors.top:birthT.top;
            height:20;
            clip: true;
            readOnly: true;
            selectByMouse: true;
            text:userInfo == null ?
                     "1994-12-20" :
                     interactionCenter.getDateString(userInfo.birthday / 1000, "yyyy-MM-dd");
        }
        Rectangle{
            id:dateBtn;
            width: 20;
            height:15;
            anchors.left: birthText.right;
            anchors.leftMargin: 15;
            anchors.bottom: birthText.bottom;
            anchors.bottomMargin: 3;
            border.color: "#000000";
            border.width: 1;
            Text{
                anchors.centerIn: parent;
                text:"..";
            }
            MouseArea{
                anchors.fill: parent;
                onClicked: {
                    dateChooser.visible = true;
                }
            }
        }
        Calendar{
            id: dateChooser;
            x:dateBtn.x + dateBtn.width;
            y:dateBtn.y - height;
            visible: false;
            onClicked: {
                var str = selectedDate.getFullYear() + "-" + (selectedDate.getMonth()+1) + "-" + selectedDate.getDate()
                //var str = visibleYear + "-" + visibleMonth + "-" + dayOfWeekFormat
                birthText.text = str;
                visible = false;
            }
        }

        //titleBar
        Rectangle{
            id:titleBar;
            width:parent.width;
            height:30;
            anchors.top: parent.top;
            anchors.left: parent.left;
            color:"#00000000"
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
                    mainRec.x = mainRec.x+delta.x;
                    mainRec.y = mainRec.y+delta.y;
                }
            }
            Rectangle{
                id:closeBtn;
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left;
                anchors.leftMargin: 8;
                width:13;
                height:13;
                radius: 10;
                color:"#FF6666";
                Image{
                    id:closeImg;
                    anchors.fill: parent;
                    anchors.margins: 3;
                    source: "qrc:/icon/icon/chat-close.png";
                    visible: closeArea.containsMouse;
                }
                MouseArea{
                    id:closeArea;
                    hoverEnabled: true;
                    anchors.fill: parent;
                    onClicked: container.visible = false;
                }
            }
        }
    }
}
