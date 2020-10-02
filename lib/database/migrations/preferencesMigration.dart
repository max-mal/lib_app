import '../init.dart';
import '../core/models/migration.dart';

class PreferencesMigration extends Migration {
  String name = "preferences_table_create";

  void apply() async {
    var database = await db.open();

    database.execute(
        "CREATE TABLE `preferences` ( `name`	TEXT, `value`	TEXT, PRIMARY KEY(`name`));"
    );
  }
}