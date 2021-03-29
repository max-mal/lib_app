import 'package:flutter/material.dart';
import 'package:flutter_app/models/collection.dart';
import 'package:flutter_app/utils/transparent.dart';
import 'package:share/share.dart';
import '../colors.dart';

class CollectionShareDialog extends StatefulWidget {

  final Collection collection;
  final Function doAfter;

  CollectionShareDialog(this.collection, this.doAfter);

  @override
  CollectionShareDialogState createState() => new CollectionShareDialogState();

  static void open(context, Collection collection, Function after) {
    Navigator.of(context).push(
        TransparentRoute(builder: (BuildContext context) => CollectionShareDialog(collection, after))
    );
  }
}

class CollectionShareDialogState extends State<CollectionShareDialog> {

  void _share() {
    Share.share(widget.collection.name + ' https://openlibrary.org', subject: widget.collection.name);
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
                        child: Text('Поделиться коллекцией', style: TextStyle(color: Colors.black, fontSize: 20),)
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 28),
                      height: 100,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          this.shareOption('Facebook', Colors.blue, Icons.face, () { _share(); }),
                          this.shareOption('Gmail', Colors.red, Icons.mail, () { _share(); }),
                          this.shareOption('Messenger', Colors.lightBlue, Icons.message, () { _share(); }),
                          this.shareOption('Ссылка', Colors.red, Icons.content_copy, () { _share(); }),
                          this.shareOption('Больше', AppColors.primary, Icons.more_vert, () { _share(); }),

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
        print('Share colleection' + widget.collection.name);
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