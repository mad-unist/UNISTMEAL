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

class _MealAppState extends State<MealApp> {
  final List<Meal>? list;
  _MealAppState(this.list);
  @override
  Widget build(BuildContext context) {
    return new Material(
      child: Scaffold(
        appBar: AppBar(
          title: Text('유니스트 식단표'),
        ),
        body: PageView(
          children: [
            exampleGridView(5, 13, "점심"),
            exampleGridView(5, 14, "점심"),
          ],
        ),
      ),
    );
  }
  Widget exampleGridView(month, day, type) {
    List<Meal>? newlist = list?.where((data) => data.month == month && data.day == day).toList();
    return Scaffold(
      body: Column(
        children: [
          Text('${month}월 ${day}일 ${type}', textAlign: TextAlign.center, style: TextStyle(fontSize: 30)),
          new Expanded(
            child: Container(
              child: GridView.builder(
                primary: true,
                shrinkWrap: true,
                itemBuilder: (context, position) {
                  return Container(
                    child: Card(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text('  ${newlist![position].place!}  ${newlist![position].type!}', textAlign: TextAlign.center),
                          Text(newlist![position].content!, textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  );
                },
                itemCount: newlist!.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, //1 개의 행에 보여줄 item 개수
                  childAspectRatio: 1 / 1.5, //item 의 가로 1, 세로 2 의 비율
                  mainAxisSpacing: 10, //수평 Padding
                  crossAxisSpacing: 10, //수직 Padding
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}