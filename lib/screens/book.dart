import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/dialogs/bookOption.dart';
import 'package:flutter_app/dialogs/subscriptionOffer.dart';
import 'package:flutter_app/models/book.dart';
import 'package:flutter_app/parts/book.dart';
import 'package:flutter_app/parts/bottomNavBar.dart';
import 'package:flutter_app/screens/category.dart';
import 'package:flutter_app/screens/paymentDetails.dart';
import 'package:flutter_app/screens/reader.dart';
import 'package:flutter_app/screens/seq.dart';
import 'package:flutter_app/utils/transparent.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import '../colors.dart';
import '../globals.dart';
import 'author.dart';
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

  static open(context, Book book, Function goTo) async {
    await Navigator.of(context).push(
        TransparentRoute(builder: (BuildContext context) => BookScreen(goTo: goTo, book: book))
    );
  }
}

class _BookScreenState extends State<BookScreen> {

  @override
  bool get wantKeepAlive => true;

  List<Book> books = [];

  int currentTab = 0;


  Widget build(BuildContext context){
    return Scaffold(
      bottomNavigationBar: BottomNavBar(
        title: widget.book.title,
        subtitle: (widget.book.author?.name ?? '') + ' ' + (widget.book.author?.surname ?? ''),
      ),      
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    color: AppColors.grey,
                    height: 270, 
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 80),
                    child: Row(
                      children: [
                        Hero(
                          tag: 'book-${widget.book.id}',
                          child: Stack(
                            children: [
                              Container(
                                margin: EdgeInsets.only(left: 15),
                                width: 170,
                                height: 250,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(topLeft: Radius.circular(2), topRight: Radius.circular(6), bottomRight: Radius.circular(6), bottomLeft: Radius.circular(2)),                                
                                  border: Border.all(color: AppColors.grey)
                                ),
                                child: Image(image: AssetImage("assets/logo.png"), width: 170,)
                              ),
                              Container(
                                margin: EdgeInsets.only(left: 15),
                                width: 170,
                                height: 250,
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.only(topLeft: Radius.circular(2), topRight: Radius.circular(6), bottomRight: Radius.circular(6), bottomLeft: Radius.circular(2)),
                                  image: DecorationImage(image: CachedNetworkImageProvider(widget.book.picture), fit: BoxFit.cover),
                                  border: Border.all(color: AppColors.grey)
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Center(                            
                              child: Container( 
                              margin: EdgeInsets.only(left: 15, top: 60),                           
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(widget.book.title, style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w300
                                  )),
                                  SizedBox(height: 10,),
                                  InkWell(
                                    child: Text((widget.book.author?.name ?? '') + ' ' + (widget.book.author?.surname ?? ''),style: TextStyle(color: AppColors.primary),),
                                    onTap: (){
                                      AuthorScreen.open(context, widget.book.author, null);
                                    },
                                  ),
                                  SizedBox(height: 25,),
                                  this.readButton()                              
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                  ,
                  Positioned(
                    top: 80,
                    right: 30,
                    child: InkWell(
                      child: Icon(Icons.more_vert, color: AppColors.secondary,),
                      onTap: (){                        
                        BookOptionDialog.open(context, widget.book, false);
                      },
                    ),
                  )
                ],
              ),

              bookInfo(),
              bookAbout(),   
              fromAuthorBlock()         
            ],
          ),
        ),
      )
    );
  }

  @override
  void initState() {
    super.initState();   

    widget.book.getGenres().then((data){
      setState((){});
    });
    snackBarContext = context;

    if (serverApi.hasConnection && widget.book.author!= null) {
      widget.book.author.getBooks().then((books) {
        setState(() {});
      });
    }
  }

  Widget fromAuthorBlock() {

    if ((widget.book.author?.books?? []).length == 0 || !serverApi.hasConnection) {
      return Container();
    }

    return Container(
      margin: EdgeInsets.only(top: 20),
      padding: EdgeInsets.symmetric(horizontal: 24),
      color: AppColors.foldA,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(margin: EdgeInsets.only(top: 60,bottom: 8),child: Text('Другие книги от автора', style: TextStyle(color: Colors.white, fontSize: 20))),          
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

  Widget readButton() {
    String text = 'Начать читать';

    if (widget.book.progress > 0) {
      text = 'Продолжить читать';
    }

    if (!widget.book.isBought) {
      text = widget.book.price.toString() + '₽ - купить, чтобы читать';
    }
    return ElevatedButton(
      onPressed: () async {
        if (!widget.book.isBought) {
          SubscriptionOfferDialog.open(context, (){
            PaymentDetailsScreen.open(context, widget.book, (){});
          });
          return;
        }
        if (widget.book.currentChapter == null) {
          widget.book.currentChapter = 0;
        }
        await ReaderScreen.open(context, widget.book);
        setState(() {          
        });
      },
      onLongPress: (){
        showDialog(context: context, builder: (ctx) => AlertDialog(
          content: Text(widget.book.id.toString()),
        ));
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(AppColors.secondary)
      ),
      child: Text(text, style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
 
  Widget description() {
    String data = html2md.convert(widget.book.description, styleOptions: { 'headingStyle': 'atx' }, ignore: ['script', 'style']);
    return Container(
      child: MarkdownBody(data: data, onTapLink: (text, url, title) {
        launch(url);
      }, styleSheet: MarkdownStyleSheet(
          p: TextStyle(
              fontSize: 14,
              color: AppColors.grey,
          )
      ),),
    );
  }

  Widget bookInfo(){
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 20),                
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.grey),
        borderRadius: BorderRadius.circular(5)
      ),
      
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.grey))
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(right: BorderSide(color: AppColors.grey))
                    ),
                    child: Container(                      
                      padding: EdgeInsets.all(5),
                      child: Column(
                        children: [
                          Text(widget.book.year.toString(), style: TextStyle(
                            color: AppColors.grey,
                            fontWeight: FontWeight.w800,
                            fontSize: 27,
                          )),
                          Text('Год', style: TextStyle(
                            color: AppColors.grey,
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                          ),)
                        ],
                      ),
                    ),
                  ),
                ),
                
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(5),
                      child: Column(
                        children: [
                          Text((widget.book.pageCount ?? '?').toString(), style: TextStyle(
                            color: AppColors.grey,
                            fontWeight: FontWeight.w800,
                            fontSize: 27,
                          )),
                          Text('Страниц', style: TextStyle(
                            color: AppColors.grey,
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                          ),)
                        ],
                      ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(right: BorderSide(color: AppColors.grey))
                  ),
                  child: Container(
                    padding: EdgeInsets.all(5),
                    child: Column(                         
                      children: [
                        InkWell(
                          child: Text(widget.book.type != null ? widget.book.type.name : '-', style: TextStyle(
                            color: AppColors.grey,
                            fontWeight: FontWeight.w800,
                            fontSize: 19,
                          ), textAlign: TextAlign.center,),
                          onTap: (){
                            if (widget.book.types.length == 1) {
                              SeqScreen.open(context, widget.book.type, (){});
                            } else if (widget.book.genres.length > 0) {
                              showDialog(context: context, builder: (ctx) => AlertDialog(
                                title: Text(widget.book.title),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: widget.book.types.map((type) => ElevatedButton(
                                    style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.grey)),
                                    child: Text(type.name),
                                    onPressed: (){
                                      SeqScreen.open(context, type, (){});
                                    },
                                  )).toList(),
                                ),
                                actions: [
                                  TextButton(child: Text('Отмена'), onPressed: (){
                                    Navigator.pop(context);
                                  })
                                ],
                              ));
                            }
                          }, 
                        ),
                        Text('Серия', style: TextStyle(
                          color: AppColors.grey,
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                        ),)
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(5),
                    child: Column(
                      children: [
                        InkWell(
                          child: Text(widget.book.genre != null? widget.book.genre.name : '-', style: TextStyle(
                            color: AppColors.grey,
                            fontWeight: FontWeight.w800,
                            fontSize: 19,
                          ),textAlign: TextAlign.center,),
                          onTap: (){
                            if (widget.book.genres.length == 1) {
                              CategoryScreen.open(context, widget.book.genre, (){});
                            } else if (widget.book.genres.length > 0) {
                              showDialog(context: context, builder: (ctx) => AlertDialog(
                                title: Text(widget.book.title),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: widget.book.genres.map((genre) => ElevatedButton(
                                    style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.grey)),
                                    child: Text(genre.name),
                                    onPressed: (){
                                      CategoryScreen.open(context, genre, (){});
                                    },
                                  )).toList(),
                                ),
                                actions: [
                                  TextButton(child: Text('Отмена'), onPressed: (){
                                    Navigator.pop(context);
                                  })
                                ],
                              ));
                            }
                          },                          
                        ),
                        Text('Жанр', style: TextStyle(
                          color: AppColors.grey,
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                        ),)
                      ],
                    ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget bookAbout(){
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.grey),
        borderRadius: BorderRadius.circular(5)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('О книге',style: TextStyle(
            color: AppColors.secondary,
            fontSize: 16
          )),
          Divider(color: AppColors.grey,),
          this.description()
        ],
      ),
    );
  }

}