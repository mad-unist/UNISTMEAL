import 'package:flutter/foundation.dart';

class ListProvider with ChangeNotifier {
  List<String> goodList = [];
  List<String> badList = [];

  void addGood(String item){
    goodList.add(item);
    notifyListeners();
  }
  void addBad(String item){
    badList.add(item);
    notifyListeners();
  }
  void removeGood(String item){
    goodList.remove(item);
    notifyListeners();
  }
  void removeBad(String item){
    badList.remove(item);
    notifyListeners();
  }

}