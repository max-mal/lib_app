import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/models/author.dart';
import 'package:flutter_app/models/book.dart';
import 'package:flutter_app/models/searchResult.dart';
import 'package:flutter_app/screens/author.dart';
import 'package:flutter_app/screens/book.dart';

import '../colors.dart';
import '../globals.dart';

List<SearchResult> history = [];

class SearchDialog extends StatefulWidget {
  @override
  SearchDialogState createState() => new SearchDialogState();
}

class SearchDialogState extends State<SearchDialog> {

  final searchController = TextEditingController();

  List<SearchResult> results = [];
  List<SearchResult> resultsFiltered = [];

  bool showAllResults = true;
  bool showBooks = true;
  bool showAuthors = true;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: SingleChildScrollView(
          child: new Container(
            margin: EdgeInsets.only(top: 55),
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                this.searchBar(),
                searchController.text.isEmpty? this.searchHistory(): this.searchResults()
              ],
            ),
          ),
        )
    );
  }

  Widget searchBar()
  {
    return Row(
      children: [
        Container(
          width: MediaQuery.of(context).size.width - 100,
          child: TextFormField(
              controller: searchController,
              onEditingComplete: () {
                setState(() {});
                this.doSearch();
              },
              decoration: new InputDecoration(
                hintText: 'Введите ключевое слово',
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                hintStyle: TextStyle(fontSize: 14, color: AppColors.secondary),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColors.secondary,
                    width: 1.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: AppColors.secondary,
                      width: 1.0
                  ),
                ),
              )
          ),
        ),
        Container(
            child: IconButton(icon: Icon(Icons.clear, color: AppColors.secondary,),
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  SystemNavigator.pop();
                }
              }),
          ),

      ],
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,

    );
  }

  Widget searchHistory()
  {
    if (history.length == 0) {
      return Container(
        margin: EdgeInsets.only(top: 40),
        child: Text('Вы еще ничего не искали', textAlign: TextAlign.left, style: TextStyle(color: AppColors.secondary)),
      );
    }

    return Container(
      child: ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: history.length + 1,
          itemBuilder: (BuildContext ctx, index) {
            if (index == 0) {
              return Container(
                margin: EdgeInsets.only(top: 40),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      child: Text('Последние результаты', style: TextStyle(color: AppColors.grey, fontSize: 16)),
                    ),
                    GestureDetector(
                      child: Container(
                        child: Text('Очистить', style: TextStyle(color: AppColors.secondary, fontSize: 14)),
                      ),
                      onTap: () {
                        setState(() {
                          history = [];
                        });
                      },
                    )

                  ],
                ),
              );
            }

            SearchResult result = history[index -1];

            return GestureDetector(
              onTap: (){
                if (result.type == 'author') {
                  AuthorScreen.open(context, result.author, (){});
                }
                if (result.type == 'book') {
                  BookScreen.open(context, result.book, (){});
                }
              },
              child: Container(
                margin: EdgeInsets.only(top: 15),
//              padding: EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(result.resultTitle, style: TextStyle(color: AppColors.grey, fontSize: 14)),
                    Container(
                      margin: EdgeInsets.only(top: 15),
                      child: Divider(
                        color: AppColors.primary,
                        height: 2,
                      ),
                    )
                  ],
                ),
              ),
            );
          }
      ),
    );
  }

  Widget searchResults()
  {
    if (!this.showAllResults) {
      resultsFiltered = [];
      for (SearchResult result in results) {
        if (showAuthors && result.type == 'author') {
          resultsFiltered.add(result);
        }
        if (showBooks && result.type == 'book') {
          resultsFiltered.add(result);
        }
      }
    }

    return Container(
      margin: EdgeInsets.only(top: 40),
      child: Column(
        children: [
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  child: Text('Результаты', style: TextStyle(color: Colors.black, fontSize: 16)),
                ),
                Row(
                  children: [
                    GestureDetector(
                      child: Container(
                        margin: EdgeInsets.only(right: 20),
                        child: Text('Все', style: TextStyle(color: showAllResults? AppColors.secondary: AppColors.grey, fontSize: 14)),
                      ),
                      onTap: () {
                        setState(() {
                          showAllResults = true;
                          showBooks = true;
                          showAuthors = true;
                        });
                      },
                    ),
                    GestureDetector(
                      child: Container(
                        margin: EdgeInsets.only(right: 20),
                        child: Text('Книги', style: TextStyle(color: showBooks? AppColors.secondary: AppColors.grey, fontSize: 14)),
                      ),
                      onTap: () {
                        setState(() {
                          if (showBooks) {
                            showBooks = false;
                          } else {
                            showBooks = true;
                          }

                          if (showBooks && showAuthors) {
                            showAllResults = true;
                          } else {
                            showAllResults = false;
                          }
                        });

                      },
                    ),
                    GestureDetector(
                      child: Container(
                        child: Text('Авторы', style: TextStyle(color: showAuthors? AppColors.secondary: AppColors.grey, fontSize: 14)),
                      ),
                      onTap: () {
                        setState(() {
                          if (showAuthors) {
                            showAuthors = false;
                          } else {
                            showAuthors = true;
                          }

                          if (showBooks && showAuthors) {
                            showAllResults = true;
                          } else {
                            showAllResults = false;
                          }
                        });
                      },
                    ),

                  ],
                ),
              ],
            ),
          ),
          isLoading ? Container(
            margin: EdgeInsets.only(top: 40),
            child: Text('Поиск...', textAlign: TextAlign.left, style: TextStyle(color: AppColors.secondary)),
          ) : Container(),
          Container( margin: EdgeInsets.only(top: 24), decoration: BoxDecoration( border: Border( bottom: BorderSide( color: AppColors.primary, width: 1)))),
          ListView.separated(
              separatorBuilder: (BuildContext cnt, int index) {
                return Container( margin: EdgeInsets.only(top: 24), decoration: BoxDecoration( border: Border( bottom: BorderSide( color: AppColors.primary, width: 1))));
              },
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (BuildContext ctx, index) {
                SearchResult item = this.showAllResults? results[index] : resultsFiltered[index];

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      print('Adding ' + item.toString());
                      if (!history.contains(item)){
                        history.add(item);
                      }
                      if (item.type == 'author') {
                        AuthorScreen.open(context, item.author, (){});
                      }
                      if (item.type == 'book') {
                        BookScreen.open(context, item.book, (){});
                      }
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.only(right: 24),
                              width: 64,
                              height: item.type == 'book' ? 98 : 64,
                              decoration: BoxDecoration(
                                color: AppColors.grey,
                                borderRadius: item.type == 'book' ?
                                BorderRadius.only(topLeft: Radius.circular(2), topRight: Radius.circular(6), bottomRight: Radius.circular(6), bottomLeft: Radius.circular(2)) :
                                BorderRadius.circular(32),
                                image: DecorationImage(image: CachedNetworkImageProvider(item.type == 'book'? item.book.picture: item.author.picture), fit: BoxFit.cover),
                              ),
                            ),
                            Container(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width - 150,
                                      child: Text(item.resultTitle, style: TextStyle(
                                        color: AppColors.grey,
                                        fontSize: 14,
                                      )),
                                    ),
                                    item.type == 'book' ? (Container(
                                      margin: EdgeInsets.only(top: 15, bottom: 12),
                                      child: Text(item.book.author.name + ' ' + item.book.author.surname, style: TextStyle(
                                        color: AppColors.secondary,
                                        fontSize: 14,
                                      )),
                                    )): Container(),
                                    item.type == 'author' ? (Container(
                                      margin: EdgeInsets.only(top: 15, bottom: 12),
                                      child: Text(item.author.count.toString() + ' книг(и)', style: TextStyle(
                                        color: AppColors.secondary,
                                        fontSize: 14,
                                      )),
                                    )): Container(),

                                  ]),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                );

              },
              itemCount: this.showAllResults? results.length: resultsFiltered.length
          )
        ],
      ),
    );
  }

  List<Book> books = [];
  List<Author> authors = [];

  bool isBooksLoading = false;
  bool isAuthorsLoading = false;

  void doSearch() async
  {
    results = [];
    setState(() {
      authors = [];
      books = [];
      results = [];
      isLoading = true;
      isAuthorsLoading = true;
      isBooksLoading = true;
    });

    serverApi.getAuthors(query: searchController.text).then((data){
      authors = List<Author>.from(data);
      isAuthorsLoading = false;
      buildResults();
    });

    serverApi.getBooks(query: searchController.text).then((data){
      books = List<Book>.from(data);
      isBooksLoading = false;
      buildResults();
    });

    setState(() {});
  }

  buildResults() {
    results = [];
    for (Book book in books) {
      SearchResult result = new SearchResult();
      result.query = searchController.text;
      result.book = book;
      result.type = 'book';
      result.resultTitle = result.book.title;

      results.add(result);
    }

    for (Author author in authors) {
      SearchResult result = new SearchResult();
      result.query = searchController.text;
      result.author = author;
      result.type = 'author';
      result.resultTitle = result.author.name + ' ' + result.author.surname;

      results.add(result);
    }

    setState((){
      isLoading = isBooksLoading || isAuthorsLoading;
    });
  }
}