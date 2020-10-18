import '../init.dart';
import '../core/models/migration.dart';

class AuthorMigration extends Migration {
  String name = "author_table_create";

  void apply() async {
    var database = await db.open();

    database.execute(
        "CREATE TABLE `authors` ( `id`	INTEGER, `name`	TEXT, `surname`	TEXT, `count`	INTEGER,  `picture` TEXT, `description` TEXT,  PRIMARY KEY(`id`));"
    );
  }
}

class UserAuthorMigration extends Migration {
  String name = "user_authors_table_create";

  void apply() async {
    var database = await db.open();

    database.execute(
        "CREATE TABLE `user_authors` ( `id`	INTEGER, `authorId`	INTEGER,  PRIMARY KEY(`id`));"
    );
  }
}
