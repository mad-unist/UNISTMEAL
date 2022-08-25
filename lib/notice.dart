class Notice{
  String? content;
  String? title;
  int? id;

  Notice({this.id, this.title, this.content});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
    };
  }
  factory Notice.fromJson(Map<String, dynamic> json) {
    return Notice(
      id : json['id'],
      title : json['title'],
      content : json['content'],
    );
  }

}