import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart' as prefix;

class DebugPage extends StatelessWidget {
  List titles;
  String blackUserId = "blackUserId";

  DebugPage() {
    titles = [
      "加入黑名单",
      "移除黑名单",
      "查看黑名单状态",
      "获取黑名单列表",
      "设置免打扰",
      "取消免打扰",
      "查看免打扰",
      "获取特定会话",
      "获取特定方向的消息列表",
      "分页获取会话",
      "消息携带用户信息",
      "消息携带@信息",
      "测试自定义消息"
    ];
  }

  void _didTap(int index) {
    print("did tap debug " + titles[index]);
    switch (index) {
      case 0:
        _addBlackList();
        break;
      case 1:
        _removeBalckList();
        break;
      case 2:
        _getBlackStatus();
        break;
      case 3:
        _getBlackList();
        break;
      case 4:
        _setConStatusEnable();
        break;
      case 5:
        _setConStatusDisanable();
        break;
      case 6:
        _getConStatus();
        break;
      case 7:
        _getCons();
        break;
      case 8:
        _getMessagesByDirection();
        break;
      case 9:
        _getConversationListByPage();
        break;
      case 10:
        _sendMessageAddSendUserInfo();
        break;
      case 11:
        _sendMessageAddMentionedInfo();
        break;
      case 12:
        _sendTestMessageInfo();
        break;
    }
  }

  void _addBlackList() {
    print("_addBlackList");
    prefix.RongcloudImPlugin.addToBlackList(blackUserId, (int code) {
      print("_addBlackList:" + blackUserId + " code:" + code.toString());
    });
  }

  void _removeBalckList() {
    print("_removeBalckList");
    prefix.RongcloudImPlugin.removeFromBlackList(blackUserId, (int code) {
      print("_removeBalckList:" + blackUserId + " code:" + code.toString());
    });
  }

  void _getBlackStatus() {
    print("_getBlackStatus");
    prefix.RongcloudImPlugin.getBlackListStatus(blackUserId,
        (int blackStatus, int code) {
      if (0 == code) {
        if (prefix.RCBlackListStatus.In == blackStatus) {
          print("用户:" + blackUserId + " 在黑名单中");
        } else {
          print("用户:" + blackUserId + " 不在黑名单中");
        }
      } else {
        print("用户:" + blackUserId + " 黑名单状态查询失败" + code.toString());
      }
    });
  }

  void _getBlackList() {
    print("_getBlackList");
    prefix.RongcloudImPlugin.getBlackList(
        (List/*<String>*/ userIdList, int code) {
      print("_getBlackList:" +
          userIdList.toString() +
          " code:" +
          code.toString());
      userIdList.forEach((userId) {
        print("userId:" + userId);
      });
    });
  }

  void _setConStatusEnable() {
    prefix.RongcloudImPlugin.setConversationNotificationStatus(
        prefix.RCConversationType.Private, "SealTalk", true,
        (int status, int code) {
      print("setConversationNotificationStatus1 status " + status.toString());
    });
  }

  void _setConStatusDisanable() {
    prefix.RongcloudImPlugin.setConversationNotificationStatus(
        prefix.RCConversationType.Private, "SealTalk", false,
        (int status, int code) {
      print("setConversationNotificationStatus2 status " + status.toString());
    });
  }

  void _getConStatus() {
    prefix.RongcloudImPlugin.getConversationNotificationStatus(
        prefix.RCConversationType.Private, "SealTalk", (int status, int code) {
      print("getConversationNotificationStatus3 status " + status.toString());
    });
  }

  void _getCons() async {
    int conversationType = prefix.RCConversationType.Private;
    String targetId = "SealTalk";
    prefix.Conversation con = await prefix.RongcloudImPlugin.getConversation(
        conversationType, targetId);
    if (con != null) {
      print("getConversation type:" +
          con.conversationType.toString() +
          " targetId:" +
          con.targetId);
    } else {
      print("不存在该会话 type:" +
          conversationType.toString() +
          " targetId:" +
          targetId);
    }
  }

  void _getMessagesByDirection() async {
    int conversationType = prefix.RCConversationType.Private;
    String targetId = "SealTalk";
    int sentTime = 1567756686643;
    int beforeCount = 10;
    int afterCount = 10;
    List msgs = await prefix.RongcloudImPlugin.getHistoryMessages(
        conversationType, targetId, sentTime, beforeCount, afterCount);
    if (msgs == null) {
      print("未获取消息列表 type:" +
          conversationType.toString() +
          " targetId:" +
          targetId);
    } else {
      for (prefix.Message msg in msgs) {
        print("getHistoryMessages messageId:" +
            msg.messageId.toString() +
            " objName:" +
            msg.objectName +
            " sentTime:" +
            msg.sentTime.toString());
      }
    }
  }

  void _getConversationListByPage() async {
    List list = await prefix.RongcloudImPlugin.getConversationListByPage(
        [prefix.RCConversationType.Private, prefix.RCConversationType.Group],
        2,
        0);
    prefix.Conversation lastCon;
    if (list != null && list.length > 0) {
      list.sort((a, b) => b.sentTime.compareTo(a.sentTime));
      for (int i = 0; i < list.length; i++) {
        prefix.Conversation con = list[i];
        print("first targetId:" +
            con.targetId +
            " " +
            "time:" +
            con.sentTime.toString());
        lastCon = con;
      }
    }
    if (lastCon != null) {
      list = await prefix.RongcloudImPlugin.getConversationListByPage(
          [prefix.RCConversationType.Private, prefix.RCConversationType.Group],
          2,
          lastCon.sentTime);
      if (list != null && list.length > 0) {
        list.sort((a, b) => b.sentTime.compareTo(a.sentTime));
        for (int i = 0; i < list.length; i++) {
          prefix.Conversation con = list[i];
          print("last targetId:" +
              con.targetId +
              " " +
              "time:" +
              con.sentTime.toString());
        }
      }
    }
  }

  void _sendMessageAddSendUserInfo() async {
    prefix.TextMessage msg = new prefix.TextMessage();
    msg.content = "测试文本消息携带用户信息";
    /*
    测试携带用户信息
    */
    prefix.UserInfo sendUserInfo = new prefix.UserInfo();
    sendUserInfo.name = "textSendUser.name";
    sendUserInfo.userId = "textSendUser.userId";
    sendUserInfo.portraitUri = "textSendUser.portraitUrl";
    sendUserInfo.extra = "textSendUser.extra";
    msg.sendUserInfo = sendUserInfo;

    prefix.Message message = await prefix.RongcloudImPlugin.sendMessage(
        prefix.RCConversationType.Private, "SealTalk", msg);
    print("send message add sendUserInfo:" +
        message.content.getObjectName() +
        " msgContent:" +
        message.content.encode());
  }

  void _sendMessageAddMentionedInfo() async {
    prefix.TextMessage msg = new prefix.TextMessage();
    msg.content = "测试文本消息携带@信息";
    /*
    测试携带 @ 信息
    */
    prefix.MentionedInfo mentionedInfo = new prefix.MentionedInfo();
    mentionedInfo.type = prefix.RCMentionedType.Users;
    mentionedInfo.userIdList = ["SealTalk"];
    mentionedInfo.mentionedContent = "这是 mentionedContent";
    msg.mentionedInfo = mentionedInfo;

    prefix.Message message = await prefix.RongcloudImPlugin.sendMessage(
        prefix.RCConversationType.Private, "SealTalk", msg);
    print("send message add mentionedInfo:" +
        message.content.getObjectName() +
        " msgContent:" +
        message.content.encode());
  }
  void _sendTestMessageInfo() async {
    Map testMap = {
    "userid":'1',"title":"标题",'img':''
    };
    prefix.TextMessage msg = new prefix.TextMessage();
    msg.content = json.encode(testMap);
    /*
    测试自定义信息
    */
    msg.extra = "customize";

    prefix.Message message = await prefix.RongcloudImPlugin.sendMessage(
        prefix.RCConversationType.Private, "SealTalk", msg);
    print("send message add mentionedInfo:" +
        message.content.getObjectName() +
        " msgContent:" +
        message.content.encode());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Debug"),
      ),
      body: ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: titles.length,
        itemBuilder: (BuildContext context, int index) {
          return MaterialButton(
            onPressed: () {
              _didTap(index);
            },
            child: Text(titles[index]),
            color: Colors.blue,
          );
        },
      ),
    );
  }
}
