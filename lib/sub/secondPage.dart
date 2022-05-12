import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:unistapp/meal.dart';

class MealPhotoApp extends StatefulWidget {
  final List<Meal>? list;
  const MealPhotoApp({Key? key, this.list}) : super(key: key);

  @override
  _MealPhotoAppState createState() => _MealPhotoAppState(list);
}


class _MealPhotoAppState extends State<MealPhotoApp> with SingleTickerProviderStateMixin{
  TabController? controller;
  final List<Meal>? list;
  _MealPhotoAppState(this.list);
  void initState() {
    super.initState();
    controller = TabController(length: 3, vsync: this);
  }
  @override
  Widget build(BuildContext context) {
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
                children: [
                    FadeInImage.assetNetwork(placeholder: 'assets/images/loading.png', image: 'https://uspace.unist.ac.kr/Storage/Cabinet/Editor/0/1172/1220508162048079110/Content/2022051010070719481fc6-2f7b-4338-85c5-16397461db35.png', fit: BoxFit.contain,),
                    Image.network('https://uspace.unist.ac.kr/Storage/Cabinet/Editor/0/1172/1220506175135938104/Content/2022050617511408dfb69a-302c-4bcf-89c2-f6161c39e893.jpg', fit: BoxFit.contain,),
                    Image.network('https://uspace.unist.ac.kr/Storage/Cabinet/Editor/0/1172/1220506112846156088/Content/20220506113523a3c1dba1-353a-4297-af2a-ca12e7783e95.png', fit: BoxFit.contain,),
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