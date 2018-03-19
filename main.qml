import QtQuick 2.9
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
/**
  *  登录界面
  */
Window {
    id:mainwindow
    visible: true
    width: 250
    height: 320
    maximumHeight: 320
    maximumWidth: 250
    minimumHeight: 320
    minimumWidth: 250
    flags:Qt.WindowCloseButtonHint
    property bool isOpen: false;
    //保持窗口大小不变
    onActiveChanged: {
        if(!active){
            color = "#F5F5F5";
            users_rec.color = "#F5F5F5"
        }else{
            color = "#FFFFFF";
            users_rec.color = "#FFFFFF";
        }
    }
    onWidthChanged: {
        width = 250;
        height = 320;
        isOpen = false;
    }
    //整个窗口覆盖press移动窗口事件
    MouseArea{
        anchors.fill: parent;
        acceptedButtons: Qt.LeftButton;
        property point clickPos : "0,0";
        onPressed: {
            clickPos = Qt.point(mouse.x, mouse.y);
        }
        onPositionChanged: {
            var delta = Qt.point(mouse.x-clickPos.x, mouse.y-clickPos.y);
            mainwindow.setX(mainwindow.x+delta.x);
            mainwindow.setY(mainwindow.y+delta.y);
        }
    }
    //关闭按钮
    Rectangle{
        id: closeBtn;
        width: 15;
        height: 15;
        radius: 8;
        color: "#FF6347";
        anchors.left: parent.left;
        anchors.leftMargin: 5;
        anchors.top: parent.top;
        anchors.topMargin: 5;
        visible: false;
        Image{
            width:15;
            height:15;
            anchors.centerIn: parent;
            source:"qrc:/icon/icon/close.png";
            fillMode: Image.PreserveAspectFit;
        }
       MouseArea{
           anchors.fill: parent;
           onPressed: closeBtn.color = "#FF4500";
           onReleased: closeBtn.color = "#FF6347";
           onClicked: Qt.quit();
       }
    }
    //大头像
    HeadNormal{
        id: head_normal;
        width: 100;
        height: 100;
        x:75;
        y:40;
        ParallelAnimation{
            id:animation;

            NumberAnimation {
                id:xAni
                target: head_normal
                property: "x"
                duration: 500
                easing.type: Easing.InOutQuad
            }
            NumberAnimation {
                id: yAni;
                target: head_normal
                property: "y"
                duration: 500
                easing.type: Easing.InOutQuad
            }

            NumberAnimation {
                id: wAni
                target: head_normal
                property: "width"
                duration: 500
                easing.type: Easing.InOutQuad
            }

            NumberAnimation {
                id:hAni
                target: head_normal
                property: "height"
                duration: 500
                easing.type: Easing.InOutQuad
            }
            onStopped: {
                head_normal.width = 100;
                head_normal.height = 100;
                head_normal.x = 75;
                head_normal.y = 40;
                users_rec.visible = true;
                head_normal.visible = false;
            }
        }
        onClicked: {
            var num = users_rec.currentNum;
            xAni.to = 15 + num % 3 * 25 + num % 3 * 40 + 25;
            yAni.to = (num > 2 ? 60 : 10) + 30;
            wAni.to = 40;
            hAni.to = 40;
            animation.running = true;
            loginState.visible = false;
//            visible = false;
//            users_rec.visible = true;
        }
    }
    //在线状态
    OnlineState{
        id: loginState;
        width: 12;
        height: 12;
        anchors.left: parent.left;
        anchors.leftMargin: (parent.width - width) / 2;
        y: head_normal.y + head_normal.height - 4;
        onlineState: users_rec.currentData.state;
    }
    //点击登录时，旋转的圈圈
    Image{
        id:loginAnimation;
        source: "qrc:/icon/icon/login-animation.png";
        width:200;
        height:200;
        x:22;
        y:-5;
        visible: false;
        property alias running:login_ani.running;
        NumberAnimation {
            id:login_ani
            target: loginAnimation
            property: "rotation";
            duration: 700
            easing.type: Easing.Linear
            loops: -1;
            from: 0;
            to:360;
        }
    }
    //所有用户的Rectangle
    Rectangle{
        id:users_rec
        height: 150;
//        border.color: "red";
//        border.width: 1;
        width:200;
        anchors.left: parent.left;
        anchors.leftMargin: (parent.width - width) / 2;
        anchors.top: closeBtn.bottom;
        anchors.topMargin: 10;
        property var currentData;
        property var objs:[];
        property int currentNum: 0;
        Component.onCompleted: {
            model.clear();
            model.append(JSON.parse(loginController.getTopFiveUsers()));
            loadData();
            users_rec.visible = false;
            currentData = model.get(0);
            head_normal.source = currentData.headPic;
        }
        //存储数据的model
        ListModel{
            id:model;
        }
        //组件加载完成时加载数据
        function loadData(){
            model.append({"headPic":"qrc:/icon/icon/add.png","nickName":"default","stuId":"","password":"","remenberPass":0});
            var comp = Qt.createComponent("HeadSmall.qml");
            for(var i = 0 ; i < model.count ; i++){
                var x = 15 + i % 3 * 25 + i % 3 * 40;
                var y = i > 2 ? 60 : 10;
                var obj = comp.createObject(users_rec, {"source":model.get(i).headPic,"x":x,"y":y,"userData":model.get(i),"order_number":i});
                obj.clicked.connect(onSmallHeadClick);
                obj.deleteClicked.connect(onDeleteClicked);
                objs.push(obj);
            }
        }

        function onSmallHeadClick(order_num){
            currentData = model.get(order_num);
            head_normal.source = currentData.nickName === "default" ? "qrc:/icon/icon/head-default.jpg" : currentData.headPic;
            currentNum = order_num;
            users_rec.visible = false;
            head_normal.visible = true;
            loginState.visible = true;
        }
        function onDeleteClicked(order){
            var size = model.count;
            for(var i = order+1 ; i < size ; i++){
                var x = 15 + (i-1) % 3 * 25 + (i-1) % 3 * 40;
                var y = (i-1) > 2 ? 60 : 10;
                objs[i].x = x;
                objs[i].y = y;
                objs[i].order_number = i-1;
            }
            loginController.removeByStuId(model.get(order).stuId);
            objs[order].destroy();
            model.remove(order);
            currentData = model.get(0);
            currentNum = 0;
        }
    }

    //用户名输入框
    TextInput{
        id:userNameText;
        height :30;
        width: 200;
        anchors.top: parent.top;
        anchors.topMargin: 185;
        anchors.left: parent.left;
        anchors.leftMargin: 25
        anchors.right: parent.right;
        anchors.rightMargin: 25;
        font.pixelSize: 20;
        selectByMouse: true;
        selectionColor: "#DCDCDC"
        clip:true;
        verticalAlignment: Text.AlignVCenter;
        text: users_rec.currentData.stuId;
        property string placeholderText: "输入账号"
        validator:  RegExpValidator{regExp: /[0-9]+/}

        Text {
            text: userNameText.placeholderText;
            color: "#aaa";
            visible: !userNameText.text
            anchors.fill: parent;
            verticalAlignment: Text.AlignVCenter;
            font.pixelSize: 15;
        }
    }
    //分割线
    Rectangle{
        height:1;
        width:200;
        anchors.top:userNameText.bottom;
        anchors.topMargin: 8;
        anchors.left: parent.left;
        anchors.leftMargin: 25;
        color: "#aaa";
    }
    //密码输入框
    TextInput{
        id:passwordText;
        height :30;
        width: 160;
        anchors.top: userNameText.bottom;
        anchors.topMargin: 13;
        anchors.left: parent.left;
        anchors.leftMargin: 25
        font.pixelSize: 20;
        selectByMouse: true;
        selectionColor: "#DCDCDC"
        clip:true;
        verticalAlignment: Text.AlignVCenter;
        echoMode: TextInput.Password;
        text: users_rec.currentData.remenberPass === 1 ? users_rec.currentData.password : "";
        property string placeholderText: "输入密码";

        Text {
            text: passwordText.placeholderText;
            color: "#aaa";
            visible: !passwordText.text
            anchors.fill: parent;
            verticalAlignment: Text.AlignVCenter;
            font.pixelSize: 15;
        }
    }

    //登录按钮
    Rectangle{
        id:loginBtn;
        width:25;
        height:25;
        anchors.left: passwordText.right;
        anchors.leftMargin: 12
        anchors.top: passwordText.top;
        anchors.topMargin: 3;
        //opacity: loginMa.containsMouse ? 0.8 : 0.6;
        color: "#00000000";
//        border.color: "red";
//        border.width: 1;
        Image{
            id:loginImg;
            anchors.fill: parent;
            source: "qrc:/icon/icon/login-btn2.png";
        }
        MouseArea{
            id:loginMa;
            anchors.fill:parent;
            hoverEnabled: true;
            onEntered: loginImg.source = "qrc:/icon/icon/login-btn3.png";
            onExited: loginImg.source = "qrc:/icon/icon/login-btn2.png";
            onPressed: loginImg.source = "qrc:/icon/icon/login-btn.png";
            onReleased: loginImg.source = "qrc:/icon/icon/login-btn2.png";
            onClicked: {
                var name = userNameText.text;
                var password = passwordText.text;
                var state = loginState.onlineState;
                if(name ==="" || password === ""){
                    return;
                }
                userNameText.enabled = false;
                passwordText.enabled = false;
                loginBtn.enabled = false;
                remenberBtn.enabled = false;

                loginTimer.start();

                head_normal.visible = true;
                users_rec.visible = false;
                loginAnimation.visible = true;
                loginAnimation.running = true;
                head_normal.enabled = false;
                loginState.enabled = false;
            }
            Timer{
                id:loginTimer;
                interval: 2000;
                triggeredOnStart: false;
                onTriggered: {
                    var name = userNameText.text;
                    var password = passwordText.text;
                    var state = loginState.onlineState;
                    loginController.login(name, password, state);
                }
            }
        }
    }
    //信号连接器，连接登录结果
    Connections{
        target: loginController
        onLoginResult:{
            console.log(result);
            var resJson = JSON.parse(result);
            userNameText.enabled = true;
            passwordText.enabled = true;
            loginBtn.enabled = true;
            loginAnimation.visible = false;
            loginAnimation.running = false;
            head_normal.enabled = true;
            loginState.enabled = true;
            remenberBtn.enabled = true;

            if(resJson.code !== 0){
                //输出错误信息
                infoDialog.x = mainwindow.x-25;
                infoDialog.y = mainwindow.y + 100;
                infoDialog.visible = true;
                infoDialog.text = resJson.msg;

                openAni.start();
                return;
            }
            //更新登录用户的信息
            loginController.updateUser(JSON.stringify(resJson.data.user))
            opacityAni.loginData = resJson;
            opacityAni.isLogin = true;
            opacityAni.start();
        }
        onTimeout:{
            if(opacityAni.isLogin){
                return;
            }

            userNameText.enabled = true;
            passwordText.enabled = true;
            loginBtn.enabled = true;
            loginAnimation.visible = false;
            loginAnimation.running = false;
            infoDialog.x = mainwindow.x - 25;
            infoDialog.y = mainwindow.y + 100;
            infoDialog.visible = true;
            head_normal.enabled = true;
            loginState.enabled = true;
            remenberBtn.enabled = true;
            infoDialog.text = "无法连接到服务器";
            openAni.start();
        }
    }

    //登录成功后，登录框的消失动画
    NumberAnimation{
        id:opacityAni;
        property var loginData;
        property bool isLogin:false;
        property:"opacity"
        from: 1;
        to:0;
        target: mainwindow;
        duration: 1000;
        onStopped: {
            var chatWindow = Qt.createComponent("ChatWindow.qml");

            while(true){
                if(chatWindow.status === Component.Ready){
                    break;
                }
            }

            var obj = chatWindow.createObject(mainwindow, {"loginData": loginData.data});
            obj.show();
            var headPic = loginData.data.user.headPic;
            var nickName = loginData.data.user.nickName;
            loginController.saveUserInfo(userNameText.text, passwordText.text, loginState.onlineState, remenberBtn.checked, headPic, nickName);
            mainwindow.visible = false;
        }
    }
    //分割线
    Rectangle{
        id:line_1;
        height:1;
        width:200;
        anchors.top:passwordText.bottom;
        anchors.topMargin: 8;
        anchors.left: parent.left;
        anchors.leftMargin: 25;
        color: "#aaa";
    }
    //弹出更多按钮
    Rectangle{
        id:moreRec;
        width:20;
        height:20;
        x: (parent.width-width) / 2;
        anchors.top: line_1.bottom;
        anchors.topMargin: 30;
        color: "#00000000";
//        border.color: "red";
//        border.width: 1;
        Image{
            id: moreImg;
            anchors.fill: parent;
            source: "qrc:/icon/icon/more-1.png";
        }
        MouseArea{
            anchors.fill: parent;
            hoverEnabled: true;
            onEntered: moreImg.source = "qrc:/icon/icon/more-2.png";
            onExited: moreImg.source = "qrc:/icon/icon/more-1.png";
            onPressed: moreImg.source = "qrc:/icon/icon/more-3.png";
            onReleased: moreImg.source = "qrc:/icon/icon/more-1.png";
            onClicked: {
                if(mainwindow.isOpen){
                    mainwindow.height -= 60;
                    mainwindow.isOpen = false;
                }else{
                    mainwindow.height += 60;
                    mainwindow.isOpen = true;
                }
            }
        }
    }
    //注册账号 和记住密码
    Rectangle{
        id: moreInfoRec;
        width: parent.width;
        height:60;
        y:320;
//        border.color: "red";
//        border.width: 1;
        Rectangle{
            width: parent.width;
            height:15;
            gradient: Gradient {
                GradientStop {
                    color: "#D3D3D3";
                    position: 0.01
                }
                GradientStop {
                    color: "#FFFFFF"
                    position: 1
                }
            }
        }

       CheckBox{
           id:remenberBtn;
           text: "记住密码";
           anchors.verticalCenter: parent.verticalCenter;
           anchors.left: parent.left;
           anchors.leftMargin: 20;
           checked: users_rec.currentData.remenberPass === 1;
       }

       Text{
           id:register;
           text:"注册账号"
           anchors.verticalCenter: parent.verticalCenter;
           anchors.right: parent.right;
           anchors.rightMargin: 40;
           font.underline: true;
           MouseArea{
               cursorShape: Qt.OpenHandCursor;
               anchors.fill: parent;
               onClicked: {
                   Qt.openUrlExternally("http://www.baidu.com");
               }
           }
       }
    }

    //弹出对话框
    Window{
        id:infoDialog;
        modality: Qt.ApplicationModal;
        property alias text: contentText.text;
        height:1;
        width:1;
        maximumHeight: 100
        maximumWidth: 250
        visible: false;
        ParallelAnimation{
            id:openAni;
            NumberAnimation{
                target: infoDialog;
                property: "width";
                to:300;
                from: 1;
                duration: 400;
            }

            NumberAnimation {
                target: infoDialog
                property: "height"
                to:100;
                from:1;
                duration: 400
            }
        }

        Text{
            id:contentText;
            anchors.centerIn: parent;
            text:"错误:00000000";
        }
        Button{
            id:okBtn;
            height:parent.height / 5;
            width: parent.width / 5;
            anchors.right: parent.right;
            anchors.rightMargin: 10;
            anchors.bottom: parent.bottom;
            anchors.bottomMargin: 10;
            text: "确定"
            onClicked: {
                infoDialog.visible = false;
            }
        }
    }
}

