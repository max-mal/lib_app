import '../init.dart';
import '../core/models/migration.dart';

class BookMigration extends Migration {
  String name = "books_table_create";

  void apply() async {
    var database = await db.open();

    database.execute(
        "CREATE TABLE `books` ( "
            "`id`	INTEGER, "
            "`picture`	TEXT, "
            "`title`	TEXT, "
            "`description`	TEXT,  "
            "`progress` INTEGER,  "
            "`authorId` INTEGER,  "
            "`year` INTEGER,  "
            "`pageCount` INTEGER,  "
            "`isBought` INTEGER,  "
            "`price` REAL,  "
            "`currentChapter` INTEGER,  "
            "`rate` INTEGER,  "
            "`createdAt` TEXT,  "
            "PRIMARY KEY(`id`)"
        ");"
    );
  }
}

class BookGenreMigration extends Migration {
  String name = "book_genre_table_create";

  void apply() async {
    var database = await db.open();

    database.execute(
        "CREATE TABLE `book_genre` ( `id`	INTEGER PRIMARY KEY AUTOINCREMENT, `bookId`	INTEGER, `genreId` INTEGER);"
    );
  }
}

class BookToTypeMigration extends Migration {
  String name = "book_to_types_table_create";

  void apply() async {
    var database = await db.open();

    database.execute(
        "CREATE TABLE `book_to_type` ( `id`	INTEGER PRIMARY KEY AUTOINCREMENT, `bookId`	INTEGER, `typeId` INTEGER);"
    );
  }
}


class BookTypeMigration extends Migration {
  String name = "book_types_table_create";

  void apply() async {
    var database = await db.open();

    database.execute(
        "CREATE TABLE `book_types` ( `id`	INTEGER, `picture`	TEXT, `name` TEXT, `description` TEXT, PRIMARY KEY(`id`));"
    );
  }
}

class BookChapterMigration extends Migration {
  String name = "book_chapter_table_create";

  void apply() async {
    var database = await db.open();

    database.execute(
        "CREATE TABLE `chapter` ( `id`	INTEGER, `title`	TEXT, `number` INTEGER, `isRead` INTEGER, `bookId` INTEGER, `url` TEXT, PRIMARY KEY(`id`));"
    );
  }
}
