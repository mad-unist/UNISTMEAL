class Restaurant{
  String? name;
  String? place;
  String? type;
  String? content;
  String? phone;
  int? id;

  Restaurant({this.name, this.place, this.type, this.content, this.phone, this.id});

  Map<String, dynamic> toMap() {
    return {
      'id':id,
      'place': place,
      'type': type,
      'content': content,
    };
  }
  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
        id: json['id'],
        place: json['place'],
        type: json['type'],
    );
  }

}