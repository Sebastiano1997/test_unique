import 'package:flutter/material.dart';


class LineNumberedTextField2 extends StatefulWidget {
  const LineNumberedTextField2({
    super.key,
    this.controller,
    this.hintText = '',
    this.lineNumberWidth = 40,
    this.textStyle,
    this.decoration,
  });

  /// Controller esterno opzionale
  final TextEditingController? controller;

  /// Testo di hint
  final String hintText;

  /// Larghezza colonna numeri di riga
  final double lineNumberWidth;

  /// Stile del testo
  final TextStyle? textStyle;

  /// Decorazione del TextField
  final InputDecoration? decoration;

  @override
  State<LineNumberedTextField2> createState() => _LineNumberedTextField2State();
}

class _LineNumberedTextField2State extends State<LineNumberedTextField2> {
  late final TextEditingController _textController;
  late final ScrollController _textScrollController;
  late final ScrollController _lineScrollController;

  int _lineCount = 1;
  bool _isSyncingScroll = false;

  @override
  void initState() {
    super.initState();

    _textController = widget.controller ?? TextEditingController();
    _textScrollController = ScrollController();
    _lineScrollController = ScrollController();

    _textController.addListener(_updateLineCount);

    _textScrollController.addListener(() {
      if (!_isSyncingScroll && _textScrollController.hasClients) {
        _isSyncingScroll = true;
        _lineScrollController.jumpTo(_textScrollController.offset);
        _isSyncingScroll = false;
      }
    });

    _lineScrollController.addListener(() {
      if (!_isSyncingScroll && _lineScrollController.hasClients) {
        _isSyncingScroll = true;
        _textScrollController.jumpTo(_lineScrollController.offset);
        _isSyncingScroll = false;
      }
    });
  }

  void _updateLineCount() {
    setState(() {
      _lineCount = _textController.text.split('\n').length;
    });
  }

  @override
  void dispose() {
    _textController.removeListener(_updateLineCount);

    if (widget.controller == null) {
      _textController.dispose();
    }

    _textScrollController.dispose();
    _lineScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveTextStyle =
        widget.textStyle ?? Theme.of(context).textTheme.bodyLarge;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Numeri di riga
        Container(
          width: widget.lineNumberWidth,
          padding: const EdgeInsets.only(right: 8, top: 12),
          child: ListView.builder(
            controller: _lineScrollController,
            itemCount: _lineCount,
            itemBuilder: (context, index) {
              return Text(
                '${index + 1}',
                textAlign: TextAlign.right,
                style: effectiveTextStyle?.copyWith(
                  color: Colors.grey[600],
                ),
              );
            },
          ),
        ),

        // TextField
        Expanded(
          child: TextField(
            controller: _textController,
            scrollController: _textScrollController,
            maxLines: null,
            expands: true,
            keyboardType: TextInputType.multiline,
            textAlignVertical: TextAlignVertical.top,
            style: effectiveTextStyle,
            decoration: widget.decoration ??
                InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: widget.hintText,
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                ),
          ),
        ),
      ],
    );
  }
}