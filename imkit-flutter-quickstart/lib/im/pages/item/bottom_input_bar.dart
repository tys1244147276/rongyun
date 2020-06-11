import 'package:flutter/material.dart';

import '../../util/media_util.dart';

class BottomInputBar extends StatefulWidget {
  BottomInputBarDelegate delegate;
  _BottomInputBarState state;
  BottomInputBar(
      BottomInputBarDelegate delegate) {
    this.delegate = delegate;
  }
  @override
  _BottomInputBarState createState() =>
      state = _BottomInputBarState(this.delegate);

  void setTextContent (String textCotent){
    if(textCotent == null){
      textCotent = '';
    }
    this.state.textEditingController.text = textCotent;
  }
}

class _BottomInputBarState extends State<BottomInputBar> {
  BottomInputBarDelegate delegate;
  TextField textField;
  FocusNode focusNode = FocusNode();
  InputBarStatus inputBarStatus;
  TextEditingController textEditingController;

  _BottomInputBarState(
      BottomInputBarDelegate delegate) {
    this.delegate = delegate;
    this.inputBarStatus = InputBarStatus.Normal;
    this.textEditingController = TextEditingController();
    this.textField = TextField(
      onSubmitted: _clickSendMessage,
      controller: textEditingController,
      decoration:
          InputDecoration(border: InputBorder.none, hintText: '随便说点什么吧'),
      focusNode: focusNode,
    );
  }

  @override
  void initState() {
    super.initState();
    textEditingController.addListener(() {
      //获取输入的值
      delegate.onTextChange(textEditingController.text);
    });
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        _notifyInputStatusChanged(InputBarStatus.Normal);
      }
    });
  }

  void _clickSendMessage(String messageStr) {
    if (messageStr == null || messageStr.length <= 0) {
      print('不能为空');
      return;
    }
    if (this.delegate != null) {
      this.delegate.willSendText(messageStr);
    } else {
      print("没有实现 BottomInputBarDelegate");
    }
    this.textField.controller.text = '';
  }

  switchVoice() {
    print("switchVoice");
    InputBarStatus status = InputBarStatus.Normal;
    if (this.inputBarStatus != InputBarStatus.Voice) {
      status = InputBarStatus.Voice;
    }
    _notifyInputStatusChanged(status);
  }

  switchExtention() {
    print("switchExtention");
    if (focusNode.hasFocus) {
      focusNode.unfocus();
    }
    InputBarStatus status = InputBarStatus.Normal;
    if (this.inputBarStatus != InputBarStatus.Extention) {
      status = InputBarStatus.Extention;
    }
    if (this.delegate != null) {
      this.delegate.didTapExtentionButton();
    } else {
      print("没有实现 BottomInputBarDelegate");
    }
    _notifyInputStatusChanged(status);
  }

  _onVoiceGesLongPress() {
    print("_onVoiceGesLongPress");
    MediaUtil.instance.startRecordAudio();
    if (this.delegate != null) {
      this.delegate.willStartRecordVoice();
    } else {
      print("没有实现 BottomInputBarDelegate");
    }
  }

  _onVoiceGesLongPressEnd() {
    print("_onVoiceGesLongPressEnd");

    if (this.delegate != null) {
      this.delegate.willStopRecordVoice();
    } else {
      print("没有实现 BottomInputBarDelegate");
    }

    MediaUtil.instance.stopRecordAudio((String path, int duration) {
      if (this.delegate != null && path.length > 0) {
        this.delegate.willSendVoice(path, duration);
      } else {
        print("没有实现 BottomInputBarDelegate || 录音路径为空");
      }
    });
  }

  Widget _getMainInputField() {
    Widget widget;
    if (this.inputBarStatus == InputBarStatus.Voice) {
      widget = Container(
        alignment: Alignment.center,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          child: Text("按住 说话", textAlign: TextAlign.center),
          onTap: () {
              print("------onTap");
            },
          onLongPress: () {
            _onVoiceGesLongPress();
          },
          onLongPressEnd: (LongPressEndDetails details) {
            _onVoiceGesLongPressEnd();
          },
        ),
      );
    } else {
      widget = Container(
        padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
        child: this.textField,
      );
    }
    return Container(
      height: 45,
      child: Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
            decoration: BoxDecoration(
                border: new Border.all(color: Colors.black54, width: 0.5),
                borderRadius: BorderRadius.circular(8)),
          ),
          widget
        ],
      ),
    );
  }

  void _notifyInputStatusChanged(InputBarStatus status) {
    this.inputBarStatus = status;
    if (this.delegate != null) {
      this.delegate.inputStatusDidChange(status);
    } else {
      print("没有实现 BottomInputBarDelegate");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Row(
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.mic),
            iconSize: 32,
            onPressed: () {
              switchVoice();
            },
          ),
          Expanded(child: _getMainInputField()),
          IconButton(
            icon: Icon(Icons.add),
            iconSize: 32,
            onPressed: () {
              switchExtention();
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    this.textEditingController.dispose();
    super.dispose();
  }
}

enum InputBarStatus {
  Normal, //正常
  Voice, //语音输入
  Extention, //扩展栏
}

abstract class BottomInputBarDelegate {
  ///输入工具栏状态发生变更
  void inputStatusDidChange(InputBarStatus status);

  ///即将发送消息
  void willSendText(String text);

  ///即将发送语音
  void willSendVoice(String path, int duration);

  ///即将开始录音
  void willStartRecordVoice();

  ///即将停止录音
  void willStopRecordVoice();

  ///点击了加号按钮
  void didTapExtentionButton();

  ///输入框内容变化监听
  void onTextChange(String text);
}
