import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/dialogs/bookOption.dart';
import 'package:flutter_app/dialogs/subscriptionOffer.dart';
import 'package:flutter_app/models/book.dart';
import 'package:flutter_app/models/userGenre.dart';
import 'package:flutter_app/parts/book.dart';
import 'package:flutter_app/screens/paymentDetails.dart';
import 'package:flutter_app/screens/reader.dart';
import 'package:flutter_app/utils/transparent.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import '../colors.dart';
import '../globals.dart';
import 'author.dart';
import 'category.dart';
import 'package:html2md/html2md.dart' as html2md;

class BookScreen extends StatefulWidget {
  final Function goTo;
  final Book book;

  const BookScreen({
    Key key,
    this.goTo,
    this.book,
  }) : super(key: key);

  _BookScreenState createState() => _BookScreenState();

  static void open(context, Book book, Function goTo) {
    Navigator.of(context).push(
        TransparentRoute(builder: (BuildContext context) => BookScreen(goTo: goTo, book: book))
    );
  }
}

class _BookScreenState extends State<BookScreen> with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {

  @override
  bool get wantKeepAlive => true;

  List<Book> books = [];

  int currentTab = 0;



  final searchController = TextEditingController();

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
            height: MediaQuery.of(context).size.height - 75,
            width: MediaQuery.of(context).size.width,
            child: new SingleChildScrollView(
                child: Container(
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
      margin: EdgeInsets.only(top: 36, left: 24, right: 24),
      child: Column(
        children: [
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.only(right: 24),
                      width: 100,
                      height: 155,
                      decoration: BoxDecoration(
                        color: AppColors.grey,
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(2), topRight: Radius.circular(6), bottomRight: Radius.circular(6), bottomLeft: Radius.circular(2)),
                        image: DecorationImage(image: CachedNetworkImageProvider(widget.book.picture), fit: BoxFit.cover),
                      ),
                    ),
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.30
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 12),
                            child: Text(widget.book.title, style: TextStyle(color: AppColors.grey, fontSize: 20)),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 8),
                            child: GestureDetector(
                              child: Text(widget.book.genre != null ? widget.book.genre.name : '', style: TextStyle(color: AppColors.grey, fontSize: 14)),
                              onTap: () {
                                CategoryScreen.open(context, widget.book.genre, (){});
                              },
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              AuthorScreen.open(context, widget.book.author, (){});
                            },
                            child: Container(
                              margin: EdgeInsets.only(top: 8),
                              child: Text(widget.book.author.name + ' ' + widget.book.author.surname, style: TextStyle(color: AppColors.grey, fontSize: 14)),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                Container(

                  height: 150,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: AppColors.primary,
                        ),
                        child: IconButton(
                          icon: Icon(Icons.more_vert),
                          onPressed: () {
                            BookOptionDialog.open(context, widget.book, false);
                          },
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget booksListView(List<Book> books)
  {
    return ListView.separated(
//        shrinkWrap: true,
//        physics: NeverScrollableScrollPhysics(),
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


  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    snackBarContext = context;

    if (serverApi.hasConnection) {
      widget.book.author.getBooks().then((books) {
        setState(() {});
      });
    }

    UserGenre().all().then((genres) async {
      List<int> ids = [];
      for (UserGenre userGenre in genres) {
        ids.add(userGenre.genreId);
      }
      if (ids.length == 0) {
        return;
      }
      if (serverApi.hasConnection) {
        serverApi.getBooks(genres: ids.join(','), popular: false).then((data) {
          print('Got books: ' + data.toString());
          books = List<Book>.from(data);
          setState(() {});
        });
      }

    });
  }

  Widget tabs()
  {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 24),
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
              Tab(text: 'Описание'),
              Tab(text: 'Инфо'),
              Tab(text: 'Обзоры'),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 40),
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width - 48,
                height: MediaQuery.of(context).size.height - 350,
                child: TabBarView(
                    controller: _tabController,
                    children: [
                      Stack(
                        children: [
                          Container(
                            padding: EdgeInsets.only(bottom: 110),
                            child: description(),
                          ),
                          Positioned(
                            bottom: 40,
                            child: Container(
                              child: this.readButton(),
                            ),
                          )
                        ],
                      ),
                      Container(child: Column(
                        children: [
                          this.infoItem('Жанр', widget.book.genre != null? widget.book.genre.name : ''),
                          this.infoItem('Год', widget.book.year.toString()),
                          this.infoItem('Количество страниц', widget.book.pageCount.toString()),
                          this.infoItem('Тип', widget.book.type != null ? widget.book.type.name : ''),
                        ],
                      )),
                      Container(),
                    ]
                ),
              ),
              this.fromAuthorBlock(),
              this.moreBooksBlock(),
            ],
          ),
        )
      ],
    );
  }

  Widget fromAuthorBlock() {

    if (widget.book.author.books.length == 0 || !serverApi.hasConnection) {
      return Container();
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24),
      color: AppColors.foldA,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(margin: EdgeInsets.only(top: 60,bottom: 8),child: Text('Другие книги от автора', style: TextStyle(color: Colors.white, fontSize: 20))),
          Container(child: Text('Специально для вас', style: TextStyle(color: AppColors.primary, fontSize: 14))),
          Container(
            margin: EdgeInsets.only(top: 40),
            width: MediaQuery.of(context).size.width,
            height: 300,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemBuilder: (BuildContext ctx, int index) {
                Book item = widget.book.author.books[index];
                return HorizontalBookWidget(book: item,);
              },
              itemCount: widget.book.author.books.length,
            ),
          )
        ],
      ),
    );
  }

  Widget moreBooksBlock() {

    if (!serverApi.hasConnection) {
      return Container();
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24),
      color: AppColors.fold,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(margin: EdgeInsets.only(top: 60,bottom: 8),child: Text('Еще книги для вас', style: TextStyle(color: AppColors.grey, fontSize: 20))),
          Container(child: Text('Из списка любимых жанров', style: TextStyle(color: AppColors.secondary, fontSize: 14))),
          books.length == 0? Container(margin: EdgeInsets.only(top: 20, bottom: 40),child: Center(child: CircularProgressIndicator())) : Container(
            margin: EdgeInsets.only(top: 40),
            width: MediaQuery.of(context).size.width,
            child: ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (BuildContext ctx, int index) {
                Book item = books[index];
                return BookWidget(book: item,);
              },
              separatorBuilder: (BuildContext ctx, int index) {
                return Divider(
                  color: AppColors.primary,
                  height: 2,
                );
              },
              itemCount: books.length,
            ),
          )
        ],
      ),
    );
  }

  Widget infoItem(name, value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(bottom: 24, top: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: TextStyle(fontSize: 14, color: AppColors.secondary)),
              Text(value, style: TextStyle(fontSize: 14, color: AppColors.grey))
            ],
          ),
        ),
        Divider(
          color: AppColors.primary,
          height: 2,
        )
      ],
    );
  }

  Widget readButton() {
    String text = 'Начать читать';

    if (widget.book.progress > 0) {
      text = 'Продолжить читать';
    }

    if (!widget.book.isBought) {
      text = widget.book.price.toString() + '₽ - купить, чтобы читать';
    }
    return InkWell(
          onTap: () async {
            if (!widget.book.isBought) {
              SubscriptionOfferDialog.open(context, (){
//                ReaderScreen.open(context, widget.book);
                PaymentDetailsScreen.open(context, widget.book, (){});
              });
              return;
            }
            if (widget.book.currentChapter == null) {
              widget.book.currentChapter = 0;
            }
            ReaderScreen.open(context, widget.book);
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppColors.secondary,
            ),
            height: 52,
            width: MediaQuery.of(context).size.width - 48,
            child: Center(
              child: new Text(text, style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.grey,
                ),
              ),
            ),
          ),
    );
  }

  description() {
    String data = html2md.convert(widget.book.description, styleOptions: { 'headingStyle': 'atx' }, ignore: ['script', 'style']);
    return SingleChildScrollView(
      child: Container(
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