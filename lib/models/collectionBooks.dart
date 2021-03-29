import 'package:flutter_app/database/core/models/base.dart';

class CollectionBook extends DatabaseModel {

  String table = 'collection_books';
  String pk = 'id';

  int id;
  int collectionId;
  int bookId;

  constructModel() {
    return new CollectionBook();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'collectionId': this.collectionId,
      'bookId': this.bookId,
    };
  }

  loadFromMap(Map<String, dynamic> map){

    this.id = map['id'];
    this.collectionId = map['collectionId'];
    this.bookId = map['bookId'];

    return this;
  }

}
