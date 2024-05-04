class Course{
  final int id;
  final String title;

  Course({
    required this.id,
    required this.title
  });

  factory Course.fromJson(Map<String, dynamic> json) => Course(
    id: json['id'],
    title: json['title'],
  );
}