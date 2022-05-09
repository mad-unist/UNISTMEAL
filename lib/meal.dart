class Meal{
  String? place;
  String? type;
  String? time;
  String? content;
  int? calorie;
  int? month;
  int? day;
  int? id;

  Meal({this.place, this.type, this.time, this.content, this.calorie, this.month, this.day, this.id});

  Map<String, dynamic> toMap() {
    return {
      'id':id,
      'place': place,
      'type': type,
      'time': time,
      'content': content,
      'month': month,
      'day': day,
      'calorie': calorie,
    };
  }
}