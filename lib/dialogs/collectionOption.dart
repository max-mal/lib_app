

import 'package:flutter/material.dart';
import 'package:flutter_app/dialogs/renameCollection.dart';
import 'package:flutter_app/dialogs/shareCollection.dart';
import 'package:flutter_app/models/collection.dart';
import 'package:flutter_app/utils/transparent.dart';
import '../colors.dart';

class CollectionOptionDialog extends StatefulWidget {

  final Collection collection;  
  final Function doAfter;
  final BuildContext parentContext;

  CollectionOptionDialog(this.collection, this.doAfter, this.parentContext);

  @override
  CollectionOptionDialogState createState() => new CollectionOptionDialogState();

  static void open(context, Collection collection, Function after) {
    Navigator.of(context).push(
        TransparentRoute(builder: (BuildContext context) => CollectionOptionDialog(collection, after, context))
    );
  }
}

class CollectionOptionDialogState extends State<CollectionOptionDialog> {



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
                    this.option('Поделиться коллекцией', Icons.file_upload, AppColors.secondary, () {
                      Navigator.pop(context);
                      CollectionShareDialog.open(context, widget.collection, (){});
                    }),
                    this.option('Редактировать коллекцию', Icons.edit, AppColors.secondary, () {
                      Navigator.pop(context);
                      CollectionRenameDialog.open(context, widget.collection, () {
                        widget.doAfter('edit');
                      });
                    }),
                    this.option('Удалить коллекцию', Icons.delete, AppColors.secondary, () async {
                      await widget.collection.deleteLocally();

                      Navigator.pop(context);
                      widget.doAfter('delete');


                    }, textColor: AppColors.secondary),
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

  Widget option(String text, IconData icon, Color color, Function onTap, {Color textColor = Colors.grey})
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
                  child: Text(text, style: TextStyle(fontSize: 14, color: textColor))
              )
            ],
          ),
          onPressed: onTap,
        )
    );
  }
}