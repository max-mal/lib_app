import 'package:flutter_app/database/core/models/base.dart';
import 'package:flutter_app/utils/convert.dart';

class BookReview extends DatabaseModel {

  String pk = 'id';
  String table = 'book_review';

  int id;
  int bookId;
  String text;
  String time;
  String username;

  constructModel() {
    return new BookReview();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'text': this.text,
      'bookId': this.bookId,
      'time': this.time,
      'username': this.username
    };
  }

  loadFromMap(Map<String, dynamic> map){

    this.id = map['id'];
    this.bookId = toInt(map['bookId']);
    this.text = map['text'];
    this.username = map['username'];
    this.time = map['time'];
    return this;
  }
}