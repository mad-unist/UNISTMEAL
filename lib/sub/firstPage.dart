import 'dart:async';
import 'dart:convert';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:unistapp/kakaoLogin.dart';
import 'package:unistapp/meal.dart';
import 'package:intl/intl.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:unistapp/rating.dart';
import 'package:unistapp/sub/loginViewModel.dart';
import 'package:unistapp/sub/sideBar.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class MealApp extends StatefulWidget {
  final List<Meal>? list;
  List? pageList;
  MealApp({Key? key, this.list, this.pageList,}) : super(key: key);

  @override
  _MealAppState createState() => _MealAppState(list, pageList!);
}

class _MealAppState extends State<MealApp> with SingleTickerProviderStateMixin{
  TabController? controller;
  ValueNotifier<int> _pageNotifier = new ValueNotifier<int>(1);
  PageController pagecontroller = PageController();
  final List<Meal>? list;
  List<String> goodList = [];
  List<String> badList = [];
  List<String> prefList = ["기숙사식당", "학생식당","교직원식당"];
  List<Meal>? sortList = [];
  List pageList = [];
  List<Meal> todayList = [];
  List<Rating> todayRatingList = [];
  List<String> profileUrl = ['','카카오 로그인이 필요합니다','이메일 정보가 없습니다',''];
  _MealAppState(this.list, this.pageList,);
  Map<String, dynamic> rateHistory = {};
  int initTab = 1;
  var viewModel = loginViewModel(KakaoLogin());
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _key1 = GlobalKey();
  final _key2 = GlobalKey();
  final _key3 = GlobalKey();
  final _key4 = GlobalKey();
  int menuCount = 0;
  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();

  callback(login) {
    setState(() {
      getProfileUrl();
    });
  }

  void getGoodList() async{
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      goodList = prefs.getStringList("goodList")!;
    });
  }
  void getBadList() async{
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      badList = prefs.getStringList("badList")!;
    });
  }
  void getPrefList() async{
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      prefList = prefs.getStringList("prefList")!;
    });
  }
  void setPrefList(setList) async{
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setStringList("prefList", setList);
    });
  }

  void getProfileUrl() async{
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      profileUrl = prefs.getStringList("profileUrl")!;
      fetchTodayRating();
    });
  }

  _loginCheck() async{
    if (viewModel.user == null) {
      await viewModel.loginCheck();
      setState(() {});
    }
  }

  createPage() {
    pageList.clear();
    for (var i = 0; i < 9; i++) {
      var d = DateTime.now().add(Duration(days: i));
      pageList.add(d);
    }
    setState(() {

    });
  }

  setPage() {
    setState(() {
      var m = DateTime.now().hour * 60 + DateTime.now().minute;
      if (m >= 840) {
        initTab = 2;
      } else if (m >= 570) {
        initTab = 1;
      } else {
        initTab = 0;
      }
    });
  }

  Future<String> fetchTodayRating() async {
    if (profileUrl[3] != '') {
      final response = await http.get(Uri.parse('https://unist-meal-backend.herokuapp.com/rating/v1/today-ratings/${profileUrl[3]}?format=json'));
      setState(() {
        print(response);
        var _text = utf8.decode(response.bodyBytes);
        var data = jsonDecode(_text)['data'] as List;
        List<Rating> tempList = [];
        data.forEach((element) {
          tempList.add(Rating.fromJson(element));
        });
        todayRatingList = tempList;
      });
    } else{
      todayRatingList.clear();
    }
    return "Sucessful";
  }

  @override
  void initState() {
    super.initState();
    _loginCheck();
    getProfileUrl();
    createPage();
    setPage();
    controller = TabController(initialIndex: initTab, length: 3, vsync: this);
    getGoodList();
    getBadList();
    getPrefList();
  }

  createAlertDialog(BuildContext context){
    List<String> tempList = [];
    bool _dormitory = false;
    bool _student = false;
    bool _employee = false;
    return showDialog(context: context, builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text("선호도 입력", textAlign: TextAlign.center,),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SwitchListTile(
                  title: Text("기숙사식당"),
                  value: _dormitory,
                  onChanged: (value) {
                    setState(() {
                      _dormitory = value;
                      if (_dormitory) {
                        tempList.add("기숙사식당");
                      } else {
                        tempList.remove("기숙사식당");
                      }
                    });
                  },
                ),
                SwitchListTile(
                  title: Text("학생식당"),
                  value: _student,
                  onChanged: (value) {
                    setState(() {
                      _student = value;
                      if (_student) {
                        tempList.add("학생식당");
                      } else {
                        tempList.remove("학생식당");
                      }
                    });
                  },
                ),
                SwitchListTile(
                  title: Text("교직원식당"),
                  value: _employee,
                  onChanged: (value) {
                    setState(() {
                      _employee = value;
                      if (_employee) {
                        tempList.add("교직원식당");
                      } else {
                        tempList.remove("교직원식당");
                      }
                    });
                  },
                ),
                tempList.isNotEmpty ?
                tempList.length == 1 ?
                Text('${tempList.join(",\n")}\n 만 표시됩니다.', softWrap: true, textAlign: TextAlign.center,)
                    :Text('${tempList.join(",\n")}\n 순으로 정렬됩니다.', softWrap: true, textAlign: TextAlign.center,)
                    : Text("정렬을 원하는 것만\n순서대로 선택해주세요.", softWrap: true, textAlign: TextAlign.center,)
              ],
            ),
            actions: [
              MaterialButton(
                child: Text('취소'),
                minWidth: 0.3,
                onPressed: () {
                  Navigator.pop(context, "Cancel");
                },
              ),
              MaterialButton(
                child: Text('확인'),
                minWidth: 0.3,
                onPressed: () {
                  Navigator.pop(context, "confirm");
                  if (tempList.isEmpty) {
                    tempList = ['기숙사식당', '교직원식당', '학생식당'];
                    Fluttertoast.showToast(
                        msg: "미선택으로 디폴트로 정렬됩니다.",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.redAccent,
                        textColor: Colors.white,
                        fontSize: MediaQuery.of(context).size.width * 0.04
                    );
                  } else {
                    Fluttertoast.showToast(
                        msg: "${tempList.join(", ")} 순 정렬완료",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.redAccent,
                        textColor: Colors.white,
                        fontSize: MediaQuery.of(context).size.width * 0.04
                    );
                  }
                  setPrefList(tempList);
                  getPrefList();
                },
              ),
            ],
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<double>(
        future: tillGetSource(
            Stream<double>.periodic(
                Duration(milliseconds: 100),
                    (x) => MediaQuery.of(context).size.height
            )
        ),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Material(
              child: Scaffold(
                key: _scaffoldKey,
                drawer: SideBarApp(viewModel: viewModel, callbackFunction: callback,),
                appBar: AppBar(
                  leading: Showcase(
                    key: _key1,
                    child: TextButton(
                      onPressed: () {
                        setState (() {
                          _scaffoldKey.currentState?.openDrawer();
                        });
                      },
                      child: FaIcon(
                          Icons.menu,
                          color: Theme.of(context).colorScheme.onPrimary
                      ),
                    ),
                    description: "사이드바 메뉴를 통해 다양한 기능들을 활용하세요.",
                  ),
                  title: Text('유니스트 식단표'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        setState (() {
                          ShowCaseWidget.of(context).startShowCase([_key1, _key2, _key3, _key4,]);
                        });

                        // showDialog(
                        //   context: context,
                        //   barrierDismissible: true,
                        //   builder: (BuildContext context) => TutorialDialog(),
                        // );
                      },
                      child: FaIcon(
                          Icons.help_outline,
                          color: Theme.of(context).colorScheme.onPrimary
                      ),
                    ),
                    Showcase(
                      key: _key2,
                      child: TextButton(
                        onPressed: () {
                          createAlertDialog(context);
                        },
                        child: FaIcon(
                            FontAwesomeIcons.rankingStar,
                            color: Theme.of(context).colorScheme.onPrimary
                        ),
                      ),
                      description: "식단표를 원하는 순서로 정렬하거나,\n보고 싶은 식단표만 보세요."
                    ),
                  ],
                ),
                body: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      alignment: Alignment.bottomCenter,
                      margin: EdgeInsets.only(top: MediaQuery.of(context).size.width * 0.22),
                      color: Colors.yellow,
                      child : Showcase(
                        key: _key3,
                        description: "식단표를 길게 터치해 식단을 평가하거나 공유하세요.\n페이지를 아래로 당겨, 별점을 새로고침 하세요.",
                        child: Container(),
                      ),
                    ),
                    Container(
                      child: PageView.builder(
                        controller: pagecontroller,
                        itemCount: pageList.length,
                        itemBuilder: (context, position) {
                          if (position == 0) {
                            return exampleTabView(pageList[position].month, pageList[position].day, DateFormat.E('ko_KR').format(pageList[position]), context, true);
                          } else {
                            return exampleTabView(pageList[position].month, pageList[position].day, DateFormat.E('ko_KR').format(pageList[position]), context, false);
                          }
                        },
                        onPageChanged: (index){
                          setState(() {
                            _pageNotifier.value = index;
                          });
                        },
                      ),
                    ),
                    Container(
                      alignment: Alignment.bottomCenter,
                      margin: EdgeInsets.only(bottom: 1.0 * MediaQuery.of(context).size.width * 0.015,),
                      child: Showcase(
                        key: _key4,
                        description: "도트를 터치해 한번에 여러 페이지를 쉽게 이동하세요.",
                        child: SmoothPageIndicator(
                          controller: pagecontroller,
                          count:  9,
                          effect:  WormEffect(
                            dotHeight: MediaQuery.of(context).size.width * 0.035,
                            dotWidth: MediaQuery.of(context).size.width * 0.035,
                            spacing: MediaQuery.of(context).size.width * 0.035,
                            paintStyle: PaintingStyle.fill,
                          ),
                          onDotClicked: (index){
                            setState(() {
                              _pageNotifier.value = index;
                              pagecontroller.animateToPage(index, duration: Duration(milliseconds: 500), curve: Curves.ease);
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return Material(
              child: Scaffold(
                appBar: AppBar(
                  title: Text('유니스트 식단표'),
                  actions: [
                    TextButton(
                      onPressed: () {
                      createAlertDialog(context);
                      },
                      child: FaIcon(
                      FontAwesomeIcons.rankingStar,
                      color: Theme.of(context).colorScheme.onPrimary
                      ),
                    ),
                  ],
                ),
                body: Container(),
              ),
            );
          }
        }
    );
  }

  exampleTabView(month, day, koreanDay, context, boolToday) {
    sortList = list?.where((element) => prefList.contains(element.place)).toList();
    sortList?.sort((a, b) {
      if (prefList.indexOf(a.place!) == prefList.indexOf(b.place!)) {
        return ["한식","일품"].indexOf(a.type!).compareTo(["한식","일품"].indexOf(b.type!));
      } else {
        return prefList.indexOf(a.place!).compareTo(prefList.indexOf(b.place!));
      }
    });
    double unitWidthValue = MediaQuery.of(context).size.width * 0.01;
    List<Meal>? newlist = sortList?.where((data) => data.month == month && data.day == day).toList();
    return Scaffold(
      body: Column(
        children: [
          Container(
            child: Text('${month}월 ${day}일 (${koreanDay})', textAlign: TextAlign.center, style: TextStyle(fontSize: 6 * unitWidthValue)),
          ),
          TabBar(
            unselectedLabelColor: Colors.black,
            labelColor: Colors.white,
            automaticIndicatorColorAdjustment: true,
            indicator: BoxDecoration(
              color: Colors.blue[300],
              borderRadius:  BorderRadius.circular(5 * unitWidthValue),
              border: Border.all(
                width: unitWidthValue,
                color: Colors.blue,
              ),
            ),
            indicatorSize: TabBarIndicatorSize.label,
            tabs: [
              Container(
                height: unitWidthValue * 10,
                width: unitWidthValue * 25,
                child: Tab(text: '아침',),
              ),
              Container(
                height: unitWidthValue * 10,
                width: unitWidthValue * 25,
                child: Tab(text: '점심',),
              ),
              Container(
                height: unitWidthValue * 10,
                width: unitWidthValue * 25,
                child: Tab(text: '저녁',),
              ),
            ],
            controller: controller,
          ),
          Divider(
            thickness: 0.5 * unitWidthValue,
            indent: 5 * unitWidthValue,
            endIndent: 5 * unitWidthValue,
            color: Colors.black,
          ),
          Expanded(
            child: TabBarView(
              physics: NeverScrollableScrollPhysics(),
              children: [
                exampleGridview(newlist?.where((data) => data.time == "아침").toList(), koreanDay, context, boolToday),
                exampleGridview(newlist?.where((data) => data.time == "점심").toList(), koreanDay, context, boolToday),
                exampleGridview(newlist?.where((data) => data.time == "저녁").toList(), koreanDay, context, boolToday),
              ],
              controller: controller,
            ),
          ),
        ],
      ),
    );
  }

  Future<double> tillGetSource(Stream<double> source) async{
    await for (double value in source){
      if(value > 0)
        return value;
    }
    return await tillGetSource(source);
  }

  exampleGridview(List<Meal>? gridList, koreanDay, context, boolToday) {
    return SafeArea(
      child: EasyRefresh(
        callRefreshOverOffset: MediaQuery.of(context).size.height * 0.08,
        onRefresh: () async {
          createPage();
          fetchToday();
        },
        child: GridView.builder(
          primary: true,
          itemBuilder: (context, position) {
            return Container(
              child: MenuCard(gridList, koreanDay, context, boolToday, position),
            );
          },
          itemCount: gridList!.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, //1 개의 행에 보여줄 item 개수
            childAspectRatio: boolToday? 1 / 1.6 : 1 / 1.4, //item 의 가로 1, 세로 2 의 비율
            mainAxisSpacing: 0.01 * MediaQuery.of(context).size.width, //수평 Padding
            crossAxisSpacing: 0.01 * MediaQuery.of(context).size.width, //수직 Padding
          ),
        ),
      ),
    );
  }

  MenuCard(List<Meal>? gridList, koreanDay, context, boolToday, position) {
    double unitWidthValue = MediaQuery.of(context).size.width * 0.01;
    double multiplier = 3.3;
    return Container(
      child: GestureDetector(
        onLongPress: () {
          createPopupMenu(context, gridList?[position], gridList, koreanDay, boolToday);
        },
        child: Container(
          margin: EdgeInsets.only(bottom: 1 * unitWidthValue,),
          child: Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8 * unitWidthValue)
            ),
            color: goodList.any((element) => (gridList?[position].content)!.contains(element)) ? Colors.lightGreen[50] : badList.any((element) => (gridList?[position].content)!.contains(element)) ? Colors.pink[50] : Colors.lightBlue[50],
            child:  Column(
              children: <Widget>[
                Container(
                  child: Column(
                    children: [
                      Text('${gridList?[position].place}  ${gridList?[position].type}', textAlign: TextAlign.start, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 4 * unitWidthValue,),),
                      Divider(
                        thickness: 0.5 * unitWidthValue,
                        indent: 5 * unitWidthValue,
                        endIndent: 5 * unitWidthValue,
                        color: goodList.any((element) => (gridList?[position].content)!.contains(element)) ? Colors.lightGreen : badList.any((element) => (gridList?[position].content)!.contains(element)) ? Colors.pink : Colors.lightBlue,
                      ),
                    ],
                  ),
                  padding: EdgeInsets.only(top: 2 * unitWidthValue,),
                ),
                Spacer(),
                Container(
                  child: Column(
                    children: [
                      Text((gridList?[position].content)!, textAlign: TextAlign.center, style: TextStyle(height: 1.4, fontSize: multiplier * unitWidthValue, ),),
                      Container(
                        padding: EdgeInsets.only(top: 2 * unitWidthValue,),
                      ),
                      Text('${gridList?[position].calorie!}Kcal', style: TextStyle(fontSize: multiplier * unitWidthValue, fontWeight: FontWeight. bold),),
                    ],
                  ),
                ),
                Spacer(),
                boolToday? Container(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (todayRatingList.any((data) => data.menu == gridList?[position].id)) const Icon(
                            Icons.person,
                            color: Colors.yellow,
                          ) else Icon(
                            Icons.person,
                            color: goodList.any((element) => (gridList?[position].content)!.contains(element)) ? Colors.lightGreen : badList.any((element) => (gridList?[position].content)!.contains(element)) ? Colors.pink : Colors.lightBlue,
                          ),
                          Text(' 리뷰 ${gridList?[position].rating_count}개', style: TextStyle(height: 1, fontSize: multiplier * unitWidthValue,),)
                        ],
                      ),
                      RatingBarIndicator(
                        rating: (gridList?[position].rating)!,
                        itemBuilder: (context, index) => Icon(
                          Icons.star,
                          color: goodList.any((element) => (gridList?[position].content)!.contains(element)) ? Colors.lightGreen : badList.any((element) => (gridList?[position].content)!.contains(element)) ? Colors.pink : Colors.lightBlue,
                        ),
                        itemCount: 5,
                        itemSize: unitWidthValue * 6,
                        direction: Axis.horizontal,
                      ),
                    ],
                  ),
                  padding: EdgeInsets.only(bottom: 2 * unitWidthValue,),
                ) : Container(
                  padding: EdgeInsets.only(top: 5 * unitWidthValue,),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  kakaoShare(element, koreanDay) async{
    TextTemplate defaultText = TextTemplate(
      text:
      '${element.place} ${element.type} ${element.month}/${element.day} (${koreanDay})\n\n${element.content}',
      link: Link(
        androidExecutionParams: {'':''},
        iosExecutionParams: {'':''},
      ),
      buttonTitle: '앱으로 보기',
    );
    bool result = await ShareClient.instance.isKakaoTalkSharingAvailable();
    if (result) {
      Uri uri =
          await ShareClient.instance.shareDefault(template: defaultText);
      await ShareClient.instance.launchKakaoTalk(uri);
      print('카카오톡으로 공유 가능');
    } else {
      print('카카오톡 미설치: 웹 공유 기능 사용 권장');
      Fluttertoast.showToast(
          msg: "카카오톡이 설치되어있지 않습니다",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.redAccent,
          textColor: Colors.white,
          fontSize: MediaQuery.of(context).size.width * 0.04
      );
    }
  }

  createPopupMenu(BuildContext context, element, tabMenu, koreanDay, boolToday) {
    int? rated = 0;
    tabMenu.forEach((element1) {
      todayRatingList.forEach((element2) {
        if (element1.id == element2.menu) {
          rated = element2.menu;
        }
      });
    });
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title:  Text("일일 식단표 행동 선택", textAlign: TextAlign.center,),
          children: [
            ListTile(
              leading: Icon(Icons.share),
              title: Text('카카오톡 공유하기'),
              onTap: () {
                kakaoShare(element, koreanDay);
                Navigator.pop(context, "Cancel");
              },
            ),
            ListTile(
              leading: Icon(Icons.copy),
              title: Text('클립보드 복사하기'),
              onTap: () {
                Clipboard.setData(ClipboardData(
                  text: '${element.place} ${element.type} ${element.month}/${element.day} (${koreanDay})\n\n${element.content}',
                ));
                Fluttertoast.showToast(
                    msg: "클립보드 복사완료",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.redAccent,
                    textColor: Colors.white,
                    fontSize: MediaQuery.of(context).size.width * 0.04
                );
                Navigator.pop(context, "Cancel");
              },
            ),
            boolToday? ListTile(
              leading: Icon(Icons.star),
              title: (todayRatingList.any((data) => data.menu == element.id))? Text('식단평가 수정하기') : Text('식단 평가하기'),
              onTap: () {
                Navigator.pop(context, "Cancel");
                if (viewModel.user != null){
                  createRatingDialog(context, element, rated);
                } else {
                  Fluttertoast.showToast(
                      msg: "카카오 로그인을 먼저 해주세요",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.redAccent,
                      textColor: Colors.white,
                      fontSize: MediaQuery.of(context).size.width * 0.04
                  );
                  _scaffoldKey.currentState?.openDrawer();
                }
              },
            ) : Container()
          ],
        );
      },
    );
  }

  createRatingDialog(BuildContext context, element, rated){
    double rate = 3.0;
    return showDialog(context: context, builder: (context)
    {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text("식단 평가", textAlign: TextAlign.center,),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                rated > 0? Text("오늘 ${element.time}에 평가한 식단이 이미 존재합니다.\n새로운 평가를 작성하시면,\n기존 평가는 삭제됩니다.", textAlign: TextAlign.center, style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.035, color: Colors.red, fontWeight: FontWeight. bold,))
                    : Text("식단을 평가해 주세요.", textAlign: TextAlign.center, style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.035,)),
                RatingBar.builder(
                  initialRating: 3,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemSize: MediaQuery.of(context).size.width * 0.09,
                  itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {
                    print(rating);
                    setState(() {
                      rate = rating;
                    });
                  },
                ),
                Text("${rate}", textAlign: TextAlign.center, style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.05,)),
              ],
            ),
            actions: [
              Row(
                children: [
                  RoundedLoadingButton(
                    animateOnTap: false,
                    height: MediaQuery.of(context).size.width * 0.1,
                    width: MediaQuery.of(context).size.width * 0.3,
                    child: Text('취소'),
                    onPressed: () {
                      Navigator.pop(context, "Cancel");
                    },
                    controller: _btnController,
                  ),
                  Spacer(),
                  RoundedLoadingButton(
                    height: MediaQuery.of(context).size.width * 0.1,
                    width: MediaQuery.of(context).size.width * 0.3,
                    child: Text('평가하기'),
                    onPressed: () async {
                      if (viewModel.user != null){
                        int time = 480;
                        switch (element.time) {
                          case "아침":
                            time = 480;
                            break;
                          case "점심":
                            time = 660;
                            break;
                          case "저녁":
                            time = 1020;
                            break;
                        }
                        if ((DateTime.now().hour * 60 + DateTime.now().minute) >= time) {
                          Timer(Duration(seconds: 5), () {
                            _btnController.success();
                          });
                          if (rated > 0) {
                            await deleteRating(viewModel.user?.id, rated);
                          }
                          await postRating(viewModel.user?.id, element.id, rate);
                          fetchToday();
                          Navigator.pop(context, "Cancel");
                          Fluttertoast.showToast(
                              msg: "평가 완료",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.redAccent,
                              textColor: Colors.white,
                              fontSize: MediaQuery.of(context).size.width * 0.04
                          );
                        } else {
                          Fluttertoast.showToast(
                              msg: "식사 시간 ${(time/60).toInt()}시 이후 평가해주세요",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.redAccent,
                              textColor: Colors.white,
                              fontSize: MediaQuery.of(context).size.width * 0.04
                          );
                          Navigator.pop(context, "Cancel");
                        }
                      } else {
                        Fluttertoast.showToast(
                            msg: "카카오 로그인을 먼저 해주세요",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.redAccent,
                            textColor: Colors.white,
                            fontSize: MediaQuery.of(context).size.width * 0.04
                        );
                        Navigator.pop(context, "Cancel");
                        _scaffoldKey.currentState?.openDrawer();
                      }
                    },
                    controller: _btnController,
                  ),
                ],
              ),
            ],
          );
        },
      );
    });
  }

  Future<http.Response> postRating(userId, mealId, rating) async{
    return await http.post(
      Uri.parse('https://unist-meal-backend.herokuapp.com/rating/v1/ratings'),
      headers:{
        'Content-Type': "application/json",
      },
      body: jsonEncode(<String, dynamic>{
        "user_id": "${userId}",
        "menu_id": mealId,
        "rating": rating
      }),
    );
  }

  Future<http.Response> deleteRating(userId, mealId) async{
    return await http.delete(
      Uri.parse('https://unist-meal-backend.herokuapp.com/rating/v1/ratings'),
      headers:{
        'Content-Type': "application/json",
      },
      body: jsonEncode(<String, dynamic>{
        "user_id": "${userId}",
        "menu_id": mealId,
      }),
    );
  }

  Future<String> fetchToday() async {
    final response = await http.get(Uri.parse('https://unist-meal-backend.herokuapp.com/menu/v1/today-menus?format=json'));
    setState(() {
      fetchTodayRating();
      var _text = utf8.decode(response.bodyBytes);
      var data = jsonDecode(_text)['data'] as List;
      todayList.clear();
      data.forEach((element) {
        todayList.add(Meal.fromJson(element));
      });
      list?.removeWhere((data) => data.month == DateTime.now().month && data.day == DateTime.now().day);
      list?.addAll(todayList);
    });
    return "Sucessful";
  }

}