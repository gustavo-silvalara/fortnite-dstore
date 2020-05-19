class ItemLoja {
  final String id;
  final String name;
  final String description;
  final String fullBackground;

  ItemLoja({this.id, this.name, this.description, this.fullBackground});

  ItemLoja.fromJson(Map<String, dynamic> jsonData)
      : id = jsonData['id'],
        name = jsonData['name'],
        description = jsonData['description'],
        fullBackground = jsonData['full_background'];

  @override
  String toString() {
    return this.fullBackground;
  }
}
