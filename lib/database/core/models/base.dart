import 'package:sqflite/sqflite.dart';

import'../../init.dart';

class DatabaseModel {

  String table;
  String pk = 'id';

  ConflictAlgorithm _conflictAlgorithm = ConflictAlgorithm.replace;
  String _where;
  String _order;
  List<dynamic> _whereArgs = [];
  List<String> _select = ['*'];
  int _limit;
  int _offset;

  bool isCreated = false;


  constructModel() {
    return new DatabaseModel();
  }

  Map<String, dynamic> toMap() {
    throw new Exception('Not implemented');
  }

  loadFromMap(Map<String, dynamic> map){
    throw new Exception('Not implemented');
  }

  store() async {
    var database = await db.open();

    var pkValue = await database.insert(
        this.table,
        this.toMap(),
        conflictAlgorithm: this._conflictAlgorithm
    );


    var map = this.toMap();
    map[this.pk] = pkValue;
    this.loadFromMap(map);

    print("Stored! PK is " + pkValue.toString());
    isCreated = true;
  }

  save() async {
    if (this.toMap()[this.pk] == null || isCreated == false) {
      return await this.store();
    }
    var database = await db.open();
    await database.update(
        this.table,
        this.toMap(),
        where: this.pk +" = ?",
        whereArgs: [this.toMap()[this.pk]]
    );

    print("Updated!");
  }

  delete() async {
    var database = await db.open();
    await database.delete(
        this.table,
        // Use a `where` clause to delete a specific dog.
        where: this._where,
        // Pass the Dog's id as a whereArg to prevent SQL injection.
        whereArgs: this._whereArgs
    );
  }

  remove() async {
    var database = await db.open();
    await database.delete(
        this.table,
        // Use a `where` clause to delete a specific dog.
        where: this.pk +" = ?",
        // Pass the Dog's id as a whereArg to prevent SQL injection.
        whereArgs: [this.toMap()[this.pk]]
    );
    print('removed ' + this.constructModel().toString() + ' ' + this.toMap()[this.pk].toString());
  }

  where(String condition, List<dynamic> args) {
    this._where = condition;
    this._whereArgs = args;

    return this;
  }

  andWhere(String condition, List<dynamic> args) {
    this._where += " AND " + condition;
    for (var argument in args) {
      this._whereArgs.add(argument);
    }

    return this;
  }

  select(List<String> columns) {
    this._select = columns;

    return this;
  }



  find() async {
    var database = await db.open();
    var result = await database.query(
      this.table,
      columns:this._select,
      where: this._where,
      whereArgs: this._whereArgs,
      orderBy: this._order,
      limit: this._limit,
      offset: this._offset,
    );

    List<dynamic> list = [];
    for (var map in result) {
      var model = this.constructModel();
      model.isCreated = true;
      model.loadFromMap(map);
      await model.afterFetch();
      list.add(model);
    }

    return list;

  }

  raw(String sql) async {
    var database = await db.open();
    var result = await database.rawQuery(sql);

    List<dynamic> list = [];
    for (var map in result) {
      var model = this.constructModel();
      model.isCreated = true;
      model.loadFromMap(map);
      await model.afterFetch();
      list.add(model);
    }

    return list;
  }

  first() async {
    var list = await this.find();
    if (list.length > 0) {
      return list[0];
    }

    return null;
  }

  all() async {
    var database = await db.open();
    var result = await database.query(
      this.table,
      columns:this._select,
      orderBy: this._order,
      limit: this._limit,
      offset: this._offset,
    );

    List<dynamic> list = [];
    for (var map in result) {
      var model = this.constructModel();
      model.isCreated = true;
      model.loadFromMap(map);
      await model.afterFetch();
      list.add(model);
    }

    return list;
  }

  order(String order) {
    this._order = order;
    return this;
  }

  afterFetch() async {

  }

  limit(int limit) {
    this._limit = limit;

    return this;
  }

  offset(int offset) {
    this._offset = offset;

    return this;
  }
}