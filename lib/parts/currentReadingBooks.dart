import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/dialogs/bookOption.dart';
import 'package:flutter_app/models/book.dart';
import 'package:flutter_app/parts/book.dart';
import 'package:flutter_app/screens/areader.dart';
import 'package:flutter_app/screens/author.dart';
import 'package:flutter_app/screens/book.dart';
import 'package:flutter_app/screens/category.dart';

import '../colors.dart';

class CurrentReadingBooks extends StatelessWidget {

  final List<Book> readingBooks;
  final Function onAfter;
  
  CurrentReadingBooks({this.readingBooks, this.onAfter});

  @override
  Widget build(BuildContext context) {

    if (readingBooks.length == 0) {
      return Container(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Приветствуем,', style: TextStyle(
              color: AppColors.grey,
              fontSize: 26,
            )),
          SizedBox(height: 5,), 
            Text('Вы пока ничего не читаете...', style: TextStyle(
              color: AppColors.grey,
              fontSize: 18,
            )),
            SizedBox(height: 10),
            Stack(
              children: [
                Center(child: Image(image: AssetImage("assets/logo.png"),height: 110,)),
                Positioned(
                  bottom: 5,
                  left: 0,
                  right: 73,
                  child: Center(child: Icon(Icons.book_rounded, color: AppColors.grey, size: 30,)),
                ),
              ],
            )
          ]
        )
      );
    }
    return Container(
      padding: EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('С возвращением', style: TextStyle(
            color: AppColors.grey,
            fontSize: 18,
          )),
          SizedBox(height: 5,), 
          Text('Продолжить читать', style: TextStyle(
            color: AppColors.grey,
            fontSize: 26,
          )),
          Container(
            margin: EdgeInsets.only(top: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () async {
                    await BookScreen.open(context, readingBooks.first, (){});
                    onAfter();
                  },
                  child: Stack(
                    children: [
                      Container(                              
                        width: 150,
                        height: 230,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(2), topRight: Radius.circular(6), bottomRight: Radius.circular(6), bottomLeft: Radius.circular(2)),                                
                          border: Border.all(color: AppColors.grey)
                        ),
                        child: Image(image: AssetImage("assets/logo.png"), width: 170,)
                      ),
                      Container(                              
                        width: 150,
                        height: 230,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(2), topRight: Radius.circular(6), bottomRight: Radius.circular(6), bottomLeft: Radius.circular(2)),
                          image: DecorationImage(image: CachedNetworkImageProvider(readingBooks.first.picture), fit: BoxFit.cover),
                          border: Border.all(color: AppColors.grey)
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    constraints: BoxConstraints(minHeight: 150),
                    margin: EdgeInsets.only(left: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(readingBooks.first.title, style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.w400
                              )),
                            ),
                            IconButton(onPressed: () async {
                              BookOptionDialog.open(context, readingBooks.first, false, showHideButton: true, after: (){
                                onAfter();
                              });
                            }, icon: Icon(Icons.more_vert),color: AppColors.grey,)
                          ],
                        ),
                        SizedBox(height: 10,),
                        Wrap(
                          runSpacing: 10,
                          spacing: 10,
                          children: readingBooks.first.genres.map((genre) => InkWell(
                          onTap: () async {
                            await CategoryScreen.open(context, genre, (){});
                            onAfter();
                          },
                          child: Text(genre != null? (genre.name ?? '') : '', style: TextStyle(
                            color: AppColors.secondary,
                            fontSize: 14,
                          )),
                        )).toList(),
                        ),
                        SizedBox(height: 10,),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: readingBooks.first.authors.map((author) => Container(
                            margin: EdgeInsets.only(bottom: 5),
                            child: GestureDetector(
                              child: Text((author.name + ' ' + author.surname).trim(), style: TextStyle(
                                  color: AppColors.grey,
                                  fontSize: 14,
                                )
                              ),
                            onTap: () async {
                              await AuthorScreen.open(context, author, (){});
                              onAfter();
                            },
                        ),
                          )).toList(),
                        ),
                        SizedBox(height: 10,),
                        Container(
                          // width: 150,
                          child: new LinearProgressIndicator(
                            backgroundColor: AppColors.primary,
                            value: readingBooks.first.progress.toDouble() / 100,
                            valueColor: AlwaysStoppedAnimation(AppColors.secondary),
                          ),
                        ),
                        SizedBox(height: 20,),
                        ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(AppColors.secondary),
                            minimumSize: MaterialStateProperty.all(Size(200,40)),
                          ),
                          child: Text('Продолжить читать', style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          onPressed: (){
                            showDialog(context: context, builder: (_){
                              return AReaderScreeen(book: readingBooks.first);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (BuildContext ctx, int index){
              return ReadingBookWidget(book: readingBooks[index + 1], onAfter: (){
                onAfter();
              },);
            },
            itemCount: readingBooks.length -1,
          ),
        ],
      ),
    );
  }
}