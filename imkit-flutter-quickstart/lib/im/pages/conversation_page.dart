import 'package:flutter/material.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

import 'item/conversation_item.dart';
import 'item/bottom_input_bar.dart';
import 'item/widget_util.dart';

import '../util/style.dart';
import '../util/time.dart';
import '../util/user_info_datesource.dart';
import '../util/media_util.dart';
import '../util/event_bus.dart';
import 'package:fluttertoast/fluttertoast.dart';

enum ConversationStatus {
  Normal, //正常
  VoiceRecorder, //语音输入，页面中间回弹出录音的 gif
}

class ConversationPage extends StatefulWidget {
  final Map arguments;
  ConversationPage({Key key, this.arguments}) : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      _ConversationPageState(arguments: this.arguments);
}

class _ConversationPageState extends State<ConversationPage>
    implements ConversationItemDelegate, BottomInputBarDelegate {
  Map arguments;
  int conversationType;
  String targetId;

  List messageDataSource = new List(); //消息数组
  List<Widget> extWidgetList = new List(); //加号扩展栏的 widget 列表
  bool showExtentionWidget = false; //是否显示加号扩展栏内容
  ConversationStatus currentStatus; //当前输入工具栏的状态
  String textDraft = ''; //草稿内容

  ScrollController _scrollController = ScrollController();
  BaseInfo info;
  BottomInputBar bottomInputBar;

  _ConversationPageState({this.arguments});
  @override
  void initState() {
    super.initState();
    _requestPermissions();

    conversationType = arguments["coversationType"];
    targetId = arguments["targetId"];
    currentStatus = ConversationStatus.Normal;

    if (conversationType == RCConversationType.Private) {
      this.info = UserInfoDataSource.getUserInfo(targetId);
    } else {
      this.info = UserInfoDataSource.getGroupInfo(targetId);
    }

    //增加 IM 监听
    _addIMHandler();
    //获取默认的历史消息
    onGetHistoryMessages();
    //增加加号扩展栏的 widget
    _initExtentionWidgets();
    //获取草稿内容
    onGetTextMessageDraft();

    _scrollController.addListener(() {
      //此处要用 == 而不是 >= 否则会触发多次
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _pullMoreHistoryMessage();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (textDraft == null) {
      textDraft = '';
    }
    RongcloudImPlugin.saveTextMessageDraft(
        conversationType, targetId, textDraft);
    RongcloudImPlugin.clearMessagesUnreadStatus(conversationType, targetId);
    EventBus.instance.commit(EventKeys.ConversationPageDispose, null);
    EventBus.instance.removeListener(EventKeys.ReceiveMessage);
  }

  void _pullMoreHistoryMessage() async {
    //todo 加载更多历史消息
  }

  ///请求相应的权限，只会在此一次触发
  void _requestPermissions() {
    MediaUtil.instance.requestPermissions();
  }

  _addIMHandler() {
    EventBus.instance.addListener(EventKeys.ReceiveMessage, (map) {
      Message msg = map["message"];
      // int left = map["left"];
      if (msg.targetId == this.targetId) {
        _insertOrReplaceMessage(msg);
      }
      _refreshUI();
    });

    RongcloudImPlugin.onMessageSend =
        (int messageId, int status, int code) async {
      Message msg = await RongcloudImPlugin.getMessage(messageId);
      if (msg.targetId == this.targetId) {
        _insertOrReplaceMessage(msg);
      }
      _refreshUI();
    };
  }

  onGetHistoryMessages() async {
    print("get history message");

    List msgs = await RongcloudImPlugin.getHistoryMessage(
        conversationType, targetId, 0, 20);
    if (msgs != null) {
      msgs.sort((a, b) => b.sentTime.compareTo(a.sentTime));
      messageDataSource = msgs;
      RongcloudImPlugin.getRemoteHistoryMessages(
        conversationType, targetId, 1589252427357 , 20, (List msgList,int code) {
        if(code == 0) {
          for(Message msg in msgList) {
            print("getRemoteHistoryMessages  success "+ msg.messageId.toString());
          }
        }else {
          print("getRemoteHistoryMessages error "+code.toString());
        }
      });
    }
    _refreshUI();
  }

  onGetTextMessageDraft() async {
    textDraft =
        await RongcloudImPlugin.getTextMessageDraft(conversationType, targetId);
    bottomInputBar.setTextContent(textDraft);
    // _refreshUI();
  }

  void _insertOrReplaceMessage(Message message) {
    int index = -1;
    for (int i = 0; i < messageDataSource.length; i++) {
      Message msg = messageDataSource[i];
      if (msg.messageId == message.messageId) {
        index = i;
        break;
      }
    }
    //如果数据源中相同 id 消息，那么更新对应消息，否则插入消息
    if (index >= 0) {
      messageDataSource[index] = message;
    } else {
      messageDataSource.insert(0, message);
    }
    _refreshUI();
  }

  Widget _getExtentionWidget() {
    if (showExtentionWidget) {
      return Container(
          height: 200,
          child: GridView.count(
            physics: new NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            padding: EdgeInsets.all(10),
            children: extWidgetList,
          ));
    } else {
      return WidgetUtil.buildEmptyWidget();
    }
  }

  void _deleteMessage(Message message) {
    //删除消息完成需要刷新消息数据源
    RongcloudImPlugin.deleteMessageByIds([message.messageId], (int code) {
      onGetHistoryMessages();
      _refreshUI();
    });
  }

  void _recallMessage(Message message) async {
    RecallNotificationMessage recallNotifiMessage =
        await RongcloudImPlugin.recallMessage(message, "");
    if (recallNotifiMessage != null) {
      message.content = recallNotifiMessage;
      _insertOrReplaceMessage(message);
    } else {
      showShortToast("撤回失败");
    }
  }

  void showShortToast(String message) {
    Fluttertoast.showToast(
        msg: message, toastLength: Toast.LENGTH_SHORT, timeInSecForIos: 1);
  }

  /// 禁止随意调用 setState 接口刷新 UI，必须调用该接口刷新 UI
  void _refreshUI() {
    if (this.mounted) {
      setState(() {});
    }
  }

  void _initExtentionWidgets() {
    Widget imageWidget =
        WidgetUtil.buildExtentionWidget(Icons.photo, "相册", () async {
      String imgPath = await MediaUtil.instance.pickImage();
      if (imgPath == null) {
        return;
      }
      print("imagepath " + imgPath);
      ImageMessage imgMsg = ImageMessage.obtain(imgPath);
      Message msg = await RongcloudImPlugin.sendMessage(
          conversationType, targetId, imgMsg);
      _insertOrReplaceMessage(msg);
    });

    Widget cameraWidget =
        WidgetUtil.buildExtentionWidget(Icons.camera, "相机", () async {
      String imgPath = await MediaUtil.instance.takePhoto();
      if (imgPath == null) {
        return;
      }

      print("imagepath " + imgPath);
      ImageMessage imgMsg = ImageMessage.obtain(imgPath);
      Message msg = await RongcloudImPlugin.sendMessage(
          conversationType, targetId, imgMsg);
      _insertOrReplaceMessage(msg);
    });

    Widget videoWidget =
        WidgetUtil.buildExtentionWidget(Icons.video_call, "视频", () async {
      print("push to video record page");
      Map map = {"coversationType": conversationType, "targetId": targetId};
      Navigator.pushNamed(context, "/video_record", arguments: map);
    });

    Widget orderWidget = WidgetUtil.buildExtentionWidget(
        Icons.insert_drive_file, "采购订单", () async {
      print("push to cuntom page");
      Map map = {"coversationType": conversationType, "targetId": targetId, 'type': 'order'};
      Navigator.pushNamed(context, "/order_list_page",arguments: map).then((value) {
        _willSendOrder(value);
      });
    });

    Widget rentWidget = WidgetUtil.buildExtentionWidget(
        Icons.add_a_photo, "租赁", () async {
      print("push to rent page");
      Map map = {"coversationType": conversationType, "targetId": targetId, 'type': 'rent'};
      Navigator.pushNamed(context, "/order_list_page",arguments: map).then((value) {
        _willSendRent(value);
      });
    });

    extWidgetList.add(imageWidget);
    extWidgetList.add(cameraWidget);
    extWidgetList.add(videoWidget);
    extWidgetList.add(orderWidget);
    extWidgetList.add(rentWidget);
  }
    
  bool _needShowTime(int index) {
    bool needShow = false;
    //消息是逆序的
    if (index == messageDataSource.length - 1) {
      //第一条消息一定显示时间
      needShow = true;
    } else {
      //如果满足条件，则显示时间
      Message lastMessage = messageDataSource[index + 1];
      Message curMessage = messageDataSource[index];
      if (TimeUtil.needShowTime(lastMessage.sentTime, curMessage.sentTime)) {
        needShow = true;
      }
    }
    return needShow;
  }

  ///长按录制语音的 gif 动画
  Widget _buildExtraCenterWidget() {
    if (this.currentStatus == ConversationStatus.VoiceRecorder) {
      return WidgetUtil.buildVoiceRecorderWidget();
    } else {
      return WidgetUtil.buildEmptyWidget();
    }
  }

  void _showExtraCenterWidget(ConversationStatus status) {
    this.currentStatus = status;
    _refreshUI();
  }

  // 底部输入栏
  Widget _buildBottomInputBar() {
    bottomInputBar = BottomInputBar(this);
    return bottomInputBar;
  }

  @override
  Widget build(BuildContext context) {
    if(this.info.name == null){
        this.info.name = '';
      }
    return Scaffold(
        appBar: AppBar(
          title: Text('与${this.info.name}的会话',
              style: TextStyle(color: Colors.black)),
          iconTheme: IconThemeData(
            color: Colors.black, //修改颜色
          ),
          elevation: 0,
          backgroundColor: Colors.white,
          centerTitle: true,
        ),
        body: Container(
          child: Stack(
            children: <Widget>[
              SafeArea(
                child: Column(
                  children: <Widget>[
                    Flexible(
                      child: Column(
                        children: <Widget>[
                          Flexible(
                            child: ListView.separated(
                              key: UniqueKey(),
                              shrinkWrap: true,

                              //因为消息超过一屏，ListView 很难滚动到最底部，所以要翻转显示，同时数据源也要逆���
                              reverse: true,
                              controller: _scrollController,
                              itemCount: messageDataSource.length,
                              itemBuilder: (BuildContext context, int index) {
                                if (messageDataSource.length != null &&
                                    messageDataSource.length > 0) {
                                  return ConversationItem(
                                      this,
                                      messageDataSource[index],
                                      _needShowTime(index));
                                } else {
                                  return WidgetUtil.buildEmptyWidget();
                                }
                              },
                              separatorBuilder:
                                  (BuildContext context, int index) {
                                return Container(
                                  height: 10,
                                  width: 1,
                                );
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      height: 55,
                      child: _buildBottomInputBar(),
                    ),
                    _getExtentionWidget(),
                  ],
                ),
              ),
              _buildExtraCenterWidget(),
            ],
          ),
        ));
  }

  @override
  void didTapMessageItem(Message message) {
    print("didTapMessageItem " + message.objectName);
    if (message.content is VoiceMessage) {
      VoiceMessage msg = message.content;
      MediaUtil.instance.startPlayAudio(msg.remoteUrl);
    } else if (message.content is ImageMessage) {
      Navigator.pushNamed(context, "/image_preview", arguments: message);
    } else if (message.content is SightMessage) {
      Navigator.pushNamed(context, "/video_play", arguments: message);
    }
  }

  @override
  void didLongPressMessageItem(Message message, Offset tapPos) {
    Map<String, String> actionMap = {
      RCLongPressAction.DeleteKey: RCLongPressAction.DeleteValue,
      RCLongPressAction.RecallKey: RCLongPressAction.RecallValue,
    };
    WidgetUtil.showLongPressMenu(context, tapPos, actionMap, (String key) {
      if (key == RCLongPressAction.DeleteKey) {
        _deleteMessage(message);
      } else if (key == RCLongPressAction.RecallKey) {
        _recallMessage(message);
      }
      print("当前选中的是 " + key);
    });
  }

  @override
  void didTapUserPortrait(String userId) {
    print("点击了用户头像 " + userId);
  }

  @override
  void willSendText(String text) async {
    TextMessage msg = new TextMessage();
    msg.content = text;
    Message message =
        await RongcloudImPlugin.sendMessage(conversationType, targetId, msg);
    _insertOrReplaceMessage(message);
  }

   _willSendOrder(String value) async {
      TextMessage msg = new TextMessage();
      msg.content = value;
      /*测试自定义信息*/
      msg.extra = "customize";
      Message message = await RongcloudImPlugin.sendMessage(
          conversationType, targetId, msg);
      print("send message add mentionedInfo:" +
          message.content.getObjectName() +
          " msgContent:" +
          message.content.encode());
      _insertOrReplaceMessage(message);
    }
   _willSendRent(String value) async {
      TextMessage msg = new TextMessage();
      msg.content = value;
      /*测试自定义信息*/
      msg.extra = "customizeRent";
      Message message = await RongcloudImPlugin.sendMessage(
          conversationType, targetId, msg);
      print("send message add mentionedInfo:" +
          message.content.getObjectName() +
          " msgContent:" +
          message.content.encode());
      _insertOrReplaceMessage(message);
    }
  @override
  void willSendVoice(String path, int duration) async {
    VoiceMessage msg = VoiceMessage.obtain(path, duration);
    Message message =
        await RongcloudImPlugin.sendMessage(conversationType, targetId, msg);
    _insertOrReplaceMessage(message);
  }

  @override
  void didTapExtentionButton() {}

  @override
  void inputStatusDidChange(InputBarStatus status) {
    if (status == InputBarStatus.Extention) {
      showExtentionWidget = true;
    } else {
      showExtentionWidget = false;
    }
    _refreshUI();
  }

  @override
  void onTextChange(String text) {
    // print('input ' + text);
    textDraft = text;
  }

  @override
  void willStartRecordVoice() {
    _showExtraCenterWidget(ConversationStatus.VoiceRecorder);
  }

  @override
  void willStopRecordVoice() {
    _showExtraCenterWidget(ConversationStatus.Normal);
  }
}
