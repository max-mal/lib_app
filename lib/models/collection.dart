import 'package:faker/faker.dart';
import 'package:flutter_app/database/core/models/base.dart';
import '../globals.dart';
import 'book.dart';
import 'collectionBooks.dart';

class Collection extends DatabaseModel {

  String table = 'collections';
  String pk = 'iid';

  int iid;
  int id;
  String name;
  List<Book> books = [];
  bool isDeleted = false;

  Collection({
    this.id,
    this.name
  });

  static List<Collection> generate(int count) {
    var faker = new Faker();
    List<Collection> list = [];

    for (int i=0; i< count; i++) {
      Collection collection = new Collection(id: i, name: faker.food.dish());
      collection.books = Book.generate(5, false);
      list.add(collection);
    }

    return list;
  }

  getBooks() async {
    if (books.length > 0) {
      return books;
    }

    for (CollectionBook cBook in await CollectionBook().where('collectionId = ?', [this.iid.toString()]).find()) {
      Book book = await Book().where('id = ?', [cBook.bookId.toString()]).first();

      if (book == null) {
        book = await serverApi.getBook(cBook.bookId);
      }

      if (book != null) {
        books.add(book);
      }
    }

    return books;
  }

  constructModel() {
    return new Collection();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'iid': this.iid,
      'name': this.name,
      'isDeleted' : this.isDeleted ? 1 : 0
    };
  }

  loadFromMap(Map<String, dynamic> map){

    this.id = map['id'];
    this.name = map['name'];
    this.iid = map['iid'];
    this.isDeleted = map['isDeleted'] == 1? true: false;

    return this;
  }

  addBook(Book book) async {
    CollectionBook collectionBook = await CollectionBook().where('collectionId = ? and bookId = ?', [this.iid.toString(), book.id.toString()]).first();
    if (collectionBook != null) {
      return false;
    }

    collectionBook = new CollectionBook();
    collectionBook.bookId = book.id;
    collectionBook.collectionId = this.iid;
    await collectionBook.save();
    await serverApi.addCollectionBook(this, book.id);

    this.books = [];

    await this.getBooks();
    return true;
  }

  removeBook(Book book) async {
    CollectionBook collectionBook = await CollectionBook().where('collectionId = ? and bookId = ?', [this.iid.toString(), book.id.toString()]).first();
    if (collectionBook == null) {
      return false;
    }

    await collectionBook.remove();
    await serverApi.removeCollectionBook(this, book.id);

    this.books = [];

    await this.getBooks();

    return true;
  }

  hasBook(Book book) {

    for (Book collectionBook in books) {
      if (collectionBook.id == book.id) {
        return true;
      }
    }

    return false;
  }

  create() async {
    await this.save();
    await serverApi.createCollection(this);
  }

  update() async {
    await this.save();
    await serverApi.updateCollection(this);
  }

  deleteLocally() async {
    this.isDeleted = true;
    await this.save();
  }

  deleteFully() async {
    await this.deleteLocally();
    await CollectionBook().where('collectionId = ?', [this.iid.toString()]).delete();
    await serverApi.deleteCollection(this);
    await this.remove();
  }



}
