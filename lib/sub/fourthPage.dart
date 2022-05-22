import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:unistapp/meal.dart';
import 'package:intl/intl.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

class BookmarkApp extends StatefulWidget {
  const BookmarkApp({Key? key,}) : super(key: key);

  @override
  _BookmarkAppState createState() => _BookmarkAppState();
}

class _BookmarkAppState extends State<BookmarkApp> with SingleTickerProviderStateMixin {
  TabController? controller;
  List<String> goodList = [];
  List<String> badList = [];
  _BookmarkAppState();

  void setGoodList() async{
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setStringList("goodList", goodList);
      print(prefs.getStringList("goodList")!);
    });
  }
  void setBadList() async{
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setStringList("badList", badList);
    });
  }
  void getGoodList() async{
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      goodList = prefs.getStringList("goodList")!;
    });
  }
  void getBadList() async{
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      badList = prefs.getStringList("badList")!;
    });
  }

  createAlertDialog(BuildContext context){
    TextEditingController customController = TextEditingController();
    return showDialog(context: context, builder: (context){
      return AlertDialog(
        title: Text("키워드 입력"),
        content: TextField(
          controller: customController,
          decoration: InputDecoration(hintText: "Ex)돈까스, 피망"),
        ),
        actions: <Widget>[
          MaterialButton(
            child: Text('취소'),
            minWidth: 0.3,
            onPressed: () {
              Navigator.pop(context, "Cancel");
            },
          ),
          MaterialButton(
            child: Text('선호'),
            minWidth: 0.3,
            onPressed: () {
              Navigator.pop(context, customController.text);
              if(customController.text.isNotEmpty) {
                goodList.add(customController.text);
                setGoodList();
              }
            },
          ),
          MaterialButton(
            child: Text('불호'),
            minWidth: 0.3,
            onPressed: () {
              Navigator.pop(context, customController.text);
              if(customController.text.isNotEmpty) {
                badList.add(customController.text);
                setBadList();
              }
            },
          ),
        ],
      );
    });
  }

  void initState() {
    super.initState();
    controller = TabController(length: 2, vsync: this);
    getGoodList();
    getBadList();
    goodList.add("우동");
    setGoodList();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: AppBar(
          title: Text('음식 즐겨찾기'),
          bottom: TabBar(
            tabs: const [
              Tab(text: '선호 음식',),
              Tab(text: '불호 음식',),
            ],
            controller: controller,
          ),
        ),
        body: TabBarView(
          physics: NeverScrollableScrollPhysics(),
          children: [
            exampleListview(goodList, Colors.lightGreen[50]),
            exampleListview(badList, Colors.pink[50]),
          ],
          controller: controller,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            createAlertDialog(context);
          },
          child: Icon(Icons.add),
        ),
      ),
    );
  }

  exampleListview(List <String>? bookmarkList, Color? col){
    return Container(
      child: ListView.builder(
        itemBuilder: (context, position) {
          MediaQueryData queryData = MediaQuery.of(context);
          double unitHeightValue = MediaQuery.of(context).size.height * 0.01;
          return Container(
            alignment: Alignment.center,
            child: Slidable(
              endActionPane: ActionPane(
                extentRatio: 0.25,
                motion: ScrollMotion(),
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(0.025 * queryData.size.width, 0, 0, 0),
                    child: GestureDetector(
                      onTap: () {
                        if (col == Colors.lightGreen[50]){
                          goodList.remove((bookmarkList?[position])!);
                          setGoodList();
                        }
                        else {
                          badList.remove((bookmarkList?[position])!);
                          setBadList();
                        }
                      },
                      child: Container(
                        width: queryData.size.width * 0.2,
                        height: 0.1 * queryData.size.height,
                        decoration: BoxDecoration(
                            color: Colors.grey[700],
                            borderRadius: BorderRadius.circular(20)
                        ),
                        child: Align(
                          alignment: Alignment.center,
                          child: Icon(Icons.delete, color: Colors.white,),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)
                ),
                color: col,
                child: Container(
                  alignment: Alignment.center,
                  height: 0.1 * queryData.size.height,
                  width: 0.98 * queryData.size.width,
                  child: Text((bookmarkList?[position])!, textAlign: TextAlign.center, style: TextStyle(fontSize: 2.5 * unitHeightValue,),),
                ),
              ),
            ),
          );
        },
        itemCount: bookmarkList!.length,
      ),
    );
  }
}