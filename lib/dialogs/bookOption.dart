import 'package:flutter/material.dart';
import 'package:flutter_app/dialogs/shareBook.dart';
import 'package:flutter_app/models/book.dart';
import 'package:flutter_app/screens/profile.dart';
import 'package:flutter_app/ui/loader.dart';
import 'package:flutter_app/utils/transparent.dart';

import '../colors.dart';
import '../globals.dart';
import 'collectionAdd.dart';

// ignore: must_be_immutable
class BookOptionDialog extends StatefulWidget {

  final Book book;
  final bool showTrash;
  bool showHideButton;
  final Function onAfter;

  BookOptionDialog(this.book, this.showTrash, {this.showHideButton, this.onAfter});

  @override
  BookOptionDialogState createState() => new BookOptionDialogState();

  static open(context, Book book, bool showTrash, {showHideButton = false, Function after}) async {
    // await Navigator.of(context).push(
    //     TransparentRoute(builder: (BuildContext context) => BookOptionDialog(book, showTrash, showHideButton: showHideButton, onAfter: after,))
    // );
    await showFloatingModalBottomSheet(context: context, builder: (_){
      return BookOptionDialog(book, showTrash, showHideButton: showHideButton, onAfter: after,);
    });
  }
}

class BookOptionDialogState extends State<BookOptionDialog> {

  bool bookDownloaded = false;
  void _share() {
    Navigator.pop(context);
    BookShareDialog.open(context, widget.book, () {});
  }

  @override
  void initState() {
    bookDownloaded = widget.book.isDownloaded();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.showHideButton == null) {
      widget.showHideButton = false;
    }    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(topRight: Radius.circular(8), topLeft: Radius.circular(8)),
        color: Colors.white,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          this.widget.showHideButton? this.option('Уже не читаю', Icons.delete, AppColors.secondary, () {removeFromRead();}) : Container(),
          this.widget.showTrash? this.option('Болшьше не показывать', Icons.delete, AppColors.secondary, () {}) : Container(),
          // this.option('Добавить в избраное', Icons.favorite, AppColors.secondary, () {}),
          this.option('Сохранить в коллекцию', Icons.bookmark, AppColors.secondary, () {
            Navigator.pop(context);
            CollectionAddDialog.open(context, widget.book, (){});
          }),
          this.option('Поделиться', Icons.file_upload, AppColors.secondary, () {
            this._share();
          }),
          this.option(bookDownloaded? 'Удалить': 'Загрузить', bookDownloaded? Icons.delete: Icons.download_rounded, AppColors.secondary, () async {

            UiLoader.showLoader(context);                        
            try {
              if (bookDownloaded) {
                await widget.book.deleteDownloaded();
              } else {
                await widget.book.downloadBook();   
              }
              
              await UiLoader.doneLoader(context);
              Navigator.pop(context);
            } catch(e) {
              await UiLoader.errorLoader(context);
            }
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

    await showDialog(builder: (context) => AlertDialog(
      title: Text('Сбросить прогресс чтения книги?'),
      actions: [

        TextButton(
          child: Text('Нет'),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        TextButton(
          child: Text('Да'),
          onPressed: () async {            
            Navigator.pop(context);            
            widget.book.progress = 0;
            await widget.book.save();
            serverApi.setProgress(widget.book);

            if (widget.onAfter != null) {
              widget.onAfter();
            }

          },
        )
      ],
    ), context: context);
    Navigator.pop(context);
  }
}