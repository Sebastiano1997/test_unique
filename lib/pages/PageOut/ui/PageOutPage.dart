import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../Component/ComponentE.dart';
import '../../../Component/IconExpandedList.dart';
import '../model/PageOutModels.dart';
import '../viewmodel/PageOutViewModel.dart';

class PageOutPage extends StatelessWidget {
  const PageOutPage({super.key});

  @override
  Widget build(BuildContext context) {
    PageOutViewModel vm=PageOutViewModel();
    return
      FutureBuilder<bool>(
          future: vm.buildAsync(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
      return ChangeNotifierProvider<PageOutViewModel>(
      create: (_) => vm,
      child: const _PageOutView(),
    );
  });
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
              onPressed: vm.selectedSectionOut==section?null: () => vm.onSelectedSectionOut(section),
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
    return Consumer<PageOutViewModel>(
      builder: (context, viewModel, child) {
        return ComponentE3(
          title: const Text('Home'),
          children: [
            _OutTextFieldValue(
              label: 'Value',
              initialValue: viewModel.selectedOut.value,
              onChanged: (value) => viewModel.selectedOut.value = value,
            ),
            _OutTextField(
              label: 'Description',
              initialValue: viewModel.selectedOut.description,
              onChanged: (value) => viewModel.selectedOut.description = value,
            ),
            Row(
              children: [
                Expanded(
                  child: _OutTextField(
                    isIconRemove: false,
                    label: 'Date',
                    initialValue: viewModel.selectedOut.date.toIso8601String(),
                    onChanged: (value) {
                      final date = DateTime.tryParse(value);
                      if (date != null) viewModel.selectedOut.date = date;
                    },
                  ),
                ),
                IconButton(
                  tooltip: 'Date now',
                  icon: const Icon(Icons.today),
                  onPressed: () async {
                    viewModel.selectedOut.date = (await selectDateTime(context,dateDefault:viewModel.selectedOut.date ))??DateTime.now();
                    viewModel.notifyListeners();
                  },
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _add(context, viewModel, 'A'),
                    child: const Text('Add A'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _add(context, viewModel, 'B'),
                    child: const Text('Add B'),
                  ),
                ),
              ],
            ),
          ],
        );
        },
    );
  }

  Future<void> _add(
    BuildContext context,
    PageOutViewModel vm,
    String whose,
  ) async {
    await vm.onClickAddOut(whose, vm.selectedOut);
  }

  Widget _settingsList(BuildContext context, PageOutViewModel vm) {
    return ComponentE3(
      getFatherChildren: (child)=>Container(child: child,height: 500,),
      title: const Text('Setting'),
      settings: [
        IconButton(
          tooltip: 'Copy',
          icon: const Icon(Icons.copy_all),
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
        IconButton(
          tooltip: 'Copy Section',
          icon: const Icon(Icons.copy),
          onPressed: () async {
            await Clipboard.setData(
              ClipboardData(text: vm.model.getSyntaxStringWhereSection()),
            );
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Text copied for section')),
            );
          },
        ),
        IconButton(
          tooltip: 'Copy Section Order',
          icon: const Icon(Icons.copy),
          onPressed: () async {
            await Clipboard.setData(
              ClipboardData(text: vm.model.getSyntaxStringWhereSectionOrder()),
            );
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Text copied for the section Order')),
            );
          },
        ),
        IconButton(
          tooltip: 'Clean',
          icon: const Icon(Icons.clean_hands_rounded),
          onPressed: () async {
            vm.cleanHistory();
          },
        ),
      ],
      isChildrenColumnOrListView: false,
      children: vm.list.reversed.map((item) =>
          _outItem(context, vm, item)
      ).toList(),
    );
  }

  Widget _outItem(
    BuildContext context,
    PageOutViewModel vm,
    Out item,
  ) {
    return ComponentE3(
      size: SizeE.medium,
      isBorder: true,
      title: Text(item.section.name),
      settings: [
        IconButton(
          tooltip: 'Delete',
          icon: const Icon(Icons.delete),
          onPressed: () => vm.deleteItem(item),
        ),
        IconExpandedList(isOnOff: false,),
        Text(item.description)
      ],
      children: [
        // #break
         _OutTextField(
            label: 'value',
            initialValue: item.value,
            onChanged: (value) {
              item.value = value;
              vm.model.dal.save(vm.model.dm);
            },
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
          size: SizeE.small,
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
          size: SizeE.small,
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
          size: SizeE.small,
        ),

        ComponentE3(
          title: Text(item.date.toLocal().toString()),
          leading: IconButton(
              onPressed: () async
              {
              item.date = await selectDateTime(context)??item.date;
              vm.model.dal.save(vm.model.dm);
              vm.notifyListeners();
              },
              icon: Icon(Icons.calendar_month)),
          subtitle: const Text('date'),
          size: SizeE.ssmall,
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
    this.isIconRemove=true,

  });

  final String label;
  final String initialValue;
  final ValueChanged<String> onChanged;
  final bool isIconRemove;

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
    return Row(
      children: [
        Container(
          width: 100,
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(labelText: widget.label),
            onChanged: widget.onChanged,
          ),
        ),
        !widget.isIconRemove?SizedBox():IconButton(onPressed: ()=>setState(() {
          _controller.text="";
        }), icon: Icon(Icons.remove))
      ],
    );
  }
}


class _OutTextFieldValue extends StatefulWidget {
  const _OutTextFieldValue({
    required this.label,
    required this.initialValue,
    required this.onChanged,
    this.isIconRemove=true,

  });

  final String label;
  final String initialValue;
  final ValueChanged<String> onChanged;
  final bool isIconRemove;

  @override
  State<_OutTextFieldValue> createState() => _OutTextFieldValueState();
}

class _OutTextFieldValueState extends State<_OutTextFieldValue> {
  late final TextEditingController _controller;

  bool _isNumeric=true;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(covariant _OutTextFieldValue oldWidget) {
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
    //_controller.text=widget.label;

    return ComponentE3(
          title: Container(
          width: 100,
          child: CustomInputField(
  label: _isNumeric ? 'Numbers' : 'Text',
  controller: _controller,
  isNumeric: _isNumeric,
  onChanged: widget.onChanged,
),
        ),
          subtitle: const Text('value'),
          size: SizeE.small,
      leading: !widget.isIconRemove?SizedBox():IconButton(onPressed: ()=>setState(() {
          _controller.text="";
        }), icon: Icon(Icons.remove)),
settings:[


],
      children: [
        Container(
          width: 100, // Ora 100px bastano e avanzano!
          child: Center(
            child: Switch(
              value: _isNumeric,
              onChanged: (bool value) {
                setState(() {
                  _isNumeric = value;
                });
              },
            ),
          ),
        )
      ],
      
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
    return Container(
      width: 200,
      child: DropdownButtonFormField<String>(
        value: values.contains(value) ? value : null,
        decoration: const InputDecoration(labelText: 'whose'),
        items: values
            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
        onChanged: (value) {
          if (value != null) onChanged(value);
        },
      ),
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
    return Container(
      width: 200,
      child: DropdownButtonFormField<String>(
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
      ),
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
        Text(date.toLocal().toString()),
        IconButton(
          tooltip: 'Date now',
          icon: const Icon(Icons.today),
          onPressed: () async => onChanged(await selectDateTime(context)??DateTime.now()),
        ),
      ],
    );
  }
}


Future<DateTime?> selectDateTime( BuildContext context, {DateTime? dateDefault}) async {
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: dateDefault??DateTime.now(),
    firstDate: DateTime(2020),
    lastDate: DateTime(2030),
  );
  return picked;
}

class CustomInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isNumeric;
  final ValueChanged<String>? onChanged;

  const CustomInputField({
    Key? key,
    required this.label,
    required this.controller,
    required this.isNumeric,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      // Imposta il tipo di tastiera in base al flag booleano
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}

