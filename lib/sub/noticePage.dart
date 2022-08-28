import 'dart:convert';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:unistapp/notice.dart';
import 'package:http/http.dart' as http;

class NoticeDialog extends StatefulWidget {
  const NoticeDialog({Key? key}) : super(key: key);

  @override
  State<NoticeDialog> createState() => _NoticeDialogState();
}

class _NoticeDialogState extends State<NoticeDialog> {
  List<Notice> noticeList = [];


  ValueNotifier<int> _pageNotifier = new ValueNotifier<int>(1);
  PageController pagecontroller =  PageController();

  @override
  void initState() {
    super.initState();
    fetchNotices();

  }

  Future<String> fetchNotices() async {
    final response = await http.get(Uri.parse('https://unist-meal-backend.herokuapp.com/notice/v1/notices?format=json'));
    setState(() {
      var _text = utf8.decode(response.bodyBytes);
      var data = jsonDecode(_text)['data'] as List;
      data.forEach((element) {
        noticeList.add(Notice.fromJson(element));
      });
      noticeList.sort((a, b) => (a.id)!.compareTo((b.id)!));
      if (noticeList.length == 0) {
        noticeList.add(Notice(id: 1, title: '공지사항 안내', content: '공지사항이 존제하지 않습니다.'));
      }
    });
    return "Sucessful";
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        double unitWidthValue = MediaQuery.of(context).size.width * 0.01;
        if (noticeList.length == 0) {
          return LoadingAnimationWidget.inkDrop(
            color: Colors.white,
            size: 50 * unitWidthValue,
          );
        } else {
          return AlertDialog(
            contentPadding: EdgeInsets.zero,
            insetPadding: EdgeInsets.only(top: 20 * unitWidthValue, bottom: 20 * unitWidthValue, left: 5 * unitWidthValue, right: 5 * unitWidthValue,),
            title: Text("공지사항 게시판", textAlign: TextAlign.center,),
            content: Container(
              height: MediaQuery.of(context).size.height,
              margin: EdgeInsets.only(left: 10 * unitWidthValue, right: 10 * unitWidthValue,),
              width: MediaQuery.of(context).size.width,
              child: Stack(
                children: [
                  Container(
                    padding: EdgeInsets.only(bottom: 6 * unitWidthValue, top: 2 * unitWidthValue,),
                    child: PageView.builder(
                      controller: pagecontroller,
                      itemCount: noticeList.length,
                      itemBuilder: (context, position) {
                        return Container(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${noticeList[position].title}', textAlign: TextAlign.left),
                                Divider(),
                                Text('${noticeList[position].content}', textAlign: TextAlign.left),
                              ],
                            ),
                          ),
                        );
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
                    child: SmoothPageIndicator(
                        controller: pagecontroller,
                        count: noticeList.length,
                        effect:  WormEffect(
                          dotHeight: MediaQuery.of(context).size.width * 0.035,
                          dotWidth: MediaQuery.of(context).size.width * 0.035,
                          spacing: MediaQuery.of(context).size.width * 0.035,
                          activeDotColor: Colors.redAccent,
                          paintStyle: PaintingStyle.fill,
                        ),
                        onDotClicked: (index) {
                          setState(() {
                            _pageNotifier.value = index;
                            pagecontroller.animateToPage(
                                index, duration: Duration(milliseconds: 500),
                                curve: Curves.ease);
                          });
                        }
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              MaterialButton(
                child: Text('확인'),
                minWidth: 0.5,
                onPressed: () {
                  Navigator.pop(context, "Cancel");
                },
              ),
            ],
          );
        }
      }
    );
  }
}
