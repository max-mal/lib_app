import 'package:faker/faker.dart';
import 'package:flutter_app/database/core/models/base.dart';

class BookType extends DatabaseModel {

  String table = 'book_types';
  String pk = 'id';

  int id;
  String picture;
  String name;
  String description;

  BookType({
    this.id,
    this.name,
  });

  constructModel() {
    return new BookType();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'picture': this.picture,
      'name': this.name,
      'description': this.description,
    };
  }

  loadFromMap(Map<String, dynamic> map){

    this.id = map['id'];
    this.picture = map['picture'];
    this.name = map['name'];
    this.description = map['description'];

    return this;
  }

  static List<BookType> generate(int count) {
    var faker = new Faker();
    List<BookType> list = [];

    for (int i=0; i< count; i++) {
      BookType event = new BookType(id: i, name: faker.food.dish());
      list.add(event);
    }

    return list;
  }

}
