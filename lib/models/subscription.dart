import 'package:faker/faker.dart';

class Subscription {
  int id;
  String name;
  double price;


  Subscription(
      this.id,
      this.name,
      this.price
  );


  static List<Subscription> generate() {
    List<Subscription> list = [];

    Subscription subscription = new Subscription(1, '1 месяц', 300.0);
    list.add(subscription);

    Subscription subscription1 = new Subscription(1, '3 месяца', 300.0);
    list.add(subscription1);

    Subscription subscription2 = new Subscription(1, '6 месяцев', 300.0);
    list.add(subscription2);

    Subscription subscription3 = new Subscription(1, '1 год', 300.0);
    list.add(subscription3);

    return list;
  }

}
