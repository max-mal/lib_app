import 'package:flutter/material.dart';
import 'package:flutter_app/models/author.dart';
import 'package:flutter_app/models/book.dart';
import 'package:flutter_app/parts/book.dart';
import 'package:flutter_app/parts/bottomNavBar.dart';
import 'package:flutter_app/utils/transparent.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import '../colors.dart';
import '../globals.dart';
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

  static open(context, Author author, Function goTo) async {
    await Navigator.of(context).push(
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
      bottomNavigationBar: BottomNavBar(
        title: widget.author.name + ' ' + widget.author.surname
      ),
      body: Container(
        child:NestedScrollView(
          headerSliverBuilder: (context, value){
            return [
              SliverToBoxAdapter(child: this.header(),),
            ];
          }, 
          body: this.tabs()
        )
      ),
    );
  }

  Widget header()
  {
    return Container(
      margin: EdgeInsets.only(top: 30),
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
          IconButton(onPressed: (){
            Share.share(widget.author.name + ' ' + widget.author.surname + '\n' + widget.author.getDeepLink(),subject: widget.author.name + ' ' + widget.author.surname);
          }, icon: Icon(Icons.share, color: AppColors.secondary,))
        ],
      ),
    );
  }


  Widget booksListView()
  {

    if (loadingBooks && books.length == 0) {
      return Container(margin: EdgeInsets.only(top: 20),child: Center(child: CircularProgressIndicator()));
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15),
      child: ListView.separated(
         shrinkWrap: true,
         physics: NeverScrollableScrollPhysics(),
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
      ),
    );

  }


  TabController _tabController;




  Widget tabs()
  {
    return Container(
      margin: EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.withAlpha(50), width: 0.8))
      ),
      child: Container(
        color: Colors.white,
        child: Stack(
          children: [         
            // SizedBox(height: 10,),
            Container(            
              margin: EdgeInsets.only(top: 40),
              child: TabBarView(
                controller: _tabController,
                children: [
                    this.booksListView(),
                    description()
                ]
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              // height: 200,
              child: Container(            
              decoration: BoxDecoration(            
                  color: Colors.white,
                  border: Border(bottom: BorderSide(color: AppColors.primary, width: 0.8))),
              child: Container(
                color: Colors.white,
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
            )),
          ],
        ),
      ),
    );
  }

  description() {
    widget.author.description = widget.author.description.replaceAll('[img]', '<img src="');
    widget.author.description = widget.author.description.replaceAll('[/img]', '">');
    
    widget.author.description = widget.author.description.replaceAll('[b]', '<strong>');
    widget.author.description = widget.author.description.replaceAll('[/b]', '</strong>');

    widget.author.description = widget.author.description.replaceAll('\n', '<br>');

    String data = html2md.convert(widget.author.description, styleOptions: { 'headingStyle': 'atx' }, ignore: ['script', 'style']);
    return SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 15, vertical: 30),
        child: MarkdownBody(data: data, onTapLink: (text, url, title) {
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