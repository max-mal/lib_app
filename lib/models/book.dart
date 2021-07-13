import 'dart:convert';
import 'dart:io';

import 'package:faker/faker.dart';
import 'package:flutter_app/database/core/models/base.dart';
import 'package:flutter_app/models/bookAuthor.dart';
import 'package:flutter_app/models/bookReview.dart';
import 'package:flutter_app/models/bookType.dart';
import 'package:flutter_app/models/type.dart';
import 'package:flutter_app/utils/convert.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:math';
import '../globals.dart';
import 'author.dart';
import 'bookChapter.dart';
import 'bookGenre.dart';
import 'genre.dart';
import 'package:http/http.dart' as http;

class Book extends DatabaseModel {

  String table = 'books';
  String pk = 'id';


  int id;
  String picture;
  String title;
  String description;
  int progress = 0;
  int authorId;
  int year;
  int pageCount = 0;

  bool isBought = false;
  double price = 0;
  int currentChapter = 0;
  int rate = 0;
  String createdAt;

  Author author;
  List<Author> authors;
  Genre genre;  
  BookType type;

  List<Genre> genres = [];
  List<BookType> types = [];

  List<BookChapter> chapters = [];

  List<BookReview> reviews;

  constructModel() {
    return new Book();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'picture': this.picture,
      'title': this.title,
      'description': this.description,
      'progress': this.progress,
      'authorId': this.authorId,
      'year': this.year,
      'pageCount': this.pageCount,
      'isBought': this.isBought? 1 : 0,
      'price': this.price,
      'currentChapter': this.currentChapter,
      'rate': this.rate,
      'createdAt': this.createdAt,
    };
  }

  loadFromMap(Map<String, dynamic> map){

    this.id = map['id'];
    this.title = map['title'];
    this.picture = map['picture'];
    this.description = map['description'];
    this.progress = map['progress'];
    this.authorId = map['authorId'];
    this.year = map['year'];
    this.pageCount = map['pageCount'];
    this.isBought = map['isBought'] == 1? true : false;
    this.price = map['price'];
    this.currentChapter = map['currentChapter'];
    this.rate = map['rate'];
    this.createdAt = map['createdAt'];

    return this;
  }

  loadFromResponse(Map<String, dynamic> map){

    this.id = toInt(map['id']);
    this.title = map['title'];
    this.picture = map['picture'];
    this.description = map['description'];
    this.progress = toInt(map['progress']);
    this.authorId = toInt(map['author_id']);
    this.year = toInt(map['year']);
    this.pageCount = toInt(map['page_count']);
    this.isBought = toInt(map['is_bought']) == 1? true : false;
    this.price = toDouble(map['price']);
    this.currentChapter = toInt(map['current_chapter']);
    this.rate = toInt(map['rae']);
    this.createdAt = map['created_at'];

    return this;
  }


  getChapters() async {
    if (chapters.length != 0) {
      return chapters;
    }

    chapters = List<BookChapter>.from(await BookChapter().where('bookId = ?', [this.id.toString()]).find());

    if (chapters.length == 0) {
      await serverApi.getChapters(this.id);

      chapters = List<BookChapter>.from(await BookChapter().where('bookId = ?', [this.id.toString()]).find());
    }
    return chapters;
  }


  Book({
    this.id,
    this.picture,
    this.title,
    this.description,
    this.progress,
  });

  static List<Book> generate(int count, bool reading) {
    var faker = new Faker();
    Random random = new Random();
    List<Book> list = [];

    for (int i=0; i< count; i++) {
      Book book = new Book(
          id: i,
          picture: 'https://source.unsplash.com/featured/?book,' + i.toString(),
          title: faker.lorem.word(),
          description: faker.lorem.sentence() + ' ' + faker.lorem.sentence(),
          progress: reading? random.nextInt(100): 0,
      );

      book.author = Author.generate(1)[0];
      book.genre = Genre.generate(1)[0];
      book.year = random.nextInt(10) + 2000;
      book.pageCount = random.nextInt(500) + 10;
      book.type = BookType.generate(1)[0];
      book.price = random.nextInt(1000).toDouble() + 50.0;

      book.isBought = reading;
      list.add(book);
    }

    return list;
  }

  getAuthor() async {
    if (this.author != null) {
      return this.author;
    }

    this.author = await Author().where('id = ?', [this.authorId.toString()]).first();
    if (this.author == null) {
      this.author = await serverApi.getAuthor(this.authorId);
    }

    return this.author;
  }

  getGenres() async {
    if (this.genres.length != 0) {
      return this.genres;
    }    
    var bookGenres = await BookGenre().where('bookId = ?', [this.id.toString()]).find();        
    for(BookGenre bookGenre in bookGenres) {
      Genre genre = await Genre().where('id = ?', [bookGenre.genreId]).first();
      if (genre != null) {
        this.genres.add(genre);        
      }
      
    }
    this.genre = this.genres.length > 0 ? this.genres.first : null;
    return this.genres;
  }

  getTypes() async {
    if (this.types.length != 0) {
      return this.types;
    }
    var bookTypes = await BookToType().where('bookId = ?', [this.id.toString()]).find();

    for(BookToType bookToType in bookTypes) {
      BookType type = await BookType().where('id = ?', [bookToType.typeId.toString()]).first();
      if (type != null) {
        this.types.add(type);
      }

    }
    this.type = this.types.length > 0 ? this.types.first : null;
    return this.types;
  }

  @override
  afterFetch() async {
    // await getAuthor();
    await getAuthors();
    await getGenres();
    await getTypes();
    return super.afterFetch();
  }

  isDownloaded() {
    String filename = documentDirectory.path + '/book-' + this.id.toString() + '-chapter-1.json';
    return File(filename).existsSync();
  }

  deleteDownloaded() async {
    await getChapters();
    for (BookChapter chapter in this.chapters) {
      
      String filename = documentDirectory.path + '/book-' + this.id.toString() + '-chapter-' + chapter.number.toString() + '.json';
      File file = File(filename);
      if ( await file.exists()) {
        await file.delete();
      }
    }
  }

  downloadBook({onProgress}) async {
    if (onProgress == null) {
      onProgress = (status){ print(status); };
    }
    onProgress('Получаю информацию о книге...');
    await getChapters();    

    bool hasFiles = true;

    for (BookChapter chapter in this.chapters) {
      onProgress('Загружаю главу ' + (chapter.number + 1).toString() + '/' + this.chapters.length.toString());
      String filename = documentDirectory.path + '/book-' + this.id.toString() + '-chapter-' + chapter.number.toString() + '.json';
      if (!await File(filename).exists()) {
        String response = await http.read(chapter.getUrl());
        await File(filename).writeAsString(response);
        hasFiles = false;
      }
    }

    //var file = await DefaultCacheManager().getSingleFile(url);
    if (hasFiles) {
      return;
    }

    try {
      onProgress('Получаю список изображений...');
      String url = serverApi.booksUrl + this.id.toString() + '/images.json';
      var response = jsonDecode(await http.read(Uri.parse(url)));
      int index = 0;
      for (var imageUrl in response) {
        onProgress('Загружаю изображение ' + (index + 1).toString() + '/' + response.length.toString());
        await DefaultCacheManager().downloadFile(imageUrl);
        print((imageUrl));
        index++;
      }
    } catch (e) {
      print('Cant download images ' + e.toString());
    }
  }

  getAuthors() async {
    if (this.authors != null) {
      return this.authors;
    }
    
    this.authors = [];

    for (var bookAuthor in await BookToAuthor().where('bookId = ?', [this.id.toString()]).find()) {
      Author author = await Author().where('id = ?', [bookAuthor.authorId.toString()]).first();

      if (author != null) {
        this.authors.add(author);
      }
    }
    this.author = this.authors.length > 0? this.authors.first: null;
    return this.authors;
  }

  getReviews() async {
    if (reviews != null) {
      return reviews;
    }

    reviews = await serverApi.getBookReviews(this);
    return reviews;
  }

  getDeepLink() {
    return serverApi.getServerUrl() + '/link/book/${this.id}';
  }
}
