import 'single_note.dart';

class SingleNoteForSection {
  final SingleNote father;

  SingleNoteForSection(this.father);

  /// Titolo della nota padre
  String get title => father.title;

  /// Testo del primo item, o stringa vuota se non esiste
  String get text => father.items.isNotEmpty ? father.items.first.text : "";
}
