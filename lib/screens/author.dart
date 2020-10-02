import 'package:flutter/material.dart';
import 'package:flutter_app/dialogs/bookOption.dart';
import 'package:flutter_app/models/author.dart';
import 'package:flutter_app/models/book.dart';
import 'package:flutter_app/models/genre.dart';
import 'package:flutter_app/parts/book.dart';
import 'package:flutter_app/utils/transparent.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import '../colors.dart';
import '../globals.dart';
import 'category.dart';
import 'package:html2md/html2md.dart' as html2md;

class AuthorScreen extends StatefulWidget {
  final Function goTo;
  final Author author;

  const AuthorScreen({
    Key key,
    this.goTo,
    this.author,
  }) : super(key: key);

  _AuthorScreenState createState() => _AuthorScreenState();

  static void open(context, Author author, Function goTo) {
    Navigator.of(context).push(
        TransparentRoute(builder: (BuildContext context) => AuthorScreen(goTo: goTo, author: author))
    );
  }
}

class _AuthorScreenState extends State<AuthorScreen> with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {

  @override
  bool get wantKeepAlive => true;

  List<Book> books = [];
  bool loadingBooks = false;
  int currentTab = 0;


  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    snackBarContext = context;
    _tabController = TabController(length: 2, vsync: this);

    setState((){
      loadingBooks = true;
    });

    this.widget.author.getAllBooks(onPart: (){
      books = List<Book>.from(widget.author.books);
      setState((){});
    }).then((data) {
      books = List<Book>.from(data);

      setState((){
        loadingBooks = false;
      });

    });
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
            width: MediaQuery.of(context).size.width,
            child: new SingleChildScrollView(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      this.header(),
                      this.tabs(),
                    ],
                  ),
                )
            ),
          ),
        ],
      ),
    );
  }

  Widget header()
  {
    return Container(
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.grey,
              borderRadius: BorderRadius.circular(40),
              image: DecorationImage(image: NetworkImage(widget.author.picture), fit: BoxFit.cover),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 12),
            child: Text(widget.author.name + ' ' + widget.author.surname, style: TextStyle(color: Colors.black, fontSize: 16)),
          ),
          Container(
            margin: EdgeInsets.only(top: 4),
            child: GestureDetector(
                child: Text(widget.author.genre != null? widget.author.genre.name : '', style: TextStyle(color: AppColors.secondary, fontSize: 14)),
                onTap: () {
                  CategoryScreen.open(context, widget.author.genre, (){});
                },
            ),
          )
        ],
      ),
    );
  }


  Widget booksListView()
  {

    if (loadingBooks && books.length == 0) {
      return Container(margin: EdgeInsets.only(top: 20),child: Center(child: CircularProgressIndicator()));
    }

    return ListView.separated(
//        shrinkWrap: true,
//        physics: NeverScrollableScrollPhysics(),
        separatorBuilder: (BuildContext ctx, int index) {
          if (index == books.length - 1 && loadingBooks) {
            return Container(margin: EdgeInsets.only(top: 20, bottom: 20),child: Center(child: CircularProgressIndicator()));
          }
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


  TabController _tabController;


  Widget tabs()
  {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            //This is for background color
              color: Colors.white.withOpacity(0.0),
              border: Border(bottom: BorderSide(color: AppColors.primary, width: 0.8))),
          child: TabBar(
            labelColor: AppColors.secondary,
            unselectedLabelColor: AppColors.grey,
            indicatorColor: AppColors.secondary,
            controller: _tabController,
            tabs: [
              Tab(text: 'Книги'),
              Tab(text: 'Описание'),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 40),
          width: MediaQuery.of(context).size.width - 48,
          height: MediaQuery.of(context).size.height - 250,
          child: TabBarView(
            controller: _tabController,
            children: [
                this.booksListView(),
                Container(
                  child: description(),
                )
            ]
          ),
        )
      ],
    );
  }

  description() {
    String data = html2md.convert(widget.author.description, styleOptions: { 'headingStyle': 'atx' }, ignore: ['script', 'style']);
    return SingleChildScrollView(
      child: Container(
        child: MarkdownBody(data: data, onTapLink: (url) {
          launch(url);
        }, styleSheet: MarkdownStyleSheet(
            p: TextStyle(
              fontSize: 14,
              color: AppColors.grey,
            )
        ),),
      ),
    );
  }
}