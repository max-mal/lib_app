import 'authorMigration.dart';
import 'bookMigration.dart';
import 'collectionMigration.dart';
import 'genreMigration.dart';
import 'userMigration.dart';
import 'preferencesMigration.dart';

var migrations = [
  PreferencesMigration(),
  UserMigration(),
  GenreMigration(),
  UserGenreMigration(),
  AuthorMigration(),
  UserAuthorMigration(),
  BookMigration(),
  BookGenreMigration(),
  BookTypeMigration(),
  BookToTypeMigration(),
  BookChapterMigration(),
  CollectionMigration(),
  CollectionBooksMigration(),
];