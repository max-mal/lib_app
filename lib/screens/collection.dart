import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/dialogs/collectionOption.dart';
import 'package:flutter_app/models/collection.dart';

import '../colors.dart';
import '../globals.dart';
import '../models/book.dart';
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

    if (collections.length == 0) {
      return Center(
        child: Container(
          margin: EdgeInsets.only(top: 80),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,  
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,        
            children: [
              Text('Здесь пока ничего нет', style: TextStyle(
                color: AppColors.grey,
                fontSize: 22,
              )),
              SizedBox(height: 24,),
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle
                ),
                child: Text('🐈', style: TextStyle(
                  fontSize: 70
                )),
              ),
              SizedBox(height: 24,),
              Text('Для начала, \nдобавьте книгу в коллекцию', style: TextStyle(
                color: AppColors.grey,
                fontSize: 16,
              ), textAlign: TextAlign.center,),
            ],
          ),
        ),
      );
    }

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
                showDialog(builder: (context) => AlertDialog(
                  title: Text('Удалить из коллекции?'),
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
                        await userCollection.removeBook(book);
                        setState((){});

                      },
                    )
                  ],
                ), context: context);
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
        duration: Duration(milliseconds: 100000),
        vsync: this,
        value: 1
    );


    Timer timer = Timer.periodic(const Duration(milliseconds: 5), (Timer tmr) {
      _progressAnimcontroller.value -= 7 / 5000;// 0.003;
      if (_progressAnimcontroller.value <= 0 ) {
        print('shouldDelete');
        userCollections.remove(collection);
        serverApi.syncCollections();
        print('timer cancel');
        tmr.cancel();
      }
    });

    Flushbar flushbar;

    flushbar = Flushbar(
      onStatusChanged: (FlushbarStatus status) {
        if (status == FlushbarStatus.DISMISSED) {
          timer.cancel();
        }
      },
      messageText: Text("Удалено: " + collection.name, style: TextStyle(fontSize: 14, color: AppColors.primary),),
      showProgressIndicator: true,
      progressIndicatorBackgroundColor: Colors.black,
      progressIndicatorValueColor: AlwaysStoppedAnimation(AppColors.secondary),
      progressIndicatorController: _progressAnimcontroller,
      duration: Duration(seconds: 5),
      mainButton: TextButton(
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

  @override
  void initState(){
    getCollections();
    super.initState();
  }

  getCollections() async {
    if (serverApi.hasConnection) {
      serverApi.syncCollections();
    }
    userCollections = List<Collection>.from(await Collection().all());

    for (Collection collection in userCollections) {
      await collection.getBooks();
    }
    print(userCollections.toString());
    setState((){
      collections = userCollections;
    });
  }
}