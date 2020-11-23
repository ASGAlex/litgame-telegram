class CardCollection {
  CardCollection(String name) : this.name = name.isEmpty ?? 'default';
  final String name;
}
