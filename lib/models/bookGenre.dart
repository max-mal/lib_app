import 'package:flutter_app/database/core/models/base.dart';

class BookGenre extends DatabaseModel {
  String table = 'book_genre';
  String pk = 'id';

  int id;
  int genreId;
  int bookId;

  constructModel() {
    return new BookGenre();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'genreId': this.genreId,
      'bookId': this.bookId,
    };
  }

  loadFromMap(Map<String, dynamic> map){

    this.id = map['id'];
    this.bookId = map['bookId'];
    this.genreId = map['genreId'];

    return this;
  }

}