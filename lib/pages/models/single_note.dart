import 'item_single_note.dart';

class SingleNote {
  String title = "";
  List<ItemSingleNote> items = [];

  /// Aggiungi un item alla nota
  void addItemSingle(
    String text, {
    double? value,
    bool? isTrue,
    String? key,
  }) {
    items.add(
      ItemSingleNote(text)
        ..value = value
        ..isTrue = isTrue
        ..key = key,
    );
  }

  /// Torna alla sezione
  void backToSection() {
    // TODO: Implement navigation back to section
  }

  /// Modifica un item (mostra popup)
  void editItemSingle() {
    // TODO: Implement edit popup
  }
}
