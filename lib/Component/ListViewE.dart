import 'package:flutter/cupertino.dart';

class ListViewE extends StatelessWidget {
  const ListViewE({
    super.key,
    this.height,
    this.percent,
    required this.children,
  });

  final double? height;
  final double? percent;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final calculatedHeight = (height ?? MediaQuery.of(context).size.height) * (percent??1);

    return SizedBox(
      height: calculatedHeight,
      child: ListView(
        children: children,
      ),
    );
  }
}