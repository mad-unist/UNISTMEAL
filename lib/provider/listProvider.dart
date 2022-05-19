import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

class ListProvider with ChangeNotifier {
  List<String> goodList = ["돈까스"];
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