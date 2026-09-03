import 'Models/PageOutDm.dart';

/// ========== Infrastructure ==========

abstract class ISaveLoad<T> {
  Future<void> save(T dm);
  Future<T> load();
}

abstract class IModel01<T> {
  T get dm;
  set dm(T value);
  Future<void> buildAsync();
}

abstract class IViewModel01 {
  Future<void> buildAsync();
}

/// ========== ADU (Abstract Data Unit) ==========

class ADU<T> {
  List<T> list;
  Function? callBack;

  ADU(this.list, {this.callBack});

  void add(T item) {
    list.add(item);
    callBack?.call();
  }

  void delete(T item) {
    list.remove(item);
    callBack?.call();
  }

  void update(T oldItem, T newItem) {
    final index = list.indexOf(oldItem);
    if (index != -1) {
      list[index] = newItem;
      callBack?.call();
    }
  }
}

/// ========== DAL (Data Access Layer) ==========

class OutDal1 implements ISaveLoad<Out> {
  Map<String, dynamic> toJson(Out outPar) {
    return {
      'value': outPar.value,
      'description': outPar.description,
      'whose': outPar.whose,
      'section': outPar.section.name,
      'date': outPar.date.toIso8601String(),
    };
  }

  Out fromJson(Map<String, dynamic> json) {
    return Out(
      value: json['value'] as String? ?? '',
      description: json['description'] as String? ?? '',
      whose: json['whose'] as String? ?? '',
      section: SectionOut(json['section'] as String? ?? ''),
      date: DateTime.parse(json['date'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  @override
  Future<void> save(Out dm) async {
    // TODO: Implementare salvataggio
    print('Saving: ${toJson(dm)}');
  }

  @override
  Future<Out> load() async {
    // TODO: Implementare caricamento
    throw UnimplementedError();
  }
}

class PageOutDal1 implements ISaveLoad<PageOutDm> {
  Map<String, dynamic> toJson(PageOutDm page) {
    return {
      'listWhose': page.listWhose,
    };
  }

  PageOutDm fromJson(Map<String, dynamic> json) {
    final page = PageOutDm();
    page.listWhose = List<String>.from(json['listWhose'] as List? ?? []);
    return page;
  }

  @override
  Future<void> save(PageOutDm dm) async {
    // TODO: Implementare salvataggio
    print('Saving PageOut: ${toJson(dm)}');
  }

  @override
  Future<PageOutDm> load() async {
    // TODO: Implementare caricamento
    throw UnimplementedError();
  }
}

/// ========== Model ==========

abstract class IPageOut implements IModel01<PageOutDm> {
  ADU<Out> get adu;
  set adu(ADU<Out> value);

  SectionOut get selectedSectionOut;
  set selectedSectionOut(SectionOut value);

  void onClickAddOut(String valueWhose, Out outItem);
  void onSelectedSectionOut(SectionOut sectionOut);
  String getSyntaxString();
}

class PageOut1 implements IPageOut {
  @override
  late PageOutDm dm = PageOutDm();

  @override
  late ISaveLoad<PageOutDm> dal = PageOutDal1();

  @override
  late ADU<Out> adu;

  @override
  late SectionOut selectedSectionOut;

  PageOut1() {
    adu = ADU<Out>(dm.list, callBack: () => dal.save(dm));
    selectedSectionOut = dm.listSection.first;
  }

  @override
  Future<void> buildAsync() async {
    try {
      dm = await dal.load();
    } catch (e) {
      print('Error loading: $e');
    }
  }

  @override
  void onClickAddOut(String valueWhose, Out outItem) {
    outItem.whose = valueWhose;
    adu.add(outItem);
    dal.save(dm);
  }

  @override
  void onSelectedSectionOut(SectionOut sectionOut) {
    selectedSectionOut = sectionOut;
  }

  @override
  String getSyntaxString() {
    String result = '';
    for (var item in dm.list) {
      result += getSyntaxStringItem(item) + '\n';
    }
    return result;
  }

  String getSyntaxStringItem(Out outItem) {
    String result = '';
    for (var item in selectedSectionOut.syntax) {
      if (item.value != null) {
        result += item.value!;
      } else if (item.itemForm != null) {
        switch (item.itemForm) {
          case ItemFormOut.value:
            if (item.whose == null || item.whose == outItem.whose) {
              result += outItem.value;
            }
            break;
          case ItemFormOut.description:
            if (item.whose == null || item.whose == outItem.whose) {
              result += outItem.description;
            }
            break;
          case ItemFormOut.whose:
            if (item.whose == null || item.whose == outItem.whose) {
              result += outItem.whose;
            }
            break;
          case ItemFormOut.section:
            if (item.whose == null || item.whose == outItem.whose) {
              result += selectedSectionOut.name;
            }
            break;
          case ItemFormOut.date:
            if (item.whose == null || item.whose == outItem.whose) {
              result += outItem.date.toString();
            }
            break;
          default:
            break;
        }
      }
    }
    return result;
  }
}

/// ========== ViewModel ==========

abstract class IPageOutVM implements IViewModel01 {
  IPageOut get model;
  set model(IPageOut value);

  Out get selectedOut;
  set selectedOut(Out value);

  List<String> get listWhose;
  List<SectionOut> get listSection;
  List<Out> get list;
  ADU<Out> get adu;
  SectionOut get selectedSectionOut;

  void onClickAddOut(String valueWhose, Out outItem);
  void onSelectedSectionOut(SectionOut sectionOut);
  void onClickCopyOut();
}

class PageOutVM1 implements IPageOutVM {
  @override
  late IPageOut model = PageOut1();

  @override
  late Out selectedOut = Out(
    section: SectionOut(''),
    date: DateTime.now(),
  );

  PageOutVM1();

  @override
  List<String> get listWhose => model.dm.listWhose.take(2).toList();

  @override
  List<SectionOut> get listSection => model.dm.listSection;

  @override
  List<Out> get list => model.dm.list;

  @override
  ADU<Out> get adu => model.adu;

  @override
  SectionOut get selectedSectionOut => model.selectedSectionOut;

  @override
  void onClickAddOut(String valueWhose, Out outItem) {
    model.onClickAddOut(valueWhose, outItem);
  }

  @override
  void onSelectedSectionOut(SectionOut sectionOut) {
    model.onSelectedSectionOut(sectionOut);
  }

  @override
  void onClickCopyOut() {
    final String syntaxString = model.getSyntaxString();
    print('Copied: $syntaxString');
  }

  @override
  Future<void> buildAsync() async {
    await model.buildAsync();
  }
}
