import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:unistapp/photo.dart';
import 'package:photo_view/photo_view.dart';
import 'dart:ui';
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
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Material(
              child: Scaffold(
                  appBar: AppBar(
                    title: Text('식단표 사진'),
                    bottom: TabBar(
                      tabs: const [
                        Tab(text: '기숙사 식당',),
                        Tab(text: '학생 식당',),
                        Tab(text: '교직원 식당',),
                      ],
                      controller: controller,
                    ),
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}