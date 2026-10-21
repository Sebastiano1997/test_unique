import 'package:flutter/material.dart';

import 'Component/ComponentE.dart';

abstract class IItemForManagement {
  String get name;
  set name(String value);
}

class ADU<T extends IItemForManagement> {
  final List<T> items = [];

  void add(T item) {
    items.add(item);
  }

  void delete(T item) {
    items.remove(item);
  }
}

class ManagementList<T extends IItemForManagement> extends StatelessWidget {
  const ManagementList({
    super.key,
    required this.adu,
    required this.newItem,
  });

  final ADU<T> adu;
  final T Function() newItem;

  @override
  Widget build(BuildContext context) {
    final itemsBody = adu.items.map((item) {
      return ComponentE3(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'go out popup',
          onPressed: () {},
        ),
        settings: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'delete item',
            onPressed: () => adu.delete(item),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            tooltip: 'open item',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => Dialog(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child:ManagementItem(item: item, adu: adu, child: Text("...."),)
                  ),
                ),
              );
            },
          ),
        ],
        children: [
          TextButton(
            onPressed: () {},
            child: Text(item.name),
          ),
        ],
      );
    }).toList();

    return ComponentE3(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        tooltip: 'go out popup',
        onPressed: () {},
      ),
      settings: [
        IconButton(
          icon: const Icon(Icons.add),
          tooltip: 'add item',
          onPressed: () => adu.add(newItem()),
        ),
      ],
      children: itemsBody,
      isChildrenColumnOrListView: true,
      isExpandedChildren: true,
    );
  }
}

class ManagementItem<T extends IItemForManagement> extends StatelessWidget {
  const ManagementItem({
    super.key,
    required this.item,
    required this.adu,
    required this.child,
  });

  final T item;
  final ADU<T> adu;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ComponentE3(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        tooltip: 'go out popup',
        onPressed: () {},
      ),
      settings: [
        IconButton(
          icon: const Icon(Icons.arrow_upward),
          tooltip: 'exit back to the previous popup',
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.check),
          tooltip: 'save',
          onPressed: () {},
        ),
      ],
      children: [child],
    );
  }
}

class DemoItem implements IItemForManagement {
  DemoItem({required this.name});

  @override
  String name;
}

class ManagementListExamplePage extends StatelessWidget {
  ManagementListExamplePage({super.key}) {
    adu.add(DemoItem(name: 'First item'));
    adu.add(DemoItem(name: 'Second item'));
  }

  final ADU<DemoItem> adu = ADU<DemoItem>();

  DemoItem createNewItem() => DemoItem(name: 'New item');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Management list'),
      ),
      body: ManagementList<DemoItem>(
        adu: adu,
        newItem: createNewItem,
      ),
    );
  }
}

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ManagementListExamplePage(),
    ),
  );
}
