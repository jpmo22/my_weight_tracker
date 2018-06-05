import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';

const String _TABLE = 'Weights';
const String _COL_ID = '_id';
const String _COL_DATETIME = 'DateTime';
const String _COL_WEIGHT = 'WeightValue';
const String _COL_DIFF = 'Diff';

final DateFormat dateFormat = DateFormat('yyyy-MM-ddTHH:mm:ss');

class WeightRec {
  int _id;
  DateTime _dateTime;
  double _weight;
  double _diff;

  int get id => _id;
  DateTime get dateTime => _dateTime;
  double get weight => _weight;
  double get diff => _diff;
  bool get isLoss => _diff <= 0;

  WeightRec(this._id, this._dateTime, this._weight, this._diff);

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      _COL_ID: this._id,
      _COL_DATETIME: dateFormat.format(this._dateTime),
      _COL_WEIGHT: this._weight,
      _COL_DIFF: this._diff
    };
    return map;
  }

  WeightRec.fromMap(Map map) {
    _id = map[_COL_ID];
    _dateTime = DateTime.parse(map[_COL_DATETIME]);
    _weight = map[_COL_WEIGHT];
    _diff = map[_COL_DIFF];
  }
}

class WeightRecProvider {
  Database db;

  Future open(String path) async {
    db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('''CREATE TABLE $_TABLE (
          $_COL_ID INTEGER PRIMARY KEY AUTOINCREMENT, 
          $_COL_DATETIME TEXT NOT NULL,
          $_COL_WEIGHT REAL NOT NULL,
          $_COL_DIFF REAL NOT NULL)''');
    });
  }

  Future<WeightRec> insert(WeightRec weightRec) async {
    int newId = await db.insert(_TABLE, weightRec.toMap());
    return WeightRec(
        newId, weightRec._dateTime, weightRec._weight, weightRec.diff);
  }

  Future<List<WeightRec>> get() async {
    List<Map> maps = await db.query(
      _TABLE,
      columns: [_COL_ID, _COL_DATETIME, _COL_WEIGHT, _COL_DIFF],
    );

    if (maps.length == 0) {
      sampleData();
      return await get();
    }

    List<WeightRec> result = [];
    for (Map m in maps) {
      result.add(WeightRec.fromMap(m));
    }
    return result;
  }

  Future<WeightRec> getById(int id) async {
    List<Map> maps = await db.query(
      _TABLE,
      columns: [_COL_ID, _COL_DATETIME, _COL_WEIGHT, _COL_DIFF],
      where: '$_COL_ID = ?',
      whereArgs: [id],
    );
    if (maps.length > 0) {
      return WeightRec.fromMap(maps.first);
    }
    return null;
  }

  Future<int> delete(int id) async {
    return await db.delete(_TABLE, where: '$_COL_ID = ?', whereArgs: [id]);
  }

  Future<int> update(WeightRec weightRec) async {
    return await db.update(_TABLE, weightRec.toMap(),
        where: '$_COL_ID = ?', whereArgs: [weightRec._id]);
  }

  Future<int> lenght() async {
    return Sqflite
        .firstIntValue(await db.rawQuery("SELECT COUNT(*) FROM $_TABLE"));
  }

  Future close() async => db.close();

  void sampleData() {
    insert(WeightRec(null, DateTime.parse('2018-05-26T22:30:25Z'), 98.1, -0.7));
    insert(WeightRec(null, DateTime.parse('2018-05-26T22:30:25Z'), 98.1, -0.7));
    insert(WeightRec(null, DateTime.parse('2018-05-26T22:30:25Z'), 98.1, -0.7));
    insert(WeightRec(null, DateTime.parse('2018-05-25T21:58:10Z'), 98.8, 0.1));
    insert(WeightRec(null, DateTime.parse('2018-05-24T22:12:45Z'), 98.7, -0.6));
    insert(WeightRec(null, DateTime.parse('2018-05-23T22:22:23Z'), 99.3, -0.5));
    insert(WeightRec(null, DateTime.parse('2018-05-22T23:01:43Z'), 99.8, -0.2));
    insert(
        WeightRec(null, DateTime.parse('2018-05-21T22:13:10Z'), 100.0, -1.2));
    insert(WeightRec(null, DateTime.parse('2018-05-20T20:45:09Z'), 101.2, 0.1));
    insert(
        WeightRec(null, DateTime.parse('2018-05-19T19:32:05Z'), 101.1, -0.6));
    insert(WeightRec(null, DateTime.parse('2018-05-18T23:10:13Z'), 101.7, 0.0));
  }
}
