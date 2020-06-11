import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_rong/user/until/ajax.dart';
import 'package:flutter_rong/user/until/interface.dart';

class OrderListPage extends StatefulWidget {
  Map arguments;
  OrderListPage({Key key, this.arguments}) : super(key: key);
  _OrderListPageState createState() => _OrderListPageState(arguments:arguments);
}

class _OrderListPageState extends State<OrderListPage> {
  List arr = [];
  Map arguments;
  _OrderListPageState({this.arguments});
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(arguments['type'] == 'order'){
      Ajax.post(queryOrder, null, (respone) {
        setState(() {
        arr = respone['data'];
        for(int i= 0;i<arr.length;i++){
          if(arr[i]['contact'] == null){ 
            arr[i]['contact']='默认昵称';
          }
        }
        });
        print(arr);
      }, (error) {
        print(error);
      });
    }else if(arguments['type'] == 'rent') {
      Ajax.post(queryLease, null, (respone) {
        setState(() {
        arr = respone['data'];
        for(int i= 0;i<arr.length;i++){
          if(arr[i]['con_price'] == null){ 
            arr[i]['con_price']= 0.00;
          }
        }
        });
        print(arr);
      }, (error) {
        print(error);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          return Column(
            children: <Widget>[
              RaisedButton(
                onPressed: () async {
                  Navigator.of(context).pop(json.encode(arr[index]));
                },
                child:Text(arr[index]['contact']==null ? '${arr[index]['con_price']}' : arr[index]['contact']),
              ),
              SizedBox(
                height: 0.2,
                child: Container(
                  color: Colors.black,
                ),
              )
            ],
          );
        },
        itemCount: arr.length,
      ),
    );
  }
}
Widget orderList(){
  
}