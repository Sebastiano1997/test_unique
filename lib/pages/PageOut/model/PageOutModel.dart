import 'package:flutter/foundation.dart';

import '../../../dependencies/services/ISaveLoad.dart';
import '../data/PageOutDal.dart';
import 'PageOutModels.dart';

class ADU<T> extends ChangeNotifier {
  ADU(
    this.items, {
    Future<void> Function()? callBack,
  }) : _callBack = callBack;

  final List<T> items;
  final Future<void> Function()? _callBack;

  Future<void> add(T item) async {
    items.add(item);
    notifyListeners();
    await _callBack?.call();
  }

  Future<void> delete(T item) async {
    items.remove(item);
    notifyListeners();
    await _callBack?.call();
  }
}

abstract interface class IPageOut {
  PageOutDm get dm;
  set dm(PageOutDm value);

  PageOutDal get dal;
  set dal(PageOutDal value);

  ADU<Out> get adu;

  SectionOut get selectedSectionOut;
  set selectedSectionOut(SectionOut value);

  Future<void> buildAsync();
  Future<void> onClickAddOut(String valueWhose, Out outItem);
  void onSelectedSectionOut(SectionOut sectionOut);
  String getSyntaxString();
}

class PageOutModel extends ChangeNotifier implements IPageOut {
  PageOutModel({PageOutDm? initialDm, PageOutDal? dal})
      : _dm = initialDm ?? PageOutDm(),
        _dal = dal ?? PageOutDal() {
    _selectedSectionOut = _dm.listSection.first;
    _createAdu();
  }

  PageOutDm _dm;
  PageOutDal _dal;
  late ADU<Out> _adu;
  late SectionOut _selectedSectionOut;

  void _createAdu() {
    _adu = ADU<Out>(_dm.list, callBack: () => _dal.save(_dm));
  }

  @override
  PageOutDm get dm => _dm;

  @override
  set dm(PageOutDm value) {
    _dm = value;
    _selectedSectionOut = value.listSection.first;
    _createAdu();
    notifyListeners();
  }

  @override
  PageOutDal get dal => _dal;

  @override
  set dal(PageOutDal value) {
    _dal = value;
    _createAdu();
  }

  @override
  ADU<Out> get adu => _adu;

  @override
  SectionOut get selectedSectionOut => _selectedSectionOut;

  @override
  set selectedSectionOut(SectionOut value) {
    _selectedSectionOut = value;
    notifyListeners();
  }

  @override
  Future<void> buildAsync() async {
    dm = await dal.load();
  }

  @override
  Future<void> onClickAddOut(String valueWhose, Out outItem) async {
    outItem.whose = valueWhose;
    outItem.section = selectedSectionOut;
    await adu.add(outItem);
  }

  @override
  void onSelectedSectionOut(SectionOut sectionOut) {
    selectedSectionOut = sectionOut;
  }

  @override
  String getSyntaxString() {
    return dm.list.map(_getSyntaxStringItem).join('\r\n');
  }

  String _getSyntaxStringItem(Out outItem) {
    final result = StringBuffer();

    for (final syntax in selectedSectionOut.listSyntax) {
      if (syntax.value != null) {
        result.write(syntax.value);
        continue;
      }

      final itemForm = syntax.itemForm;
      if (itemForm == null) continue;
      if (syntax.whose != null && syntax.whose != outItem.whose) continue;

      switch (itemForm) {
        case ItemFormOut.value:
          result.write(outItem.value);
          break;
        case ItemFormOut.description:
          result.write(outItem.description);
          break;
        case ItemFormOut.whose:
          result.write(outItem.whose);
          break;
        case ItemFormOut.section:
          result.write(selectedSectionOut.name);
          break;
        case ItemFormOut.date:
          result.write(outItem.date.toString());
          break;
      }
    }

    return result.toString();
  }
}
