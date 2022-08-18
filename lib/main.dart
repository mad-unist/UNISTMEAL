import 'dart:io';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:new_version/new_version.dart';
import 'package:unistapp/meal.dart';
import 'package:unistapp/restaurant.dart';
import 'package:unistapp/photo.dart';
import 'package:unistapp/sub/firstPage.dart';
import 'package:http/http.dart' as http;
import 'package:unistapp/sub/fourthPage.dart';
import 'dart:convert';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'package:unistapp/sub/secondPage.dart';
import 'package:unistapp/sub/thirdPage.dart';
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]);
  initializeDateFormatting('ko_KR', null);
  KakaoSdk.init(nativeAppKey: '1fdb8c2a87d39a7446137dc2963ee6a4');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, child) {
        return MediaQuery(
          child: child!,
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
        );
      },
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
        primaryColor: Colors.blue[500],
        textTheme: GoogleFonts.notoSansTextTheme(
          Theme.of(context).textTheme
        ),
        scaffoldBackgroundColor: Colors.white,

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
class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver{
  PageController _pageController = PageController();
  List<Meal> mealList = List.empty(growable: true);
  List<Photo> photoList = List.empty(growable: true);
  List<Restaurant> restList = List.empty(growable: true);
  int _currentIndex = 0;
  List pageList = [];

  createPage() {
    pageList.clear();
    for (var i = 0; i < 9; i++) {
      var d = DateTime.now().add(Duration(days: i));
      pageList.add(d);
    }
    setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        setState(() {
          createPage();
        });
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pageController = PageController();
    _checkVersion();
    Future<String> fetchPost() async {
      final response = await http.get(Uri.parse('https://unist-meal-backend.herokuapp.com/menu/v1/menus?format=json'));
      setState(() {
        var _text = utf8.decode(response.bodyBytes);
        var data = jsonDecode(_text)['data'] as List;
        data.forEach((element) {
          mealList.add(Meal.fromJson(element));
        });
      });
      return "Sucessful";
    }
    fetchPost();
    // photo API 연동
    Future<String> fetchPhotos() async {
      final response = await http.get(Uri.parse('https://unist-meal-backend.herokuapp.com/photo/v1/photos?format=json'));
      setState(() {
        var _text = utf8.decode(response.bodyBytes);
        var data = jsonDecode(_text)['data'] as List;
        data.forEach((element) {
          photoList.add(Photo.fromJson(element));
        });
      });
      return "Sucessful";
    }
    fetchPhotos();

    // restaurant API 연동
    Future<String> fetchRestaurants() async {
      final response = await http.get(Uri.parse('https://unist-meal-backend.herokuapp.com/restaurant/v1/restaurants?format=json'));
      setState(() {
        var _text = utf8.decode(response.bodyBytes);
        var data = jsonDecode(_text)['data'] as List;
        data.forEach((element) {
          restList.add(Restaurant.fromJson(element));
        });
      });
      return "Sucessful";
    }
    fetchRestaurants();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: PageView(
          physics: NeverScrollableScrollPhysics(),
          onPageChanged: (index) {
            setState(() => _currentIndex = index);
          },
          children: <Widget>[MealApp(list:mealList, pageList: pageList,), MealPhotoApp(list:photoList), RecommendationApp(list:restList), BookmarkApp()],
          controller: _pageController,
        ),
        bottomNavigationBar: BottomNavyBar(
          selectedIndex: _currentIndex,
          onItemSelected: (index) {
            setState(() => _currentIndex = index);
            _pageController.jumpToPage(index);
          },
          items: <BottomNavyBarItem>[
            BottomNavyBarItem(
                title: Text('일일식단', textAlign: TextAlign.center,),
                icon: Icon(Icons.home)
            ),
            BottomNavyBarItem(
                title: Text('식단사진', textAlign: TextAlign.center,),
                icon: Icon(Icons.image)
            ),
            BottomNavyBarItem(
                title: Text('유니맛집', textAlign: TextAlign.center,),
                icon: Icon(Icons.contact_phone)
            ),
            BottomNavyBarItem(
                title: Text('즐겨찾기', textAlign: TextAlign.center,),
                icon: Icon(Icons.star)
            ),
          ],
        ),
    );
  }

  void _checkVersion() async {
    final newVersion = NewVersion(
      forceAppVersion: '2.0.0',
      androidId: 'com.wjddnwls7879.unistbab',
    );
    final status=await newVersion.getVersionStatus();
    print(status?.localVersion);
    print(status?.storeVersion);
    print(status?.appStoreLink);
    if(status?.canUpdate==true){
      newVersion.showUpdateDialog(
        context: context,
        versionStatus: status!,
        dialogTitle: "업데이트 권장",
        dialogText: "새로운 버전 ${status.storeVersion}이 출시되었습니다.\n 업데이트를 권장합니다.",
        updateButtonText: "업데이트",
        dismissButtonText: "나중에",
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    WidgetsBinding.instance.removeObserver(this);
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