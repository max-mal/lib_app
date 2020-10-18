import 'package:flutter_app/database/core/models/base.dart';

class BookToType extends DatabaseModel {
  String table = 'book_to_type';
  String pk = 'id';

  int id;
  int typeId;
  int bookId;

  constructModel() {
    return new BookToType();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'typeId': this.typeId,
      'bookId': this.bookId,
    };
  }

  loadFromMap(Map<String, dynamic> map){

    this.id = map['id'];
    this.bookId = map['bookId'];
    this.typeId = map['typeId'];

    return this;
  }

}