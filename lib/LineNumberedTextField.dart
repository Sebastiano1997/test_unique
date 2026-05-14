import 'package:flutter/material.dart';

////////////////////////////////////////


class LineNumberedTextEditor extends StatefulWidget {
  const LineNumberedTextEditor({
    super.key,
    this.controller,
    this.textStyle,
    this.hintText = '',
    this.lineNumberWidth = 40,
    this.onLineTap,
  });

  final TextEditingController? controller;
  final TextStyle? textStyle;
  final String hintText;
  final double lineNumberWidth;

  /// Callback quando si clicca un numero di riga (1-based)
  final ValueChanged<int>? onLineTap;

  @override
  State<LineNumberedTextEditor> createState() =>
      _LineNumberedTextEditorState();
}

class _LineNumberedTextEditorState extends State<LineNumberedTextEditor> {
  late final TextEditingController _textController;
  late final ScrollController _textScrollController;
  late final ScrollController _lineScrollController;

  int _lineCount = 1;
  bool _isSyncingScroll = false;

  Map<int,int> mapIndexCountBlock={
    1:25,
    41:(79-41)
  };

  @override
  void initState() {
    super.initState();

    _textController = widget.controller ?? TextEditingController();
    _textScrollController = ScrollController();
    _lineScrollController = ScrollController();

    _textController.addListener(_updateLineCount);
    _textScrollController.addListener(_syncFromText);
    _lineScrollController.addListener(_syncFromLines);
  }

  void _updateLineCount() {
    setState(() {
      _lineCount = _textController.text.split('\n').length;
    });
  }

  void _syncFromText() {
    if (!_isSyncingScroll && _textScrollController.hasClients) {
      _isSyncingScroll = true;
      _lineScrollController.jumpTo(_textScrollController.offset);
      _isSyncingScroll = false;
    }
  }

  void _syncFromLines() {
    if (!_isSyncingScroll && _lineScrollController.hasClients) {
      _isSyncingScroll = true;
      _textScrollController.jumpTo(_lineScrollController.offset);
      _isSyncingScroll = false;
    }
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
    final style =
        widget.textStyle ?? Theme.of(context).textTheme.bodyLarge;

    final lineHeight =
        (style?.fontSize ?? 14) * (style?.height ?? 1.0);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ======================
        // NUMERI DI RIGA
        // ======================
        Container(
          width: widget.lineNumberWidth,
          padding: const EdgeInsets.only(right: 8, top: 12),
          child: ListView.builder(
            controller: _lineScrollController,
            itemCount: _lineCount,
            itemBuilder: (context, index) {
              return SizedBox(
                height: lineHeight,
                child: TextButton(
                  onPressed: widget.onLineTap != null
                      ? () => widget.onLineTap!(index + 1)
                      : (){},//null, //todo
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize:
                    MaterialTapTargetSize.shrinkWrap,
                    alignment: Alignment.centerRight,
                  ),
                  child: Text(
                    !mapIndexCountBlock.containsKey(index)?'${index + 1}':'${mapIndexCountBlock[index]}',
                    textAlign: TextAlign.right,
                    style: style?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // ======================
        // TEXTFIELD
        // ======================
        Expanded(
          child: TextField(
            controller: _textController,
            scrollController: _textScrollController,
            maxLines: null,
            expands: true,
            keyboardType: TextInputType.multiline,
            textAlignVertical: TextAlignVertical.top,
            style: style,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: widget.hintText,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}


////////////////////////////////////////


