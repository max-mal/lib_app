import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app/models/bookAuthor.dart';
import 'package:flutter_app/models/bookReview.dart';
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
      ? 'http://192.168.0.101:8081/api/'
      : 'http://192.168.0.101:8081/api/';
  String booksUrl = Platform.environment['dev'] == null
      ? 'http://192.168.0.101:8081/books/'
      : 'http://192.168.0.101:8081/books/';

  String backupServerUrl = "http://pi.my-pc.pw:8081/api/";
  String backupBooksUrl = "http://pi.my-pc.pw:8081/api/";

  bool hasConnection = false;

  getServerUrl() {
    return this.serverUrl.replaceAll('/api/', '');
  }

  probe({bool backupUrl = false}) async {    
    if (backupUrl) {
      String currentUrl = serverUrl;
      String currentBooksUrl = booksUrl;

      serverUrl = backupServerUrl;
      booksUrl = backupBooksUrl;

      backupServerUrl = currentUrl;
      backupBooksUrl = currentBooksUrl;
    }
    print('Probing connection on $serverUrl ...');
    var response;
    try {
      response = await this.get('auth/probe', ignoreConnectionStatus: true);
    } catch (e) {
      hasConnection = false;
      if (backupUrl == false) {
        probe(backupUrl: true);
      }
      return;
    }

    if (response['ok'] == true) {
      hasConnection = true;
    } else {
      hasConnection = false;
      if (backupUrl == false) {
        probe(backupUrl: true);
      }      
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
    print('GET ' +
        serverUrl +
        method +
        (token != null ? ('?token=' + token) : '') +
        params.join('&'));
    try {
      http.Response response = await http.get(Uri.parse(serverUrl +
          method +
          (token != null ? ('?token=' + token) : '') +
          params.join('&')));
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
          Uri.parse(serverUrl + method + (token != null ? ('?token=' + token) : '')),
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
        ScaffoldMessenger.of(snackBarContext)
            .showSnackBar(SnackBar(content: Text(message)));
      }
      return message;
    }

    if (showSnackbar && hasConnection) {
      ScaffoldMessenger.of(snackBarContext).showSnackBar(
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
          id: toInt(userResponse['id']),
          name: userResponse['name'],
          lastName: userResponse['lastName'],
          email: userResponse['email']);
      user.picture = userResponse['picture'];
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
            id: int.parse(responseGenre['id']),
            name: responseGenre['name'],
            picture: responseGenre['picture'],
            count: int.parse(responseGenre['count']));
        await genre.store();
      }
    }

    return await new Genre().all();
  }

  Future<Genre> getGenre(int id) async {
    var response = await this.get('genre/get', params: ['id=$id']);
    var responseGenre = response['genre'];
    var genre = await Genre().where('id = ?', [responseGenre['id']]).first();
    if (responseGenre['isDeleted'] == true) {
      await genre.remove();    
      return null;
    }

    genre = Genre(
      id: int.parse(responseGenre['id']),
      name: responseGenre['name'],
      picture: responseGenre['picture'],
      count: int.parse(responseGenre['count']));

    await genre.store();

    return genre;
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
            id: toInt(responseGenre['id']),
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

    if (hasConnection) {
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
    
    var books = await Book().raw("SELECT books.* FROM books inner join book_genre on book_genre.bookId = books.id where book_genre.genreId = ${genre.id} order by ${popular? "rate desc" : "date(createdAt) desc"} limit 10 offset ${(page - 1) * 10};");

    return List<Book>.from(books);
  }

  getSeqBooks(int seqId, {bool popular = false, int page = 1}) async {
        
    if (hasConnection) {
      return await this.getBooks(seq: seqId.toString(), popular: popular, page: page);
    }

    var books = await Book().raw("SELECT books.* FROM books inner join book_to_type on book_to_type.bookId = books.id where book_to_type.typeId = $seqId order by ${popular? "rate desc" : "date(createdAt) desc"} limit 10 offset ${(page - 1) * 10};");
    return List<Book>.from(books);
  }

  getBooks(
      {authors: '',
      genres: '',
      popular: false,
      page: 1,
      query: '',
      seq: '',
      reading: ''}) async {
    var response = await this.get('books/list', params: [
      '&authors=' + authors,
      '&reading=' + reading,
      'query=' + query,
      'genres=' + genres,
      'page=' + page.toString(),
      'seq=' + seq.toString(),
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
          id: toInt(responseAuthor['id']),
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
      responseBook['progress'] = book.progress;
    }
    book.loadFromResponse(responseBook);
    await book.save();

    for(dynamic bookAuthor in responseBook['authors']) {
      BookToAuthor bookAuthorModel = await BookToAuthor().where('bookId = ? and authorId = ?', [
        book.id.toString(), bookAuthor['AvtorId'].toString()
      ]).first();

      if (bookAuthorModel != null) {
        continue;
      }

      bookAuthorModel = new BookToAuthor();
      bookAuthorModel.bookId = book.id;
      bookAuthorModel.authorId = toInt(bookAuthor['AvtorId'].toString());
      await bookAuthorModel.save();

      Author author = await Author().where('id = ?', [bookAuthor['AvtorId'].toString()]).first();

      if (author == null) {
        await this.getAuthor(bookAuthorModel.authorId);
      }
    }

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

      Genre genre = await Genre().where('id = ?', [bookGenre.genreId.toString()]).first();
      if (genre == null) {
        await getGenre(bookGenre.genreId);
      }
    }

    for (BookGenre bookGenre
        in await BookGenre().where('bookId = ?', [book.id]).find()) {
      if (!responseBook['genres'].contains(bookGenre.genreId.toString())) {
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
      // this.getError(response, showSnackbar: true);
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

  getBookReviews(Book book) async {

    if (hasConnection == false) {
      return List<BookReview>.from(await BookReview().where('bookId = ?', [book.id.toString()]).find());
    }
    
    var response = await this.get('books/reviews', params: ['&id=${book.id}']);

    if (response['ok'] != true) {
      this.getError(response, showSnackbar: true);
      return null;
    }
    List<BookReview> reviews = [];
    await BookReview().where('bookId = ?', [book.id.toString()]).delete();
    for (var review in response['reviews']){
      BookReview reviewModel = BookReview();
      reviewModel.loadFromMap(review);
      await reviewModel.save();
      reviews.add(reviewModel);
    }

    return reviews;
  }

  uploadAvatar(String filePath) async {
    var uri = Uri.parse(serverUrl + 'profile/avatar?token=${this.token}');
    print(uri.toString());
    var request = http.MultipartRequest('POST', uri)      
      ..files.add(await http.MultipartFile.fromPath(
          'avatar', filePath,
      ));
    var response = await request.send();    
    String responseBody = await response.stream.bytesToString();
    print(responseBody);
    var body = jsonDecode(responseBody);
    print(body);
    if (response.statusCode != 200) {
      print('Got code: ' + response.statusCode.toString());
      this.getError(body ?? {});
      return false;
    }

    if (body['ok'] == true) {
      return true;
    }

    this.getError(body);
    return false;
  }

  getUser() async {
    var userResponse = await this.get('profile/get');
    print(userResponse);
    user = new User(
        id: toInt(userResponse['id']),
        name: userResponse['name'],
        lastName: userResponse['lastName'],
        email: userResponse['email']);
    user.picture = userResponse['picture'];
    await user.store();
    return true;
  }

  changePassword(String password) async {
    var response = await this.post('profile/password', {
      'password': password
    });

    if (response['ok'] == true) {
      return true;
    }

    this.getError(response);
    return false;    
  }

  getDownloadedBooks() async {    
    Directory dir = Directory(documentDirectory.path);
    List<FileSystemEntity> list = await dir.list().toList();
    List<int> bookIds = [];
    for (FileSystemEntity e in list) {
      String filename = e.path.split('/').last;
      List<String> parts = filename.split('-');
      if (parts.length == 4 && !bookIds.contains(int.parse(parts[1]))) {
        bookIds.add(int.parse(parts[1]));
      }
    }

    return List<Book>.from(await Book().where('id in (${bookIds.join(',')})', []).find());
  }
}
