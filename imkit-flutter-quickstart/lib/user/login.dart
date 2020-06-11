import 'package:flutter/material.dart';
import 'package:flutter_rong/other/home_page.dart';
import 'package:flutter_rong/user/until/ajax.dart';
import 'package:flutter_rong/user/until/interface.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class  Login extends StatefulWidget {
  @override
  createState() => new LoginState();
  
}

class LoginData {
  String username;
  String pwd;
}

class LoginState extends State<Login> {
  LoginData loginData = new LoginData();

  IconData eyesIcon = Icons.visibility_off;
  bool obscure = true;
  String loginButtonText = '登录';
  bool loading = false;

  printData() {
    setState(() {
      loading = true;
    });
    print(loginData.username);
    print(loginData.pwd);
    Ajax.post(login, {'username': loginData.username, 'userpassword': loginData.pwd}, (res) async{
      Fluttertoast.showToast(
          msg: '登录成功',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          // timeInSecForIosWeb: 1,
          timeInSecForIos: 1,
          backgroundColor: Colors.grey,
          textColor: Colors.white,
          fontSize: 16.0);
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('token', res['data']['token']);
      prefs.setString('imInfo', res['data']['iminfo']);
      prefs.setString('userid', res['data']['userid']);
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
          (router) => router == null);
      print(res);
    }, (error) {
      setState(() {
      loading = false;
    });
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

  TextEditingController usernameController = TextEditingController();
  TextEditingController pwdController = TextEditingController();
  @override
  void dispose() {
    super.dispose();
    usernameController.dispose();
    pwdController.dispose();
  }

  @override
  void initState() {
    super.initState();
    usernameController.addListener(() {
      loginData.username = usernameController.text;
    });
    pwdController.addListener(() {
      loginData.pwd = pwdController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil(width: 375, height: 667)..init(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
          body: SingleChildScrollView(
              child: Column(
        children: <Widget>[
          //顶部图片
          Container(
            height: ScreenUtil().setHeight(250),
            width: ScreenUtil().setWidth(375),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("lib/imgs/heard.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              child: new Image.asset(
                'lib/imgs/logo.png',
                width: ScreenUtil().setWidth(77.76),
                height: ScreenUtil().setHeight(92.78),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(
                left: ScreenUtil().setWidth(37),
                right: ScreenUtil().setWidth(37),
                top: ScreenUtil().setHeight(43)),
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  //输入账号框
                  Container(
                    padding:
                        EdgeInsets.only(bottom: ScreenUtil().setHeight(15)),
                    child: TextFormField(
                      controller: usernameController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                          // contentPadding: const EdgeInsets.symmetric(vertical: 45.h),
                          border: OutlineInputBorder(),
                          hintText: '请输入账号',
                          prefixIcon: new Icon(Icons.person)),
                      validator: (value) {
                        if (value == '') {
                          return '请输入账号';
                        }
                        return null;
                      },
                      // onChanged: _usernameOnchage,
                    ),
                  ),
                  //输入密码框
                  Container(
                    padding:
                        EdgeInsets.only(bottom: ScreenUtil().setHeight(15)),
                    child: TextFormField(
                        controller: pwdController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: '请输入密码',
                            // labelText: '左上角',
                            prefixIcon: Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(eyesIcon),
                              onPressed: () {
                                // displayPwd();
                                setState(() {
                                  eyesIcon = Icons.visibility;
                                  obscure = !obscure;
                                  if (obscure) {
                                    eyesIcon = Icons.visibility_off;
                                  } else {
                                    eyesIcon = Icons.visibility;
                                  }
                                });
                              },
                            )),
                        validator: (value) {
                          if (value == '') {
                            return '请输入密码';
                          }
                          return null;
                        },
                        obscureText: this.obscure
                        //obscureText: true,是否是密码
                        ),
                  ),
                  //修改密码
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      GestureDetector(
                        child: Text(
                          '修改密码',
                          style: TextStyle(
                            fontSize:
                                ScreenUtil(allowFontScaling: true).setSp(12),
                          ),
                        ),
                        // onTap: jumpChangePwd,
                      ),
                      // Padding(padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),),
                    ],
                  ),
                  Container(
                    width: ScreenUtil().setHeight(301),
                    height: ScreenUtil().setHeight(45),
                    // padding: EdgeInsets.only(top: 10.h),
                    margin: EdgeInsets.only(top: ScreenUtil().setHeight(60)),
                    decoration: BoxDecoration(
                        gradient: loading? LinearGradient(colors: [
                          Color(0xFFffffff),
                          Color(0xFFffffff)
                        ]): LinearGradient(colors: [
                          Color(0xFF1D7DFF),
                          Color(0xFF57ACFF)
                        ]), // 渐变色
                        borderRadius: BorderRadius.circular(5)),
                    child: RaisedButton(
                      child: 
                      Text(
                        loading?'加载中……':'登陆',
                        style: TextStyle(
                            fontSize:
                                ScreenUtil(allowFontScaling: true).setSp(18),
                            color: Colors.white),
                      ),
                      //背景色透明
                      color: Colors.transparent,
                      elevation: 0, // 正常时阴影隐藏
                      highlightElevation: 0,
                      onPressed: loading?null:_loginPass,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ))),
    );
  }


  _loginPass() {
    if (_formKey.currentState.validate()) {
      printData();
    }
  }
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

}
