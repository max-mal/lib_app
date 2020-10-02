import 'package:flutter_app/database/core/models/base.dart';

class UserAuthor extends DatabaseModel {
  String table = 'user_authors';
  String pk = 'id';

  int id;
  int authorId;

  constructModel() {
    return new UserAuthor();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'authorId': this.authorId,
    };
  }

  loadFromMap(Map<String, dynamic> map){

    this.id = map['id'];
    this.authorId = map['authorId'];

    return this;
  }

}