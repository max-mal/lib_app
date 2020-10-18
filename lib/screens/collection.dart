import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/dialogs/collectionOption.dart';
import 'package:flutter_app/models/collection.dart';

import '../colors.dart';
import '../globals.dart';
import '../models/event.dart';
import '../models/book.dart';
import '../models/author.dart';
import 'book.dart';



class CollectionScreen extends StatefulWidget {
  final Function goTo;
  const CollectionScreen({
    Key key,
    this.goTo
  }) : super(key: key);

  _CollectionScreenState createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> with TickerProviderStateMixin {

  List<Collection> collections = userCollections;

  void getCollections()
  {
//    if (collections.isNotEmpty) {
//      return;
//    }
//
//    collections = Collection.generate(3);
  }


  @override
  Widget build(BuildContext context) {
    return new SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(margin: EdgeInsets.only(top: 24), child: Text('Моя коллекция', style: TextStyle(fontSize: 32, color: Colors.black))),
            Container(margin: EdgeInsets.only(top: 12),child: Text('Сохраните ваши любимые книги и откройте их позже.\nТолько вы видите ваши коллекции.', style: TextStyle(fontSize: 14, color: AppColors.secondary))),
            this.collectionsList(),
          ],
        ),
      ),
    );
  }

  Widget collectionsList() {
    this.getCollections();
    return ListView.separated(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext ctx, index) {

          Collection item = collections[index];

          if (item.isDeleted) {
            return Container();
          }

          return Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(child: Text(item.name, style: TextStyle(fontSize: 20, color: AppColors.grey))),
                      Container(constraints: BoxConstraints(maxWidth: 40),child: RawMaterialButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          onPressed: () {
                            print('Cololection options');
                            CollectionOptionDialog.open(context, item, (action) {
                              print(action);
                              if (action == 'delete') {
                                this.showDeletedMessage(item);
                              }
                              setState(() {});
                            });

                          },
                          child: Icon(Icons.more_vert, color: AppColors.secondary),
                      ))
                    ],
                  ),
                ),
                Container(margin: EdgeInsets.only(bottom: 16),child: Text(item.books.length.toString() + ' книг', style: TextStyle(fontSize: 14, color: AppColors.secondary))),
                this.collectionBooks(item),
              ],
            ),
          );
        },
        separatorBuilder: (BuildContext ctx, index) {

          Collection item = collections[index];

          if (item.isDeleted) {
            return Container();
          }
          return Container(
            margin: EdgeInsets.only(top: 24, bottom: 12),
            child: Divider(
              color: AppColors.primary,
              height: 2,
            ),
          );
        },
        itemCount: collections.length
    );
  }

  Widget collectionBooks(Collection userCollection) {
    return Container(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: userCollection.books.length,
          itemBuilder: (BuildContext ctx, index) {
            Book book = userCollection.books[index];

            return GestureDetector(
              onTap: (){
                BookScreen.open(context, book, (){});
              },
              onLongPress: () {
                showDialog(context: context, child: AlertDialog(
                  title: Text('Удалить из коллекции?'),
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
                        await userCollection.removeBook(book);
                        setState((){});

                      },
                    )
                  ],
                ));
              },
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 12),
                width: 64,
                height: 98,
                decoration: BoxDecoration(
                  color: AppColors.grey,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(2), topRight: Radius.circular(6), bottomRight: Radius.circular(6), bottomLeft: Radius.circular(2)),
                  image: DecorationImage(image: CachedNetworkImageProvider(book.picture), fit: BoxFit.cover),
                ),
              ),
            );
          }
      ),
    );
  }

  void showDeletedMessage(Collection collection)
  {
    var _progressAnimcontroller = AnimationController(
        duration: Duration(milliseconds: 100),
        vsync: this,
        value: 1
    );


    Timer timer = Timer.periodic(const Duration(milliseconds: 5), (Timer tmr) {
      _progressAnimcontroller.value -= 5 / 5000;// 0.003;
      if (_progressAnimcontroller.value <= 0 ) {
        userCollections.remove(collection);
        tmr.cancel();
      }
    });

    Flushbar flushbar;

    flushbar = Flushbar(
      messageText: Text("Удалено: " + collection.name, style: TextStyle(fontSize: 14, color: AppColors.primary),),
      showProgressIndicator: true,
      progressIndicatorBackgroundColor: Colors.black,
      progressIndicatorValueColor: AlwaysStoppedAnimation(AppColors.secondary),
      progressIndicatorController: _progressAnimcontroller,
      duration: Duration(seconds: 5),
      mainButton: FlatButton(
        onPressed: () async {
          collection.isDeleted = false;
          await collection.save();
          setState(() {

          });

          timer.cancel();
          _progressAnimcontroller.dispose();
          flushbar.dismiss();
        },
        child: Text(
          "Отменить",
          style: TextStyle(color: AppColors.secondary, fontSize: 14),
        ),
      ),

    );

    flushbar..show(context);
  }
}