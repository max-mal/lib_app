import 'package:flutter_app/database/core/models/migration.dart';

import '../init.dart';

class CollectionMigration extends Migration {
  String name = "collections_table_create";

  void apply() async {
    var database = await db.open();

    database.execute(
        "CREATE TABLE `collections` ( `id`	INTEGER, `iid` INTEGER PRIMARY KEY AUTOINCREMENT, `name`	TEXT, `isDeleted` INTEGER);"
    );
  }
}


class CollectionBooksMigration extends Migration {
  String name = "collection_books_table_create";

  void apply() async {
    var database = await db.open();

    database.execute(
        "CREATE TABLE `collection_books` ( `id` INTEGER PRIMARY KEY AUTOINCREMENT, `collectionId`	INTEGER, `bookId` INTEGER);"
    );
  }
}
