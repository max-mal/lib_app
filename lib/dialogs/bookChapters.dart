import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/models/book.dart';
import 'package:flutter_app/models/bookChapter.dart';
import 'package:flutter_app/utils/transparent.dart';

import '../colors.dart';

class BookChapterDialog extends StatefulWidget {
  @override
  BookChapterDialogState createState() => new BookChapterDialogState();
  final Book book;
  final Function navigate;

  BookChapterDialog({this.book, this.navigate});

  static void open(context, Book book, Function navigate,) {
    Navigator.of(context).push(
        TransparentRoute(builder: (BuildContext context) => BookChapterDialog(book: book, navigate: navigate))
    );
  }
}

class BookChapterDialogState extends State<BookChapterDialog> {

  final searchController = TextEditingController();


  @override
  void initState() {
    super.initState();
    widget.book.getChapters().then((result) {
      setState((){});
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        backgroundColor: AppColors.getColor('background'),
        body: Column(
          children: [
            Container(
              child: this.closeModal(),
              margin: EdgeInsets.only(top: 55),
            ),
            Container(
              height: MediaQuery.of(context).size.height - MediaQuery.of(context).size.height * 0.07 - 70,
              child: SingleChildScrollView(
                child: new Container(
//                  margin: EdgeInsets.only(top: 55),
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: ListView.separated(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (BuildContext ctx, index) {
                        BookChapter chapter = widget.book.chapters[index];
                        return Container(
                          padding: EdgeInsets.only(top: 24, bottom: 24),
                          child: GestureDetector(
                            onTap: (){
                              Navigator.pop(context);
                              widget.navigate(index);
                            },
                            child: Text(
                              'Глава ' + (index + 1).toString() + ': ' + chapter.title,
                              style: TextStyle(
                                fontSize: 14,
                                color: widget.book.currentChapter == index? AppColors.secondary : AppColors.grey
                              ),
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (BuildContext ctx, index) {
                        return Container(
                          child: Divider(
                            height: 2,
                            color: AppColors.secondary,
                          ),
                        );
                      },
                      itemCount: widget.book.chapters.length,
                  ),
                ),
              ),
            ),
          ],
        )
    );
  }


  Widget closeModal(){
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        child: IconButton(icon: Icon(Icons.clear, color: AppColors.grey,),
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                SystemNavigator.pop();
              }
            }),
      ),
    );
  }
}