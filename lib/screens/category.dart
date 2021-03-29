import 'package:flutter/material.dart';
import 'package:flutter_app/models/book.dart';
import 'package:flutter_app/models/genre.dart';
import 'package:flutter_app/parts/book.dart';
import 'package:flutter_app/utils/transparent.dart';
import '../colors.dart';
import '../globals.dart';

class CategoryScreen extends StatefulWidget {
  final Function goTo;
  final Genre genre;

  const CategoryScreen({
    Key key,
    this.goTo,
    this.genre,
  }) : super(key: key);

  _CategoryScreenState createState() => _CategoryScreenState();

  static void open(context, Genre category, Function goTo) {
    Navigator.of(context).push(
        TransparentRoute(builder: (BuildContext context) => CategoryScreen(goTo: goTo, genre: category))
    );
  }
}

class _CategoryScreenState extends State<CategoryScreen> with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;

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
    getRecommendations();
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 24),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                child: IconButton(icon: Icon(Icons.arrow_back_ios), onPressed: () {
                  Navigator.pop(context);
                }),
              ),
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height - 80,
            child: new SingleChildScrollView(
                child: Container(
                  child: Column(
                    children: [
                      this.booksBlock(),
                    ],
                  ),
                )
            ),
          ),
        ],
      ),
    );
  }

  void getRecommendations({bool append = false}) async {
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
      list = await serverApi.getGenreBooks(widget.genre, popular: true, page: page);
    }

    if (isLast) {
      list = await serverApi.getGenreBooks(widget.genre, page: page);
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
//    this.getRecommendations();
    return Container(
//      margin: EdgeInsets.only(top: 32),
      padding: EdgeInsets.symmetric(horizontal: 26, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: Text(this.widget.genre.name ?? '', style: TextStyle(
              color: Colors.black,
              fontSize: 32,
            )),
          ),
          Container(
            margin: EdgeInsets.only(top: 12),
            child: Text(this.widget.genre.description ?? '', style: TextStyle(
              color: AppColors.secondary,
              fontSize: 14,
            )),
          ),
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
                        getRecommendations();
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
                        getRecommendations();
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

    if (isLoading) {
      return Container();
    }

    if (!showMoreButton) {
      return Container(child: Text('Больше книг нет'));
    }

    return new ButtonTheme(
        minWidth: MediaQuery.of(context).size.width,
        height: 52,
        child: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(AppColors.secondary),
            padding: MaterialStateProperty.all(EdgeInsets.all(10))
          ),          
          onPressed: () {
            if (isMoreLoading) {
              return;
            }

            page += 1;
            getRecommendations(append: true);
          },
          child: new Text(isMoreLoading ? 'Загрузка...' : 'Далее', style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white60
          )),
        )
    );
  }


}