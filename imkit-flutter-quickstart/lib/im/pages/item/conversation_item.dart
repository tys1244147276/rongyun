import 'package:flutter/material.dart';
import 'package:flutter_rong/user/until/ajax.dart';
import 'package:flutter_rong/user/until/interface.dart';

import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart' as prefix;
import 'message_item_factory.dart';
import 'widget_util.dart';
import '../../util/style.dart';
import '../../util/user_info_datesource.dart';

class ConversationItem extends StatefulWidget {
  prefix.Message message ;
  ConversationItemDelegate delegate;
  bool showTime;

  ConversationItem(ConversationItemDelegate delegate,prefix.Message msg,bool showTime) {
    this.message = msg;
    this.delegate = delegate;
    this.showTime = showTime;
  }

  @override
  State<StatefulWidget> createState() {
    return new _ConversationItemState(this.delegate,this.message,this.showTime);
  }
}

class _ConversationItemState extends State<ConversationItem> {
  prefix.Message message;
  ConversationItemDelegate delegate;
  bool showTime;
  UserInfo user;
  Offset tapPos;
  //static const List notifiTypeMessage = ["RC:RcNtf"];

  _ConversationItemState(ConversationItemDelegate delegate,prefix.Message msg,bool showTime) {
    this.message = msg;
    this.delegate = delegate;
    this.showTime = showTime;
    this.user = UserInfoDataSource.getUserInfo(msg.senderUserId);
  }

  @override
  void initState () {
    super.initState();
    getUserName(this.message.senderUserId);
  }

  getUserName(id) async {
    await Ajax.post(queryUserName, {'userid':id}, (res) async {
      this.user.name = res['data'];
      setState(() {});
    }, (error) {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
      child:Column(
        children: <Widget>[
          this.showTime? WidgetUtil.buildMessageTimeWidget(message.sentTime):WidgetUtil.buildEmptyWidget(),
          showMessage()
        ],
      ),
    );
  }

  Widget showMessage(){
      //属于通知类型的消息
      if(message.content is prefix.RecallNotificationMessage){
        return ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Container(
          alignment: Alignment.center,
          width: RCLayout.MessageNotifiItemWidth,
          height: RCLayout.MessageNotifiItemHeight,
          color: Color(RCColor.MessageTimeBgColor),
          child: Text('成功撤回一条消息',style: TextStyle(color: Colors.white,fontSize: RCFont.MessageNotifiFont),),
        ),
        );
      }else{
        return Row(
            children: <Widget>[subContent()],
          );
      }
  }

  Widget subContent() {
    if (message.messageDirection == prefix.RCMessageDirection.Send) {
      return Expanded(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Column(
                children: <Widget>[
                  Container(
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.fromLTRB(0, 0, 15, 0),
                    child: Text(this.user.name,style: TextStyle(fontSize: RCFont.MessageNameFont,color: Color(RCColor.MessageNameBgColor))),
                  ),
                  buildMessageWidget(),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                __onTapedUserPortrait();
              },
              child: WidgetUtil.buildUserPortrait(this.user.portraitUrl),
            ),
          ],
        ),
      );
    } else if (message.messageDirection == prefix.RCMessageDirection.Receive) {
      return Expanded(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                __onTapedUserPortrait();
              },
              child: WidgetUtil.buildUserPortrait(this.user.portraitUrl),
            ),
            Expanded(
              child: Column(
                children: <Widget>[
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                    child: Text(this.user.name,style: TextStyle(color: Color(RCColor.MessageNameBgColor)),),
                  ),
                  buildMessageWidget(),
                ],
              ),
            ),
          ],
        ),
      );
    }else {
      return WidgetUtil.buildEmptyWidget();
    }
  }

  void __onTapedMesssage() {
    if(delegate != null) {
      delegate.didTapMessageItem(message);
    }else {
      print("没有实现 ConversationItemDelegate");
    }
  }

  void __onLongPressMessage(Offset tapPos) {
    if(delegate != null) {
      delegate.didLongPressMessageItem(message,tapPos);
    }else {
      print("没有实现 ConversationItemDelegate");
    }
  }

  void __onTapedUserPortrait() {
    if(delegate != null) {
      delegate.didTapUserPortrait(message.senderUserId);
    }else {
      print("没有实现 ConversationItemDelegate");
    }
  }

  Widget buildMessageWidget() {
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
            padding: EdgeInsets.fromLTRB(15, 6, 15, 10),
            alignment: message.messageDirection == prefix.RCMessageDirection.Send
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (TapDownDetails details) {
                this.tapPos = details.globalPosition;
              },
              onTap: () {
                __onTapedMesssage();
              },
              onLongPress: () {
                __onLongPressMessage(this.tapPos);
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: MessageItemFactory(message: message) ,
              ) ,
            )
          ),
        )
      ],
    );
  }
}

abstract class ConversationItemDelegate {
  //点击消息
  void didTapMessageItem(prefix.Message message);
  //长按消息
  void didLongPressMessageItem(prefix.Message message,Offset tapPos);
  //点击用户头像
  void didTapUserPortrait(String userId);
}