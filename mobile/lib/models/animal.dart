class Animal {
  final String name;
  final String sex;
  final String imageUrl;

  Animal({required this.name, required this.sex, required this.imageUrl});

  factory Animal.fromJson(Map<String, dynamic> json) {
    // A API retorna uma lista de fotos, vamos pegar a primeira
    final List<dynamic> images = json['urlImage'] ?? [];
    final String imageUrl = images.isNotEmpty ? images.first['url'] : 'https://i.imgur.com/sopaE59.png'; 

    return Animal(
      name: json['name'] ?? 'Pet',
      sex: json['sex'] ?? 'NA',
      imageUrl: imageUrl,
    );
  }
}