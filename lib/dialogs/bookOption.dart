import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/database/core/models/preferences.dart';
import 'package:flutter_app/dialogs/shareBook.dart';
import 'package:flutter_app/models/author.dart';
import 'package:flutter_app/models/book.dart';
import 'package:flutter_app/models/searchResult.dart';
import 'package:flutter_app/utils/transparent.dart';
import 'package:share/share.dart';

import '../colors.dart';
import '../globals.dart';
import 'collectionAdd.dart';

class BookOptionDialog extends StatefulWidget {

  Book book;
  bool showTrash;
  bool showHideButton;
  Function onAfter;

  BookOptionDialog(this.book, this.showTrash, {this.showHideButton, this.onAfter});

  @override
  BookOptionDialogState createState() => new BookOptionDialogState();

  static void open(context, Book book, bool showTrash, {showHideButton = false, Function after}) {
    Navigator.of(context).push(
        TransparentRoute(builder: (BuildContext context) => BookOptionDialog(book, showTrash, showHideButton: showHideButton, onAfter: after,))
    );
  }
}

class BookOptionDialogState extends State<BookOptionDialog> {


  void _share() {
    Navigator.pop(context);
    BookShareDialog.open(context, widget.book, () {

    });
//    Share.share(widget.book.title + ' https://openlibrary.org', subject: widget.book.title);

  }

  @override
  Widget build(BuildContext context) {
    if (widget.showHideButton == null) {
      widget.showHideButton = false;
    }
    return new Scaffold(
      backgroundColor: Color.fromRGBO(159, 159, 159, 0.8),
        body: new Stack(
            children: [
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(topRight: Radius.circular(8), topLeft: Radius.circular(8)),
                      color: Colors.white,
                    ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      this.widget.showHideButton? this.option('Не показывать в списке', Icons.delete, AppColors.secondary, () {removeFromRead();}) : Container(),
                      this.widget.showTrash? this.option('Болшьше не показывать', Icons.delete, AppColors.secondary, () {}) : Container(),
                      this.option('Добавить в избраное', Icons.favorite, AppColors.secondary, () {}),
                      this.option('Сохранить в коллекцию', Icons.bookmark, AppColors.secondary, () {
                        Navigator.pop(context);
                        CollectionAddDialog.open(context, widget.book, (){});
                      }),
                      this.option('Поделиться', Icons.file_upload, AppColors.secondary, () {
                        this._share();
                      }),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 28),
                        child: Divider(
                          color: AppColors.primary,
                          height: 2,
                        ),
                      ),
                      this.option('Отменить', Icons.clear, AppColors.secondary, () {Navigator.pop(context);}),
                    ],
                  )
                ),
              )
            ],
          ),
        );

  }

  Widget option(String text, IconData icon, Color color, Function onTap)
  {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12),
        margin: EdgeInsets.symmetric(horizontal: 28),
        child: RawMaterialButton(

          child: Row(
            children: [
              Container(
                margin: EdgeInsets.only(right: 24),
                child: Icon(icon, color: color)
              ),
              Container(
                child: Text(text, style: TextStyle(fontSize: 14, color: AppColors.grey))
              )
            ],
          ),
          onPressed: onTap,
        )
    );
  }

  removeFromRead() async {

    await showDialog(context: context, child: AlertDialog(
      title: Text('Не показывать в списке?'),
      actions: [

        FlatButton(
          child: Text('Нет'),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        FlatButton(
          child: Text('Да'),
          onPressed: () async {
            Navigator.pop(context);
            //TODO
            readingBooksHideIds.add(widget.book.id);
            Preferences.set('readingBooksHideIds', readingBooksHideIds.join(','));
            if (widget.onAfter != null) {
              widget.onAfter();
            }

          },
        )
      ],
    ));
    Navigator.pop(context);
  }
}