import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/models/author.dart';
import 'package:flutter_app/models/genre.dart';
import 'package:flutter_app/models/userAuthor.dart';
import 'package:flutter_app/models/userGenre.dart';
import 'package:flutter_app/parts/button.dart';
import 'package:flutter_app/parts/input.dart';
import 'package:flutter_app/screens/subscriptionBuy.dart';
import 'package:flutter_app/utils/transparent.dart';
import '../colors.dart';
import '../globals.dart';

class UserPreferencesScreen extends StatefulWidget {

  const UserPreferencesScreen({
    Key key,
  }) : super(key: key);

  _UserPreferencesScreenState createState() => _UserPreferencesScreenState();

  static void open(context) {
    Navigator.of(context).push(
        TransparentRoute(builder: (BuildContext context) => UserPreferencesScreen())
    );
  }
}

class _UserPreferencesScreenState extends State<UserPreferencesScreen> with TickerProviderStateMixin {

  int currentTab = 0;
  TabController _tabController;

  final searchController = TextEditingController();
  List<dynamic> genreList = [];
  List<dynamic> authorList = [];
  List<Genre> filteredGenreList = [];
  List<int> selectedGenres = [];
  List<dynamic> filteredAuthorList = [];
  List<dynamic> mineAuthorsList = [];
  List<int> selectedAuthors = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    snackBarContext = context;
    getGenres();
    getAuthors();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
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
//              height: MediaQuery.of(context).size.height - 80,
                width: MediaQuery.of(context).size.width,
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
          ],
        ),
      ),
    );
  }

  Widget header()
  {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(child: Text('Изменить интересы', style: TextStyle(color: Colors.black, fontSize: 32)), margin: EdgeInsets.only(top: 36, bottom: 12),),
          Container(child: Text('Выберите свои любимые жанры, следуйте за авторами, и они будут главной странице.', style: TextStyle(color: AppColors.secondary, fontSize: 14))),
        ],
      ),
    );
  }



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
              Tab(text: 'Жанры'),
              Tab(text: 'Авторы'),
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
                Column(
                  children: [
                    isLoading? Container(margin: EdgeInsets.only(top: 20),child: Text('Загрузка...'))  : Container(),
                    new Expanded(
                      child: new SizedBox(
                        child: this.genresList(),
                        height: 200,
                      ),
                    ),
                  ],
                ),
                SingleChildScrollView(
                  child: SizedBox(
                    child: Column(
                      children: [
                        this.authorsSearch(),
                        isLoading? Container(margin: EdgeInsets.only(top: 20),child: Text('Загрузка...'))  : Container(),
                        searchController.text.length > 0 || mineAuthorsList.length == 0? Container() : Container(margin: EdgeInsets.only(bottom: 10),child: Text('Ваш список', style: TextStyle(color: AppColors.grey, fontSize: 20))),
                        searchController.text.length > 0 || mineAuthorsList.length == 0? Container() : this.authorsList(true),
                        searchController.text.length > 0? Container() : Container(margin: EdgeInsets.only(bottom: 10),child: Text('Предложение', style: TextStyle(color: AppColors.grey, fontSize: 20))),
                        this.authorsList(false),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ]
          ),
        )
      ],
    );
  }

  Widget genresList()
  {

    return ListView.separated(
      separatorBuilder: (BuildContext ctx, int index) {
        return Container(padding: EdgeInsets.symmetric(horizontal: 16), child: Divider(height: 1, color: AppColors.secondary));
      },
      itemBuilder: (BuildContext ctx, int index) {
        Genre currentGenre = searchController.text.length > 0? filteredGenreList[index]: genreList[index];
        return new Container(
          padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    height: 64,
                    width: 64,
                    margin: EdgeInsets.only(right: 24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      image: DecorationImage(image: CachedNetworkImageProvider(currentGenre.picture), fit: BoxFit.cover),
                      color: Colors.grey,
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width - 250,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        new Container(
                            constraints: BoxConstraints(maxWidth: 250),
                            margin: EdgeInsets.only(bottom: 4),
                            child: Text(currentGenre.name, textAlign: TextAlign.left, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.grey))
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              GestureDetector(
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        color: selectedGenres.contains(currentGenre.id)? AppColors.secondary :Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: AppColors.grey,
                            offset: Offset(0.0, 2.0),
                            blurRadius: 5.0,
                          ),
                        ]
                    ),
                    child: Icon(selectedGenres.contains(currentGenre.id)? Icons.check : Icons.add, color: selectedGenres.contains(currentGenre.id)? AppColors.grey : Colors.black),

                  ),
                  onTap: () async {
                    print('Tapped!');

                    if (!selectedGenres.contains(currentGenre.id)) {
                      print('Added ' + currentGenre.id.toString());
                      selectedGenres.add(currentGenre.id);
                      UserGenre item = new UserGenre();
                      item.genreId = currentGenre.id;
                      await item.store();
                    } else {
                      print('Removed ' + currentGenre.id.toString());
                      selectedGenres.remove(currentGenre.id);
                      await UserGenre().where('genreId = ? ', [currentGenre.id]).delete();
                    }
                    setState(() {});
                    await serverApi.setUserGenres();
                  }
              )

            ],
          ),
        );
      },
      itemCount: searchController.text.length > 0? filteredGenreList.length : genreList.length,
    );
  }

  void getGenres() async {
    setState(() {
      isLoading = true;
    });
    genreList = await new Genre().all();

    List<UserGenre> userGenres = List<UserGenre>.from(await UserGenre().all());
    for (UserGenre userGenre in userGenres) {
      selectedGenres.add(userGenre.genreId);
    }

    serverApi.getGenres().then((data) async {
      genreList = await new Genre().all();
      setState((){ isLoading = false; });
    });
    setState((){});
  }

  Widget authorsList(bool onlyMine)
  {

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext ctx, int index) {
        Author currentAuthor = onlyMine? mineAuthorsList[index] : (searchController.text.length > 0? filteredAuthorList[index]: authorList[index]);
        return new Container(
          padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              Row(
                children: [
                  Container(
                    margin: EdgeInsets.only(right: 24),
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      image: DecorationImage(image: CachedNetworkImageProvider(currentAuthor.picture), fit: BoxFit.cover),
                      color: Colors.grey,
                    ),

                  ),
                  Container(

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        new Container(
                            constraints: BoxConstraints(maxWidth: 250),
                            margin: EdgeInsets.only(bottom: 4),
                            child: Text(currentAuthor.name + ' ' + currentAuthor.surname, textAlign: TextAlign.left, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold))
                        ),
                        new Container(
                            margin: EdgeInsets.only(bottom: 4),
                            child: Text(currentAuthor.count.toString() + ' книги', textAlign: TextAlign.left, style: TextStyle(fontSize: 14, color: Colors.grey))
                        ),
                      ],
                    ),
                  ),

                ],
              ),

              GestureDetector(
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        color: selectedAuthors.contains(currentAuthor.id)? AppColors.secondary :Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: AppColors.grey,
                            offset: Offset(0.0, 2.0),
                            blurRadius: 5.0,
                          ),
                        ]
                    ),
                    child: Icon(selectedAuthors.contains(currentAuthor.id)? Icons.check : Icons.add, color: selectedAuthors.contains(currentAuthor.id)? AppColors.grey : Colors.black),

                  ),
                  onTap: () async {
                    print('Tapped!');

                    if (!selectedAuthors.contains(currentAuthor.id)) {
                      print('Added ' + currentAuthor.id.toString());
                      selectedAuthors.add(currentAuthor.id);
                      UserAuthor item = new UserAuthor();
                      item.authorId = currentAuthor.id;
                      setState(() {});
                      await item.store();
                    } else {
                      print('Removed ' + currentAuthor.id.toString());
                      selectedAuthors.remove(currentAuthor.id);
                      setState(() {});
                      await UserAuthor().where('authorId = ? ', [currentAuthor.id]).delete();
                    }

                    await serverApi.setUserAuthors();
                    getUserAuthors();
                  }
              )

            ],
          ),
        );
      },
      itemCount: onlyMine? mineAuthorsList.length : (searchController.text.length > 0? filteredAuthorList.length : authorList.length),
    );
  }

  Widget authorsSearch()
  {
    return new Container(
        margin: EdgeInsets.only(bottom: 20),
        child: new TextFormField(
            controller: searchController,
            onChanged: (text) {
              filteredAuthorList = [];
              for (Author author in authorList) {
                if (author.name.toLowerCase().indexOf(text.toLowerCase()) != -1 || author.surname.toLowerCase().indexOf(text.toLowerCase()) != -1) {
                  filteredAuthorList.add(author);
                }
              }

              serverApi.getAuthors(query: searchController.text).then((data) async {
                authorList = await new Author().where('name like ? or surname like ?', ['%' + text +'%', '%' + text +'%']).limit(20).find();
                setState((){
                  isLoading = false;
                });
              });

              setState(() {
                isLoading = true;
              });
            },
            decoration: new InputDecoration(
              hintText: 'Поиск по авторам',
              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
            )
        )
    );
  }

  void getAuthors() async {

    await getUserAuthors();

    authorList = await Author().limit(20).all();
    isLoading = true;
    serverApi.getAuthors().then((data) async {
      authorList = await Author().limit(20).all();
      setState((){
        isLoading = false;
      });
    });
    setState((){});
  }

  getUserAuthors() async {
    mineAuthorsList = [];
    var userAuthors = await UserAuthor().all();

    for (UserAuthor userAuthor in userAuthors) {
      Author author = await Author().where('id = ?', [userAuthor.authorId]).first();
      if (author != null) {
        mineAuthorsList.add(author);
        selectedAuthors.add(author.id);
      }
    }

    setState(() {});
  }

}