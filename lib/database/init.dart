import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'migrations/index.dart';
import 'utils/migrator.dart';

var db = new AppDatabase(migrations);

class AppDatabase {
  final dbName = "app.db";
  Database instance;
  var migrations = [];
  bool isMigrating = false;

  void onCreate(db, version) {
    return db.execute(
      "CREATE TABLE `migration` ( `name`	VARCHAR(255), PRIMARY KEY(`name`));",
    );
  }


  Future open() async {
    if (instance != null) {
      return instance;
    }
    instance = await openDatabase(
      join(await getDatabasesPath(), dbName),
      onCreate: onCreate,
      version: 1,
    );

    if (!isMigrating) {
      isMigrating = true;
      var migrator = new Migrator(this.migrations);
      await migrator.start();
      isMigrating = false;
    }

    return instance;
  }

  AppDatabase(migrations) {
    this.migrations = migrations;
  }
}

