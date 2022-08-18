class Meal{
  String? place;
  String? type;
  String? time;
  String? content;
  int? calorie;
  int? month;
  int? day;
  int? id;
  double? rating;
  int? rating_count;

  Meal({this.place, this.type, this.time, this.content, this.calorie, this.month, this.day, this.id, this.rating, this.rating_count});

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
      'rating': rating,
      'rating_count': rating_count,
    };
  }
  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id'],
      place: json['place'],
      type: json['type'],
      time: json['time'],
      content: json['content'],
      calorie: json['calorie'],
      month: int.parse(json['date'].split('-')[1]),
      day: int.parse(json['date'].split('-')[2].split('T')[0]),
      rating: json['rating'],
      rating_count: json['rating_count'],
    );
  }

}