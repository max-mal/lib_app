import 'package:flutter/material.dart';
import 'package:flutter_app/models/author.dart';
import 'package:flutter_app/models/book.dart';
import 'package:flutter_app/screens/author.dart';
import 'package:flutter_app/screens/book.dart';
import 'package:flutter_app/ui/loader.dart';
import 'package:uni_links/uni_links.dart';
import 'package:flutter_app/dialogs/navigation.dart';
import 'package:flutter_app/dialogs/search.dart';
import 'package:flutter_app/screens/afterRegister.dart';
import 'package:flutter_app/screens/collection.dart';
import 'package:flutter_app/screens/news.dart';
import 'package:flutter_app/screens/recomendations.dart';
import 'package:flutter_app/screens/startScreen.dart';
import '../colors.dart';
import '../globals.dart';
import '../screens/home.dart';
import '../screens/account.dart';
import '../screens/welcome.dart';
import '../screens/signup.dart';
import '../screens/genres.dart';
import '../screens/authors.dart';
import '../screens/congratulation.dart';

bool gotInitialLink = false;

class AppScreen extends StatefulWidget {
  const AppScreen({Key key, this.page}) : super(key: key);

  final String page;

  ScreenState createState() => ScreenState();
}

class ScreenState extends State<AppScreen> {
  String page = user == null ? 'start' : 'home';
  bool showTabs = true;
  int navBarSelectedIndex = 0;

  @override
  initState(){
    initDeepLinks();
    super.initState();
  }

  initDeepLinks() async {
    getLinksStream().listen((String link) {
      processDeepLink(link);
    }, onError: (err) async {
      UiLoader.showLoader(context);
      await Future.delayed(Duration(seconds: 1));
      await UiLoader.errorLoader(context);
    });
    String initialLink = await getInitialLink();
    if (!gotInitialLink) {
      gotInitialLink = true;
      processDeepLink(initialLink);
    }
  }

  processDeepLink(String link) async {
    if (link == null) {
      return;
    }

    String req = link.replaceAll('meow://books/', '');
    List<String> parts = req.split('/').where((element) => element.isNotEmpty).toList();

    if (parts.isEmpty) {
      return;
    }

    if (int.tryParse(parts.first) != null && parts.length == 1) {      
      try {
        UiLoader.showLoader(context);
        int bookId = int.tryParse(parts.first);
        Book book = await Book().where('id = ?', [parts.first]).first();
        if (book == null) {
          book = await serverApi.getBook(bookId);
        }
        if (book == null) {
          await UiLoader.errorLoader(context);
          return;
        }
        Navigator.pop(context);
        BookScreen.open(context, book, goTo);
      } catch (e) {
        await UiLoader.errorLoader(context);
      }
      
      return;
    }

    if (parts.first == 'author' && int.tryParse(parts.last) != null && parts.length == 2) {      
      try {
        UiLoader.showLoader(context);
        int authorId = int.tryParse(parts.last);
        Author author = await Author().where('id = ?', [parts.last]).first();
        if (author == null) {
          author = await serverApi.getAuthor(authorId);
        }
        if (author == null) {
          await UiLoader.errorLoader(context);
          return;
        }
        Navigator.pop(context);
        AuthorScreen.open(context, author, goTo);
      } catch (e) {
        await UiLoader.errorLoader(context);
      }
      
      return;
    }
  }

  void goTo(String page) {
    setState(() {
      this.page = page;
    });
  }

  void onNavBarTap(int index) {
    setState(() {
      this.navBarSelectedIndex = index;

      switch (this.navBarSelectedIndex) {
        case 0:
          this.page = 'home';
          break;
        // case 1:
        //   this.page = 'recommendations';
        //   break;
        case 1:
          NavigationDialog.open(context);
          break;
        case 2:
          this.page = 'account';
          break;
        case 3:
          this.page = 'collection';
          break;
        case 4:
          showDialog(context: context, builder: (ctx){
            return SearchDialog();
          });
          break;
        // case 5:
        //   this.page = 'news';
        //   break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: null,
      body: this.buildBody(),
      bottomNavigationBar: this.showTabs
          ? (new BottomNavigationBar(
              showSelectedLabels: false,
              showUnselectedLabels: false,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.secondary,
              items: [
                new BottomNavigationBarItem(
                    icon: new Icon(Icons.home), label: 'Home'),
                // new BottomNavigationBarItem(
                //     icon: new Icon(Icons.short_text),
                //     label: 'Recommendations'),
                new BottomNavigationBarItem(
                    icon: new Icon(Icons.category),
                    label: 'Categories'),
                new BottomNavigationBarItem(
                    icon: new Icon(Icons.account_circle),
                    label: 'Account'),
                new BottomNavigationBarItem(
                    icon: new Icon(Icons.list), label: 'Collection'),
                // new BottomNavigationBarItem(
                //     icon: new Icon(Icons.new_releases),
                //     label: 'News'),
                new BottomNavigationBarItem(
                    icon: new Icon(Icons.search), label: 'Search'),
              ],
              currentIndex: this.navBarSelectedIndex,
              onTap: this.onNavBarTap,
            ))
          : null,
    );
  }

  Widget buildBody() {
    switch (this.page) {
      case 'home':
        setState(() {
          this.showTabs = true;
          navBarSelectedIndex = 0;
        });
        return new HomeScreen(goTo: this.goTo);

      case 'account':
        setState(() {
          this.showTabs = true;
          navBarSelectedIndex = 2;
        });
        return new AccountScreen(goTo: this.goTo);
      case 'start':
        setState(() {
          this.showTabs = false;
          navBarSelectedIndex = 0;
        });
        return new StartScreen(goTo: this.goTo);
      case 'welcome':
        setState(() {
          this.showTabs = false;
          navBarSelectedIndex = 0;
        });
        return new WelcomeScreen(goTo: this.goTo);
      case 'signup':
        setState(() {
          this.showTabs = false;
        });
        return new SignUpScreen(goTo: this.goTo);
      case 'genres':
        setState(() {
          this.showTabs = false;
        });
        return new GenresScreen(goTo: this.goTo);
      case 'authors':
        setState(() {
          this.showTabs = false;
        });
        return new AuthorsScreen(goTo: this.goTo);
      case 'congratulation':
        setState(() {
          this.showTabs = false;
        });
        return new CongratulationScreen(goTo: this.goTo);
      case 'recommendations':
        setState(() {
          this.showTabs = true;
          navBarSelectedIndex = 1;
        });
        return new RecommendationsScreen(goTo: this.goTo);
      case 'collection':
        setState(() {
          this.showTabs = true;
          navBarSelectedIndex = 3;
        });
        return new CollectionScreen(goTo: this.goTo);
      case 'news':
        setState(() {
          this.showTabs = true;
          navBarSelectedIndex = 5;
        });
        return new NewsScreen(goTo: this.goTo);
      case 'afterRegister':
        setState((){
          this.showTabs = false;
        });
        return new AfterRegisterScreen(goTo: this.goTo);
    }
    setState(() {
      this.showTabs = true;
    });
    return new Text('Unknown page: ' + this.page);
  }
}
