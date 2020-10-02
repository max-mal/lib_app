import 'base.dart';

class Migration extends DatabaseModel{

  String table = 'migration';


  // Fields
  String name;

  constructModel() {
    return new Migration();
  }

  Map<String, dynamic> toMap() {
    return {
      'name': this.name,
    };
  }

  loadFromMap(Map<String, dynamic> map){

    name = map['name'];

    return this;
  }
}