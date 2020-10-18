import 'base.dart';

class Preferences extends DatabaseModel{

  String table = 'preferences';
  String pk = 'name';


  // Fields
  String name;
  String value;

  constructModel() {
    return new Preferences();
  }

  Map<String, dynamic> toMap() {
    return {
      'name': this.name,
      'value': this.value,
    };
  }

  loadFromMap(Map<String, dynamic> map){

    name = map['name'].toString();
    value = map['value'].toString();

    return this;
  }

  static get(String name, {value}) async {
    var prefs = await Preferences().where("name = ?", [name]).find();

    if (prefs.length > 0) {
      return prefs[0].value;
    }

    return value;
  }

  static unset(String name) async {
    var prefs = await Preferences().where("name = ?", [name]).find();

    if (prefs.length > 0) {
      return await prefs[0].remove();
    }

    return null;
  }

  static set(String name, String value) async {
    var pref = Preferences();
    pref.name = name;
    pref.value = value;

    await pref.store();

    return pref;
  }
}