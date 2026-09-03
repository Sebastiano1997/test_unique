// ========== Data Models ==========

enum ItemFormOut {
  value,
  description,
  whose,
  section,
  date,
}

class Out {
  String value = '';
  String description = '';
  String whose = '';
  late SectionOut section;
  late DateTime date;

  Out({
    this.value = '',
    this.description = '',
    this.whose = '',
    required this.section,
    required this.date,
  });
}

class SectionOut {
  String name;
  late List<SyntaxBlockOut> syntax;

  SectionOut(this.name) {
    syntax = [SyntaxBlockOut(ItemFormOut.value)];
  }

  SectionOut.withSyntax(this.name, this.syntax);
}

class SyntaxBlockOut {
  String? value;
  ItemFormOut? itemForm;
  String? whose;

  SyntaxBlockOut(String value) {
    this.value = value;
  }

  SyntaxBlockOut.withForm(this.itemForm, {this.whose});
}

class PageOutDm {
  List<String> listWhose = ['A', 'B'];

  late List<SectionOut> listSection = [
    SectionOut.withSyntax('Life', [
      SyntaxBlockOut.withForm(ItemFormOut.value, whose: 'A'),
      SyntaxBlockOut('\t'),
      SyntaxBlockOut.withForm(ItemFormOut.value, whose: 'B'),
      SyntaxBlockOut('\t'),
      SyntaxBlockOut.withForm(ItemFormOut.description),
      SyntaxBlockOut('\t'),
      SyntaxBlockOut.withForm(ItemFormOut.date),
    ]),
    SectionOut('Tax'),
    SectionOut('A Personal'),
  ];

  List<Out> list = [];

  PageOutDm();
}
