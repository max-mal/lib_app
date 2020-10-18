import '../init.dart';
import '../core/models/migration.dart';

class GenreMigration extends Migration {
  String name = "genre_table_create";

  void apply() async {
    var database = await db.open();

    database.execute(
        "CREATE TABLE `genres` ( `id`	INTEGER, `name`	TEXT, `count`	INTEGER,  `picture` TEXT,  PRIMARY KEY(`id`));"
    );
  }
}

class UserGenreMigration extends Migration {
  String name = "user_genres_table_create";

  void apply() async {
    var database = await db.open();

    database.execute(
        "CREATE TABLE `user_genres` ( `id`	INTEGER, `genreId`	INTEGER,  PRIMARY KEY(`id`));"
    );
  }
}
