class Restaurant{
  String? name;
  String? place;
  String? type;
  String? phone;
  String? content;
  int? id;

  Restaurant({this.name, this.place, this.type, this.content, this.phone, this.id});

  Map<String, dynamic> toMap() {
    return {
      'id':id,
      'name': name,
      'place': place,
      'type': type,
      'number': phone,
      'content': content,
    };
  }
  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
        id: json['id'],
        name: json['name'],
        place: json['place'],
        type: json['type'],
        phone: json['phone'],
        content: json['content']
    );
  }

}