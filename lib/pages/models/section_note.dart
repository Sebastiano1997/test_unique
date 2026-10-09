import 'single_note.dart';
import 'single_note_for_section.dart';

class SectionNote {
  final String name;
  List<SingleNote> notes = [SingleNote()];

  SectionNote(this.name);

  /// Lista di note formattate per la sezione
  List<SingleNoteForSection> get notesForSection {
    return notes.map((note) => SingleNoteForSection(note)).toList();
  }
}
