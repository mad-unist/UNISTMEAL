import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class TutorialDialog extends StatefulWidget {
  const TutorialDialog({Key? key}) : super(key: key);

  @override
  State<TutorialDialog> createState() => _TutorialDialogState();
}

class _TutorialDialogState extends State<TutorialDialog> {
  int currentIndex = 0;
  final imageList = [
    'assets/images/1page.jpg',
    'assets/images/2page.jpg',
    'assets/images/3page.jpg',
    'assets/images/4page.jpg'
  ];
  ValueNotifier<int> _pageNotifier = new ValueNotifier<int>(1);
  PageController pagecontroller =  PageController();

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
        builder: (context, setState) {
          double unitWidthValue = MediaQuery.of(context).size.width * 0.01;
          return AlertDialog(
            contentPadding: EdgeInsets.zero,
            insetPadding: EdgeInsets.all(5 * unitWidthValue,),
            title: Text("앱 튜토리얼", textAlign: TextAlign.center,),
            content: Container(
              height: MediaQuery.of(context).size.height,
              margin: EdgeInsets.only(left: 5 * unitWidthValue, right: 5 * unitWidthValue,),
              width: MediaQuery.of(context).size.width,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    padding: EdgeInsets.only(bottom: 6 * unitWidthValue, top: 2 * unitWidthValue,),
                    child: PhotoViewGallery.builder(
                      pageController: pagecontroller,
                      itemCount: imageList.length,
                      builder: (context, index) {
                        return PhotoViewGalleryPageOptions(
                          imageProvider: AssetImage(imageList[index]),
                          minScale: PhotoViewComputedScale.contained * 0.8,
                          maxScale: PhotoViewComputedScale.covered * 2,
                        );
                      },
                      scrollPhysics: BouncingScrollPhysics(),
                      backgroundDecoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        color: Theme
                            .of(context)
                            .canvasColor,
                      ),
                      enableRotation: false,
                      onPageChanged: (index){
                        setState(() {
                          _pageNotifier.value = index;
                        });
                      },
                      loadingBuilder: (context, event) =>
                          Center(
                            child: Container(
                              width: 30.0,
                              height: 30.0,
                              child: CircularProgressIndicator(
                                backgroundColor: Colors.orange,
                                value: event == null
                                    ? 0
                                    : 0,
                              ),
                            ),
                          ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.bottomCenter,
                    child: SmoothPageIndicator(
                      controller: pagecontroller,
                      count: imageList.length,
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
    );
  }
}
