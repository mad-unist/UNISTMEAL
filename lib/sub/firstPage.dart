import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:unistapp/meal.dart';

class MealApp extends StatefulWidget {
  final List<Meal>? list;
  const MealApp({Key? key, this.list}) : super(key: key);

  @override
  _MealAppState createState() => _MealAppState(list);
}

class _MealAppState extends State<MealApp> with SingleTickerProviderStateMixin{
  TabController? controller;
  final List<Meal>? list;
  _MealAppState(this.list);
  void initState() {
    super.initState();
    controller = TabController(length: 3, vsync: this);
  }
  @override
  Widget build(BuildContext context) {
    return new Material(
      child: Scaffold(
        appBar: AppBar(
          title: Text('유니스트 식단표'),
        ),
        body: PageView(
          children: [
            exampleTabView(5, 11),
            exampleTabView(5, 12),
            exampleTabView(5, 13),
            exampleTabView(5, 14),
            exampleTabView(5, 15),
          ],
        ),
      ),
    );
  }
  Widget exampleTabView(month, day) {
    List<Meal>? newlist = list?.where((data) => data.month == month && data.day == day).toList();
    return Scaffold(
      body: Column(
        children: [
          Text('${month}월 ${day}일', textAlign: TextAlign.center, style: TextStyle(fontSize: 30)),
          new Expanded(
            child: Scaffold(
              appBar: AppBar(
                bottom: TabBar(
                  tabs: [
                    Tab(text: '아침',),
                    Tab(text: '점심',),
                    Tab(text: '저녁',),
                  ],
                  controller: controller,
                ),
                toolbarHeight: 0,
              ),
              body: TabBarView(
                children: [
                  exampleGridview(newlist!.where((data) => data.time == "아침").toList()),
                  exampleGridview(newlist!.where((data) => data.time == "점심").toList()),
                  exampleGridview(newlist!.where((data) => data.time == "저녘").toList()),
                ],
                controller: controller,
              ),
            ),
          ),
        ],
      ),
    );
  }

  exampleGridview(List<Meal>? glist) {
    return Container(
      child: GridView.builder(
        primary: true,
        shrinkWrap: true,
        itemBuilder: (context, position) {
          return Container(
            child: Card(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('  ${glist![position].place!}  ${glist![position].type!}', textAlign: TextAlign.center),
                  Text(glist![position].content!, textAlign: TextAlign.center),
                ],
              ),
            ),
          );
        },
        itemCount: glist!.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, //1 개의 행에 보여줄 item 개수
          childAspectRatio: 1 / 1.5, //item 의 가로 1, 세로 2 의 비율
          mainAxisSpacing: 10, //수평 Padding
          crossAxisSpacing: 10, //수직 Padding
        ),
      ),
    );
  }


}