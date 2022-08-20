class Rating{
  int? id;
  double? rating;
  String? user;
  int? menu;

  Rating({this.id, this.rating, this.user, this.menu});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'rating': rating,
      'user': user,
      'menu': menu
    };
  }
  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      id: json['id'],
      rating: json['rating'],
      user: json['user'],
      menu: json['menu'],
    );
  }
}