import 'dart:io';

import 'package:flutter/material.dart';
import 'package:unistapp/meal.dart';
import 'package:unistapp/sub/firstPage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

import 'package:unistapp/sub/secondPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}
class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin{
  TabController? controller;
  List<Meal> mealList = List.empty(growable: true);
  @override
  void initState() {
    super.initState();
    controller = TabController(length: 2, vsync: this);
    Future<String> fetchPost() async {
      final response = await http.get(Uri.parse('https://unist-meal-backend.herokuapp.com/menu/v1/menus?format=json'));
      print(response.body);
      print(utf8.decode(response.bodyBytes));
      setState(() {
        var _text = utf8.decode(response.bodyBytes);
        var data = jsonDecode(_text)['data'] as List;
        data.forEach((element) {
          print(element);
          mealList.add(Meal.fromJson(element));
          print(Meal.fromJson(element).day);
          print(Meal.fromJson(element).month);
        });
      });
      print("YES!!!");
      return "Sucessful";
    }
    fetchPost();
    mealList.add(Meal(place: "기숙사식당", type: "일품", time: "점심", content: "우동", month: 5, day: 13, calorie: 1100));
    mealList.add(Meal(place: "기숙사식당", type: "할랄", time: "점심", content: "타코", month: 5, day: 13, calorie: 1100));
    mealList.add(Meal(place: "학생식당", type: "한식", time: "점심", content: "떡볶이", month: 5, day: 13, calorie: 1100));
    mealList.add(Meal(place: "교직원식당", type: "", time: "점심", content: "백반\n소고기국", month: 5, day: 13, calorie: 1100));
    mealList.add(Meal(place: "기숙사식당", type: "일품", time: "점심", content: "라면", month: 5, day: 14, calorie: 1100));
    mealList.add(Meal(place: "기숙사식당", type: "할랄", time: "점심", content: "샐러드", month: 5, day: 14, calorie: 1100));
    mealList.add(Meal(place: "학생식당", type: "한식", time: "점심", content: "돈까스", month: 5, day: 14, calorie: 1100));
    mealList.add(Meal(place: "교직원식당", type: "", time: "점심", content: "스테이크", month: 5, day: 14, calorie: 1100));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: TabBarView(
<<<<<<< HEAD
          physics: NeverScrollableScrollPhysics(),
          children: <Widget>[MealApp(list:mealList), MealPhotoApp()],
=======
          children: <Widget>[MealApp(list:mealList), MealPhotoApp(list:[])],
>>>>>>> 73f18745a7323ddafa9f3bd3e3c69ca504f3432b
          controller: controller,
        ),
        bottomNavigationBar: TabBar(
          tabs: <Tab>[
            Tab(icon: Icon(Icons.home, color: Colors.blue),) ,
            Tab(icon: Icon(Icons.image, color: Colors.blue),),
            //Tab(icon: Icon(Icons.search, color: Colors.blue),),
            //Tab(icon: Icon(Icons.restaurant_menu, color: Colors.blue),)
          ], controller: controller,
        )
    );
  }

  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
  }
}

class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}