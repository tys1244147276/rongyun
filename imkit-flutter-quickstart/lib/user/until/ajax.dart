import 'dart:convert';

import 'package:dio/dio.dart';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../user_data.dart';

var httpClient = new HttpClient();
Dio dio = Dio();

class Ajax {
  static String baseUrl = 'http://192.168.1.103:8080/imdemo/';
  static Response response;
  static String token;
  static String imtoken;
  static var signature;
  static Options options;

  static clearToken() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('token');
    prefs.clear();
    token = null;
    // Router.navigatorKey.currentState.pushNamedAndRemoveUntil("/jumpPage", ModalRoute.withName("/"));
  }

  static get(
      String url, var paramters, Function success, Function error) async {
    if (token == null) {
      final ref = await SharedPreferences.getInstance();
      token = ref.get('token');
      options = Options(
          contentType: ContentType.parse("application/x-www-form-urlencoded"),
          headers: {
            "token": token,
          });
    }
    try {
      response = await dio.post(baseUrl + url,
          queryParameters: paramters, options: options);
      //获取里面具体值
      print(response);
      if (response.data['success']) {
        success(response.data);
      } else {
        error(response.data);
      }
    } catch (exception) {
      Map data = {'code': exception.message, 'msg': '网络异常，请稍后再试'};
      error(data);
    }
  }

  static post(
      String url, var paramters, Function success, Function error) async {
    if (token == null) {
      final ref = await SharedPreferences.getInstance();
      token = ref.get('token');
      options = Options(
          contentType: ContentType.parse("application/x-www-form-urlencoded"),
          headers: {
            "token": token,
          });
    }
    try {
      response =
          await dio.post(baseUrl + url, data: paramters, options: options);
      //获取里面具体值
      print(response.data);
      if (response.data['code'] == 'E-0003') {
        clearToken();
      } else if (response.data['success']) {
        success(response.data);
      } else {
        error(response.data);
      }
    } catch (exception) {
      Map data = {'code': exception.message, 'msg': '网络异常，请稍后再试'};
      error(data);
    }
  }

   static postIm(
    String url, var paramters, Function success, Function error) async {
    
    final ref = await SharedPreferences.getInstance();
    imtoken = ref.get('imInfo');
    
    String nonce = "rongyuntest";

    String time = new DateTime.now().millisecondsSinceEpoch.toString();

    String sum = RongAppSecret + nonce + time;

    signature = sha1.convert(utf8.encode(sum));


    options = Options(
      contentType: ContentType.parse("application/x-www-form-urlencoded"),
      headers: {
        "App-Key":RongAppKey,
        "Nonce" : nonce,
        "Timestamp": time,
        "Signature": signature,
      }
    );

    try {
      response =
          await dio.post(url, data: paramters, options: options);
      //获取里面具体值
      print(response.data);
      if (response.data['code'] == 200) {
        success();
      } else {
        error(response.data);
      }
    } catch (exception) {
      Map data = {'code': exception, 'msg': '网络异常，请稍后再试'};
      error(data);
    }
  }
}
