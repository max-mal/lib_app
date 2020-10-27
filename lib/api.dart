import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import 'database/core/models/preferences.dart';
import 'globals.dart';
import 'models/author.dart';
import 'models/book.dart';
import 'models/bookChapter.dart';
import 'models/bookGenre.dart';
import 'models/bookType.dart';
import 'models/collection.dart';
import 'models/collectionBooks.dart';
import 'models/genre.dart';
import 'models/type.dart';
import 'models/user.dart';
import 'models/userAuthor.dart';
import 'models/userGenre.dart';
import 'utils/convert.dart';

class ServerApi {
  String token;
  String serverUrl = Platform.environment['dev'] == null
      ? 'https://book-sunna.sabr.com.tr/api/'
      : 'http://192.168.88.167:8081/api/';
  String booksUrl = Platform.environment['dev'] == null
      ? 'https://book-sunna.sabr.com.tr/books/'
      : 'http://192.168.88.167:8081/books/';

  bool hasConnection = false;

  probe() async {
    print('Probing connection...');
    var response = await this.get('auth/probe', ignoreConnectionStatus: true);
    if (response['ok'] == true) {
      hasConnection = true;
    } else {
      hasConnection = false;
    }

    print('Probe finished: ' + (hasConnection ? 'ok' : 'no connection'));
  }

  showNoConnectionToast() {
    Fluttertoast.showToast(
        msg: "Отсутствует соединение с сервером",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  dynamic get(String method,
      {List<String> params, ignoreConnectionStatus = false}) async {
    if (!this.hasConnection && !ignoreConnectionStatus) {
      this.showNoConnectionToast();
      return {'ok': false, 'error': []};
    }

    if (params == null) {
      params = [];
    }
    print('GET ' + method);
    try {
      http.Response response = await http.get(serverUrl +
          method +
          (token != null ? ('?token=' + token) : '') +
          params.join('&'));
      return jsonDecode(response.body);
    } catch (exception) {
      print(exception);
      return {'ok': false, 'error': []};
    }
  }

  dynamic post(String method, var body,
      {ignoreConnectionStatus = false}) async {
    if (!this.hasConnection && !ignoreConnectionStatus) {
      this.showNoConnectionToast();
      return {'ok': false, 'error': []};
    }

    print('POST ' + method + body.toString());
    http.Response response;
    try {
      response = await http.post(
          serverUrl + method + (token != null ? ('?token=' + token) : ''),
          body: body);
      print(response.body);
      return jsonDecode(response.body);
    } catch (exception) {
      print(exception);
      return {'ok': false, 'error': []};
    }
  }

  String getError(var response, {bool showSnackbar = false}) {
    if (response['error'] == null) {
      return 'Unknown error';
    }

    if (response['error'].length > 0) {
      String message = '';
      for (var err in response['error'].values) {
        message += err.join('\n');
      }
      if (showSnackbar && hasConnection) {
        Scaffold.of(snackBarContext)
            .showSnackBar(SnackBar(content: Text(message)));
      }
      return message;
    }

    if (showSnackbar && hasConnection) {
      Scaffold.of(snackBarContext).showSnackBar(
          SnackBar(content: Text('Произошла ошибка. Повторите позже.')));
    }

    return 'Произошла ошибка. Повторите позже.';
  }

  dynamic login(String email, String password) async {
    var response = await this
        .post('auth/login', {'username': email, 'password': password});
    if (response['ok'] == true) {
      this.token = response['token'];
      Preferences.set('token', token);

      var userResponse = await this.get('profile/get');
      print(userResponse);
      user = new User(
          id: userResponse['id'],
          name: userResponse['name'],
          lastName: userResponse['lastName'],
          email: userResponse['email']);
      await user.store();
      return true;
    }

    return this.getError(response);
  }

  dynamic updateProfile() async {
    var response = await this.post('profile/update', {
      'name': user.name ?? '',
      'email': user.email,
      'lastName': user.lastName ?? ''
    });

    if (response['ok'] == true) {
      return true;
    }
    return this.getError(response, showSnackbar: false);
  }

  dynamic register(String email, String password) async {
    var response = await this
        .post('auth/register', {'email': email, 'password': password});
    if (response['ok'] != true) {
      return this.getError(response);
    }

    return await this.login(email, password);
  }

  dynamic getGenres() async {
    var response = await this.get('genre/list');
    print('Got response');
    if (response['ok'] != true) {
      this.getError(response, showSnackbar: true);
      return [];
    }

    for (var responseGenre in response['genres']) {
      var genre =
          await new Genre().where('id = ?', [responseGenre['id']]).find();
      if (genre.length > 0) {
        genre = genre[0];
        if (responseGenre['isDeleted'] == true) {
          await genre.remove();
        }
      } else {
        genre = new Genre(
            id: responseGenre['id'],
            name: responseGenre['name'],
            picture: responseGenre['picture'],
            count: int.parse(responseGenre['count']));
        await genre.store();
      }
    }

    return await new Genre().all();
  }

  dynamic getAuthors(
      {String query, bool byGenres = false, String genres: ''}) async {
    var response;
    if (byGenres) {
      response =
          await this.get('author/by-genres', params: ['&genres=' + genres]);
    } else {
      response = await this
          .get('author/list', params: query == null ? [] : ['&query=' + query]);
    }

    if (response['ok'] != true) {
      this.getError(response, showSnackbar: true);
      return [];
    }

    List<dynamic> list = [];

    for (var responseGenre in response['authors']) {
      var author =
          await new Author().where('id = ?', [responseGenre['id']]).find();
      if (author.length > 0) {
        author = author[0];
        if (responseGenre['isDeleted'] == true) {
          await author.remove();
        }
      } else {
        author = new Author(
            id: responseGenre['id'],
            name: responseGenre['name'],
            surname: responseGenre['surname'],
            picture: responseGenre['picture'],
            description: responseGenre['description'],
            count: int.parse(responseGenre['count']));
        await author.store();
      }
      list.add(author);
    }

    return list;
  }

  dynamic setUserGenres() async {
    List<int> genreIds = [];
    var userGenres = await new UserGenre().all();

    for (var genre in userGenres) {
      genreIds.add(genre.genreId);
    }

    String genres = genreIds.join(',');

    var response = await this.post('profile/set-genres', {'genres': genres});

    return response['ok'] == true;
  }

  dynamic setUserAuthors() async {
    List<int> authorIds = [];
    var userAuthors = await new UserAuthor().all();

    for (var genre in userAuthors) {
      authorIds.add(genre.authorId);
    }

    String authors = authorIds.join(',');

    var response = await this.post('profile/set-authors', {'authors': authors});

    return response['ok'] == true;
  }

  getUserAuthors() async {
    var response = await this.get('profile/get-authors');
    if (response['ok'] != true) {
      this.getError(response, showSnackbar: true);
      return false;
    }

    for (var responseAuthor in response['authors']) {
      UserAuthor userAuthor = await UserAuthor().where(
          'authorId = ?', [responseAuthor['author_id'].toString()]).first();

      if (userAuthor == null) {
        userAuthor = new UserAuthor();
        userAuthor.authorId = toInt(responseAuthor['author_id']);
        await userAuthor.save();
      }
    }
  }

  getUserGenres() async {
    var response = await this.get('profile/get-genres');
    if (response['ok'] != true) {
      this.getError(response, showSnackbar: true);
      return false;
    }

    for (var responseAuthor in response['genres']) {
      UserGenre userGenre = await UserGenre().where(
          'genreId = ?', [responseAuthor['genre_id'].toString()]).first();

      if (userGenre == null) {
        userGenre = new UserGenre();
        userGenre.genreId = toInt(responseAuthor['genre_id']);
        await userGenre.save();
      }
    }
  }

  getGenreBooks(Genre genre, {bool popular = false, int page = 1}) async {
    var response = await this.get('genre/books',
        params: popular
            ? [
                '&popular=1',
                'page=' + page.toString(),
                'genre=' + genre.id.toString()
              ]
            : ['&genre=' + genre.id.toString(), 'page=' + page.toString()]);

    if (response['ok'] != true) {
      this.getError(response, showSnackbar: true);
      return [];
    }
    List<Book> list = [];
    for (var responseBook in response['books']) {
      list.add(await syncBooks(responseBook));
    }

    return list;
  }

  getBooks(
      {authors: '',
      genres: '',
      popular: false,
      page: 1,
      query: '',
      reading: ''}) async {
    var response = await this.get('books/list', params: [
      '&authors=' + authors,
      '&reading=' + reading,
      'query=' + query,
      'genres=' + genres,
      'page=' + page.toString(),
      'popular=' + (popular ? '1' : '')
    ]);
    if (response['ok'] != true) {
      this.getError(response, showSnackbar: true);
      return [];
    }
    List<Book> list = [];
    for (var responseBook in response['books']) {
      list.add(await syncBooks(responseBook));
    }

    return list;
  }

  getRecommendationBooks({int page = 1}) async {
    var response =
        await this.get('books/recs', params: ['&page=' + page.toString()]);
    if (response['ok'] != true) {
      this.getError(response, showSnackbar: true);
      return [];
    }
    List<Book> list = [];
    for (var responseBook in response['books']) {
      list.add(await syncBooks(responseBook));
    }

    return list;
  }

  getAuthor(int id) async {
    var response =
        await this.get('author/get', params: ['&id=' + id.toString()]);
    if (response['ok'] != true) {
      this.getError(response, showSnackbar: true);
      return null;
    }

    var responseAuthor = response['author'];

    var author =
        await new Author().where('id = ?', [responseAuthor['id']]).first();
    if (author != null) {
      if (responseAuthor['isDeleted'] == true) {
        await author.remove();
      }
    } else {
      author = new Author(
          id: responseAuthor['id'],
          name: responseAuthor['name'],
          surname: responseAuthor['surname'],
          picture: responseAuthor['picture'],
          count: int.parse(responseAuthor['count']),
          description: responseAuthor['description']);
      await author.store();
    }

    return author;
  }

  syncBooks(var responseBook) async {
    Book book = await new Book()
        .where('id = ?', [responseBook['id'].toString()]).first();
    if (book != null) {
      if (responseBook['isDeleted'] == true) {
        await book.remove();
      }
    } else {
      book = new Book();
    }
    if (book.progress != null &&
        book.progress > toInt(responseBook['progress'])) {
      await setProgress(book);
    }
    book.loadFromResponse(responseBook);
    await book.save();
    await syncBookGenres(book, responseBook);
    await syncBookTypes(book, responseBook);
    await book.afterFetch();
    return book;
  }

  syncBookGenres(Book book, var responseBook) async {
    for (var bookGenreId in responseBook['genres']) {
      BookGenre bookGenre = await BookGenre().where(
          'genreId = ? and bookId = ?',
          [bookGenreId.toString(), book.id.toString()]).first();

      if (bookGenre == null) {
        bookGenre = new BookGenre();
        bookGenre.bookId = book.id;
        bookGenre.genreId = int.parse(bookGenreId.toString());
        await bookGenre.save();
      }
    }

    for (BookGenre bookGenre
        in await BookGenre().where('bookId = ?', [book.id]).find()) {
      if (!responseBook['genres'].contains(bookGenre.genreId)) {
        await bookGenre.remove();
      }
    }
  }

  syncBookTypes(Book book, var responseBook) async {
    List<dynamic> ids = [];
    for (var responseBookType in responseBook['type']) {
      BookToType bookType = await BookToType().where(
          'typeId = ? and bookId = ?',
          [responseBookType["SeqId"].toString(), book.id.toString()]).first();

      ids.add(responseBookType["SeqId"].toString());
      if (bookType == null) {
        bookType = new BookToType();
        bookType.bookId = book.id;
        bookType.typeId = int.parse(responseBookType["SeqId"].toString());

        await bookType.save();
      }

      BookType type = await BookType()
          .where('id = ?', [bookType.typeId.toString()]).first();
      if (type == null) {
        type = new BookType();
      }
      type.id = bookType.typeId;
      type.name = responseBookType["SeqName"];
      await type.save();
    }

    for (BookToType bookType
        in await BookToType().where('bookId = ?', [book.id]).find()) {
      if (!ids.contains(bookType.typeId.toString())) {
        await bookType.remove();
      }
    }
  }

  getChapters(int id) async {
    if (!hasConnection) {
      return false;
    }
    var response =
        await this.get('books/chapters', params: ['&id=' + id.toString()]);
    if (response['ok'] != true) {
      this.getError(response, showSnackbar: true);
      return null;
    }

    for (var chapter in response['chapters']) {
      BookChapter bookChapter = await BookChapter()
          .where('id = ?', [chapter['id'].toString()]).first();

      if (bookChapter == null) {
        bookChapter = new BookChapter();
        bookChapter.id = toInt(chapter['id']);
        bookChapter.title = chapter['name'];
        bookChapter.url = chapter['file'];
        bookChapter.number = toInt(chapter['number']);
        bookChapter.isRead = toInt(chapter['is_read']);
        bookChapter.bookId = toInt(chapter['book_id']);

        await bookChapter.save();
      }
    }
  }

  setProgress(Book book) async {
    if (!serverApi.hasConnection) {
      return false;
    }
    var response = await this.post('books/set-progress', {
      'id': book.id.toString(),
      'progress': book.progress.toString(),
      'currentChapter': book.currentChapter.toString()
    });
    if (response['ok'] != true) {
      print(response.toString());
      this.getError(response, showSnackbar: true);
      return null;
    }
  }

  syncCollections() async {
    var response = await this.get('collection/list');
    if (response['ok'] != true) {
      this.getError(response, showSnackbar: true);
      return null;
    }

    for (var responseCollection in response['collections']) {
      Collection collection = await Collection()
          .where('id = ? ', [responseCollection['id'].toString()]).first();

      bool isCollectionCreated = false;

      if (collection == null) {
        collection = new Collection();
        collection.id = toInt(responseCollection['id']);
        collection.name = responseCollection['name'];
        await collection.save();
        isCollectionCreated = true;
      }

      var responseBooks = await this
          .get('collection/books', params: ['&id=' + collection.id.toString()]);

      List<int> serverBookIds = [];
      List<int> clientBookIds = [];
      for (var responseBook in responseBooks['collectionBooks']) {
        CollectionBook collectionBook = await CollectionBook().where(
            'bookId = ? and collectionId = ?', [
          responseBook['book_id'].toString(),
          collection.iid.toString()
        ]).first();

        serverBookIds.add(toInt(responseBook['book_id']));

        if (isCollectionCreated && collectionBook == null) {
          collectionBook = new CollectionBook();
          collectionBook.bookId = toInt(responseBook['book_id']);
          collectionBook.collectionId = collection.iid;
          await collectionBook.save();
        }
      }

      for (CollectionBook cBook in await CollectionBook()
          .where('collectionId = ?', [collection.iid.toString()]).find()) {
        clientBookIds.add(cBook.bookId);
      }

      for (int bookId in serverBookIds) {
        if (!clientBookIds.contains(bookId)) {
          // delete from server
          await this.removeCollectionBook(collection, bookId);
        }
      }
    }

    for (Collection localCollection in await Collection().all()) {
      if (localCollection.id == null) {
        // create on server
        await this.createCollection(localCollection);

        for (Book book in await localCollection.getBooks()) {
          await this.addCollectionBook(localCollection, book.id);
        }
      }

      if (localCollection.isDeleted) {
        // delete locally and on server
        await localCollection.deleteFully();
      }
    }
  }

  createCollection(Collection collection) async {
    if (!hasConnection) {
      return false;
    }
    var response =
        await this.post('collection/create', {'name': collection.name});
    if (response['ok'] != true) {
      this.getError(response, showSnackbar: true);
      return null;
    }

    collection.id = toInt(response['collection']['id']);
    await collection.save();
  }

  addCollectionBook(Collection collection, int bookId) async {
    if (!hasConnection) {
      return false;
    }
    var response = await this.post('collection/add-book',
        {'id': collection.id.toString(), 'bookId': bookId.toString()});
    if (response['ok'] != true) {
      this.getError(response, showSnackbar: true);
      return null;
    }
    return true;
  }

  removeCollectionBook(Collection collection, int bookId) async {
    if (!hasConnection) {
      return false;
    }
    var response = await this.post('collection/remove-book',
        {'id': collection.id.toString(), 'bookId': bookId.toString()});
    if (response['ok'] != true) {
      this.getError(response, showSnackbar: true);
      return null;
    }
    return true;
  }

  deleteCollection(Collection collection) async {
    if (!hasConnection) {
      return false;
    }
    var response =
        await this.post('collection/delete', {'id': collection.id.toString()});
    if (response['ok'] != true) {
      this.getError(response, showSnackbar: true);
      return null;
    }
    return true;
  }

  updateCollection(Collection collection) async {
    if (!hasConnection) {
      return false;
    }
    var response = await this.post('collection/update',
        {'id': collection.id.toString(), 'name': collection.name});
    if (response['ok'] != true) {
      this.getError(response, showSnackbar: true);
      return null;
    }
    return true;
  }

  getBook(int id) async {
    var response =
        await this.get('books/get', params: ['&id=' + id.toString()]);
    if (response['ok'] != true) {
      this.getError(response, showSnackbar: true);
      return null;
    }

    return await this.syncBooks(response['book']);
  }

  getPromoBooks() async {
    var response = await this.get('promo/books');
    if (response['ok'] != true) {
      this.getError(response, showSnackbar: true);
      return null;
    }

    return response['books'];
  }
}
