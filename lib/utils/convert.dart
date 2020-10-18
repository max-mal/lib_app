int toInt(dynamic data) {
  return data == null? null: int.parse(data.toString());
}

double toDouble(dynamic data) {
  return data == null? null: double.parse(data.toString());
}