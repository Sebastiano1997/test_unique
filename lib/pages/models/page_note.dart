import 'package:flutter/material.dart';
import 'section_note.dart';

class PageNote with ChangeNotifier {
  late SectionNote selectedSectionNote;
  
  final List<SectionNote> sections = [
    SectionNote("Home"),
    SectionNote("Note"),
  ];

  PageNote() {
    selectedSectionNote = sections.first;
  }

  /// Aggiungi una nuova sezione
  bool addSection(String sectionName) {
    // Verifica se la sezione esiste già
    if (sections.any((section) => section.name == sectionName)) {
      return false;
    }
    
    sections.add(SectionNote(sectionName));
    notifyListeners();
    return true;
  }

  /// Seleziona una sezione
  void onSelectedSection(SectionNote item) {
    selectedSectionNote = item;
    notifyListeners();
  }
}
