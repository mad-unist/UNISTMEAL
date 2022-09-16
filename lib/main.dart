import 'dart:io';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:new_version/new_version.dart';
import 'package:showcaseview/showcaseview.dart';
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
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]);
  initializeDateFormatting('ko_KR', null);
  KakaoSdk.init(nativeAppKey: dotenv.env['Kakao_native_key']);
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
        primaryColor: Colors.blue[500],
        textTheme: GoogleFonts.notoSansTextTheme(
          Theme.of(context).textTheme
        ),
        scaffoldBackgroundColor: Colors.white,

      ),
      home: ShowCaseWidget(
        builder: Builder(
          builder: (context) => MyHomePage(),
        ),
      ),
    );
  }

  callback() {
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, }) : super(key: key);
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
  bool load = false;
  _MyHomePageState();

  createPage() {
    pageList.clear();
    for (var i = 0; i < 9; i++) {
      var d = DateTime.now().add(Duration(days: i));
      pageList.add(d);
    }
    setState(() {

    });
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

  Future<String> fetchPost() async {
    final response = await http.get(Uri.parse('https://unist-meal-backend.herokuapp.com/menu/v1/menus?format=json'));
    setState(() {
      var _text = utf8.decode(response.bodyBytes);
      var data = jsonDecode(_text)['data'] as List;
      data.forEach((element) {
        mealList.add(Meal.fromJson(element));
      });
      load = true;
    });
    return "Sucessful";
  }

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pageController = PageController();
    _checkVersion();
    fetchPost();
    fetchPhotos();
    fetchRestaurants();
  }

  Future<double> tillGetSource(Stream<double> source) async{
    await for (double value in source){
      if(value > 0)
        return value;
    }
    return await tillGetSource(source);
  }

  Widget splashUI (BuildContext context) {
    return FutureBuilder<double>(
        future: tillGetSource(
        Stream<double>.periodic(
          Duration(milliseconds: 100),
            (x) => MediaQuery.of(context).size.height
        )
    ),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Scaffold(
            backgroundColor: const Color(0xff49CCF5),
            body: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  alignment: Alignment.bottomCenter,
                  child: new Image.asset('assets/images/splash.png'),
                ),
                Container(
                  alignment: Alignment.bottomCenter,
                  width: MediaQuery.of(context).size.width * 0.3,
                  margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.width * 0.22),
                  child: LoadingIndicator(
                    indicatorType: Indicator.ballPulse,
                    colors: const [Colors.white],
                    strokeWidth: 2,
                    backgroundColor: const Color(0xff49CCF5),
                  )
                ),
              ],
            ),
          );
        } else {
          return Container();
        }
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    if(load == false) {
      return splashUI(context);
    } else {
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
  }

  void _checkVersion() async {
    final newVersion = NewVersion(
      androidId: 'com.wjddnwls7879.unistbab',
      iOSId: '1628256171',
    );
    final status=await newVersion.getVersionStatus();
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