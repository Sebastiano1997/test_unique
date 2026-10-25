

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Component/ComponentE.dart';
import 'pages/PageOut/model/PageOutModel.dart';

abstract class IItemForManagement {
  String get name;

  IItemForManagement toCopy();
}

class ManagementList<T extends IItemForManagement> extends StatelessWidget {
  const ManagementList({
    super.key,
    required this.adu,
    required this.newItem,
    required this.getChild,
    this.isPopup = false,
  });

  final ADU<T> adu;
  final T Function() newItem;
  final Widget Function(T) getChild;

  final bool isPopup;

  @override
  Widget build(BuildContext context) {
    List<Widget> itemsBody() => adu.items.map((item) {
      return ComponentE3(
        key: ValueKey(adu.items.indexOf(item).toString()),//todo
        title: TextButton(
          onPressed: () =>
              openPopup(context: context, item: item, selectedItem: item),
          child: Text(item.name),
        ),
        settings: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'delete item',
            onPressed: () => delete(item),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            tooltip: 'open item',
            onPressed: () =>
                openPopup(context: context, item: item, selectedItem: item),
          ),
          SizedBox(width: 20,)
        ],
      );
    }).toList();

    return ChangeNotifierProvider<ADU<T>>(
      create: (BuildContext context) => adu,
      builder: (context, adu) {
        return Consumer<ADU<T>>(
          builder: (context, viewModel, child) {
            return ComponentE3(
              leading:!isPopup?null: IconButton(
                icon: const Icon(Icons.arrow_back),
                tooltip: 'go out',
                onPressed: () => back(context),
              ),
              settings: [
                IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: 'add item',
                  onPressed: () => addNew(context),
                ),
              ],
              isChildrenColumnOrListView: true,
              //children: itemsBody(),
              getFatherChildren: (child)=>Expanded(
                child: ReorderableListView(
                // 2. Questa funzione sposta l'elemento nella nuova posizione quando l'utente lo rilascia
                    onReorder: (int oldIndex, int newIndex) {
                      this.adu.move(oldIndex,newIndex);
                    },
                // 3. Genera i widget della lista (ogni elemento DEVE avere una Key univoca)
                    children: itemsBody()
                ),
              ),

              //itemsBody,
            ); },
        );
      },
    );
  }

  void openPopup({
    required BuildContext context,
    required T item,
    required T? selectedItem,
  }) {
    ManagementItem.openManagementItemPopup(
      context,
        ManagementItem<T>(
            item: item,
            adu: adu,
            getChild: getChild,
            selectedItem: selectedItem,
            contextFather:context
        )
      );
  }

  void back(BuildContext context) {
    Navigator.of(context).pop();
  }

  void delete(T item) {
    adu.delete(item);
  }

  void addNew(BuildContext context) {
    T item = newItem();
    openPopup(context: context, item: item, selectedItem: null);
  }

  static void openManagementPopup<T extends IItemForManagement>({
    required BuildContext dialogContext,
    required ADU<T> adu,
    required T Function() newItem,
    required Widget Function(T) getChild,
    double? width,
    double? height
  }) {
    if(width==null) {
      double screenWidth= MediaQuery.sizeOf(dialogContext).width;
      width = screenWidth*0.5;
    }
    if(height==null) {
      final double screenHeight = MediaQuery.sizeOf(dialogContext).height;
      height = screenHeight*0.5;
    }

    ManagementList<T> father = ManagementList(
      adu: adu,
      newItem: newItem,
      getChild: getChild,
      isPopup: true,
    );
    showDialog(
      context: dialogContext,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              child: SizedBox(
                  width: width,
                  height: height,
                  child: father),
            );
          },
        );
      },
    );
  }
}

class ManagementItem<T extends IItemForManagement> extends StatelessWidget {
  ManagementItem({
    super.key,
    required this.item,
    required this.adu,
    required this.getChild,
    required this.selectedItem,
    required this.contextFather,
  }) {
    if (selectedItem != null) {
      this.item = item.toCopy() as T;
    }
  }

  late T item;
  final ADU<T> adu;
  final Widget Function(T) getChild;
  late T? selectedItem;
  final BuildContext contextFather;

  @override
  Widget build(BuildContext context) {
    return ComponentE3(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        tooltip: 'go out',
        onPressed: () => back(context),
      ),
      settings: [
        IconButton(
          icon: const Icon(Icons.arrow_upward),
          tooltip: 'exit back to the previous popup',
          onPressed: () => closePopupAll(context),
        ),
        IconButton(
          icon: const Icon(Icons.delete),
          tooltip: 'delete item',
          onPressed: () => delete(context, item),
        ),
        IconButton(
          icon: const Icon(Icons.check),
          tooltip: 'save',
          onPressed: () => ok(context),
        ),
      ],
      children: [getChild(item)],
    );
  }

  void back(BuildContext context) {
    Navigator.of(context).pop();
  }

  void delete(BuildContext context, T item) {
    if (selectedItem != null) {
      adu.delete(selectedItem!);
    }
    back(context);
  }

  void ok(BuildContext context) {
    if (selectedItem == null) {
      adu.add(item);
    } else {
      adu.replace(selectedItem!, item);
    }

    back(context);
  }

  void closePopupAll(BuildContext context) {
    back(context);
    back(contextFather);
  }

  static void openManagementItemPopup<T extends IItemForManagement>(
    BuildContext context,
    ManagementItem<T> father,
      {double? height,
      double? width,}
  ) {

    if(width==null) {
      double screenWidth= MediaQuery.sizeOf(context).width;
      width = screenWidth*0.5;
    }
    if(height==null) {
      final double screenHeight = MediaQuery.sizeOf(context).height;
      height = screenHeight*0.5;
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              child: SizedBox(width: width, height: height, child: father),
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

  String description="";
  int value=0;

  @override
  DemoItem toCopy() {
    return DemoItem(name: name)
    ..description=description
    ..value=value;
  }
}

class ManagementListExamplePage extends StatelessWidget {
  ManagementListExamplePage({super.key}) {
    List<DemoItem> list = [
      DemoItem(name: 'First item'),
      DemoItem(name: 'Second item'),
    ];

    adu = ADU<DemoItem>(list);
  }

  late ADU<DemoItem> adu;

  DemoItem createNewItem() => DemoItem(name: 'New item');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Management list')),
      bottomNavigationBar: IconButton(
        onPressed: () {
          ManagementList.openManagementPopup<DemoItem>(
            dialogContext: context,
            adu: adu,
            newItem: () => DemoItem(name: "name"),
            getChild: (i) => Column(
              children: [
                TextField(
                  controller: TextEditingController(text: i.name),
                  onChanged: (value) => i.name = value,
                ),
                TextField(
                  controller: TextEditingController(text: i.description),
                  onChanged: (value) => i.description = value,
                ),
                TextField(
                  controller: TextEditingController(text: i.value.toString()),
                  onChanged: (value) => i.value=int.parse(value),
                ),
              ],
            ),
          );
        },
        icon: Icon(Icons.control_point_duplicate),
      ),
      body: ManagementList<DemoItem>(
        adu: adu,
        newItem: createNewItem,
        getChild: (i) => Expanded(
          child: TextField(controller: TextEditingController(text: i.name)),
        ),
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
