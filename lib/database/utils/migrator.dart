class Migrator {

  var migrations;

  start () async {
    for (var migration in this.migrations) {
      print(migration.name + "...");
      var exists = (await migration.where("name = ?", [migration.name]).find()).length > 0;

      if (!exists) {
        print ("Appply migration " + migration.name);
        await migration.apply();
        await migration.store();
        print("DONE!");
      }
    }
  }

  Migrator(migrations) {
    this.migrations = migrations;
  }
}