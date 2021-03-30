import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/database/core/models/preferences.dart';
import 'package:flutter_app/dialogs/search.dart';
import 'package:flutter_app/models/collection.dart';
import 'package:flutter_app/models/userAuthor.dart';
import 'package:flutter_app/models/userGenre.dart';
import 'package:flutter_app/parts/book.dart';
import 'package:flutter_app/utils/local.dart';
import '../globals.dart';
import '../models/event.dart';
import '../models/book.dart';
import '../models/author.dart';

import '../colors.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'author.dart';

List<Book> interestingBooks = [];
List<Book> moreBooks = [];
List<Book> mayLikeBooks = [];
List<Book> readingBooks = [];
List<Author> authorsForYou = [];

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
  int moreBooksPage = 0;
  bool showMoreButton = true;
  bool moreBooksLoading = false;

  @override
  void initState() {
    super.initState();
    snackBarContext = context;
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
  Widget build(BuildContext context) {
    return new SingleChildScrollView(
      child: Container(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(left: 24, right: 24, top: 50),
              child: this.header(),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: this.events(),
            ),
            this.cards(),
            this.cardPager(),
            this.continueReadingBlock(),
            this.interestingBooksBlock(false),
            this.mayLikeBooksBlock(),

            this.authorsForYouBlock(),
            authorsForYou.length == 0? Container(margin: EdgeInsets.only(top: 20,),child: Center(child: CircularProgressIndicator())) :  Container(
                height: 250,
                color: AppColors.fold,
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: this.authorsForYouListView()
            ),
            this.interestingBooksBlock(true),
            Container(
                padding: EdgeInsets.only(left: 24, right: 24, bottom: 30),
                child: this.moreButton()
            ),

          ],
        ),
      )
    );
  }

  Widget header()
  {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          child: Text('На сегодня', style: TextStyle(color: AppColors.grey, fontSize: 32, fontWeight: FontWeight.bold)),
        ),
        GestureDetector(
          child: Container(
            width: 40,
            height: 40,
            child: Icon(Icons.search),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: AppColors.primary,
            ),
          ),
          onTap: () {
            _openSearchDialog();
          }
        )
      ],
    );
  }

  Widget events()
  {
    if (eventList.length == 0) {
      setState(() {
        eventList = Event.generate(10);
      });
    }

    return Container(
      height: 80,
      margin: EdgeInsets.only(top: 40),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext ctx, int index) {
          Event item = eventList[index];
          return Container(
            width: 80,
            height: 80,
            margin: EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
                color: AppColors.grey,
                borderRadius: BorderRadius.circular(40),
                image: DecorationImage(image: CachedNetworkImageProvider(item.picture), fit: BoxFit.cover),
                border: Border.all(color: AppColors.secondary, width: 3)
            ),
          );
        },
        itemCount: eventList.length,
      ),
    );


  }

  Widget cards()
  {
    return Container(
      margin: EdgeInsets.only(top: 20),
      child: CarouselSlider(
        options: CarouselOptions(
          height: 170,
          onPageChanged: (index, reason) {
            new Future.delayed(const Duration(milliseconds: 350), (){
              setState(() {
                currentCardPage = index;
              });
            });
          }
        ),
        items: eventList.map((i) {
          return Builder(
            builder: (BuildContext context) {
              return Container(
                padding: EdgeInsets.all(16),
                margin: EdgeInsets.symmetric(horizontal: 18),
                width: MediaQuery.of(context).size.width - 24,
                height: 160,
                decoration: BoxDecoration(
                  color: AppColors.grey,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(i.title, style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    )),
                    Container(
                      margin: EdgeInsets.only(top: 6),
                      child: Text(i.description, style: TextStyle(color: Colors.white)),
                    )
                  ],
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }

  Widget cardPager()
  {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: eventList.map((item) {
          int index = eventList.indexOf(item);
          return Container(
            width: currentCardPage == index? 16 : 4.0,
            height: 4.0,
            margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
            decoration: BoxDecoration(
//              shape: currentCardPage == index? BoxShape.rectangle: BoxShape.circle,
              borderRadius: BorderRadius.all(Radius.circular(2)),
              color: AppColors.secondary,
            ),
          );
        }).toList(),
      ),
    );
  }

  getReadingBooks() async {
    setState(() {
      if (readingBooks.length == 0) {
        loadingReadingBooks = true;
      }
    });

    var list = (await Preferences.get('readingBooksHideIds', value: '')).split(',');
    for (String item in list) {
      if (item == '') {
        continue;
      }
      int value = int.parse(item);
      if (!readingBooksHideIds.contains(value)) {
        readingBooksHideIds.add(value);
      }
    }

    readingBooks = List<Book>.from(await Book().where('progress > 0 and progress < 100 ', []).find());
    setState(() {
    loadingReadingBooks = false;
    });
  }

  void getBooks() async
  {

    getReadingBooks();


    if (serverApi.hasConnection) {
      serverApi.getBooks(reading: '1').then((data) async{
        readingBooks = List<Book>.from(await Book().where('progress > 0 and progress < 100 ', []).find());
        setState((){});
      });

      await serverApi.getUserAuthors();
      await serverApi.getUserGenres();
    }

    UserGenre().all().then((genres) async {
      List<int> ids = [];
      for (UserGenre userGenre in genres) {
        ids.add(userGenre.genreId);
      }
//      if (ids.length == 0) {
//        return;
//      }

      if (serverApi.hasConnection) {
        serverApi.getAuthors(byGenres: true, genres: ids.join(',')).then((authors) {
          print('Got authors: ' + authors.toString());
          authorsForYou = List<Author>.from(authors);
          setState(() {});
        });

        serverApi.getBooks(genres: ids.join(','), popular: false).then((books) {
          print('Got mayLikeBooks: ' + books.toString());
          mayLikeBooks = List<Book>.from(books);
          setState(() {});
        });
      } else {
        Local.getUserAuthors().then((data){
          authorsForYou = List<Author>.from(data);
          print('Got local authors: ' + data.toString());
          setState(() {});
        });
      }


      UserAuthor().all().then((authors) async {
        List<int> authorIds = [];
        for (UserAuthor userAuthor in authors) {
          authorIds.add(userAuthor.authorId);
        }
//        if (authorIds.length == 0) {
//          return;
//        }

        if (serverApi.hasConnection) {
          serverApi.getBooks(genres: ids.join(','), authors: authorIds.join(','), popular: true).then((books) {
            print('Got interestingBooks: ' + books.toString());
            interestingBooks = List<Book>.from(books);
            setState(() {});
          });
        }

      });

    });
    if (serverApi.hasConnection) {
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
    moreBooks.addAll(list);
    moreBooksLoading = false;
    setState((){});
  }

  Widget continueReadingBlock()
  {
    return Container(
      margin: EdgeInsets.only(top: 32),
      padding: EdgeInsets.symmetric(horizontal: 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: Text('Продолжить читать...', style: TextStyle(
              color: AppColors.grey,
              fontSize: 20,
            )),
          ),
          Container(
            margin: EdgeInsets.only(top: 8),
            child: Text('Книги, которые вы сейчас читаете', style: TextStyle(
              color: AppColors.secondary,
              fontSize: 14,
            )),
          ),
          Container(
            child: this.currentBooksListView(),

          )
        ],
      ),
    );
  }

  Widget currentBooksListView()
  {
    if (loadingReadingBooks) {
      return Container(margin: EdgeInsets.only(top: 20),child: Center(child: CircularProgressIndicator()));
    }

    if (readingBooks.length == 0) {
      return Container(margin: EdgeInsets.only(top: 20),child: Center(child: Text('Вы пока ничего не читаете', style: TextStyle(color: AppColors.grey, fontSize: 14))));
    }

    return ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext ctx, int index) {
          Book item = readingBooks[index];
          if (readingBooksHideIds.contains(item.id)) {
            return Container();
          }
          return ReadingBookWidget(book: item, onAfter: (){
            getReadingBooks();
          },);
        },
      itemCount: readingBooks.length,
    );

  }

  Widget interestingBooksBlock(bool additional)
  {
    return Container(
      color: !additional?AppColors.fold:null,
      margin: EdgeInsets.only(top: 32),
      padding: EdgeInsets.symmetric(horizontal: 26, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: Text(!additional? 'Интересные книги' :'Еще книги для вас', style: TextStyle(
              color: AppColors.grey,
              fontSize: 20,
            )),
          ),
          Container(
            margin: EdgeInsets.only(top: 8),
            child: Text(!additional? 'По вашим предпочтениям' : 'Из списка любимых жанров', style: TextStyle(
              color: AppColors.secondary,
              fontSize: 14,
            )),
          ),
          Container(
            child: this.interestingBooksListView(additional),

          )
        ],
      ),
    );
  }

  Widget interestingBooksListView(bool additional)
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

    if (additional && moreBooks.length == 0) {
      return Container(margin: EdgeInsets.only(top: 20),child: Center(child: CircularProgressIndicator()));
    }

    if (!additional && interestingBooks.length == 0) {
      return Container(margin: EdgeInsets.only(top: 20),child: Center(child: CircularProgressIndicator()));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext ctx, int index) {
        Book item = !additional? interestingBooks[index] : moreBooks[index];
        return BookWidget(book: item);
      },
      itemCount: !additional? interestingBooks.length : moreBooks.length
    );

  }

  Widget mayLikeBooksBlock()
  {
    return Container(
      color: AppColors.foldA,
      padding: EdgeInsets.only(top: 60, left: 26, right: 26),
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: Text('Вам может понравиться', style: TextStyle(
              color: Colors.white,
              fontSize: 20,
            )),
          ),
          Container(
            margin: EdgeInsets.only(top: 8),
            child: Text('Последние книги по вашим жанрам', style: TextStyle(
              color: AppColors.secondary,
              fontSize: 14,
            )),
          ),
          Container(
              height: mayLikeBooks.length == 0 ? null : 310,
              color: AppColors.foldA,
              margin: EdgeInsets.only(top: 40),
              child: this.mayLikeBooksListView()
          ),
        ],
      ),
    );
  }

  Widget mayLikeBooksListView()
  {
    if (!serverApi.hasConnection) {
      return Container(
          margin: EdgeInsets.only(top: 20, bottom: 60),
          child: Center(
              child: ListTile(
                leading: Icon(Icons.signal_wifi_off),
                title: Text('Нет соединения с сервером'),
              )
          )
      );
    }

    if (mayLikeBooks.length == 0) {
      return Container(margin: EdgeInsets.only(top: 20, bottom: 40),child: Center(child: CircularProgressIndicator()));
    }

    return ListView.builder(
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext ctx, int index) {
        Book item = mayLikeBooks[index];
        return HorizontalBookWidget(book: item,);
      },
      itemCount: mayLikeBooks.length,
    );

  }

  Widget authorsForYouBlock()
  {
    return Container(
      color: AppColors.fold,
      padding: EdgeInsets.symmetric(vertical: 60, horizontal: 26),
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: Text('Авторы для вас', style: TextStyle(
              color: AppColors.grey,
              fontSize: 20,
            )),
          ),
          Container(
            margin: EdgeInsets.only(top: 8),
            child: Text('Из списка любимых жанров', style: TextStyle(
              color: AppColors.secondary,
              fontSize: 14,
            )),
          ),
        ],
      ),
    );
  }

  Widget authorsForYouListView()
  {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemBuilder: (BuildContext ctx, int index) {
        Author item = authorsForYou[index];
        return GestureDetector(
          onTap: (){
            AuthorScreen.open(context, item, (){});
          },
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 108,
                  height: 108,
                  decoration: BoxDecoration(
                    color: AppColors.grey,
                    borderRadius: BorderRadius.circular(54),
                    image: DecorationImage(image: CachedNetworkImageProvider(item.picture), fit: BoxFit.cover),
                  ),
                ),
                
                Container(
                  margin: EdgeInsets.only(top: 8, bottom: 12),
                  child: Text(item.name + ' \n ' + item.surname, textAlign: TextAlign.center, style: TextStyle(
                    color: AppColors.grey,
                    fontSize: 14,
                  )),
                ),
                Container(
                  constraints: BoxConstraints(maxWidth: 200),
                  margin: EdgeInsets.only(top: 8),
                  child: Text(item.genre != null ? item.genre.name : '', style: TextStyle(
                    color: AppColors.secondary,
                    fontSize: 14,
                  )),
                ),
              ],
            ),
          ),
        );
      },
      itemCount: authorsForYou.length,
    );

  }

  Widget moreButton() {
    if (moreBooks.length ==0 || showMoreButton == false) {
      return Container();
    }
    return new ButtonTheme(
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
              fontWeight: FontWeight.bold,
              color: Colors.white60
          )),
        )
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




