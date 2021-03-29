import 'dart:async';

import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/models/book.dart';
import 'package:flutter_app/models/collection.dart';
import 'package:flutter_app/utils/transparent.dart';
import '../colors.dart';
import '../globals.dart';
import 'createCollection.dart';

class CollectionAddDialog extends StatefulWidget {

  final Book book;
  // bool showTrash;
  final Function doAfter;


  CollectionAddDialog(this.book, this.doAfter);

  @override
  CollectionAddDialogState createState() => new CollectionAddDialogState();

  static void open(context, Book book, Function after) {
    Navigator.of(context).push(
        TransparentRoute(builder: (BuildContext context) => CollectionAddDialog(book, after))
    );
  }
}

class CollectionAddDialogState extends State<CollectionAddDialog> with TickerProviderStateMixin {

  List<Collection> selectedCollections = [];

  @override
  void initState() {
    super.initState();
    for (Collection collection in userCollections) {
      if (collection.hasBook(widget.book)) {
        selectedCollections.add(collection);
      }
    }
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Сохранить в коллекцию', style: TextStyle(color: AppColors.grey, fontSize: 20)),
                            Container(
                                child: IconButton(icon: Icon(Icons.add), onPressed: () { CollectionCreateDialog.open(context, (){ setState((){}); }); }),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey[400],
                                        offset: Offset(0.0, 6.0),
                                        blurRadius: 5.0,
                                      ),
                                    ]
                                ),
                            )
                          ],
                        )
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 28),
                      child: Divider(
                        color: AppColors.primary,
                        height: 2,
                      ),
                    ),
                    Container(
                      height: 210,
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: ListView.builder(
                          itemCount: userCollections.length,
                          itemBuilder: (BuildContext ctx, index) {
                            Collection item = userCollections[index];
                            return Container(
                              child: Container(
                                margin: EdgeInsets.only(right: 16),
                                child: CheckboxListTile(
                                    controlAffinity: ListTileControlAffinity.leading,
                                    title: Text(item.name, style: TextStyle(fontSize: 14, color: AppColors.grey)),
                                    value: selectedCollections.contains(item)? true: false,
                                    activeColor: AppColors.secondary,
                                    onChanged: (value) {
                                        if (selectedCollections.contains(item)) {
                                          selectedCollections.remove(item);
                                        } else {
                                          selectedCollections.add(item);
                                        }
                                        setState(() {});
                                    },
                                  ),
                              ),
                            );
                          },
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 24),
                      child: this.button('Далее', AppColors.secondary, Colors.white, () async {
                          for (Collection collection in selectedCollections) {
                            int index = userCollections.indexOf(collection);
                            if (index < 0) {
                              return;
                            }
                            await userCollections[index].addBook(widget.book);
                            Navigator.pop(context);
                            this.showAddedMessage(selectedCollections, widget.book);

                            widget.doAfter();

                          }
                      }),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      child: this.button('Отменить', Colors.white, AppColors.grey, () {
                        Navigator.pop(context);
                      }),
                    ),
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

  Widget button(text, Color color, Color textColor, Function action) {
    return ButtonTheme(
        minWidth: MediaQuery.of(context).size.width,
        height: 52,
        child: TextButton(
          style: ButtonStyle(
            padding: MaterialStateProperty.all(EdgeInsets.all(10)),
            backgroundColor: MaterialStateProperty.all(color),
          ),          
          onPressed: action,
          child: new Text(text, style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: textColor,
          )),
        )
    );
  }

  void showAddedMessage(List<Collection> collections, Book book)
  {
    if (snackBarContext == null) {
      return;
    }
    var _progressAnimcontroller = AnimationController(
        duration: Duration(milliseconds: 100),
        vsync: this,
        value: 1
    );


    Timer timer = Timer.periodic(const Duration(milliseconds: 5), (Timer tmr) {
      _progressAnimcontroller.value -= 5 / 5000;// 0.003;
      if (_progressAnimcontroller.value <= 0 ) {
        tmr.cancel();
        _progressAnimcontroller.dispose();
        _progressAnimcontroller = null;
      }
    });

    Flushbar flushbar;

    flushbar = Flushbar(
      messageText: Text("Добавлено в " + collections.length.toString() + " коллекцию(и)", style: TextStyle(fontSize: 14, color: AppColors.primary),),
      showProgressIndicator: true,
      progressIndicatorBackgroundColor: Colors.black,
      progressIndicatorValueColor: AlwaysStoppedAnimation(AppColors.secondary),
      progressIndicatorController: _progressAnimcontroller,
      duration: Duration(seconds: 5),
      mainButton: TextButton(
        onPressed: () async {
          for (Collection collection in collections) {
            int index = userCollections.indexOf(collection);
            if (index < 0) {
              return;
            }
            await userCollections[index].removeBook(book);
            widget.doAfter();

          }
          timer.cancel();
          _progressAnimcontroller.dispose();
          flushbar.dismiss();
          _progressAnimcontroller = null;
        },
        child: Text(
          "Отменить",
          style: TextStyle(color: AppColors.secondary, fontSize: 14),
        ),
      ),

    );

    flushbar..show(snackBarContext);
  }
}