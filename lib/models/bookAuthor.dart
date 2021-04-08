import 'package:flutter_app/database/core/models/base.dart';

class BookToAuthor extends DatabaseModel {
  String table = 'book_author';
  String pk = 'id';

  int id;
  int authorId;
  int bookId;

  constructModel() {
    return new BookToAuthor();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'authorId': this.authorId,
      'bookId': this.bookId,
    };
  }

  loadFromMap(Map<String, dynamic> map){

    this.id = map['id'];
    this.bookId = map['bookId'];
    this.authorId = map['authorId'];

    return this;
  }

}