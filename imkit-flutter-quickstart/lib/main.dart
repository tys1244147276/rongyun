import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart' as prefix ;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'im/util/event_bus.dart';
import 'other/home_page.dart';
import 'router.dart';
import 'user/login.dart';

void main() {
  runApp(new MyApp());
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

  // if (Platform.isAndroid) {
  //   // 以下两行 设置android状态栏为透明的沉浸。写在组件渲染之后，是为了在渲染后进行set赋值，覆盖状态栏，
  //   //写在渲染之前MaterialApp组件会覆盖掉这个值。
  //   SystemUiOverlayStyle systemUiOverlayStyle =
  //       SystemUiOverlayStyle(statusBarColor: Colors.transparent);
  //   SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  // }
}

class MyApp extends StatefulWidget {

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  AppLifecycleState currentState = AppLifecycleState.resumed;
  String token;

  @override
  void initState() {
    super.initState();
    
    checkout();

    WidgetsBinding.instance.addObserver(this);

    prefix.RongcloudImPlugin.onMessageReceivedWrapper = (prefix.Message msg, int left, bool hasPackage, bool offline) {
      String hasP = hasPackage ? "true":"false";
      String off = offline ? "true":"false";
      print("object onMessageReceivedWrapper objName:"+msg.content.getObjectName()+" msgContent:"+msg.content.encode()+" left:"+left.toString()+" hasPackage:"+hasP+" offline:"+off);
      if(currentState == AppLifecycleState.paused) {
        _postLocalNotification(msg,left);
      }else {
        //通知其他页面收到消息
        EventBus.instance.commit(EventKeys.ReceiveMessage, {"message":msg,"left":left,"hasPackage":hasPackage});
      }
    };

    prefix.RongcloudImPlugin.onDataReceived = (Map map) {
      print("object onDataReceived " + map.toString());
    };
  }

  checkout() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token');
    });
  }

  void _postLocalNotification(prefix.Message msg, int left) async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid =
    new AndroidInitializationSettings("app_icon");// app_icon 所在目录为 res/drawable/
    var initializationSettingsIOS = new IOSInitializationSettings(requestAlertPermission: true,requestSoundPermission: true);
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid,initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: null);

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'your channel id', 'your channel name', 'your channel description',
    importance: Importance.Max, priority: Priority.High, ticker: '本地通知');


    var platformChannelSpecifics = NotificationDetails(
    androidPlatformChannelSpecifics, null);

    String content = "测试本地通知";

    await flutterLocalNotificationsPlugin.show(
    0, 'RongCloud IM', content, platformChannelSpecifics,
    payload: 'item x');
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: MaterialApp(
      onGenerateRoute: onGenerateRoute,
      theme: ThemeData(primaryColor: Colors.blue),
      home:  token == null ? Login() : HomePage(),
      // home: HomePage(),
      // home: Login(),
    )
    );
   
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("--" + state.toString());
    currentState = state;
    switch (state) {
      case AppLifecycleState.inactive: // 处于这种状态的应用程序应该假设它们可能在任何时候暂停。
        break;
      case AppLifecycleState.resumed:// 应用程序可见，前台
        break;
      case AppLifecycleState.paused: // 应用程序不可见，后台
        break;
      // case AppLifecycleState.detached: // 申请将暂时暂停
      //   break;
      case AppLifecycleState.suspending:
        break;
    }
  }  
}
