import 'package:flutter/material.dart';
import 'package:flutter_app/models/book.dart';
import 'package:flutter_app/utils/transparent.dart';
import 'package:share/share.dart';
import '../colors.dart';

class BookShareDialog extends StatefulWidget {

  final Book book;
  final Function doAfter;

  BookShareDialog(this.book, this.doAfter);

  @override
  BookShareDialogState createState() => new BookShareDialogState();

  static void open(context, Book book, Function after) {
    Navigator.of(context).push(
        TransparentRoute(builder: (BuildContext context) => BookShareDialog(book, after))
    );
  }
}

class BookShareDialogState extends State<BookShareDialog> {

  void _share({bool link = false}) {
    if (link) {
      Share.share(widget.book.getDeepLink(), subject: widget.book.title);
    } else {
      Share.share(((widget.book.author?.name?? '') + ' ' +  (widget.book.author?.surname ?? '') + ' - ' + widget.book.title).trim(), subject: widget.book.title);
    }
    
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
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
                    Container(
                        margin: EdgeInsets.only(top: 40, bottom: 24, left: 28, right: 28),
                        child: Text('Поделиться книгой', style: TextStyle(color: Colors.black, fontSize: 20),)
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 28),
                      height: 100,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [                         
                          this.shareOption('Название', Colors.blue, Icons.book, () { _share(); }),
                          this.shareOption('Ссылка', Colors.red, Icons.content_copy, () { _share(link: true); }),                          
                        ],
                      ),
                    ),

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

  Widget shareOption(text, Color color, IconData icon, Function click) {
    return GestureDetector(
      onTap: () {
        print('Share colleection' + widget.book.title);
        click();
      },
      child: Container(
        margin: EdgeInsets.only(right: 24),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.all(Radius.circular(8))
              ),
              child: Icon(icon, color: Colors.white,),
            ),
            Container(margin: EdgeInsets.only(top: 12), child: Text(text, style: TextStyle(color: AppColors.grey, fontSize: 11),),)
          ],
        ),
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
}