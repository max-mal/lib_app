import 'package:faker/faker.dart';

class PromoCode {
  int id;
  String name;
  String description;
  int expiresAt;


  PromoCode(
      this.id,
      this.name,
      this.description,
      this.expiresAt
  );

  bool isExpired() {
    return DateTime.now().millisecondsSinceEpoch > this.expiresAt;
  }

  String getDifference()
  {
    DateTime expires = DateTime.fromMicrosecondsSinceEpoch(this.expiresAt);
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

  static List<PromoCode> generate(int count) {
    List<PromoCode> list = [];

    for (int i=0; i< count; i++) {
      PromoCode code = new PromoCode(i, 'Пропокод ' + i.toString(), 'Действет на ...', new DateTime.now().millisecondsSinceEpoch + i * 10 * 3600000);
      list.add(code);
    }

    return list;
  }

}
