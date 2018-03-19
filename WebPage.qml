import QtQuick 2.0
import QtWebView 1.1

Rectangle {
    id:container;
    Rectangle{
        id:titleBar;
        width:parent.width;
        height:40;
        color:"#F0F0F0";
        Text{
            id: titleText;
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pointSize: 15
            anchors.verticalCenter: parent.verticalCenter;
            anchors.left: parent.left;
            anchors.leftMargin: 20;
            //text:webView.title;
        }

        UtilButton{
            id:reloadBtn;
            normalSource: "qrc:/icon/icon/reload.png";
            pressSource: "qrc:/icon/icon/reload-1.png"
            anchors.right: parent.right;
            anchors.rightMargin: 20;
            anchors.verticalCenter: parent.verticalCenter;
            width:25;
            height:25;
            onClicked: {
                webView.reload();
            }
        }
        UtilButton{
            id:forwardBtn;
            normalSource: "qrc:/icon/icon/forward.png";
            pressSource: "qrc:/icon/icon/forward-1.png"
            anchors.right: reloadBtn.left;
            anchors.rightMargin: 15;
            anchors.verticalCenter: parent.verticalCenter;
            width:25;
            height:25;
            onClicked: {
                webView.goForward();
            }
        }
        UtilButton{
            id:backBtn;
            normalSource: "qrc:/icon/icon/back.png";
            pressSource: "qrc:/icon/icon/back-1.png"
            anchors.right: forwardBtn.left;
            anchors.rightMargin: 15;
            anchors.verticalCenter: parent.verticalCenter;
            width:25;
            height:25;
            onClicked: {
                webView.goBack();
            }
        }
        UtilButton{
            id:mainBtn;
            normalSource: "qrc:/icon/icon/main.png";
            pressSource: "qrc:/icon/icon/main-1.png"
            anchors.right:backBtn.left;
            anchors.rightMargin: 15;
            anchors.verticalCenter: parent.verticalCenter;
            width:25;
            height:25;
            onClicked: {
                webView.url = webView.mainUrl
            }
        }
    }
    WebView{
        id:webView
        anchors.left:parent.left;
        anchors.right: parent.right;
        anchors.top:titleBar.bottom;
        height:container.height - titleBar.height
        property string mainUrl: "http://localhost:8080/post/main"
        url:mainUrl
        onLoadingChanged: {
            if(loadRequest.status === WebView.LoadSucceededStatus){
                titleText.text = title
            }
        }
    }
}
