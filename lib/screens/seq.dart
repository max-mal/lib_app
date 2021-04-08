import 'package:flutter/material.dart';
import 'package:flutter_app/models/book.dart';
import 'package:flutter_app/models/type.dart';
import 'package:flutter_app/parts/book.dart';
import 'package:flutter_app/parts/bottomNavBar.dart';
import 'package:flutter_app/parts/listMoreButton.dart';
import 'package:flutter_app/utils/transparent.dart';
import '../colors.dart';
import '../globals.dart';

class SeqScreen extends StatefulWidget {
  final Function goTo;
  final BookType seq;

  const SeqScreen({
    Key key,
    this.goTo,
    this.seq,
  }) : super(key: key);

  SeqScreenState createState() => SeqScreenState();

  static void open(context, BookType category, Function goTo) {
    Navigator.of(context).push(
        TransparentRoute(builder: (BuildContext context) => SeqScreen(goTo: goTo, seq: category))
    );
  }
}

class SeqScreenState extends State<SeqScreen> {

  List<Book> books = [];

  bool isPopular = false;
  bool isLast = true;
  bool isLoading = false;
  bool isMoreLoading = false;
  int page = 1;
  bool showMoreButton = true;

  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    snackBarContext = context;
    getBooks();
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      bottomNavigationBar: BottomNavBar(
        title: widget.seq.name,        
      ),
      body: new SingleChildScrollView(
          child: Container(
            child: this.booksBlock(),
          )
      ),
    );
  }

  void getBooks({bool append = false}) async { 
    setState(() {
      if (!append) {
        books = [];
        isLoading = true;
      } else {
        isMoreLoading = true;
      }

    });

    List<dynamic> list = [];

    if (isPopular) {
      list = await serverApi.getSeqBooks(widget.seq.id, popular: true, page: page);
    }

    if (isLast) {
      list = await serverApi.getSeqBooks(widget.seq.id, page: page);
    }

    if (append) {
      for (Book book in list) {
        books.add(book);
      }
    } else {
      books = List<Book>.from(list);
    }

    setState((){
      isLoading = false;
      isMoreLoading = false;

      if (append && list.length == 0) {
        showMoreButton = false;
      }
    });
  }

  Widget booksBlock()
  {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 26, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 20),
            child: Row(
              children: [
                Container(
                  margin: EdgeInsets.only(right: 30),
                  child: GestureDetector(
                      child: Text('Популярные', style: TextStyle(color: isPopular? AppColors.secondary: AppColors.grey, fontSize: 14)),
                      onTap: () {
                        setState(() {
                          this.isPopular = true;
                          this.isLast = false;
                          showMoreButton = true;
                          page = 1;
                        });
                        getBooks();
                    },
                  ),
                ),
                Container(
                  child: GestureDetector(
                      child: Text('Последние', style: TextStyle(color: isLast? AppColors.secondary: AppColors.grey, fontSize: 14)),
                      onTap: () {
                        setState(() {
                          this.isPopular = false;
                          this.isLast = true;
                          showMoreButton = true;
                          page = 1;
                        });
                        getBooks();
                      },
                  ),
                )
              ],
            ),
          ),
          Container(
            child: this.booksListView(),

          ),
          moreButton(),
        ],
      ),
    );
  }

  Widget booksListView()
  {
    if (isLoading) {
      return Container(margin: EdgeInsets.only(top: 50),child: Center(child: CircularProgressIndicator()));
    }

    return ListView.separated(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        separatorBuilder: (BuildContext ctx, int index) {
          return Container(
            child: Divider(
              color: AppColors.primary,
              height: 2,
            ),
          );
        },
        itemBuilder: (BuildContext ctx, int index) {
          Book item = books[index];
          return BookWidget(book: item);
        },
        itemCount: books.length
    );

  }

  Widget moreButton() {
    
    if (books.length < 10) {
      return Container();
    }
    
    return ListMoreButton(
      isLoading: isLoading,
      isMoreLoading: isMoreLoading,
      onMore: (){
        page += 1;
        getBooks(append: true);
      },
      showMoreButton: showMoreButton,
    );
  }


}