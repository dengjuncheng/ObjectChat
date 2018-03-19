import QtQuick 2.0
Rectangle {
    id:container;
    anchors.fill: parent;
    color:"#00000000";
    visible:false;
    signal emojiClicked(var value);
    MouseArea{
        id:emptyArea;
        anchors.fill: parent;
        propagateComposedEvents: true;
        onClicked: {
            container.visible = false;
            mouse.accepted = false;
        }
    }
    function onEmojiClick(value){
        emojiClicked(value);
    }

    Rectangle{
        id:allEmojiRec;
        border.color: "black";
        border.width: 1;
        width:400;
        height:240;
        x:160;
        y:210;
        Component.onCompleted: {
            var emojis = interactionCenter.getEmojis();
            var size = emojis.length;
            var component = Qt.createComponent("EmojiRectangle.qml");
            for(var i = 0 ; i < size ; i++){
                var x = (i % 9) * 40 + 20;
                var y = parseInt(i / 9) * 40 + 20;
                var obj = component.createObject(allEmojiRec, {"x":x, "y":y, "value":emojis[i]});
                obj.clicked.connect(onEmojiClick)
            }
        }
    }
}
