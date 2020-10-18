import 'package:faker/faker.dart';

class Event {
  int id;
  String picture;
  String title;
  String description;
  bool isRead = false;

  Event(
      this.id,
      this.picture,
      this.title,
      this.description
  );

  static List<Event> generate(int count) {
    var faker = new Faker();
    List<Event> list = [];

    for (int i=0; i< count; i++) {
      Event event = new Event(i, 'https://source.unsplash.com/featured/?event,' + i.toString(), faker.lorem.sentence(), faker.lorem.sentence());
      list.add(event);
    }

    return list;
  }

}
