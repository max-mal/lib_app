import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/screens/booksList.dart';
import 'package:flutter_app/screens/profile.dart';
import 'package:flutter_app/screens/userPreferences.dart';

import '../colors.dart';
import '../globals.dart';

class AccountScreen extends StatefulWidget {
  final Function goTo;
  const AccountScreen({
    Key key,
    this.goTo
  }) : super(key: key);

  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(top: 50),
              child: Text('Аккаунт', style: TextStyle(color: AppColors.getColor('black'), fontSize: 32)),
            ),
            this.header(),
            this.divider(),
            this.menuItem('Мой профиль', () async {
              await ProfileScreen.open(context);
              setState(() {});
            }),
            this.divider(),
            this.menuItem('Настройка интересов', (){
              UserPreferencesScreen.open(context);
            }),
            this.divider(),
            this.menuItem('Загруженные книги', (){
              showDialog(context: context, builder: (_){
                return BooksListScreen(
                  title: 'Загруженные книги',
                  getBooks: () async {
                    return await serverApi.getDownloadedBooks();
                  },
                );
              });
            }),
            this.divider(),            
            this.menuItem('Выйти', (){ user.logout(); this.widget.goTo('start'); }),
          ],
        ),
      ),
    );
  }

  Widget header() {    
    return Container(
      margin: EdgeInsets.only(top: 40 ,bottom: 20),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            margin: EdgeInsets.only(right: 12),
            decoration: BoxDecoration(              
              image: DecorationImage(image: (user.picture ?? '').isNotEmpty? CachedNetworkImageProvider(user.picture): AssetImage("assets/logo.png")),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.grey)
            ),
          ),
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(margin: EdgeInsets.only(bottom: 4),child: Text('${user.getName()} ${user.getLastName()}', style: TextStyle(color: AppColors.getColor('black'), fontSize: 16)),),                
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget divider() {
    return Divider(
      color: AppColors.secondary,
      height: 1,
    );
  }

  Widget menuItem(String name, Function onPress) {
    return InkWell(
      onTap: onPress,
      child: Container(
        width: MediaQuery.of(context).size.width - 48,
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Text(name, style: TextStyle(fontSize: 16, color: AppColors.grey)),
      ),
    );
  }
}