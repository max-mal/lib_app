import 'package:flutter/material.dart';
import 'package:flutter_app/dialogs/search.dart';
import 'package:flutter_app/models/collection.dart';
import 'package:flutter_app/parts/book.dart';
import 'package:flutter_app/parts/currentReadingBooks.dart';
import '../globals.dart';
import '../models/event.dart';
import '../models/book.dart';
import '../colors.dart';

List<Book> moreBooks = [];
List<Book> readingBooks = [];
bool loadingReadingBooks = true;
int moreBooksPage = 0;

class HomeScreen extends StatefulWidget {
  final Function goTo;
  const HomeScreen({
    Key key,
    this.goTo
  }) : super(key: key);

  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  List<Event> eventList = [];

  int currentCardPage = 0;

  bool loadingReadingBooks = false;  
  bool showMoreButton = true;
  bool moreBooksLoading = false;

  @override
  void initState() {
    super.initState();    
    this.getBooks();
    this.getCollections();
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
  }

  @override
  Widget build(BuildContext context){
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.only(top: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            loadingReadingBooks? Container() : CurrentReadingBooks(readingBooks: readingBooks, onAfter: (){
              setState(() {});
              getReadingBooks();
            },),
            this.interestingBooksBlock(),
            Container(
                padding: EdgeInsets.only(left: 24, right: 24, bottom: 30),
                child: this.moreButton()
            ),
          ],
        ),
      ),
    );
  }

  getReadingBooks() async {
    setState(() {
      if (readingBooks.length == 0) {
        loadingReadingBooks = true;
      }
    });

    readingBooks = List<Book>.from(await Book().order('progress desc').where('progress > 0 and progress < 100 ', []).find());
    setState(() {
      loadingReadingBooks = false;
    });
  }

  void getBooks() async
  {
    getReadingBooks();

    if (serverApi.hasConnection) {
      serverApi.getBooks(reading: '1').then((data) async{
        getReadingBooks();
      });

      await serverApi.getUserAuthors();
      await serverApi.getUserGenres();
    }

    if (serverApi.hasConnection && moreBooksPage == 0) {
      getMoreBooks();
    }

    setState((){});
  }

  getMoreBooks() async {
    moreBooksPage += 1;
    moreBooksLoading = true;
    setState((){});
    List<Book> list = [];
    list = List<Book>.from(await serverApi.getRecommendationBooks(page: moreBooksPage));
    if (list.length == 0) {
      showMoreButton = false;
    }
    if (moreBooksPage == 1) {
      moreBooks = [];
    }
    moreBooks.addAll(list);
    moreBooksLoading = false;
    setState((){});
  }

  Widget interestingBooksBlock()
  {
    return Container(      
      padding: EdgeInsets.symmetric(horizontal: 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: Text('Интересные книги', style: TextStyle(
              color: AppColors.grey,
              fontSize: 20,
            )),
          ),
          Container(
            margin: EdgeInsets.only(top: 8),
            child: Text('По вашим предпочтениям', style: TextStyle(
              color: AppColors.secondary,
              fontSize: 14,
            )),
          ),
          Container(
            child: this.moreBooksListView(),

          )
        ],
      ),
    );
  }

  Widget moreBooksListView()
  {
    if (!serverApi.hasConnection) {
      return Container(
          margin: EdgeInsets.only(top: 20),
          child: Center(
              child: ListTile(
                leading: Icon(Icons.signal_wifi_off),
                title: Text('Нет соединения с сервером'),
              )
          )
      );
    }

    if (moreBooks.length == 0) {
      return Container(margin: EdgeInsets.only(top: 20),child: Center(child: CircularProgressIndicator()));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext ctx, int index) {
        Book item = moreBooks[index];
        return BookWidget(book: item, onAfter: (){
          setState(() {});
          getReadingBooks();
        });
      },
      itemCount: moreBooks.length
    );

  }

  Widget moreButton() {
    if (moreBooks.length ==0 || showMoreButton == false || !serverApi.hasConnection) {
      return Container();
    }
    return Center(
      child: new ButtonTheme(
          minWidth: MediaQuery.of(context).size.width,
          height: 52,
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(AppColors.secondary),
              padding: MaterialStateProperty.all(EdgeInsets.all(10)),
              minimumSize: MaterialStateProperty.all(Size(150, 0))
            ),      
            onPressed: () {
              if (moreBooksLoading) {
                return false;
              }
              getMoreBooks();
            },
            child: new Text(moreBooksLoading? 'Загрузка...' : 'Далее', style: TextStyle(
                fontSize: 14,                
                color: Colors.white
            )),
          )
      ),
    );
  }

  void _openSearchDialog() {
    Navigator.of(context).push(new MaterialPageRoute<Null>(
        builder: (BuildContext context) {
          return new SearchDialog();
        },
        fullscreenDialog: true
    ));


  }

}




