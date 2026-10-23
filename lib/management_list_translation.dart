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
    required this.child,
  });

  final ADU<T> adu;
  final T Function() newItem;
  final Widget child;

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
              ManagementItem<T>.openManagementItemPopup(
                context,
                ManagementItem<T>(item,adu,child)
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



  static void openManagementPopup<T>(
    BuildContext context,
    ManagementList<T> father
  ) 
  {
    double width=420;
    double height=520;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            child: SizedBox(
              width: width,
              height: height,
              child: father
            ),
          );
        },
      );
    },
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

static void openManagementItemPopup<T>(
    BuildContext context,
    ManagementItem<T> father
  ) 
  {
    double width=420;
    double height=520;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            child: SizedBox(
              width: width,
              height: height,
              child: father
            ),
          );
        },
      );
    },
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
