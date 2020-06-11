
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import '../util/media_util.dart';

class ImagePreviewPage extends StatefulWidget {
  final Message message;
  const ImagePreviewPage({Key key, this.message}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ImagePreviewPageState(message);
  }
}

class _ImagePreviewPageState extends State<ImagePreviewPage> {
  final Message message;

  _ImagePreviewPageState(this.message);

  //优先加载本地路径图片，否则加载网络图片
  Widget getImageWidget() {
    ImageMessage msg = message.content;
    Widget widget;
    if(msg.localPath != null) {
      String path = MediaUtil.instance.getCorrectedLocalPath(msg.localPath);
      File file = File(path);
      if(file != null && file.existsSync()) {
        widget = Image.file(file);
      }else {
        widget = Image.network(msg.imageUri);
      }
    }else {
      widget = Image.network(msg.imageUri);
    }
    return widget;
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: Colors.black, //修改颜色
        ),
        title: Text("图片预览",style: TextStyle(color: Colors.black),),
      ),
      body:Center(
        child: Container(
        child: getImageWidget(),
      ),
      ) 
    );
  }
  
}