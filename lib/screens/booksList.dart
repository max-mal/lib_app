import 'package:flutter/material.dart';
import 'package:flutter_app/models/book.dart';
import 'package:flutter_app/parts/book.dart';
import 'package:flutter_app/parts/bottomNavBar.dart';

import '../colors.dart';

class BooksListScreen extends StatefulWidget {

  final String title;
  final Function getBooks;

  BooksListScreen({
    this.title,
    this.getBooks
  });

  @override
  _BooksListScreenState createState() => _BooksListScreenState();
}

class _BooksListScreenState extends State<BooksListScreen> {

  List<Book> books;
  bool loading = true;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavBar(
        title: widget.title,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: content(),
      ),
    );
  }

  Widget content(){
    if ((loading == false && books == null) || (loading == false && books.length == 0)) {
      return Center(
        child: Container(          
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,  
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,        
            children: [
              Text(books == null? 'Что-то пошло не так :(' : 'Ничего не найдено :(', style: TextStyle(
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
            ],
          ),
        ),
      );
    }

    if (loading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return ListView.builder(
      itemCount: books.length,
      itemBuilder: (_, int index){
        return BookWidget(
          book: books[index],
          onAfter: (){
            getBooks();
          },
        );
      },
    );

  }

  @override
  void initState() {    
    getBooks();  
    super.initState();
  }

  getBooks() {
    widget.getBooks().then((data){
      setState(() {
        books = List<Book>.from(data);
        loading = false;
      });
    }).catchError((e){
      setState(() {        
        loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Произошла ошибка. Попробуйте еще раз')));
    });
  }

}