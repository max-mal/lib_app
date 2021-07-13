import 'package:faker/faker.dart';
import 'package:flutter_app/database/core/models/base.dart';
import 'package:flutter_app/database/core/models/preferences.dart';
import 'package:flutter_app/models/book.dart';
import 'package:flutter_app/models/bookChapter.dart';
import 'package:flutter_app/models/collection.dart';
import 'package:flutter_app/models/subscription.dart';
import 'package:flutter_app/models/userAuthor.dart';
import 'package:flutter_app/models/userGenre.dart';
import 'package:flutter_app/screens/home.dart';

import 'collectionBooks.dart';
import 'promocode.dart';
import '../globals.dart';

class User extends DatabaseModel {

  String table = 'user';
  String pk = 'id';

  int id;
  String name = '';
  String lastName = '';
  String email;
  String picture;
  int subscriptionId;
  int subscriptionExpiresAt;
  Subscription subscription;

  constructModel() {
    return new User();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'name': this.name,
      'lastName': this.lastName,
      'email': this.email,
      'picture': this.picture,
      'subscriptionId': this.subscriptionId,
      'subscriptionExpiresAt': this.subscriptionExpiresAt,
    };
  }

  loadFromMap(Map<String, dynamic> map){

    this.id = map['id'];
    this.name = map['name'];
    this.lastName = map['lastName'];
    this.email = map['email'];
    this.picture = map['picture'];
    this.subscriptionId = map['subscriptionId'];
    this.subscriptionExpiresAt = map['subscriptionExpiresAt'];

    return this;
  }

  store() async {
    await super.store();
    await serverApi.updateProfile();
  }


  List<PromoCode> promoCodes;
  User({
    this.id,
    this.name,
    this.lastName,
    this.email,
    this.picture,
  });

  static Future<User> getUser() async  {
    List<dynamic> users = await (new User()).all();
    if (users.length == 0) {
      return null;
    }
    return users[0];
  }


  String getExpiration()
  {
    DateTime expires = DateTime.fromMicrosecondsSinceEpoch(this.subscriptionExpiresAt);
    DateTime now = DateTime.now();
    Duration difference = now.difference(expires);


    if (difference.inDays > 0) {
      return  'через ' + difference.inDays.toString() + ' дней';
    }

    if (difference.inMinutes > 0) {
      return  'через ' + difference.inMinutes.toString() + ' минут';
    }


    return  'через ' + difference.inSeconds.toString() + ' секунд';

  }

  static List<User> generate(int count) {
    var faker = new Faker();
    List<User> list = [];

    for (int i=0; i< count; i++) {
      User user = new User(id: i, name: faker.person.firstName(), lastName: faker.person.lastName(), email: faker.lorem.word() + '@' + faker.lorem.word() + '.com', picture: 'https://source.unsplash.com/featured/?person,' +  faker.person.firstName(),);
      user.subscription = Subscription.generate()[0];
      user.subscriptionExpiresAt = new DateTime.now().millisecondsSinceEpoch + 100000;
      list.add(user);
    }

    return list;
  }

  List<PromoCode> getPromoCodes() {
    if (promoCodes == null) {
      promoCodes = PromoCode.generate(4);
    }

    return promoCodes;
  }

  void logout() async {
    await Preferences.unset('token');
    await user.remove();

    await UserGenre().delete();
    await UserAuthor().delete();
    await Book().rawStatement("UPDATE books SET progress = 0;");
    await Collection().delete();
    await CollectionBook().delete();

    moreBooks = [];
    readingBooks = [];
    loadingReadingBooks = true;
    moreBooksPage = 0;

    user = null;
  }

  getName() {
    String userName = this.name ?? '';
    if (userName.isEmpty) {
      userName = '🐈';
    }
    
    return userName;
  }

  getLastName() {
    String userSurname = user.lastName ?? '';
    if ((this.name ?? '').isEmpty && userSurname.isEmpty) {
      userSurname = 'Муррыч';
    }
    return userSurname;
  }

}
