import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Converted from C# PageOut -> Dart implementation

enum ItemFormOut { value, description, whose, section, date }

class SyntaxBlockOut {
  String? value;
  ItemFormOut? itemForm;
  String? whose;

  SyntaxBlockOut.value(this.value);
  SyntaxBlockOut.form(this.itemForm, {this.whose});
}

class SectionOut {
  SectionOut(this.name) {
    syntax = [SyntaxBlockOut.form(ItemFormOut.value)];
  }

  final String name;
  late List<SyntaxBlockOut> syntax;
}

class OutItem {
  OutItem({this.value = '', this.description = '', this.whose = '', DateTime? date}) : date = date ?? DateTime.now();

  String value;
  String description;
  String whose;
  SectionOut? section;
  DateTime date;

  OutItem clone() => OutItem(value: value, description: description, whose: whose, date: date);
}

class ADU<T> {
  ADU(this.listRef);
  final List<T> listRef;

  void add(T item) => listRef.add(item);
  void delete(T item) => listRef.remove(item);
}

class PageOutModel {
  PageOutModel() {
    adu = ADU<OutItem>(list);
    selectedSectionOut = listSection.first;
  }

  final List<String> listWhose = ['A', 'B'];

  final List<SectionOut> listSection = [
    SectionOut('Life')
      ..syntax = [
        SyntaxBlockOut.form(ItemFormOut.value, whose: 'A'),
        SyntaxBlockOut.value('\t'),
        SyntaxBlockOut.form(ItemFormOut.value, whose: 'B'),
        SyntaxBlockOut.value('\t'),
        SyntaxBlockOut.form(ItemFormOut.description),
        SyntaxBlockOut.value('\t'),
        SyntaxBlockOut.form(ItemFormOut.date),
      ],
    SectionOut('Tax'),
    SectionOut('A Personal'),
  ];

  final List<OutItem> list = [];
  late final ADU<OutItem> adu;
  late SectionOut selectedSectionOut;

  void onClickAddOut(String valueWhose, OutItem outItem) {
    final item = outItem.clone();
    item.whose = valueWhose;
    item.section = selectedSectionOut;
    adu.add(item);
  }

  void onSelectedSectionOut(SectionOut sectionOut) {
    selectedSectionOut = sectionOut;
  }

  String getSyntaxString() {
    final buffer = StringBuffer();
    for (final item in list) {
      buffer.writeln(_getSyntaxStringItem(item));
    }
    return buffer.toString();
  }

  String _getSyntaxStringItem(OutItem outItem) {
    final sb = StringBuffer();
    for (final block in selectedSectionOut.syntax) {
      if (block.value != null) {
        sb.write(block.value);
      } else if (block.itemForm != null) {
        switch (block.itemForm!) {
          case ItemFormOut.value:
            if (block.whose == null || block.whose == outItem.whose) sb.write(outItem.value);
            break;
          case ItemFormOut.description:
            if (block.whose == null || block.whose == outItem.whose) sb.write(outItem.description);
            break;
          case ItemFormOut.whose:
            if (block.whose == null || block.whose == outItem.whose) sb.write(outItem.whose);
            break;
          case ItemFormOut.section:
            if (block.whose == null || block.whose == outItem.whose) sb.write(selectedSectionOut.name);
            break;
          case ItemFormOut.date:
            if (block.whose == null || block.whose == outItem.whose) sb.write(outItem.date.toString());
            break;
        }
      }
    }
    return sb.toString();
  }
}

class PageOutVM {
  PageOutVM() {
    model = PageOutModel();
    selectedOut = OutItem();
  }

  late final PageOutModel model;
  OutItem? selectedOut;

  List<String> get listWhose => model.listWhose;
  List<SectionOut> get listSection => model.listSection;
  List<OutItem> get listItems => model.list;
  ADU<OutItem> get adu => model.adu;
  SectionOut get selectedSectionOut => model.selectedSectionOut;

  void onClickAddOut(String valueWhose, OutItem outItem) => model.onClickAddOut(valueWhose, outItem);
  void onSelectedSectionOut(SectionOut sectionOut) => model.onSelectedSectionOut(sectionOut);
  String onClickCopyOut() => model.getSyntaxString();
}

// UI
class PageOutPage extends StatefulWidget {
  const PageOutPage({Key? key}) : super(key: key);

  @override
  State<PageOutPage> createState() => _PageOutPageState();
}

class _PageOutPageState extends State<PageOutPage> {
  final PageOutVM vm = PageOutVM();
  final TextEditingController _valueCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();
  final TextEditingController _dateCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _dateCtrl.text = DateTime.now().toIso8601String();
  }

  @override
  void dispose() {
    _valueCtrl.dispose();
    _descCtrl.dispose();
    _dateCtrl.dispose();
    super.dispose();
  }

  void _add(String whose) {
    final out = OutItem(
      value: _valueCtrl.text,
      description: _descCtrl.text,
      whose: whose,
      date: DateTime.tryParse(_dateCtrl.text) ?? DateTime.now(),
    );
    setState(() {
      vm.onClickAddOut(whose, out);
      _valueCtrl.clear();
      _descCtrl.clear();
      _dateCtrl.text = DateTime.now().toIso8601String();
    });
  }

  Future<void> _copyAll() async {
    final result = vm.onClickCopyOut();
    await Clipboard.setData(ClipboardData(text: result));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Testo copiato negli appunti')));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('PageOut'),
          bottom: const TabBar(tabs: [Tab(text: 'Home'), Tab(text: 'Setting')]),
          actions: [
            IconButton(onPressed: _copyAll, icon: const Icon(Icons.copy)),
          ],
        ),
        body: TabBarView(children: [
          _homeView(),
          _settingsView(),
        ]),
      ),
    );
  }

  Widget _homeView() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sections
          Expanded(
            flex: 1,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  const Text('Sections', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...vm.listSection.map((s) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: ElevatedButton(
                          onPressed: () => setState(() => vm.onSelectedSectionOut(s)),
                          child: Text(s.name),
                        ),
                      )),
                ]),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Home inputs
          Expanded(
            flex: 2,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Home', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(controller: _valueCtrl, decoration: const InputDecoration(labelText: 'Value')),
                    const SizedBox(height: 8),
                    TextField(controller: _descCtrl, decoration: const InputDecoration(labelText: 'Description')),
                    const SizedBox(height: 8),
                    Row(children: [
                      Expanded(child: TextField(controller: _dateCtrl, decoration: const InputDecoration(labelText: 'Date (ISO)'))),
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () async {
                          final now = DateTime.now();
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: now,
                            firstDate: DateTime(1900),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() {
                              _dateCtrl.text = picked.toIso8601String();
                            });
                          }
                        },
                      )
                    ]),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(child: ElevatedButton(onPressed: () => _add('A'), child: const Text('Add A'))),
                      const SizedBox(width: 8),
                      Expanded(child: ElevatedButton(onPressed: () => _add('B'), child: const Text('Add B'))),
                    ])
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingsView() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: vm.listItems.length,
              itemBuilder: (context, index) {
                final item = vm.listItems[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(item.section?.name ?? 'No Section', style: const TextStyle(fontWeight: FontWeight.bold)),
                          Row(children: [
                            IconButton(
                                onPressed: () => setState(() => vm.adu.delete(item)),
                                icon: const Icon(Icons.delete)),
                          ])
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: TextEditingController(text: item.value),
                        decoration: const InputDecoration(labelText: 'value'),
                        onChanged: (v) => item.value = v,
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: TextEditingController(text: item.description),
                        decoration: const InputDecoration(labelText: 'description'),
                        onChanged: (v) => item.description = v,
                      ),
                      const SizedBox(height: 6),
                      Row(children: [
                        const Text('whose: '),
                        const SizedBox(width: 8),
                        DropdownButton<String>(
                          value: item.whose.isEmpty ? null : item.whose,
                          hint: const Text('Select'),
                          items: vm.listWhose.map((w) => DropdownMenuItem(value: w, child: Text(w))).toList(),
                          onChanged: (v) => setState(() => item.whose = v ?? ''),
                        ),
                        const Spacer(),
                        SizedBox(
                          width: 140,
                          child: TextField(
                            controller: TextEditingController(text: item.date.toIso8601String()),
                            decoration: const InputDecoration(labelText: 'date'),
                            onChanged: (v) {
                              final dt = DateTime.tryParse(v);
                              if (dt != null) setState(() => item.date = dt);
                            },
                          ),
                        )
                      ])
                    ]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
