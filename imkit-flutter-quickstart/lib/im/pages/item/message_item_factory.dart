import 'dart:io';
import 'package:flutter/material.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import '../../util/media_util.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../../util/style.dart';

class MessageItemFactory extends StatelessWidget {
  final Message message;
  const MessageItemFactory({Key key, this.message}) : super(key: key);

  ///文本消息 item
  Widget textMessageItem() {
    TextMessage msg = message.content;
    return Container(
      padding: EdgeInsets.all(8),
      child: Text(
        msg.content,
        style: TextStyle(fontSize: RCFont.MessageTextFont),
      ),
    );
  }

  //自定义文本消息 test
  // Widget testMessageItem() {
  //   TextMessage msg = message.content;
  //   Map map = json.decode(msg.content);
  //   return GestureDetector(
  //     onTap: () {
  //       Navigator.pushNamed(context, "/detail", arguments: msg);
  //     },
  //     child: Center(
  //       child: Container(
  //         color: Colors.red,
  //         padding: EdgeInsets.all(8),
  //         child: Column(
  //           children: <Widget>[
  //             Row(
  //               mainAxisAlignment:MainAxisAlignment.center,
  //               children: <Widget>[
  //                 Text(
  //               // msg.content,
  //               map['contact'],
  //               style: TextStyle(fontSize: RCFont.MessageTextFont ),
  //             ),
  //               ],
  //             ),
  //             Container(
  //               width: 280,
  //               child: Image.network(
  //                 'https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1589274007824&di=1d12cac4988aec87f74c8390bfc652f7&imgtype=0&src=http%3A%2F%2Fa0.att.hudong.com%2F64%2F76%2F20300001349415131407760417677.jpg',
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   ); 
  // }

  ///图片消息 item
  ///优先读缩略图，否则读本地路径图，否则读网络图
  Widget imageMessageItem() {
    ImageMessage msg = message.content;

    Widget widget;
    if (msg.content != null && msg.content.length > 0) {
      Uint8List bytes = base64.decode(msg.content);
      widget = Image.memory(bytes);
    } else {
      if (msg.localPath != null) {
        String path = MediaUtil.instance.getCorrectedLocalPath(msg.localPath);
        File file = File(path);
        if (file != null && file.existsSync()) {
          widget = Image.file(file);
        } else {
          widget = Image.network(msg.imageUri);
        }
      } else {
        widget = Image.network(msg.imageUri);
      }
    }
    return widget;
  }

  ///语音消息 item
  Widget voiceMessageItem() {
    VoiceMessage msg = message.content;
    List<Widget> list = new List();
    if (message.messageDirection == RCMessageDirection.Send) {
      list.add(SizedBox(
        width: 6,
      ));
      list.add(Text(
        msg.duration.toString() + "''",
        style: TextStyle(fontSize: RCFont.MessageTextFont),
      ));
      list.add(SizedBox(
        width: 20,
      ));
      list.add(Container(
        width: 20,
        height: 20,
        child: Image.asset("assets/images/voice_icon.png"),
      ));
    } else {
      list.add(SizedBox(
        width: 6,
      ));
      list.add(Container(
        width: 20,
        height: 20,
        child: Image.asset("assets/images/voice_icon_reverse.png"),
      ));
      list.add(SizedBox(
        width: 20,
      ));
      list.add(Text(msg.duration.toString() + "''"));
    }

    return Container(
      width: 80,
      height: 44,
      child: Row(children: list),
    );
  }

  //小视频消息 item
  Widget sightMessageItem() {
    SightMessage msg = message.content;
    Widget previewW = Container(); //缩略图
    if (msg.content != null && msg.content.length > 0) {
      Uint8List bytes = base64.decode(msg.content);
      previewW = Image.memory(
        bytes,
        fit: BoxFit.fill,
      );
    }
    Widget bgWidget = Container(
      width: 100,
      height: 150,
      child: previewW,
    );
    Widget continerW = Container(
        width: 100,
        height: 150,
        child: Container(
          width: 50,
          height: 50,
          alignment: Alignment.center,
          child: Image.asset(
            "assets/images/sight_message_icon.png",
            width: 50,
            height: 50,
          ),
        ));
    Widget timeW = Container(
      width: 100,
      height: 150,
      child: Container(
        width: 50,
        height: 20,
        alignment: Alignment.bottomLeft,
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 5,
            ),
            Text(
              "${msg.duration}'s",
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
    return Stack(
      children: <Widget>[
        bgWidget,
        continerW,
        timeW,
      ],
    );
  }

  Widget messageItem() {
    if (message.content is TextMessage) {
      if (json.decode(message.content.encode())['extra'] == 'customize' || json.decode(message.content.encode())['extra'] == 'customizeRent') {
        return TestMessageItem(data: message);
      } else {
        return textMessageItem();
      }
    } else if (message.content is ImageMessage) {
      return imageMessageItem();
    } else if (message.content is VoiceMessage) {
      return voiceMessageItem();
    } else if (message.content is SightMessage) {
      return sightMessageItem();
    } else if (message.content is RecallNotificationMessage) {
      return Text("我是 RecallNotificationMessage " + message.objectName);
    } else {
      return Text("无法识别消息 " + message.objectName);
    }
  }

  Color _getMessageWidgetBGColor(int messageDirection) {
    Color color = Color(RCColor.MessageSendBgColor);
    if (message.messageDirection == RCMessageDirection.Receive) {
      color = Color(RCColor.MessageReceiveBgColor);
    }
    return color;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _getMessageWidgetBGColor(message.messageDirection),
      child: messageItem(),
    );
  }
}

class TestMessageItem extends StatefulWidget {

  final Message data;
  TestMessageItem({Key key, this.data}) : super(key: key);
  State<StatefulWidget> createState() {
    return _TestMessageItemState(arguments: {"data": this.data});
  }
}

class _TestMessageItemState extends State{
  
  Map arguments;
  Map map;
  
  _TestMessageItemState({this.arguments});

 
  @override
  void initState () {
    super.initState();
    TextMessage msg = arguments['data'].content;
    map = json.decode(msg.content);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, "/detail", arguments: arguments);
      },
      child: Center(
        child: Container(
          color: Colors.red,
          padding: EdgeInsets.all(8),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment:MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                // msg.content,
                map['contact']==null ?'${ map['con_price']}' : map['contact'],
                style: TextStyle(fontSize: RCFont.MessageTextFont ),
              ),
                ],
              ),
              Container(
                width: 280,
                child: Image.network(
                  'https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1589274007824&di=1d12cac4988aec87f74c8390bfc652f7&imgtype=0&src=http%3A%2F%2Fa0.att.hudong.com%2F64%2F76%2F20300001349415131407760417677.jpg',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
}
