import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:unistapp/meal.dart';
import 'package:intl/intl.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class MealApp extends StatefulWidget {
  final List<Meal>? list;
  const MealApp({Key? key, this.list}) : super(key: key);

  @override
  _MealAppState createState() => _MealAppState(list);
}

class _MealAppState extends State<MealApp> with SingleTickerProviderStateMixin{
  TabController? controller;
  ValueNotifier<int> _pageNotifier = new ValueNotifier<int>(0);
  PageController pagecontroller = PageController();
  final List<Meal>? list;
  _MealAppState(this.list);
  List<String> goodList = [];
  List<String> badList = [];
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

  void initState() {
    super.initState();
    controller = TabController(initialIndex: 1, length: 3, vsync: this);
    initializeDateFormatting('ko_KR', null);
    getGoodList();
    getBadList();
  }
  @override
  Widget build(BuildContext context) {
    var children = <Widget>[];
    for (var i = 0; i < 9; i++) {
      var d = DateTime.now().add(Duration(days: i));
      children.add(exampleTabView(d.month, d.day , DateFormat.E('ko_KR').format(d), context));
    }
    return Material(
      child: Scaffold(
        appBar: AppBar(
          title: Text('유니스트 식단표'),
        ),
        body: Column(
          children: [
            Expanded(
              child: PageView(
                children: children,
                controller: pagecontroller,
                onPageChanged: (index){
                  setState(() {
                    _pageNotifier.value = index;
                  });
                },
              ),
            ),
            SmoothPageIndicator(
              controller: pagecontroller,
              count:  9,
              effect:  WormEffect(
                dotHeight: 15,
                dotWidth: 15,
                spacing: 15,
              ),
              onDotClicked: (index){
                setState(() {
                  _pageNotifier.value = index;
                  pagecontroller.animateToPage(index, duration: Duration(milliseconds: 500), curve: Curves.ease);
                });
              },
            )
          ],
        ),
      ),
    );
  }
  Widget exampleTabView(month, day, korday, context) {
    double unitHeightValue = MediaQuery.of(context).size.height * 0.01;
    double multiplier = 3;
    List<Meal>? newlist = list?.where((data) => data.month == month && data.day == day).toList();
    return Scaffold(
      body: Column(
        children: [
          Text('${month}월 ${day}일 (${korday})', textAlign: TextAlign.center, style: TextStyle(fontSize: multiplier * unitHeightValue)),
          Expanded(
            child: Scaffold(
              appBar: AppBar(
                bottom: TabBar(
                  tabs: const [
                    Tab(text: '아침',),
                    Tab(text: '점심',),
                    Tab(text: '저녁',),
                  ],
                  controller: controller,
                ),
                toolbarHeight: 0,
              ),
              body: TabBarView(
                physics: NeverScrollableScrollPhysics(),
                children: [
                  exampleGridview(newlist?.where((data) => data.time == "아침").toList(), context),
                  exampleGridview(newlist?.where((data) => data.time == "점심").toList(), context),
                  exampleGridview(newlist?.where((data) => data.time == "저녁").toList(), context),
                ],
                controller: controller,
              ),
            ),
          ),
        ],
      ),
    );
  }

  exampleGridview(List<Meal>? glist, context) {
    return Container(
      child: GridView.builder(
        primary: true,
        shrinkWrap: true,
        itemBuilder: (context, position) {
          double unitHeightValue = MediaQuery.of(context).size.height * 0.01;
          double uniWidthValue = MediaQuery.of(context).size.width * 0.01;
          double multiplier = 3.5;
          return Container(
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)
              ),
              color: goodList.any((element) => (glist?[position].content)!.contains(element)) ? Colors.lightGreen[50] : badList.any((element) => (glist?[position].content)!.contains(element)) ? Colors.pink[50] : Colors.lightBlue[50],
              child:  Stack(
                children: <Widget>[
                  Container(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Column(
                        children: [
                          Text('  ${glist?[position].place}  ${glist?[position].type}', textAlign: TextAlign.start, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 4 * uniWidthValue,),),
                          Divider(
                            thickness: 2,
                            indent: 20,
                            endIndent: 20,
                            color: goodList.any((element) => (glist?[position].content)!.contains(element)) ? Colors.lightGreen : badList.any((element) => (glist?[position].content)!.contains(element)) ? Colors.pink : Colors.lightBlue,
                          )
                        ],
                      ),
                    ),
                    padding: EdgeInsets.only(top: 10, bottom: 5,),
                  ),
                  Container(
                    child: Align(
                      alignment: Alignment.center,
                      child: Text((glist?[position].content)!, textAlign: TextAlign.center, style: TextStyle(height: 1.5, fontSize: multiplier * uniWidthValue,),),
                    ),
                    padding: EdgeInsets.only(top: 5,),
                  ),
                  Container(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Text('${glist![position].calorie!}Kcal',  style: TextStyle(fontSize: multiplier * uniWidthValue,),),
                    ),
                    padding: EdgeInsets.only(bottom: 1.5 * uniWidthValue,),
                  ),
                ],
              ),
            ),
          );
        },
        itemCount: glist!.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, //1 개의 행에 보여줄 item 개수
          childAspectRatio: 1 / 1.5, //item 의 가로 1, 세로 2 의 비율
          mainAxisSpacing: 0.01 * MediaQuery.of(context).size.width, //수평 Padding
          crossAxisSpacing: 0.01 * MediaQuery.of(context).size.width, //수직 Padding
        ),
      ),
    );
  }


}