import 'package:flutter_app/database/core/models/base.dart';

class UserGenre extends DatabaseModel {
  String table = 'user_genres';
  String pk = 'id';

  int id;
  int genreId;

  constructModel() {
    return new UserGenre();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'genreId': this.genreId,
    };
  }

  loadFromMap(Map<String, dynamic> map){

    this.id = map['id'];
    this.genreId = map['genreId'];

    return this;
  }

}