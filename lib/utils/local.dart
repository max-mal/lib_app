import 'package:flutter_app/models/author.dart';
import 'package:flutter_app/models/book.dart';
import 'package:flutter_app/models/bookGenre.dart';
import 'package:flutter_app/models/userGenre.dart';

class Local {
  static getUserAuthors() async {

    List<int> userGenreIds = await Local.userGenres();
    List<BookGenre> bookGenres = List<BookGenre>.from(await BookGenre().where('id in (' + userGenreIds.join(',') + ')', []).limit(100).find());
    List<int> authorIds = [];

    for (BookGenre genre in bookGenres) {
      Book book = await Book().where('id = ? ', [genre.bookId.toString()]).first();
      if (book == null) {
        continue;
      }
      if (!authorIds.contains(book.authorId)) {
        authorIds.add(book.authorId);
      }
    }
    return List<Author>.from(await Author().where('id in (' + authorIds.join(',') + ')', []).limit(10).find());
  }

  static userGenres() async {
    var genres = await UserGenre().all();
    List<int> ids = [];
    for (UserGenre userGenre in genres) {
      ids.add(userGenre.genreId);
    }
    return ids;
  }

  static getBooksByAuthor(Author author) async {
    return List<Book>.from(await Book().where('authorId = ?', [author.id.toString()]).find());
  }


}