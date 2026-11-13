import 'package:flutter/material.dart';

import '../../../Component/ComponentE.dart';
import '../model/item_single_note.dart';
import '../model/page_note.dart';
import '../model/section_note.dart';
import '../model/single_note.dart';

/// Pagina per navigare tra le sezioni, le note e i relativi elementi.
class PageNotePage extends StatefulWidget {
  const PageNotePage({super.key});

  @override
  State<PageNotePage> createState() => _PageNotePageState();
}

class _PageNotePageState extends State<PageNotePage> {
  final PageNote _vm = PageNote();
  SingleNote? _selectedNote;
  final TextEditingController _newItemController = TextEditingController();

  @override
  void dispose() {
    _newItemController.dispose();
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _sectionTabs(),
        Expanded(
          child: _selectedNote == null
              ? _sectionNotes()
              : _singleNoteView(_selectedNote!),
        ),
      ],
    );
  }

  Widget _sectionTabs() {
    return SizedBox(
      height: 56,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        children: [
          for (final section in _vm.sections)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: ChoiceChip(
                label: Text(section.name),
                selected: section == _vm.selectedSectionNote,
                onSelected: (_) {
                  setState(() {
                    _vm.onSelectedSection(section);
                    _selectedNote = null;
                  });
                },
              ),
            ),
          IconButton(
            tooltip: 'Aggiungi sezione',
            icon: const Icon(Icons.add),
            onPressed: _addSection,
          ),
        ],
      ),
    );
  }

  Widget _sectionNotes() {
    final notes = _vm.selectedSectionNote.notesForSection;
    if (notes.isEmpty) {
      return const Center(child: Text('Nessuna nota in questa sezione.'));
    }

    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        for (final note in notes)
          ComponentE3(
            isBorder: true,
            title: Text(note.title.isEmpty ? 'Nota senza titolo' : note.title),
            subtitle: Text(note.text.isEmpty ? 'Nessun elemento' : note.text),
            leading: IconButton(
              tooltip: 'Apri nota',
              icon: const Icon(Icons.arrow_forward),
              onPressed: () => setState(() => _selectedNote = note.father),
            ),
            onTap: () => setState(() => _selectedNote = note.father),
          ),
      ],
    );
  }

  Widget _singleNoteView(SingleNote note) {
    return Column(
      children: [
        ComponentE3(
          title: Row(
            children: [
              IconButton(
                tooltip: 'Torna alle note',
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _selectedNote = null),
              ),
              Expanded(
                child: TextFormField(
                  key: ObjectKey(note),
                  initialValue: note.title,
                  decoration: const InputDecoration(labelText: 'Titolo nota'),
                  onChanged: (value) => note.title = value,
                ),
              ),
            ],
          ),
          children: [
            if (note.items.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Questa nota non contiene ancora elementi.'),
              ),
            for (final item in note.items) _noteItem(item),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _newItemController,
                  decoration: const InputDecoration(
                    labelText: 'Nuovo elemento',
                    border: OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendItem(note),
                ),
              ),
              IconButton(
                tooltip: 'Aggiungi elemento',
                icon: const Icon(Icons.send),
                onPressed: () => _sendItem(note),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _noteItem(ItemSingleNote item) {
    return ComponentE3(
      isBorder: true,
      title: Text(item.text),
      subtitle: Text(item.date.toLocal().toString()),
      children: [
        TextFormField(
          key: ValueKey('${identityHashCode(item)}-value'),
          initialValue: item.value?.toString() ?? '',
          decoration: const InputDecoration(labelText: 'Valore'),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (value) => item.value = double.tryParse(value),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Vero / falso'),
          value: item.isTrue ?? false,
          onChanged: (value) => setState(() => item.isTrue = value),
        ),
        TextFormField(
          key: ValueKey('${identityHashCode(item)}-key'),
          initialValue: item.key ?? '',
          decoration: const InputDecoration(labelText: 'Chiave'),
          onChanged: (value) => item.key = value.isEmpty ? null : value,
        ),
      ],
    );
  }

  void _sendItem(SingleNote note) {
    final text = _newItemController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      note.items.insert(0, ItemSingleNote(text));
      _newItemController.clear();
    });
  }

  Future<void> _addSection() async {
    final controller = TextEditingController();
    final sectionName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nuova sezione'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Nome sezione'),
          onSubmitted: (value) => Navigator.of(context).pop(value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Aggiungi'),
          ),
        ],
      ),
    );
    controller.dispose();

    final name = sectionName?.trim() ?? '';
    if (!mounted || name.isEmpty) return;

    setState(() {
      final added = _vm.addSection(name);
      if (added) {
        final section = _vm.sections.firstWhere((item) => item.name == name);
        _vm.onSelectedSection(section);
        _selectedNote = null;
      }
    });

    if (!_vm.sections.any((section) => section.name == name)) return;
    final duplicate = _vm.sections.where((section) => section.name == name).length > 1;
    if (duplicate && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Esiste già una sezione con questo nome.')),
      );
    }
  }
}
