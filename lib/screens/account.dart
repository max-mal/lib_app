import 'package:flutter/material.dart';
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
            this.menuItem('Мой профиль', (){
              ProfileScreen.open(context);
            }),
            this.divider(),
            this.menuItem('Настройка интересов', (){
              UserPreferencesScreen.open(context);
            }),
            this.divider(),
            this.menuItem('Посещенные книги', (){}),
            this.divider(),
            this.menuItem('История покупок', (){}),
            this.divider(),
            this.menuItem('Помощь', (){}),
            this.divider(),
            this.menuItem('Пригласить друга', (){}),
            this.divider(),
            this.menuItem('Выйти', (){ user.logout(); this.widget.goTo('welcome'); }),
          ],
        ),
      ),
    );
  }

  Widget header() {
    return Container(
      margin: EdgeInsets.only(top: 40 ,bottom: 40),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            margin: EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: AppColors.grey,
              image: user.picture != null? DecorationImage(image: NetworkImage(user.picture)) : null,
              borderRadius: BorderRadius.circular(24)
            ),
          ),
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(margin: EdgeInsets.only(bottom: 4),child: Text((user.name ?? '') + ' ' + (user.lastName ?? ''), style: TextStyle(color: AppColors.getColor('black'), fontSize: 16)),),
                Container(child: Text('Настройка учетной записи', style: TextStyle(color: AppColors.secondary, fontSize: 16)),),
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