import 'dart:io';

import 'package:faker/faker.dart';
import 'package:flutter_app/database/core/models/base.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import '../globals.dart';

class BookChapter extends DatabaseModel {

  String pk = 'id';
  String table = 'chapter';

  int bookId;
  int id;
  int number;
  String title;
  int isRead = 0;
  String url = 'https://pastebin.com/raw/RYKzRMt8';

  BookChapter({
    this.id,
    this.number,
    this.title,
    this.bookId,
  });

  constructModel() {
    return new BookChapter();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'title': this.title,
      'number': this.number,
      'isRead': this.isRead,
      'url': this.url,
      'bookId': this.bookId,
    };
  }

  loadFromMap(Map<String, dynamic> map){

    this.id = map['id'];
    this.title = map['title'];
    this.number = map['number'];
    this.isRead = map['isRead'];
    this.url = map['url'];
    this.bookId = map['bookId'];

    return this;
  }

  static List<BookChapter> generate(int count) {
    var faker = new Faker();
    List<BookChapter> list = [];

    for (int i=0; i< count; i++) {
      BookChapter event = new BookChapter(id: i, number: i, title: faker.lorem.words(2).join(' '));
      list.add(event);
    }

    return list;
  }

  Uri getUrl() {
    return Uri.parse(serverApi.booksUrl + this.bookId.toString() + this.url);
  }

  getContents() async {
    final directory = await getApplicationDocumentsDirectory();
    String filename = directory.path + '/book-' + this.bookId.toString() + '-chapter-' + this.number.toString() + '.json';
    if (!await File(filename).exists()) {
      return await http.read(this.getUrl());
    }
    return await File(filename).readAsString();
  }

}
