import 'package:flutter/material.dart';
import 'package:flutter_app/dialogs/navigation.dart';
import 'package:flutter_app/screens/collection.dart';
import 'package:flutter_app/screens/news.dart';
import 'package:flutter_app/screens/recomendations.dart';
import '../colors.dart';
import '../globals.dart';
import '../screens/home.dart';
import '../screens/account.dart';
import '../screens/welcome.dart';
import '../screens/signup.dart';
import '../screens/genres.dart';
import '../screens/authors.dart';
import '../screens/congratulation.dart';

class AppScreen extends StatefulWidget {
  const AppScreen({
    Key key,
    this.page
  }) : super(key: key);

  final String page;

  ScreenState createState() => ScreenState();
}

class ScreenState extends State<AppScreen> {
  String page = user == null ? 'welcome' : 'home';
  bool showTabs = true;
  int navBarSelectedIndex = 0;

  void goTo(String page) {
    setState(() { this.page  = page; });
  }

  void onNavBarTap(int index) {
    setState(() {
      this.navBarSelectedIndex = index;

      switch (this.navBarSelectedIndex) {
        case 0:
          this.page = 'home';
          break;
        case 1:
          this.page = 'recommendations';
          break;
        case 2:
          NavigationDialog.open(context);
          break;
        case 3:
          this.page = 'account';
          break;
        case 4:
          this.page = 'collection';
          break;
        case 5:
          this.page = 'news';
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: null,
      body: this.buildBody(),
      bottomNavigationBar: this.showTabs? (new BottomNavigationBar(
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.secondary,
        items: [
          new BottomNavigationBarItem(icon: new Icon(Icons.home), title: new Text('Home')),
          new BottomNavigationBarItem(icon: new Icon(Icons.short_text), title: new Text('Recommendations')),
          new BottomNavigationBarItem(icon: new Icon(Icons.category), title: new Text('Categories')),
          new BottomNavigationBarItem(icon: new Icon(Icons.account_circle), title: new Text('Account')),
          new BottomNavigationBarItem(icon: new Icon(Icons.list), title: new Text('Collection')),
          new BottomNavigationBarItem(icon: new Icon(Icons.new_releases), title: new Text('News')),
        ],
        currentIndex: this.navBarSelectedIndex,
        onTap: this.onNavBarTap,
      )): null,
    );
  }

  Widget buildBody()
  {
    switch (this.page) {
      case 'home':
        setState(() { this.showTabs = true; navBarSelectedIndex = 0; });
        return new HomeScreen(goTo: this.goTo);

      case 'account':
        setState(() { this.showTabs = true; navBarSelectedIndex = 3;});
        return new AccountScreen(goTo: this.goTo);
      case 'welcome':
        setState(() { this.showTabs = false; navBarSelectedIndex = 0;});
        return new WelcomeScreen(goTo: this.goTo);
      case 'signup':
        setState(() { this.showTabs = false;});
        return new SignUpScreen(goTo: this.goTo);
      case 'genres':
        setState(() { this.showTabs = false;});
        return new GenresScreen(goTo: this.goTo);
      case 'authors':
        setState(() { this.showTabs = false;});
        return new AuthorsScreen(goTo: this.goTo);
      case 'congratulation':
        setState(() { this.showTabs = false;});
        return new CongratulationScreen(goTo: this.goTo);
      case 'recommendations':
        setState(() { this.showTabs = true; navBarSelectedIndex = 1;});
        return new RecommendationsScreen(goTo: this.goTo);
      case 'collection':
        setState(() { this.showTabs = true; navBarSelectedIndex = 4;});
        return new CollectionScreen(goTo: this.goTo);
      case 'news':
        setState(() { this.showTabs = true; navBarSelectedIndex = 5;});
        return new NewsScreen(goTo: this.goTo);
    }
    setState(() { this.showTabs = true;});
    return new Text('Unknown page: ' + this.page);
  }
}