import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:unistapp/meal.dart';
import 'package:intl/intl.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class RandomApp extends StatefulWidget {
  final List<Meal>? list;
  const RandomApp({Key? key, this.list}) : super(key: key);

  @override
  _RandomAppState createState() => _RandomAppState(list);
}

class _RandomAppState extends State<RandomAppp> with SingleTickerProviderStateMixin {
  TabController? controller;
  final pagecontroller = PageController();
  final List<Meal>? list;

  _RandomAppState(this.list);

  void initState() {
    super.initState();
    controller = TabController(length: 3, vsync: this);
    initializeDateFormatting('ko_KR', null);
  }

  @override
  Widget build(BuildContext context) {

  }
}