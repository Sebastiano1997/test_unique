import 'package:flutter/material.dart';
import 'package:test_unique/Component/ComponentE.dart';
import 'PageOutViewModel.dart';
import 'Models/PageOutDm.dart';

class PageOutV1 extends StatefulWidget {
  const PageOutV1({Key? key}) : super(key: key);

  @override
  State<PageOutV1> createState() => _PageOutV1State();
}

class _PageOutV1State extends State<PageOutV1> {
  late PageOutVM1 vm;

  @override
  void initState() {
    super.initState();
    vm = PageOutVM1();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('PageOut'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Home'),
              Tab(text: 'Setting'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            home(vm),
            setting(vm),
          ],
        ),
      ),
    );
  }

  /// ========== HOME VIEW ==========
  Widget home(IPageOutVM vm) {
    return SingleChildScrollView(
      child: Row(
        children: [
          // Sezioni
          section(vm),
          // Contenuto principale
          Expanded(
            child: ComponentE3(
              title: const Text('Home'),
              children: [
                // Value TextField
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Value',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => vm.selectedOut.value = value,
                  ),
                ),
                // Description TextField
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => vm.selectedOut.description = value,
                  ),
                ),
                // Date Row
                Row(
                  children: [
                    // Date TextField
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'Date',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            try {
                              vm.selectedOut.date = DateTime.parse(value);
                            } catch (e) {
                              // Handle invalid date
                            }
                          },
                        ),
                      ),
                    ),
                    // Date Now Button
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            vm.selectedOut.date = DateTime.now();
                          });
                        },
                        child: const Text('Now'),
                      ),
                    ),
                  ],
                ),
                // Add A Button
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        vm.onClickAddOut('A', vm.selectedOut);
                        vm.selectedOut = Out(
                          section: vm.selectedSectionOut,
                          date: DateTime.now(),
                        );
                      });
                    },
                    child: const Text('Add A'),
                  ),
                ),
                // Add B Button
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        vm.onClickAddOut('B', vm.selectedOut);
                        vm.selectedOut = Out(
                          section: vm.selectedSectionOut,
                          date: DateTime.now(),
                        );
                      });
                    },
                    child: const Text('Add B'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ========== SETTING VIEW ==========
  Widget setting(IPageOutVM vm) {
    final List<Widget> listItems = vm.list
        .map((outItem) => ComponentE3(
              title: Text(outItem.section.name),
              settings: [
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      vm.adu.delete(outItem);
                    });
                  },
                ),
              ],
              children: [
                // Value Field
                ComponentE3(
                  title: TextField(
                    controller:
                        TextEditingController(text: outItem.value),
                    onChanged: (value) => setState(() => outItem.value = value),
                  ),
                  subtitle: const Text('value'),
                ),
                // Description Field
                ComponentE3(
                  title: TextField(
                    controller: TextEditingController(
                        text: outItem.description),
                    onChanged: (value) =>
                        setState(() => outItem.description = value),
                  ),
                  subtitle: const Text('description'),
                ),
                // Whose Dropdown
                ComponentE3(
                  title: DropdownButton<String>(
                    value: outItem.whose,
                    items: vm.listWhose
                        .map((String value) =>
                            DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            ))
                        .toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() => outItem.whose = newValue);
                      }
                    },
                  ),
                  subtitle: const Text('whose'),
                ),
                // Section Dropdown
                ComponentE3(
                  title: DropdownButton<String>(
                    value: outItem.section.name,
                    items: vm.listSection
                        .map((SectionOut section) =>
                            DropdownMenuItem<String>(
                              value: section.name,
                              child: Text(section.name),
                            ))
                        .toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          outItem.section = SectionOut(newValue);
                        });
                      }
                    },
                  ),
                  subtitle: const Text('section'),
                ),
                // Date Field
                ComponentE3(
                  title: TextField(
                    controller:
                        TextEditingController(text: outItem.date.toString()),
                    onChanged: (value) {
                      try {
                        setState(
                            () => outItem.date = DateTime.parse(value));
                      } catch (e) {
                        // Handle invalid date
                      }
                    },
                  ),
                  subtitle: const Text('date'),
                  settings: [
                    IconButton(
                      icon: const Icon(Icons.today),
                      onPressed: () {
                        setState(() {
                          outItem.date = DateTime.now();
                        });
                      },
                    ),
                  ],
                ),
              ],
            ))
        .toList();

    // Aggiungi il pulsante copy all'inizio
    listItems.insert(
      0,
      ComponentE3(
        title: const Text('Copy'),
        settings: [
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () {
              final String syntaxString = vm.model.getSyntaxString();
              // Copia negli appunti
              Clipboard.setData(ClipboardData(text: syntaxString));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Copied to clipboard')),
              );
            },
          ),
        ],
      ),
    );

    return SingleChildScrollView(
      child: Row(
        children: [
          // Sezioni
          section(vm),
          // Lista items
          Expanded(
            child: ComponentE3(
              title: const Text('Setting'),
              children: listItems,
            ),
          ),
        ],
      ),
    );
  }

  /// ========== SECTION VIEW ==========
  Widget section(IPageOutVM vm) {
    return ComponentE3(
      title: const Text('Section'),
      children: vm.listSection
          .map((SectionOut section) => ElevatedButton(
                onPressed: () {
                  setState(() {
                    vm.onSelectedSectionOut(section);
                  });
                },
                child: Text(section.name),
              ))
          .toList(),
    );
  }
}
