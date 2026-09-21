import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../Component/ComponentE.dart';
import '../model/PageOutModels.dart';
import '../viewmodel/PageOutViewModel.dart';

class PageOutPage extends StatelessWidget {
  const PageOutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PageOutViewModel>(
      create: (_) => PageOutViewModel(),
      child: const _PageOutView(),
    );
  }
}

class _PageOutView extends StatelessWidget {
  const _PageOutView();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Home'),
              Tab(text: 'Setting'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _home(context),
                _setting(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _home(BuildContext context) {
    final vm = context.watch<PageOutViewModel>();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _section(vm)),
        Expanded(flex: 2, child: _homeForm(context, vm)),
      ],
    );
  }

  Widget _setting(BuildContext context) {
    final vm = context.watch<PageOutViewModel>();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _section(vm)),
        Expanded(flex: 2, child: _settingsList(context, vm)),
      ],
    );
  }

  Widget _section(PageOutViewModel vm) {
    return ComponentE3(
      title: const Text('Section'),
      isChildrenColumnOrListView: true,
      children: vm.listSection
          .map(
            (section) => TextButton(
              onPressed: () => vm.onSelectedSectionOut(section),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(section.name),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _homeForm(BuildContext context, PageOutViewModel vm) {
    return ComponentE3(
      title: const Text('Home'),
      children: [
        _OutTextField(
          label: 'Value',
          initialValue: vm.selectedOut.value,
          onChanged: (value) => vm.selectedOut.value = value,
        ),
        _OutTextField(
          label: 'Description',
          initialValue: vm.selectedOut.description,
          onChanged: (value) => vm.selectedOut.description = value,
        ),
        Row(
          children: [
            Expanded(
              child: _OutTextField(
                label: 'Date',
                initialValue: vm.selectedOut.date.toIso8601String(),
                onChanged: (value) {
                  final date = DateTime.tryParse(value);
                  if (date != null) vm.selectedOut.date = date;
                },
              ),
            ),
            IconButton(
              tooltip: 'Date now',
              icon: const Icon(Icons.today),
              onPressed: () {
                vm.selectedOut.date = DateTime.now();
                vm.notifyListeners();
              },
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => _add(context, vm, 'A'),
                child: const Text('Add A'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _add(context, vm, 'B'),
                child: const Text('Add B'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _add(
    BuildContext context,
    PageOutViewModel vm,
    String whose,
  ) async {
    await vm.onClickAddOut(whose, vm.selectedOut);
    vm.selectedOut = Out(
      section: vm.selectedSectionOut,
      date: DateTime.now(),
    );
  }

  Widget _settingsList(BuildContext context, PageOutViewModel vm) {
    return ComponentE3(
      title: const Text('Setting'),
      settings: [
        IconButton(
          tooltip: 'Copy',
          icon: const Icon(Icons.copy),
          onPressed: () async {
            await Clipboard.setData(
              ClipboardData(text: vm.model.getSyntaxString()),
            );
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Text copied')),
            );
          },
        ),
      ],
      children: vm.list.map((item) => _outItem(context, vm, item)).toList(),
    );
  }

  Widget _outItem(
    BuildContext context,
    PageOutViewModel vm,
    Out item,
  ) {
    return ComponentE3(
      title: Text(item.section.name),
      settings: [
        IconButton(
          tooltip: 'Delete',
          icon: const Icon(Icons.delete),
          onPressed: () => vm.adu.delete(item),
        ),
      ],
      children: [
        ComponentE3(
          title: _OutTextField(
            label: 'value',
            initialValue: item.value,
            onChanged: (value) {
              item.value = value;
              vm.model.dal.save(vm.model.dm);
            },
          ),
          subtitle: const Text('value'),
        ),
        ComponentE3(
          title: _OutTextField(
            label: 'description',
            initialValue: item.description,
            onChanged: (value) {
              item.description = value;
              vm.model.dal.save(vm.model.dm);
            },
          ),
          subtitle: const Text('description'),
        ),
        ComponentE3(
          title: _WhoseSelector(
            value: item.whose,
            values: vm.listWhose,
            onChanged: (value) {
              item.whose = value;
              vm.model.dal.save(vm.model.dm);
              vm.notifyListeners();
            },
          ),
          subtitle: const Text('whose'),
        ),
        ComponentE3(
          title: _SectionSelector(
            value: item.section.name,
            sections: vm.listSection,
            onChanged: (section) {
              item.section = section;
              vm.model.dal.save(vm.model.dm);
              vm.notifyListeners();
            },
          ),
          subtitle: const Text('section'),
        ),
        ComponentE3(
          title: _DateEditor(
            date: item.date,
            onChanged: (date) {
              item.date = date;
              vm.model.dal.save(vm.model.dm);
              vm.notifyListeners();
            },
          ),
          subtitle: const Text('date'),
        ),
      ],
    );
  }
}

class _OutTextField extends StatefulWidget {
  const _OutTextField({
    required this.label,
    required this.initialValue,
    required this.onChanged,
  });

  final String label;
  final String initialValue;
  final ValueChanged<String> onChanged;

  @override
  State<_OutTextField> createState() => _OutTextFieldState();
}

class _OutTextFieldState extends State<_OutTextField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(covariant _OutTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue &&
        _controller.text != widget.initialValue) {
      _controller.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(labelText: widget.label),
      onChanged: widget.onChanged,
    );
  }
}

class _WhoseSelector extends StatelessWidget {
  const _WhoseSelector({
    required this.value,
    required this.values,
    required this.onChanged,
  });

  final String value;
  final List<String> values;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: values.contains(value) ? value : null,
      decoration: const InputDecoration(labelText: 'whose'),
      items: values
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    );
  }
}

class _SectionSelector extends StatelessWidget {
  const _SectionSelector({
    required this.value,
    required this.sections,
    required this.onChanged,
  });

  final String value;
  final List<SectionOut> sections;
  final ValueChanged<SectionOut> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: sections.any((section) => section.name == value) ? value : null,
      decoration: const InputDecoration(labelText: 'section'),
      items: sections
          .map(
            (section) => DropdownMenuItem(
              value: section.name,
              child: Text(section.name),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value == null) return;
        onChanged(sections.firstWhere((section) => section.name == value));
      },
    );
  }
}

class _DateEditor extends StatelessWidget {
  const _DateEditor({required this.date, required this.onChanged});

  final DateTime date;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(date.toLocal().toString())),
        IconButton(
          tooltip: 'Date now',
          icon: const Icon(Icons.today),
          onPressed: () => onChanged(DateTime.now()),
        ),
      ],
    );
  }
}
