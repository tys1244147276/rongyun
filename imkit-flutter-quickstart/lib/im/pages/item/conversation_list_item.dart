
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_rong/user/until/ajax.dart';
import 'package:flutter_rong/user/until/interface.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

import 'widget_util.dart';

import '../../util/style.dart';
import '../../util/time.dart';
import '../../util/user_info_datesource.dart';

class ConversationListItem extends StatefulWidget {
  final Conversation conversation;
  final ConversationListItemDelegate delegate;
  const ConversationListItem({Key key,this.delegate, this.conversation}) : super(key: key);
  
  @override
  State<StatefulWidget> createState() {
    return new _ConversationListItemState(this.delegate,this.conversation);
  }
}

class _ConversationListItemState extends State<ConversationListItem> {
  Conversation conversation ;
  ConversationListItemDelegate delegate;
  BaseInfo info;
  Offset tapPos;

  @override
  void initState() {
    super.initState();
    if(this.conversation.conversationType == RCConversationType.Private) {
      getUserName(this.conversation.targetId);
    }else {
      getGroupName(this.conversation.targetId);
    }

  }

  getUserName(id) async {
    await Ajax.post(queryUserName, {'userid':id}, (res) async {
      this.info.name = res['data'];
      setState(() {});
    }, (error) {});
  }

  getGroupName(id) async {
    await Ajax.post(queryProjectName, {'pid':id}, (res) async {
      this.info.name = res['data'];
      setState(() {});
    }, (error) {});
  }

  _ConversationListItemState(ConversationListItemDelegate delegate,Conversation con) {
    this.delegate = delegate;
    this.conversation = con;
    if(con.conversationType == RCConversationType.Private) {
      this.info = UserInfoDataSource.getUserInfo(con.targetId);
    }else {
      this.info = UserInfoDataSource.getGroupInfo(con.targetId);
    }
    
  }
  
  void _onTaped() {
    if(this.delegate != null) {
      this.delegate.didTapConversation(this.conversation);
    }else {
      print("没有实现 ConversationListItemDelegate");
    }
  }

  void _onLongPressed() {
    if(this.delegate != null) {
      this.delegate.didLongPressConversation(this.conversation,this.tapPos);
    }else {
      print("没有实现 ConversationListItemDelegate");
    }
  }

  Widget _buildPortrait() {
    return Stack(
      overflow: Overflow.visible,
      children: <Widget>[
        Row(
          children: <Widget>[
            SizedBox(
              width: 8,
            ),
            WidgetUtil.buildUserPortrait(this.info.portraitUrl),
          ],
        ),
        Positioned(
          right:-3.0 ,
          top: -3.0,
          child: _buildUnreadCount(conversation.unreadMessageCount),
        ),
      ],
    );
  }

  Widget _buildContent(){
    return Expanded(
      child: Container(
        height: RCLayout.ConListItemHeight,
        margin: EdgeInsets.only(left:8),
        // decoration: BoxDecoration(
        //   border: Border(
        //     bottom: BorderSide(width: 0.5,color: Color(RCColor.ConListBorderColor),)
        //   )
        // ),
        child: Row(
          children: <Widget>[
            _buildTitle(),
            _buildTime()
          ],
        ),
      ),
    );
  }

  Widget _buildTime(){
    String time = TimeUtil.convertTime(conversation.sentTime);
    List<Widget> _rightArea =<Widget>[
      Text(time,style:TextStyle(fontSize: RCFont.ConListTimeFont,color: Color(RCColor.ConListTimeColor))),
      SizedBox(height: 15,)
    ];
    return Container(
      width:RCLayout.ConListItemHeight,
      margin: EdgeInsets.only(right: 8),
      child: Column(
        mainAxisAlignment:  MainAxisAlignment.center,
        children: _rightArea
      ),
    );
  }

  Widget _buildTitle(){
    String title = this.info.name;
    String digest = "";
    if(conversation.latestMessageContent != null) {
      digest = conversation.latestMessageContent.conversationDigest();
      if(json.decode(conversation.latestMessageContent.encode())['extra'] == 'customize'){
        digest = '[采购订单]';
      }
      if(json.decode(conversation.latestMessageContent.encode())['extra'] == 'customizeRent'){
        digest = '[租赁]';
      }
    }
    if(digest == null) {
      digest = "";
    }
    if (conversation.mentionedCount > 0) {
      digest = "[有人@我] " + digest;
    }
    if(conversation.draft!=null && conversation.draft.isNotEmpty){
      digest = "[草稿] " + conversation.draft;
    }
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(fontSize: RCFont.ConListTitleFont,color: Color(RCColor.ConListTitleColor),fontWeight:FontWeight.w400),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 6),
          Text(
            digest,
            style: TextStyle(fontSize: RCFont.ConListDigestFont,color: Color(RCColor.ConListDigestColor)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          )
        ],
      ),
    );
  }

  Widget _buildUnreadCount(int count) {
    if(count <=0 || count == null) {
      return WidgetUtil.buildEmptyWidget();
    }
    return Container(
      width: RCLayout.ConListUnreadSize,
      height: RCLayout.ConListUnreadSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(RCLayout.ConListUnreadSize/2.0),
        color: Color(RCColor.ConListUnreadColor)
      ),
      child: Text(count.toString(),style:TextStyle(fontSize: RCFont.ConListUnreadFont,color: Color(RCColor.ConListUnreadTextColor)))
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Color(RCColor.ConListItemBgColor),
      child: InkWell(
        onTapDown: (TapDownDetails details) {
          tapPos = details.globalPosition;
        },
        onTap: () {
          _onTaped();
        },
        onLongPress: () {
          _onLongPressed();
        },
        child: Container(
          height: RCLayout.ConListItemHeight,
          color: Color(RCColor.ConListItemBgColor),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildPortrait(),
              _buildContent()
            ],
          ),
        ),
      ),
    );
  }
}

abstract class ConversationListItemDelegate {
  ///点击了会话 item
  void didTapConversation(Conversation conversation);
  ///长按了会话 item
  void didLongPressConversation(Conversation conversation,Offset tapPos);
}