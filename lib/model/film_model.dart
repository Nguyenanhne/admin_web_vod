class FilmModel {
  final String id;
  final String actors;
  final int age;
  final String description;
  final String director;
  final String name;
  final int year;
  final int viewTotal;
  final List<String> type;
  String upperName = '';
  String note = '';
  String url = '';

  FilmModel({
    required this.type,
    required this.id,
    required this.actors,
    required this.age,
    required this.description,
    required this.director,
    required this.name,
    required this.year,
    required this.viewTotal,
    required this.upperName
  });

  // Convert FilmModel to Map
  Map<String, dynamic> toMap() {
    return {
      'actors': actors,
      'age': age,
      'description': description,
      'director': director,
      'name': name,
      'note': note,
      'year': year,
      'viewTotal': viewTotal,
      'type': type,
      'upperName': upperName
    };
  }

  // Create FilmModel from Map
  factory FilmModel.fromMap(Map<String, dynamic> map, String id) {
    return FilmModel(
      id: id,
      actors: map['actors'] ?? "",
      age: map['age'] is String ? int.parse(map['age'] as String) : map['age'] as int,
      description: map['description'] ?? '',
      director: map['director'] ?? '',
      name: map['name'] ?? '',
      upperName: map['upperName'] ?? '',
      viewTotal: map['viewTotal'] ?? 0,
      year: map['year'] ?? 0,
      type: map['type'] != null ? List<String>.from(map['type']) : [],
    );
  }

  // Set URL for the film
  void setUrl(String newUrl) {
    url = newUrl;
  }
}
