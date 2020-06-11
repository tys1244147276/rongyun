import 'dart:convert' as convert;

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rong/user/until/ajax.dart';
import 'package:flutter_rong/user/until/interface.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StartGroupChatPage extends StatefulWidget {
  _StartGroupChatPageState createState() => _StartGroupChatPageState();
}

class _StartGroupChatPageState extends State<StartGroupChatPage> {
  String groupName = '';
  String loginButtonText = '登录';
  bool loading = false;
  List listData;
  String groupId;
  printData() {
    setState(() {
      loading = true;
    });
  }

  @override
  void initState() {
    super.initState();
    getUid();
    //获取用户列表
    // Ajax.post(queryUserList, null, (respone) {
    //   setState(() {});
    // }, (error) {
    //   print(error);
    // });
  }

  getUid() async {
    await _addFriends();
    final prefs = await SharedPreferences.getInstance();
    userIdList.add(prefs.getString('userid'));
  }

  _addFriends() async {
    await Ajax.post(queryUserList, null, (res) async {
      setState(() {
        listData = res['data'];
      });
    }, (error) {
      Fluttertoast.showToast(
          msg: error['msg'],
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIos: 1,
          // timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey,
          textColor: Colors.white,
          fontSize: 16.0);
      print(error);
    });
  }

  _getGroupId() async {
    loading = true;
    await Ajax.post(getProjectId, null, (res) async {
      setState(() {
        this.groupId = res['data'];
      });

      FormData param = new FormData();
      param.add("userId", userIdList);
      param.add('groupId', groupId);
      param.add('groupName', groupName);

      _createGrouop(param);
    }, (error) {
      Fluttertoast.showToast(
          msg: error['msg'],
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIos: 1,
          // timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey,
          textColor: Colors.white,
          fontSize: 16.0);
      print(error);
    });
  }

  _createGrouop(param) async {
    await Ajax.postIm(rongYunAddGroup, param, () {
      _saveGroup();
    }, (error) {
      print(error);
    });
  }

  _sentMsg() async {
    await Ajax.postIm(rongYunPublish, {
      'fromUserId': userIdList[0],
      'toGroupId': this.groupId,
      'objectName': 'RC:TxtMsg',
      'content': '{"content":"大家好","extra":"helloExtra"}',
      'isIncludeSender': 1
    }, () {
      loading = false;
      Navigator.pop(context);
    }, (error) {
      print(error);
    });
  }

  _saveGroup() async {
    await Ajax.post(creactProject, {
      'pid': this.groupId,
      'pname': groupName,
      'userid': userIdList[0],
      'cyid': convert.jsonEncode(userIdList)
    }, (res) {
      _sentMsg();
    }, (error) {
      Fluttertoast.showToast(
          msg: error['msg'],
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIos: 1,
          // timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey,
          textColor: Colors.white,
          fontSize: 16.0);
      print(error);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('发起群聊', style: TextStyle(color: Colors.black)),
          iconTheme: IconThemeData(
            color: Colors.black, //修改颜色
          ),
          elevation: 0,
          backgroundColor: Colors.white,
          centerTitle: true,
        ),
        body: Container(
          child: Column(
            children: <Widget>[
              TextField(
                  // controller: groupnameController,
                  decoration: InputDecoration(
                    icon: Icon(Icons.person),
                    hintText: "起个群名",
                    // helperText: "helperText",
                  ),
                  onChanged: (value) {
                    groupName = value;
                    print(value);
                  }),
              Expanded(child: itemList(listData)),
              //按钮
              Container(
                // width: ScreenUtil().setHeight(301),
                width: 301,
                // height: ScreenUtil().setHeight(45),
                height: 45,
                // padding: EdgeInsets.only(top: 10.h),
                margin: EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                    gradient: loading
                        ? LinearGradient(
                            colors: [Color(0xFFC0C0C0), Color(0xFFC0C0C0)])
                        : LinearGradient(colors: [
                            Color(0xFF1D7DFF),
                            Color(0xFF57ACFF)
                          ]), // 渐变色
                    borderRadius: BorderRadius.circular(5)),
                child: RaisedButton(
                  child: Text(
                    loading ? '加载中……' : '创建',
                    style: TextStyle(
                        fontSize: 18,
                        // ScreenUtil(allowFontScaling: true).setSp(18),
                        color: Colors.white),
                  ),
                  //背景色透明
                  color: Colors.transparent,
                  elevation: 0, // 正常时阴影隐藏
                  highlightElevation: 0,
                  // onPressed: loading?null:_loginPass,
                  onPressed: () async {
                    if (groupName == '' || groupName == null) {
                      Fluttertoast.showToast(
                        msg: '我名呢？',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIos: 1,
                      );
                    } else {
                      String userId = '';
                      for (var i = 0; i < userIdList.length; i++) {
                        userId = userId + ',' + userIdList[i].toString();
                      }
                      userId = userId.substring(1, userId.length);

                      await _getGroupId();
                    }
                  },
                ),
              ),
            ],
          ),
        ));
  }
}

class BuddyItem extends StatefulWidget {
  Map listMap;
  BuddyItem({this.listMap});

  _BuddyItemState createState() => _BuddyItemState();
}

class _BuddyItemState extends State<BuddyItem> {
  bool _checkboxSelected = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        CheckboxListTile(
          secondary: const Icon(Icons.airline_seat_individual_suite),
          title: Text(widget.listMap['u_name']),
          // subtitle: Text('12小时58分钟后响铃'),
          value: _checkboxSelected,
          activeColor: Colors.blue,
          onChanged: (bool value) {
            if (value) {
              userIdList.add(widget.listMap['id']);
            } else {
              userIdList.remove(widget.listMap['id']);
            }
            print(value);
            setState(() {
              _checkboxSelected = !_checkboxSelected;
            });
          },
        ),
      ],
    );
  }
}

List userIdList = [];
// List listData = [
//   {'id': 1263, 'name': "某某某"},
//   {'id': 1263, 'name': "ba某某"},
//   {'id': 1523, 'name': "wa某某某"},
//   {'id': 1823, 'name': "li某某"},
//   {'id': 1023, 'name': "li某某"},
//   {'id': 1223, 'name': "li某某"},
//   {'id': 1423, 'name': "li某某"},
//   {'id': 1223, 'name': "li某某"},
// ];

Widget itemList(List itemData) {
  if (itemData != null) {
    return ListView.builder(
      itemCount: itemData.length,
      itemExtent: 60.0,
      itemBuilder: (BuildContext context, int index) {
        return BuddyItem(
          listMap: itemData[index],
        );
      },
    );
  } else {
    return Text('您当前没有好友');
  }
}
