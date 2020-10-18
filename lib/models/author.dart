import 'package:faker/faker.dart';
import 'package:flutter_app/database/core/models/base.dart';
import 'package:flutter_app/utils/local.dart';
import '../globals.dart';
import 'book.dart';
import 'genre.dart';

class Author extends DatabaseModel {

  String table = 'authors';
  String pk = 'id';

  int id;
  String name;
  String surname;
  String picture;
  String description = '';
  int count;
  Genre genre;
  List<Book> books = [];

  Author({
    this.id,
    this.name,
    this.surname,
    this.picture,
    this.count,
    this.description,
  });

  constructModel() {
    return new Author();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'name': this.name,
      'surname': this.surname,
      'picture': this.picture,
      'count': this.count,
      'description': this.description,
    };
  }

  loadFromMap(Map<String, dynamic> map){

    this.id = map['id'];
    this.name = map['name'];
    this.picture = map['picture'];
    this.surname = map['surname'];
    this.count = map['count'];
    this.description = map['description'];

    return this;
  }

  static List<Author> generate(int count) {
    var faker = new Faker();
    List<Author> list = [];

    for (int i=0; i< count; i++) {
      Author author = new Author(id: i, name: faker.person.firstName(), surname: faker.person.lastName(), picture: 'https://source.unsplash.com/featured/?avatar,' + faker.person.firstName(), count: i *2);
      author.description = faker.lorem.sentences(10).join('. ');
      author.genre = Genre.generate(1)[0];
      list.add(author);
    }

    return list;
  }

  getBooks() async {
    if (books.length > 0) {
      return books;
    }
    if (serverApi.hasConnection) {
      books = List<Book>.from(await serverApi.getBooks(authors: this.id.toString()));
    } else {
      books = await Local.getBooksByAuthor(this);
    }

    return books;
  }

  getAllBooks({Function onPart}) async {

    if (books.length > 0) {
      return books;
    }

    int page = 0;
    books = [];

    List<Book> list = [];

    if (serverApi.hasConnection) {
      while (page == 0 || list.length > 0) {
        page = page + 1;
        list = List<Book>.from(await serverApi.getBooks(authors: this.id.toString(), page: page));

        books.addAll(list);
        if (onPart != null) {
          onPart();
        }
      }
    } else {
      books = await Local.getBooksByAuthor(this);
      onPart();
    }


    return books;

  }

}
