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

  void initState() {
    super.initState();
    controller = TabController(length: 2, vsync: this);
    goodList.add("돈까스");
    goodList.add("피자");
    badList.add("피망");
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
      ),
    );
  }

  exampleListview(List <String>? bookmarkList, Color? col){
    return Container(
      child: ListView.builder(
        itemBuilder: (context, position) {
          MediaQueryData queryData = MediaQuery.of(context);
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

                      },
                      child: Container(
                        width: queryData.size.width * 0.2,
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
                  child: Text((bookmarkList?[position])!, textAlign: TextAlign.center,),
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