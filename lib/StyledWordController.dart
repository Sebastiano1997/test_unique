import 'package:flutter/material.dart';

class StyledWordController extends TextEditingController {
  final Map<String, TextStyle> wordStyles;

  StyledWordController({required this.wordStyles});

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    bool? withComposing,
  }) {
    final text = value.text;
    final spans = <TextSpan>[];

    final words = wordStyles.keys.toList()
      ..sort((a, b) => b.length.compareTo(a.length));

    final regex = RegExp(
      words.isEmpty
          ? '(?!x)x'
          : '\\b(${words.map(RegExp.escape).join('|')})\\b',
      caseSensitive: false,
    );


    int last = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > last) {
        spans.add(TextSpan(
          text: text.substring(last, match.start),
          style: style,
        ));
      }

      final word = match.group(0)!;
      spans.add(TextSpan(
        text: word,
        style: style?.merge(wordStyles[word.toLowerCase()]),
      ));

      last = match.end;
    }

    if (last < text.length) {
      spans.add(TextSpan(
        text: text.substring(last),
        style: style,
      ));
    }

    return TextSpan(
        style: style,
        children: spans,
    );
  }
}
