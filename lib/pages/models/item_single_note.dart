class ItemSingleNote {
  final String text;
  double? value;
  bool? isTrue;
  late DateTime date;
  String? key;

  ItemSingleNote(this.text) {
    date = DateTime.now();
  }
}
