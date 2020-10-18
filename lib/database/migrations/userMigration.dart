import '../init.dart';
import '../core/models/migration.dart';

class UserMigration extends Migration {
  String name = "user_table_create";

  void apply() async {
    var database = await db.open();

    database.execute(
        "CREATE TABLE `user` ( `id`	INTEGER, `name`	TEXT, `email`	TEXT,  `lastName` TEXT, `picture` TEXT, `subscriptionId` INTEGER, `subscriptionExpiresAt` INTEGER,  PRIMARY KEY(`id`));"
    );
  }
}
