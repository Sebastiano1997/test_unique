// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'PageOutModels.dart';

SyntaxBlockOut _$SyntaxBlockOutFromJson(Map<String, dynamic> json) =>
    SyntaxBlockOut(
      value: json['value'] as String?,
      itemForm: $enumDecodeNullable(
        _$ItemFormOutEnumMap,
        json['itemForm'],
      ),
      whose: json['whose'] as String?,
    );

Map<String, dynamic> _$SyntaxBlockOutToJson(SyntaxBlockOut instance) =>
    <String, dynamic>{
      'value': instance.value,
      'itemForm': _$ItemFormOutEnumMap[instance.itemForm],
      'whose': instance.whose,
    };

const _$ItemFormOutEnumMap = {
  ItemFormOut.value: 'value',
  ItemFormOut.description: 'description',
  ItemFormOut.whose: 'whose',
  ItemFormOut.section: 'section',
  ItemFormOut.date: 'date',
};

SectionOut _$SectionOutFromJson(Map<String, dynamic> json) => SectionOut(
      name: json['name'] as String,
      listSyntax: (json['listSyntax'] as List<dynamic>?)
              ?.map((e) => SyntaxBlockOut.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$SectionOutToJson(SectionOut instance) =>
    <String, dynamic>{
      'name': instance.name,
      'listSyntax': instance.listSyntax.map((e) => e.toJson()).toList(),
    };

Out _$OutFromJson(Map<String, dynamic> json) => Out(
      value: json['value'] as String? ?? '',
      description: json['description'] as String? ?? '',
      whose: json['whose'] as String? ?? 'A',
      section: SectionOut.fromJson(json['section'] as Map<String, dynamic>),
      date: DateTime.parse(json['date'] as String),
    );

Map<String, dynamic> _$OutToJson(Out instance) => <String, dynamic>{
      'value': instance.value,
      'description': instance.description,
      'whose': instance.whose,
      'section': instance.section.toJson(),
      'date': instance.date.toIso8601String(),
    };

PageOutDm _$PageOutDmFromJson(Map<String, dynamic> json) => PageOutDm(
      listWhose: (json['listWhose'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      listSection: (json['listSection'] as List<dynamic>?)
          ?.map((e) => SectionOut.fromJson(e as Map<String, dynamic>))
          .toList(),
      list: (json['list'] as List<dynamic>?)
          ?.map((e) => Out.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PageOutDmToJson(PageOutDm instance) => <String, dynamic>{
      'listWhose': instance.listWhose,
      'listSection': instance.listSection.map((e) => e.toJson()).toList(),
      'list': instance.list.map((e) => e.toJson()).toList(),
    };
