import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:unistapp/meal.dart';
import 'package:intl/intl.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class NotificationApp extends StatefulWidget {
  final List<Meal>? list;
  const NotificationApp({Key? key, this.list}) : super(key: key);

  @override
  _NotificationAppState createState() => _NotificationAppState(list);
}

class _NotificationAppState extends State<NotificationApp> with SingleTickerProviderStateMixin {
  TabController? controller;
  final ValueNotifier<int> _pageNotifier = new ValueNotifier<int>(0);
  final pagecontroller = PageController();
  final List<Meal>? list;

  _NotificationAppState(this.list);

  void initState() {
    super.initState();
    controller = TabController(length: 3, vsync: this);
    initializeDateFormatting('ko_KR', null);
  }

  @override
  Widget build(BuildContext context) {

  }
}