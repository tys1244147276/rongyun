import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rong/user/until/ajax.dart';
import 'package:flutter_rong/user/until/interface.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart' as prefix;
import 'package:shared_preferences/shared_preferences.dart';

import '../im/util/user_info_datesource.dart';

class ContactsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _ContactsPageState();
  }
}

class _ContactsPageState extends State<ContactsPage> with SingleTickerProviderStateMixin{
  List<Widget> widgetList1 = new List();
  List<Widget> widgetList2 = new List();
  List<UserInfo> userList1 = new List();
  List<GroupInfo> userList2 = new List();
  ScrollController _scrollViewController;
  TabController _tabController;
  var currentPanelIndex=-1;
   List<int> mList;
  @override
  void initState() {
    super.initState();
    _scrollViewController = ScrollController(initialScrollOffset: 0.0);
    _tabController = TabController(vsync: this, length: 2);
    mList=new List();
    for(int i=0;i<2;i++){
      mList.add(i);
    }
    getList();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollViewController.dispose();
    _tabController.dispose();
  }

  getList() async {
    await _addFriends();
    await _addGroup();
    for(UserInfo u in userList1) {
      this.widgetList1.add(getWidget1(u));
    }
    for(GroupInfo u in userList2) {
      this.widgetList2.add(getWidget2(u));
    }
    if(this.mounted){
      setState(() {});
    }
  }

  _addFriends() async{
    await Ajax.post(queryUserList, null, (res) async {
      List arr = res['data'];
      for(var i=0;i<arr.length;i++){
        userList1.add(UserInfoDataSource.getUserInfo("${arr[i]['id']}","${arr[i]['u_name']}"));
      }

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

  _addGroup() async{
    final prefs = await SharedPreferences.getInstance();
    await Ajax.post(queryProjectNameByUid, {'userid': prefs.getString('userid')}, (res) async {
      List arr = res['data'];
      for(var i=0;i<arr.length;i++){
        userList2.add(UserInfoDataSource.getGroupInfo("${arr[i]['id']}","${arr[i]['p_name']}"));
      }

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

  void _onTapUser1(UserInfo user) {
    
    Map arg = {"coversationType":prefix.RCConversationType.Private,"targetId":user.id};
    Navigator.pushNamed(context, "/conversation",arguments: arg);
  }
  void _onTapUser2(GroupInfo user) {
    
    Map arg = {"coversationType":prefix.RCConversationType.Group,"targetId":user.id};
    Navigator.pushNamed(context, "/conversation",arguments: arg);
  }

  void _pushToDebug() {
    Navigator.pushNamed(context, "/debug");
  }

  Widget getWidget1(UserInfo user) {
    return Container(
            height: 50.0,
            color: Colors.white,
            child:InkWell(
              onTap: () {
                _onTapUser1(user);
              },
              child: new ListTile(
                title: new Text(user.name),
                leading: Container(
                    width: 36,
                    height: 36,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: CachedNetworkImage(
                        fit: BoxFit.fill,
                        imageUrl: user.portraitUrl,
                      ),
                    ),
                  ),
                ),
              ),
    );
  }
  Widget getWidget2(GroupInfo user) {
    return Container(
            height: 50.0,
            color: Colors.white,
            child:InkWell(
              onTap: () {
                _onTapUser2(user);
              },
              child: new ListTile(
                title: new Text(user.name),
                leading: Container(
                    width: 36,
                    height: 36,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: CachedNetworkImage(
                        fit: BoxFit.fill,
                        imageUrl: user.portraitUrl,
                      ),
                    ),
                  ),
                ),
              ),
    );
  }


   Widget _buildListView(String type){
    if(type == 'single'){
      return SingleChildScrollView(
        child: ListView.builder(
          shrinkWrap: true,
          physics:NeverScrollableScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            return this.widgetList1[index];
          },
          itemCount: this.widgetList1.length,
        ),
      );
    }else{
      return SingleChildScrollView(
        child: ListView.builder(
          shrinkWrap: true,
          physics:NeverScrollableScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            return this.widgetList2[index];
          },
          itemCount: this.widgetList2.length,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text("通讯录",style: TextStyle(color: Colors.black),),
        actions: <Widget>[
          IconButton(
            color: Colors.black,
            icon: Icon(Icons.more),
            onPressed: () {
              _pushToDebug();
            },
          ),
        ],
      ),
      // body: new ListView(
      //   children: this.widgetList,
      // ),
      body: NestedScrollView(
        controller: _scrollViewController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              pinned: true,
              floating: true,
              bottom: TabBar(controller: _tabController, tabs: [
                Tab(text: "成员通讯录"),
                Tab(text: "群组通讯录")
              ]),
            )
          ];
        },
        body: TabBarView(controller: _tabController, children: [
          _buildListView('single'),
          _buildListView('group')
        ])
      )
      //   ExpansionPanelList(
      //     expansionCallback: (index,bol){
      //       setState(() {
      //         currentPanelIndex=(currentPanelIndex!=index?index:-1);
      //       });
      //     },
      //     children: mList.map((i){
      //       return new ExpansionPanel(
      //         headerBuilder: (context,isExpanded){
      //           return new ListTile(
      //             title: i == 0 ? Text('用户列表') : Text('群列表'),
      //           );
      //         },
      //         body:new Padding(
      //           padding: EdgeInsets.all(30.0),
      //           child: ListView.builder(
      //             shrinkWrap: true,
      //             physics:NeverScrollableScrollPhysics(),
      //             itemBuilder: (BuildContext context, int index) {
      //               return this.widgetList[index];
      //             },
      //             itemCount: this.widgetList.length,
      //           ),
      //         ),
      //         isExpanded: currentPanelIndex==i,
      //       );
      //     }).toList()
      // )
    );
  }
}
