import 'package:json_annotation/json_annotation.dart';

part 'PageOutModels.g.dart';

@JsonEnum(alwaysCreate: true)
enum ItemFormOut {
  value,
  description,
  whose,
  section,
  date,
}

@JsonSerializable(explicitToJson: true)
class SyntaxBlockOut {
  SyntaxBlockOut({
    this.value,
    this.itemForm,
    this.whose,
  });

  String? value;
  ItemFormOut? itemForm;
  String? whose;

  factory SyntaxBlockOut.fromJson(Map<String, dynamic> json) =>
      _$SyntaxBlockOutFromJson(json);

  Map<String, dynamic> toJson() => _$SyntaxBlockOutToJson(this);
}

@JsonSerializable(explicitToJson: true)
class SectionOut {
  SectionOut({
    required this.name,
    List<SyntaxBlockOut>? listSyntax,
  }) : listSyntax = listSyntax ?? [
    SyntaxBlockOut(itemForm: ItemFormOut.value),
  ];

  String name;
  List<SyntaxBlockOut> listSyntax;

  factory SectionOut.fromJson(Map<String, dynamic> json) =>
      _$SectionOutFromJson(json);

  Map<String, dynamic> toJson() => _$SectionOutToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Out {
  Out({
    this.value = '',
    this.description = '',
    this.whose = 'A',
    required this.section,
    required this.date,
  });

  String value;
  String description;
  String whose;
  SectionOut section;
  DateTime date;

  factory Out.fromJson(Map<String, dynamic> json) => _$OutFromJson(json);

  Map<String, dynamic> toJson() => _$OutToJson(this);
}

@JsonSerializable(explicitToJson: true)
class PageOutDm {
  PageOutDm({
    List<String>? listWhose,
    List<SectionOut>? listSection,
    List<Out>? list,
  })
      : listWhose = listWhose ?? ['A', 'B'],
        listSection = listSection ?? createDefaultSections(),
        list = list ?? [];

  List<String> listWhose;
  List<SectionOut> listSection;
  List<Out> list;

  factory PageOutDm.fromJson(Map<String, dynamic> json) =>
      _$PageOutDmFromJson(json);

  Map<String, dynamic> toJson() => _$PageOutDmToJson(this);
}

List<SectionOut> createDefaultSections() {
  return [
  SectionOut(
    name: 'Life',
    listSyntax: [
      SyntaxBlockOut(itemForm: ItemFormOut.value, whose: 'A'),
      SyntaxBlockOut(value: '\t'),
      SyntaxBlockOut(itemForm: ItemFormOut.value, whose: 'B'),
      SyntaxBlockOut(value: '\t'),
      SyntaxBlockOut(itemForm: ItemFormOut.description),
      SyntaxBlockOut(value: '\t'),
      SyntaxBlockOut(itemForm: ItemFormOut.date),
    ],
  )
  ,
  SectionOut(name: 'Tax',
  listSyntax: [
  SyntaxBlockOut(itemForm: ItemFormOut.value, whose: 'A'),
  SyntaxBlockOut(value: '\t'),
  SyntaxBlockOut(itemForm: ItemFormOut.value, whose: 'B'),
  SyntaxBlockOut(value: '\t'),
  SyntaxBlockOut(itemForm: ItemFormOut.description),
  SyntaxBlockOut(value: '\t'),
  SyntaxBlockOut(itemForm: ItemFormOut.date),
  ],
  ),
  SectionOut(name: 'A Personal',
    listSyntax: [
  SyntaxBlockOut(itemForm: ItemFormOut.value, whose: 'A'),
  SyntaxBlockOut(value: '\t'),
  SyntaxBlockOut(itemForm: ItemFormOut.value, whose: 'B'),
  SyntaxBlockOut(value: '\t'),
  SyntaxBlockOut(itemForm: ItemFormOut.description),
  SyntaxBlockOut(value: '\t'),
  SyntaxBlockOut(itemForm: ItemFormOut.date),
  ],
  )
  ];
}
