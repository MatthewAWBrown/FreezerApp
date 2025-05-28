import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../model/inven_model.dart';
import '../db_helper/db_helper.dart';

class InvenProvider extends ChangeNotifier{

  List<InvenModel> invenItem = [];

  Future<void>selectData()async{

    final dataList = await DBHelper.selectAll(DBHelper.inven);

    invenItem=dataList
      .map(
        (item) => InvenModel(
            id: item['id'],
            title: item['title'],
            count: item['count'],
            date: item['date'],
        ),
    ).toList();
    notifyListeners();
  }

  Future<void> search(String searchText) async {
    final dataList = await DBHelper.search(DBHelper.inven, searchText);

    invenItem=dataList
      .map(
        (item) => InvenModel(
          id: item['id'],
          title: item['title'],
          count: item['count'],
          date: item['date'],
        ),
    ).toList();
    notifyListeners();
  }

  Future insertData(
      String title,
      String count,
      String date,
  ) async {

    final newInven = InvenModel(
        id: const Uuid().v1(),
        title: title,
        count: count,
        date: date
    );
    invenItem.add(newInven);

    DBHelper.insert(DBHelper.inven, {
      'id': newInven.id,
      'title': newInven.title,
      'count': newInven.count,
      'date': newInven.date,
    },);

    notifyListeners();
  }

  Future updateTitle(String id, String title) async {

    DBHelper.update(
      DBHelper.inven,
      'title',
      title,
      id,
    );
    notifyListeners();
  }

  Future updateCount(String id, String count) async {

    DBHelper.update(
      DBHelper.inven,
      'count',
      count,
      id,
    );
    notifyListeners();
  }

  Future updateDate(String id, String date) async {

    DBHelper.update(
      DBHelper.inven,
      'date',
      date,
      id,
    );
    notifyListeners();
  }

  Future deleteById(id) async {

    DBHelper.deleteById(
      DBHelper.inven,
      'id',
      id,
    );
    notifyListeners();
  }

  Future deleteTable() async {

    DBHelper.deleteTable(DBHelper.inven);
    invenItem.clear();
    notifyListeners();
  }
}