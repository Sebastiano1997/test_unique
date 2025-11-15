

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';



class SelectItem<T> extends StatefulWidget {

  SelectItem(T defaultItem, {super.key, T Function(T newValue, T oldValue, bool isUpper)? onChangedCaller,String Function(T item)? onGetItem, List<T>? list}) {
    viewModel=SelectItemViewModel(defaultItem,onChangedCaller: onChangedCaller,onGetItem:onGetItem,list: list);
  }

  late SelectItemViewModel<T> viewModel;

  @override
  State<SelectItem> createState() => _SelectItem<T>();
}

class _SelectItem<T> extends State<SelectItem> {

  void up()
  {
    setState(() {
      widget.viewModel.up();
    });
  }
  void down()
  {
    setState(() {
      widget.viewModel.down();
    });
  }

  String get item=>widget.viewModel.getItem();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(onPressed: up, icon: Icon(Icons.arrow_drop_up)),
        Text(item),
        IconButton(onPressed: down, icon: Icon(Icons.arrow_drop_down)),
      ],
    );
  }

}

// -----

class SelectItemViewModel<T> {
  SelectItemViewModel(T defaultItem, { T Function(T newValue, T oldValue, bool isUpper)? onChangedCaller,this.onGetItem, List<T>? list})
  {
    model=SelectItemModel(defaultItem,onChangedCaller: onChangedCaller,list: list);
  }

  late SelectItemModel<T> model;
  final String Function(T item)? onGetItem;

  void up() {
    model.up();
  }

  void down() {
    model.down();
  }

  String getItem()
  {
    if (onGetItem == null) {
      return "${model.item}";
    } else {
      return onGetItem!(model.item);
    }
  }
}

class SelectItemModel<T> {
  SelectItemModel(T defaultItem, { T Function(T newValue, T oldValue, bool isUpper)? onChangedCaller, List<T>? list})
      : _onChangedCaller = onChangedCaller
  {
    item=defaultItem;
    index = list?.indexOf(item) ?? -1;
  }

  late T item;
  final T Function(T newValue, T oldValue, bool isUpper)? _onChangedCaller;
  List<T>? list;
  int index = -1;

  void up() {
    T oldItem = item;
    T? newItem;

    if (list != null && list!.isNotEmpty) {
      index++;
      if (index >= list!.length) index = 0;
      newItem = list![index];
    } else if (item is int) {
      int y = (item as int) + 1;
      newItem = y as T;
    }

    if (newItem != null) {
      _onChanged(newItem, oldItem, true);
    }
  }

  void down() {
    T oldItem = item;
    T? newItem;

    if (list != null && list!.isNotEmpty) {
      index--;
      if (index < 0) index = list!.length - 1;
      newItem = list![index];
    } else if (item is int) {
      int y = (item as int) - 1;
      newItem = y as T;
    }

    if (newItem != null) {
      _onChanged(newItem, oldItem, false);
    }
  }


  void _onChanged(T newValue, T oldValue, bool isUpper) {
    if (_onChangedCaller == null) {
      item = newValue;
    } else {
      item = _onChangedCaller!(newValue, oldValue, isUpper);
    }
  }
}

// -------------------------
// Test
// -------------------------
void main() {
  // esempio con int
  var select1 = SelectItemModel<int>(10, onChangedCaller: onChanged);
  select1.up();
  select1.up();
  select1.down();
  print("Final int: ${select1.item}");

  // esempio con string
  var select2 = SelectItemModel<String>(
    "ciao",
    onChangedCaller: onChanged,
    list: ["hallo", "world", "!!!"],
  );
  select2.up();
  select2.up();
  select2.down();
  print("Final string: ${select2.item}");
}

// funzione di callback generica
T onChanged<T>(T newValue, T oldValue, bool isUpper) {
  if (newValue is int) return (newValue + (isUpper ? 1 : -1)) as T;
  if (newValue is String) return (newValue + "...") as T;
  return newValue;
}
