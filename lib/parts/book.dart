import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/dialogs/bookOption.dart';
import 'package:flutter_app/models/book.dart';
import 'package:flutter_app/screens/author.dart';
import 'package:flutter_app/screens/book.dart';
import 'package:flutter_app/screens/category.dart';

import '../colors.dart';

class BookWidget extends StatelessWidget {
  const BookWidget({
    Key key,
    this.book,
    this.onAfter,

  }) : super(key: key);

  final Book book;
  final Function onAfter;

  @override
  Widget build(BuildContext context) {
    Book item = this.book;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () async{
                  await BookScreen.open(context, item, (){});
                  if (onAfter != null) {
                    onAfter();
                  }
                },
                child: Hero(
                  tag: 'book-${book.id}',
                  child: Stack(
                    children: [
                      Container(
                        margin: EdgeInsets.only(right: 24),
                        width: 64,
                        height: 98,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(2), topRight: Radius.circular(6), bottomRight: Radius.circular(6), bottomLeft: Radius.circular(2)),                        
                          border: Border.all(color: AppColors.grey),
                        ),
                        child: Image(image: AssetImage("assets/logo.png"), width: 170,)
                      ),                    
                      Container(
                        margin: EdgeInsets.only(right: 24),
                        width: 64,
                        height: 98,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(2), topRight: Radius.circular(6), bottomRight: Radius.circular(6), bottomLeft: Radius.circular(2)),
                          image: DecorationImage(image: CachedNetworkImageProvider(item.picture), fit: BoxFit.cover),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          await BookScreen.open(context, item, (){});
                          if (onAfter != null) {
                            onAfter();
                          }
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width - 200,
                          child: Text(item.title, style: TextStyle(
                            color: AppColors.grey,
                            fontSize: 14,
                          )),
                        ),
                      ),
                      Container(
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 200),
                        margin: EdgeInsets.only(top: 8),
                        child: Wrap(
                          runSpacing: 5,
                          spacing: 10,
                          children: book.genres.map((genre) => InkWell(
                          onTap: () async {
                            await CategoryScreen.open(context, genre, (){});
                            if (onAfter != null) {
                              onAfter();
                            }
                          },
                          child: Text(genre != null? (genre.name ?? '') : '', style: TextStyle(
                            color: AppColors.secondary,
                            fontSize: 14,
                          )),
                        )).toList(),
                        ),
                      ),
                      Container(
                        constraints: BoxConstraints(maxWidth: 130),
                        margin: EdgeInsets.only(top: 8, bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: book.authors.map((author) => Container(
                            margin: EdgeInsets.only(bottom: 5),
                            child: GestureDetector(
                              child: Text((author.name + ' ' + author.surname).trim(), style: TextStyle(
                                  color: AppColors.grey,
                                  fontSize: 14,
                                )
                              ),
                            onTap: () async {
                              await AuthorScreen.open(context, author, (){});
                              if (onAfter != null) {
                                onAfter();
                              }
                            },
                        ),
                          )).toList(),
                        ),
                      ),
                      Divider(
                        height: 5,
                        color: AppColors.primary,
                      )
                    ]),
              )
            ],
          ),
          Container(
            child: RawMaterialButton(
              constraints: BoxConstraints(maxWidth: 20, minHeight: 20, minWidth: 20),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
              ),
              onPressed: () async {
                print('Options - ' + item.id.toString());
                await BookOptionDialog.open(context, item, true);
                if (onAfter != null) {
                  onAfter();
                }
              },
              child: Icon(Icons.more_vert, color: AppColors.secondary),
            ),
          )
        ],
      ),
    );
  }
}







class ReadingBookWidget extends StatelessWidget {
  const ReadingBookWidget({
    Key key,
    this.book,
    this.onAfter,
  }) : super(key: key);

  final Book book;
  final Function onAfter;

  @override
  Widget build(BuildContext context) {
    Book item = this.book;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () async {
                  await BookScreen.open(context, item, (){});
                  if (onAfter != null) {
                    onAfter();
                  }
                },
                child: Hero(
                    tag: 'book-${book.id}',
                    child: Container(
                    margin: EdgeInsets.only(right: 24),
                    width: 64,
                    height: 98,
                    decoration: BoxDecoration(
                      color: AppColors.grey,
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(2), topRight: Radius.circular(6), bottomRight: Radius.circular(6), bottomLeft: Radius.circular(2)),
                      image: DecorationImage(image: CachedNetworkImageProvider(item.picture), fit: BoxFit.cover),
                    ),
                  ),
                ),
              ),
              Container(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          await BookScreen.open(context, item, (){});
                          if (onAfter != null) {
                            onAfter();
                          }
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width - 170,
                          child: Text(item.title, style: TextStyle(
                            color: AppColors.grey,
                            fontSize: 14,
                          )),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 8, bottom: 12),
                        child: GestureDetector(
                          child: Text(item.author.name + ' ' + item.author.surname, style: TextStyle(
                            color: AppColors.secondary,
                            fontSize: 14,
                          )),
                          onTap: () async  {
                            await AuthorScreen.open(context, item.author, () {});
                            if (onAfter != null) {
                              onAfter();
                            }
                          },
                        ),
                      ),
                      Container(
                        width: 150,
                        child: new LinearProgressIndicator(
                          backgroundColor: AppColors.primary,
                          value: item.progress.toDouble() / 100,
                          valueColor: AlwaysStoppedAnimation(AppColors.secondary),
                        ),
                      )
                    ]),
              )
            ],
          ),
          Container(
            child: GestureDetector(
              onTap: () async {
                print('Options - ' + this.book.id.toString());
                await BookOptionDialog.open(context, item, false, showHideButton: true, after: onAfter);
                if (onAfter != null) {
                  onAfter();
                }
              },
              child: Icon(Icons.more_vert),
            ),
          )
        ],
      ),
    );
  }
}

class HorizontalBookWidget extends StatelessWidget {
  const HorizontalBookWidget({
    Key key,
    this.book,

  }) : super(key: key);

  final Book book;

  @override
  Widget build(BuildContext context) {

    Book item = this.book;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              BookScreen.open(context, book, () {});
            },
            child: Container(
              margin: EdgeInsets.only(right: 24),
              width: 130,
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.fold,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(8), bottomRight: Radius.circular(8), bottomLeft: Radius.circular(4)),
                image: DecorationImage(image: CachedNetworkImageProvider(item.picture), fit: BoxFit.cover),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              CategoryScreen.open(context, item.genre, (){});
            },
            child: Container(
              constraints: BoxConstraints(maxWidth: 200),
              margin: EdgeInsets.only(top: 8),
              child: Text(item?.genre?.name ?? '', style: TextStyle(
                color: AppColors.secondary,
                fontSize: 14,
              )),
            ),
          ),
          GestureDetector(
            onTap: () {
              AuthorScreen.open(context, item.author, () {});
            },
            child: Container(
              margin: EdgeInsets.only(top: 8, bottom: 12),
              child: Text(item.author.name + ' ' + item.author.surname, style: TextStyle(
                color: AppColors.primary,
                fontSize: 14,
              )),
            ),
          ),
        ],
      ),
    );
  }
}