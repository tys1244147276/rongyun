import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

class Detail extends StatefulWidget {
  Map arguments;
  Detail({Key key, this.arguments}) : super(key: key);
  _DetailState createState() => _DetailState(arguments: {"data": this.arguments['data']});
}

class _DetailState extends State<Detail> {
  Map arguments;
  Map map;

  _DetailState({this.arguments});

  @override
  void initState () {
    super.initState();
    TextMessage msg = arguments['data'].content;
    map = json.decode(msg.content);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        color: Colors.white,
        child: Column(
          children: <Widget>[
            Text('详情:$map'),
          ],
        ),
      )
    );
  }
}
