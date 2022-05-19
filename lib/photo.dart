class Photo{
  String? name;
  String? url;
  int? id;

  Photo({this.name, this.url, this.id});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'url': url,
    };
  }
  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
        id: json['id'],
        name: json['name'],
        url: json['url'],
    );
  }

}