import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/models/author.dart';
import 'package:flutter_app/models/book.dart';
import 'package:flutter_app/models/searchResult.dart';
import 'package:flutter_app/screens/category.dart';
import 'package:flutter_app/utils/transparent.dart';
import '../globals.dart';
import '../models/genre.dart';

import '../colors.dart';

class NavigationDialog extends StatefulWidget {
  @override
  NavigationDialogState createState() => new NavigationDialogState();

  static void open(context) {
    Navigator.of(context).push(
        TransparentRoute(builder: (BuildContext context) => NavigationDialog())
    );
  }
}

List<Genre> categories = [];

class NavigationDialogState extends State<NavigationDialog> {

  final searchController = TextEditingController();

  List<Genre> categoriesFiltered = [];

  @override
  void initState() {

    super.initState();

    getCategories();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
//                    this.closeModal(),
                      this.searchBar(),
                      this.categoriesList(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        )
    );
  }

  Widget searchBar()
  {
    return Container(
      margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.07),
      width: MediaQuery.of(context).size.width - 48,
      child: TextFormField(
          controller: searchController,
          onChanged: (value) {
            setState(() {});
          },
          decoration: new InputDecoration(
            hintText: 'Поиск по категориям',
            border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
            hintStyle: TextStyle(fontSize: 14, color: AppColors.secondary),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: AppColors.secondary,
                width: 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: AppColors.secondary,
                  width: 1.0
              ),
            ),
          )
      ),
    );
  }

  void getCategories() async
  {

    categories = List<Genre>.from(await new Genre().all());
    setState((){});
    serverApi.getGenres().then((data) async {
      categories = List<Genre>.from(await Genre().all());
      setState((){});
    });
  }

  Widget categoriesList() {

    if (searchController.text.isNotEmpty) {
      categoriesFiltered = [];
      for (Genre genre in categories) {
        if (genre.name.toLowerCase().indexOf(searchController.text.toLowerCase()) != -1) {
          categoriesFiltered.add(genre);
        }
      }

      if (categoriesFiltered.length == 0) {
        return Container(
          margin: EdgeInsets.only(top: 40),
          child: Text('Ничего не можем найти :(', textAlign: TextAlign.left, style: TextStyle(color: AppColors.secondary, fontSize: 14)),
        );
      }
    }
    return Container(
      child: ListView.separated(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          separatorBuilder: (BuildContext ctx, index) {
            return Container(
//              padding: EdgeInsets.only(bottom: 24),
              child: Divider(
                color: AppColors.primary,
                height: 2,
              ),
            );
          },
          itemBuilder: (BuildContext ctx, index) {
            Genre item = searchController.text.isEmpty? categories[index] : categoriesFiltered[index];

            return GestureDetector(
              onTap: (){
                CategoryScreen.open(context, item, (){});
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width - 100,
                      child: Text(item.name, textAlign: TextAlign.left, style: TextStyle(color: AppColors.grey, fontSize: 14)),
                    ),
                    Container(
                      child: Text(item.count.toString(), textAlign: TextAlign.left, style: TextStyle(color: AppColors.secondary, fontSize: 14)),
                    )
                  ],
                ),
              ),
            );
          },
          itemCount: searchController.text.isEmpty? categories.length : categoriesFiltered.length,
      ),
    );
  }

  Widget closeModal(){
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        child: IconButton(icon: Icon(Icons.clear, color: AppColors.secondary,),
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