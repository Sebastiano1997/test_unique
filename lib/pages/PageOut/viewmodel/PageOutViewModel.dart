import 'package:flutter/foundation.dart';

import '../model/PageOutModel.dart';
import '../model/PageOutModels.dart';

abstract interface class IPageOutViewModel {
  PageOutModel get model;

  Out get selectedOut;
  set selectedOut(Out value);

  List<String> get listWhose;
  List<SectionOut> get listSection;
  List<Out> get list;
  ADU<Out> get adu;
  SectionOut get selectedSectionOut;

  Future<void> buildAsync();
  Future<void> onClickAddOut(String valueWhose, Out outItem);
  void onSelectedSectionOut(SectionOut sectionOut);
  Future<void> onClickCopyOut();
}

class PageOutViewModel extends ChangeNotifier
    implements IPageOutViewModel {
  PageOutViewModel({PageOutModel? model}) : _model = model ?? PageOutModel() {
    _selectedOut = Out(
      section: _model.selectedSectionOut,
      date: DateTime.now(),
    );
    _model.addListener(_forwardModelChanges);
  }

  final PageOutModel _model;
  late Out _selectedOut;

  void _forwardModelChanges() => notifyListeners();

  @override
  PageOutModel get model => _model;

  @override
  Out get selectedOut => _selectedOut;

  @override
  set selectedOut(Out value) {
    _selectedOut = value;
    notifyListeners();
  }

  @override
  List<String> get listWhose => _model.dm.listWhose.take(2).toList();

  @override
  List<SectionOut> get listSection => _model.dm.listSection;

  @override
  List<Out> get list => _model.dm.list;

  @override
  ADU<Out> get adu => _model.adu;

  @override
  SectionOut get selectedSectionOut => _model.selectedSectionOut;

  @override
  Future<bool> buildAsync() => _model.buildAsync();

  @override
  Future<void> onClickAddOut(String valueWhose, Out outItem) async {
    await _model.onClickAddOut(valueWhose, outItem);
    selectedOut = Out(
      value: selectedOut.value,
      description: selectedOut.description,
      whose: selectedOut.whose,

      section: selectedSectionOut,
      date: DateTime.now(),
    );
    notifyListeners();
  }

  @override
  void onSelectedSectionOut(SectionOut sectionOut) {
    _model.onSelectedSectionOut(sectionOut);
    _selectedOut.section = sectionOut;
    notifyListeners();
  }

  @override
  Future<void> onClickCopyOut() async {
    _model.getSyntaxString();
  }

  @override
  void dispose() {
    _model.removeListener(_forwardModelChanges);
    _model.dispose();
    super.dispose();
  }

  void cleanHistory() {
    model.cleanHistory();
    notifyListeners();
  }

  void deleteItem(Out item) {
    model.deleteItem(item);
    notifyListeners();
  }

  void onChangedValueField() {
    model.dal.save(model.dm);
    //notifyListeners();
  }
}
