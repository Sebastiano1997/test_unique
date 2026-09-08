import 'package:json_annotation/json_annotation.dart';

part 'out_models.g.dart';

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

  SectionOut(this.name, {List<SyntaxBlockOut>? listSyntax})
      : listSyntax = listSyntax ??
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

  SyntaxBlockOut.fromItemForm(this.itemForm, {this.whose})
      : value = null;

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
