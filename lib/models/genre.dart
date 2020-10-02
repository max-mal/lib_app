import 'package:faker/faker.dart';
import 'package:flutter_app/database/core/models/base.dart';

import 'book.dart';

class Genre extends DatabaseModel{
  String table = 'genres';
  String pk = 'id';

  int id;
  String name;
  String picture;
  String description;
  int count;

  List<Book> books = [];
  List<Book> booksPopular = [];
  List<Book> booksLast = [];

  Genre({
    this.id,
    this.name,
    this.picture,
    this.count,
  });

  constructModel() {
    return new Genre();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'name': this.name,
      'picture': this.picture,
      'count': this.count,
    };
  }

  loadFromMap(Map<String, dynamic> map){

    this.id = map['id'];
    this.name = map['name'];
    this.picture = map['picture'];
    this.count = map['count'].toInt();

    return this;
  }


  List<Book> getPopular() {
    if (this.booksPopular.length > 0) {
      return booksPopular;
    }

    booksPopular = Book.generate(10, false);
    return booksPopular;
  }

  List<Book> getLast() {
    if (this.booksLast.length > 0) {
      return booksLast;
    }

    booksLast = Book.generate(10, false);
    return booksLast;
  }

  static List<Genre> generate(int count) {
    var faker = new Faker();
    List<Genre> list = [];

    for (int i=0; i< count; i++) {
      Genre genre = new Genre(id: i, name: faker.lorem.word(), picture: 'https://source.unsplash.com/featured/?' + faker.lorem.word(), count: i);
      genre.description = faker.lorem.sentence();
//      genre.books = Book.generate(5, false);
      list.add(genre);
    }

    return list;
  }

}
