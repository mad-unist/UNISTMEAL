import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:unistapp/meal.dart';
import 'package:unistapp/photo.dart';
import 'package:photo_view/photo_view.dart';

class MealPhotoApp extends StatefulWidget {
  final List<Photo>? list;
  const MealPhotoApp({Key? key, this.list}) : super(key: key);

  @override
  _MealPhotoAppState createState() => _MealPhotoAppState(list);
}

class _MealPhotoAppState extends State<MealPhotoApp> with SingleTickerProviderStateMixin{
  TabController? controller;
  final List<Photo>? list;
  _MealPhotoAppState(this.list);

  void initState() {
    super.initState();
    controller = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    print("PHOTO");
    print(list);
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              title: const Text('식단표 사진'),
            ),
            body: Container(
              child: PhotoTabView(),
            )
        )
    );
  }

  Widget PhotoTabView() {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
              child: Scaffold(
                  appBar: AppBar(
                    bottom: TabBar(
                      tabs: const [
                        Tab(text: '기숙사 식당',),
                        Tab(text: '학생 식당',),
                        Tab(text: '교직원 식당',),
                      ],
                      controller: controller,
                    ),
                    toolbarHeight: 0,
                  ),
                  body: TabBarView(
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      PhotoView(
                        imageProvider: list?.length != 0 ? NetworkImage((list?[0].url)!): Image.asset("assets/images/loading.gif").image,
                        backgroundDecoration: BoxDecoration(color: Colors.transparent),
                      ),
                      PhotoView(
                        imageProvider: list?.length != 0 ? NetworkImage((list?[1].url)!): Image.asset("assets/images/loading.gif").image,
                        backgroundDecoration: BoxDecoration(color: Colors.transparent),
                      ),
                      PhotoView(
                        imageProvider: list?.length != 0 ? NetworkImage((list?[2].url)!): Image.asset("assets/images/loading.gif").image,
                        backgroundDecoration: BoxDecoration(color: Colors.transparent),
                      ),
                    ],
                    controller: controller,
                  )
              )
          ),
        ],
      ),
    );
  }
}