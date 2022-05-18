import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:unistapp/meal.dart';
import 'package:intl/intl.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:unistapp/restaurant.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

class RecommendationApp extends StatefulWidget {
  final List<Restaurant>? list;
  const RecommendationApp({Key? key, this.list}) : super(key: key);

  @override
  _RecommendationAppState createState() => _RecommendationAppState(list);
}

class _RecommendationAppState extends State<RecommendationApp> with SingleTickerProviderStateMixin {
  TabController? controller;
  final List<Restaurant>? list;
  _RecommendationAppState(this.list);

  void initState() {
    super.initState();
    controller = TabController(length: 2, vsync: this);
    initializeDateFormatting('ko_KR', null);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: AppBar(
          title: Text('유니스트 추천 맛집'),
          bottom: TabBar(
            tabs: const [
              Tab(text: '홀',),
              Tab(text: '배달',),
            ],
            controller: controller,
          ),
        ),
        body: TabBarView(
          physics: NeverScrollableScrollPhysics(),
          children: [
            exampleListview(list?.where((data) => data.type == "홀").toList()),
            exampleListview(list?.where((data) => data.type == "배달").toList()),
          ],
          controller: controller,
        ),
      ),
    );
  }

  exampleListview(List <Restaurant>? restaurantList){
    return Container(
      child: ListView.builder(
        itemBuilder: (context, position) {
          MediaQueryData queryData = MediaQuery.of(context);
          return Container(
            child: Slidable(
              endActionPane: ActionPane(
                extentRatio: 0.25,
                motion: ScrollMotion(),
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(0.025 * queryData.size.width, 0, 0, 0),
                    child: GestureDetector(
                      onTap: () {
                        FlutterPhoneDirectCaller.callNumber((restaurantList?[position].phone)!);
                        print("Call");
                      },
                      child: Container(
                        width: queryData.size.width * 0.2,
                        decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(20)
                        ),
                        child: Align(
                          alignment: Alignment.center,
                          child: Icon(Icons.phone, color: Colors.white,),
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
                color: Colors.lightBlue[50],
                child: Column(
                  children: [
                    Container(
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  child: Text((restaurantList?[position].name)!, textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold),),
                                  padding: EdgeInsets.fromLTRB(0.1 * queryData.size.width, 0, 0, 0),
                                ),
                                Spacer(),
                                Container(
                                  child: Text((restaurantList?[position].place)!, textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold),),
                                  padding: EdgeInsets.fromLTRB(0, 0, 0.1 * queryData.size.width, 0),
                                ),
                              ],
                            ),
                            Divider(
                              thickness: 2,
                              indent: 20,
                              endIndent: 20,
                              color: Colors.lightBlue,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text((restaurantList?[position].content)!, textAlign: TextAlign.center, style: TextStyle(height: 2,),),
                      ),
                      padding: EdgeInsets.fromLTRB(0.05 * queryData.size.width, 0, 0, 0),
                    ),
                    Container(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text((restaurantList?[position].phone)!, textAlign: TextAlign.center,),
                      ),
                      padding: EdgeInsets.fromLTRB(0.05 * queryData.size.width, 0, 0, 0),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        itemCount: restaurantList!.length,
      ),
    );
  }


}