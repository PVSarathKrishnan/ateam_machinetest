
import 'package:ateam_machinetest/model/search.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

class SearchProvider with ChangeNotifier {
  List<Search> _searches = [];

  List<Search> get searches => _searches;

  void loadSearches() {
    final box = Hive.box<Search>('searches');
    _searches = box.values.toList();
    notifyListeners();
  }

  void addSearch(String start, String end) async {
    final search = Search(start, end, DateTime.now());
    final box = Hive.box<Search>('searches');
    await box.add(search);
    _searches.add(search);
    notifyListeners();
  }
}
