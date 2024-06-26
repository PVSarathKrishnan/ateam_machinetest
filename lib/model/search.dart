import 'package:hive/hive.dart';

part 'search.g.dart';

@HiveType(typeId: 0)
class Search extends HiveObject {
  @HiveField(0)
  final String startLocation;
  
  @HiveField(1)
  final String endLocation;
  
  @HiveField(2)
  final DateTime searchDate;

  Search(this.startLocation, this.endLocation, this.searchDate);
}
