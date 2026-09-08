import 'package:json_annotation/json_annotation.dart';

part 'out_models.g.dart';

// ==================== DM (Data Model) ====================

@JsonSerializable()
class Out {
  String? value;
  String? description;
  String? whose;
  SectionOut? section;
  DateTime? date;

  Out({
    this.value,
    this.description,
    this.whose,
    this.section,
    this.date,
  });

  factory Out.fromJson(Map<String, dynamic> json) => _$OutFromJson(json);
  Map<String, dynamic> toJson() => _$OutToJson(this);
}

@JsonSerializable()
class SectionOut {
  String name;
  List<SyntaxBlockOut> listSyntax;

  SectionOut(
    this.name, {
    List<SyntaxBlockOut>? listSyntax,
  }) : listSyntax = listSyntax ??
            [
              SyntaxBlockOut.fromItemForm(ItemFormOut.value),
            ];

  factory SectionOut.fromJson(Map<String, dynamic> json) =>
      _$SectionOutFromJson(json);
  Map<String, dynamic> toJson() => _$SectionOutToJson(this);
}

@JsonSerializable()
class SyntaxBlockOut {
  String? value;
  ItemFormOut? itemForm;
  String? whose;

  SyntaxBlockOut.fromValue(this.value)
      : itemForm = null,
        whose = null;

  SyntaxBlockOut.fromItemForm(
    this.itemForm, {
    this.whose,
  }) : value = null;

  factory SyntaxBlockOut.fromJson(Map<String, dynamic> json) =>
      _$SyntaxBlockOutFromJson(json);
  Map<String, dynamic> toJson() => _$SyntaxBlockOutToJson(this);
}

@JsonSerializable()
class PageOutDm {
  List<String> listWhose;
  List<SectionOut> listSection;
  List<Out> list;

  PageOutDm({
    List<String>? listWhose,
    List<SectionOut>? listSection,
    List<Out>? list,
  })  : listWhose = listWhose ?? ["A", "B"],
        listSection = listSection ??
            [
              SectionOut("Life", listSyntax: [
                SyntaxBlockOut.fromItemForm(ItemFormOut.value, whose: "A"),
                SyntaxBlockOut.fromValue("\t"),
                SyntaxBlockOut.fromItemForm(ItemFormOut.value, whose: "B"),
                SyntaxBlockOut.fromValue("\t"),
                SyntaxBlockOut.fromItemForm(ItemFormOut.description),
                SyntaxBlockOut.fromValue("\t"),
                SyntaxBlockOut.fromItemForm(ItemFormOut.date),
              ]),
              SectionOut("Tax"),
              SectionOut("A Personal"),
            ],
        list = list ?? [];

  factory PageOutDm.fromJson(Map<String, dynamic> json) =>
      _$PageOutDmFromJson(json);
  Map<String, dynamic> toJson() => _$PageOutDmToJson(this);
}

enum ItemFormOut {
  value,
  description,
  whose,
  section,
  date,
}

// ==================== DAL (Data Access Layer) ====================

abstract class IDal01<T> {
  Future<void> save(T dm);
  Future<T> load();
}

class SaveLoadJson<T> {
  final Function(T) toJson;
  final Function(Map<String, dynamic>) fromJson;

  SaveLoadJson({
    required this.toJson,
    required this.fromJson,
  });
}

class PageOutDal1 implements IDal01<PageOutDm> {
  late SaveLoadJson<PageOutDm> saveLoadJsonPageOut;
  late SaveLoadJson<Out> saveLoadJsonOut;
  late SaveLoadJson<SectionOut> saveLoadJsonSectionOut;
  late SaveLoadJson<SyntaxBlockOut> saveLoadJsonSyntaxBlockOut;

  PageOutDal1() {
    saveLoadJsonPageOut = SaveLoadJson<PageOutDm>(
      toJson: _toJsonPageOut,
      fromJson: _fromJsonPageOut,
    );

    saveLoadJsonOut = SaveLoadJson<Out>(
      toJson: (out) => out.toJson(),
      fromJson: (json) => Out.fromJson(json),
    );

    saveLoadJsonSectionOut = SaveLoadJson<SectionOut>(
      toJson: (section) => section.toJson(),
      fromJson: (json) => SectionOut.fromJson(json),
    );

    saveLoadJsonSyntaxBlockOut = SaveLoadJson<SyntaxBlockOut>(
      toJson: (syntax) => syntax.toJson(),
      fromJson: (json) => SyntaxBlockOut.fromJson(json),
    );
  }

  @override
  Future<void> save(PageOutDm dm) async {
    throw UnimplementedError('save() not implemented');
  }

  @override
  Future<PageOutDm> load() async {
    throw UnimplementedError('load() not implemented');
  }

  Map<String, dynamic> _toJsonPageOut(PageOutDm page) {
    return {
      "list": page.list.map((i) => saveLoadJsonOut.toJson(i)).toList(),
      "listWhose": page.listWhose,
      "listSection":
          page.listSection.map((i) => saveLoadJsonSectionOut.toJson(i)).toList(),
    };
  }

  PageOutDm _fromJsonPageOut(Map<String, dynamic> json) {
    PageOutDm page = PageOutDm();
    // page.listWhose = List<String>.from(json["listWhose"]);
    // page.list = (json["list"] as List).map((i) => saveLoadJsonOut.fromJson(i)).toList();
    // page.listSection = (json["listSection"] as List).map((i) => saveLoadJsonSectionOut.fromJson(i)).toList();
    return page;
  }
}

// ==================== M (Model) ====================

abstract class IPageOut extends IModel01<PageOutDm> {
  ADU<Out> get adu;
  set adu(ADU<Out> value);

  SectionOut get selectedSectionOut;
  set selectedSectionOut(SectionOut value);

  void onClickAddOut(String valueWhose, Out outItem);
  void onSelectedSectionOut(SectionOut sectionOut);
  String getSyntaxString();
}

class ADU<T> {
  final List<T> list;
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
}

class PageOut1 extends IPageOut {
  @override
  PageOutDm dm = PageOutDm();

  @override
  IDal01<PageOutDm> dal = PageOutDal1();

  late ADU<Out> _adu;
  late SectionOut _selectedSectionOut;

  PageOut1() {
    _adu = ADU<Out>(dm.list, callBack: () => dal.save(dm));
    _selectedSectionOut = dm.listSection.first;
  }

  @override
  ADU<Out> get adu => _adu;

  @override
  set adu(ADU<Out> value) => _adu = value;

  @override
  SectionOut get selectedSectionOut => _selectedSectionOut;

  @override
  set selectedSectionOut(SectionOut value) => _selectedSectionOut = value;

  @override
  Future<void> buildAsync() async {
    dm = await dal.load();
  }

  @override
  void onClickAddOut(String valueWhose, Out outItem) {
    outItem.whose = valueWhose;
    _adu.add(outItem);
    dal.save(dm);
  }

  @override
  void onSelectedSectionOut(SectionOut sectionOut) {
    _selectedSectionOut = sectionOut;
  }

  @override
  String getSyntaxString() {
    StringBuffer result = StringBuffer();
    for (var item in dm.list) {
      result.writeln(getSyntaxStringItem(item));
    }
    return result.toString();
  }

  String getSyntaxStringItem(Out outItem) {
    StringBuffer result = StringBuffer();
    for (var item in _selectedSectionOut.listSyntax) {
      if (item.value != null) {
        result.write(item.value);
      } else if (item.itemForm != null) {
        switch (item.itemForm) {
          case ItemFormOut.value:
            if (item.whose == null || item.whose == outItem.whose) {
              result.write(outItem.value);
            }
            break;
          case ItemFormOut.description:
            if (item.whose == null || item.whose == outItem.whose) {
              result.write(outItem.description);
            }
            break;
          case ItemFormOut.whose:
            if (item.whose == null || item.whose == outItem.whose) {
              result.write(outItem.whose);
            }
            break;
          case ItemFormOut.section:
            if (item.whose == null || item.whose == outItem.whose) {
              result.write(_selectedSectionOut.name);
            }
            break;
          case ItemFormOut.date:
            if (item.whose == null || item.whose == outItem.whose) {
              result.write(outItem.date.toString());
            }
            break;
          default:
            break;
        }
      }
    }
    return result.toString();
  }
}

// ==================== VM (View Model) ====================

abstract class IPageOutVM extends IViewModel01<PageOutDm> {
  IPageOut get modelExt;
  set modelExt(IPageOut value);

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

class PageOutVM1 extends IPageOutVM {
  late IModel01<PageOutDm> _model;
  late IPageOut _modelExt;
  late Out _selectedOut;

  PageOutVM1() {
    _model = PageOut1();
    _modelExt = _model as IPageOut;
    _selectedOut = Out();
  }

  @override
  IModel01<PageOutDm> get model => _model;

  @override
  set model(IModel01<PageOutDm> value) => _model = value;

  @override
  IPageOut get modelExt => _modelExt;

  @override
  set modelExt(IPageOut value) => _modelExt = value;

  @override
  Out get selectedOut => _selectedOut;

  @override
  set selectedOut(Out value) => _selectedOut = value;

  @override
  List<String> get listWhose => _model.dm.listWhose.take(2).toList();

  @override
  List<SectionOut> get listSection => _model.dm.listSection;

  @override
  List<Out> get list => _model.dm.list;

  @override
  ADU<Out> get adu => _modelExt.adu;

  @override
  SectionOut get selectedSectionOut => _modelExt.selectedSectionOut;

  @override
  void onClickAddOut(String valueWhose, Out outItem) =>
      _modelExt.onClickAddOut(valueWhose, outItem);

  @override
  void onSelectedSectionOut(SectionOut sectionOut) =>
      _modelExt.onSelectedSectionOut(sectionOut);

  @override
  void onClickCopyOut() => _modelExt.getSyntaxString();

  @override
  Future<void> buildAsync() async {
    await _model.buildAsync();
  }
}

// ==================== V (View) ====================

class PageOutV1 {
  late IPageOutVM vm;

  PageOutV1() {
    vm = PageOutVM1();
  }

  // build() -> Widget (Tab)
  // Returns a tab widget with home and setting views
  Map<String, dynamic> build() {
    PageOutVM1 vmLocal = PageOutVM1();
    return {
      'type': 'Tab',
      'children': [
        home(vmLocal),
        setting(vmLocal),
      ]
    };
  }

  // home view
  Map<String, dynamic> home(IPageOutVM vm) {
    var listSection = vm.listSection
        .map((i) => {
              'type': 'TextButton',
              'label': 'TextButton${i.name}',
              'onPressed': () => vm.onSelectedSectionOut(i)
            })
        .toList();

    return {
      'type': 'ComponentE3',
      'children': [
        {
          'type': 'Row',
          'children': [
            section(vm),
            {
              'type': 'ComponentE3',
              'title': {'type': 'Text', 'content': 'Home'},
              'children': [
                {
                  'type': 'TextField',
                  'label': 'Value',
                  'onChanged': (value) => vm.selectedOut.value = value
                },
                {
                  'type': 'TextField',
                  'label': 'Description',
                  'onChanged': (value) => vm.selectedOut.description = value
                },
                {
                  'type': 'Row',
                  'children': [
                    {
                      'type': 'TextField',
                      'label': 'Date',
                      'onChanged': (value) =>
                          vm.selectedOut.date = DateTime.parse(value)
                    },
                    {
                      'type': 'TextButton',
                      'label': 'Button(DateNow)',
                      'onPressed': () => vm.selectedOut.date = DateTime.now()
                    },
                  ]
                },
                {
                  'type': 'TextButton',
                  'label': 'Button(AddA)',
                  'onPressed': () => vm.onClickAddOut("A", vm.selectedOut)
                },
                {
                  'type': 'TextButton',
                  'label': 'Button(AddB)',
                  'onPressed': () => vm.onClickAddOut("B", vm.selectedOut)
                },
              ]
            },
          ]
        }
      ]
    };
  }

  // setting view
  Map<String, dynamic> setting(IPageOutVM vm) {
    var listItem = vm.list
        .map((i) => {
              'type': 'ComponentE3',
              'title': {'type': 'Text', 'content': i.section?.name ?? ''},
              'settings': [
                {
                  'type': 'IconButton',
                  'icon': 'delete',
                  'onPressed': () => vm.adu.delete(i)
                },
              ],
              'children': [
                {
                  'type': 'ComponentE3',
                  'title': {
                    'type': 'TextField',
                    'initialValue': i.value ?? '',
                    'onChanged': (value) => i.value = value
                  },
                  'subtitle': {'type': 'Text', 'content': 'value'},
                },
                {
                  'type': 'ComponentE3',
                  'title': {
                    'type': 'TextField',
                    'initialValue': i.description ?? '',
                    'onChanged': (value) => i.description = value
                  },
                  'subtitle': {'type': 'Text', 'content': 'description'},
                },
                {
                  'type': 'ComponentE3',
                  'title': {
                    'type': 'MultipleChoice',
                    'value': i.whose ?? '',
                    'listValue': vm.listWhose,
                    'onChanged': (value) => i.whose = value,
                  },
                  'subtitle': {'type': 'Text', 'content': 'whose'},
                },
                {
                  'type': 'ComponentE3',
                  'title': {
                    'type': 'MultipleChoice',
                    'value': i.section?.name ?? '',
                    'listValue':
                        vm.listSection.map((s) => s.name).toList(),
                    'onChanged': (value) => i.section = SectionOut(value),
                  },
                  'subtitle': {'type': 'Text', 'content': 'section'},
                },
                {
                  'type': 'ComponentE3',
                  'title': {
                    'type': 'TextField',
                    'initialValue': i.date?.toString() ?? '',
                    'onChanged': (value) => i.date = DateTime.parse(value)
                  },
                  'settings': [
                    {
                      'type': 'TextButton',
                      'label': 'Button(DateNow)',
                      'onPressed': () => i.date = DateTime.now()
                    },
                  ],
                  'subtitle': {'type': 'Text', 'content': 'date'},
                },
              ]
            })
        .toList();

    listItem.insert(
      0,
      {
        'type': 'ComponentE3',
        'title': {
          'type': 'IconButton',
          'icon': 'content_copy',
          'onPressed': () => vm.onClickCopyOut()
        },
      },
    );

    return {
      'type': 'ComponentE3',
      'children': [
        {
          'type': 'Row',
          'children': [
            section(vm),
            {
              'type': 'ComponentE3',
              'title': {'type': 'Text', 'content': 'Setting'},
              'children': listItem,
            }
          ]
        }
      ]
    };
  }

  // section view
  Map<String, dynamic> section(IPageOutVM vm) {
    return {
      'type': 'ComponentE3',
      'title': {'type': 'Text', 'content': 'Section'},
      'children': vm.listSection
          .map((i) => {
                'type': 'TextButton',
                'label': 'TextButton${i.name}',
                'onPressed': () => vm.onSelectedSectionOut(i)
              })
          .toList(),
    };
  }
}

// ==================== Infrastructure-Common ====================

abstract class IDal01<T> {
  Future<void> save(T dm);
  Future<T> load();
}

abstract class IModel01<T> {
  T get dm;
  set dm(T value);

  IDal01<T> get dal;
  set dal(IDal01<T> value);

  Future<void> buildAsync();
}

abstract class IViewModel01<T> {
  IModel01<T> get model;
  set model(IModel01<T> value);

  Future<void> buildAsync();
}
