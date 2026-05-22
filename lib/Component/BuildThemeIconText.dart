
import 'package:flutter/material.dart';

import '../Wello.dart';
import 'ComponentE.dart';

class BuildThemeIconText extends StatelessWidget
{
  BuildThemeIconText({
    super.key,
    required this.child,
    required bool this.isIconText,
    this.color,
    this.size=SizeE.medium
  });

  BuildThemeIconText.all({
    super.key,
    this.child,
    required this.isIconText,
    this.getChild,
    this.color,
    this.size=SizeE.medium
  });
  BuildThemeIconText.all2({
    super.key,
    this.child,
    required this.isIconText,
    this.getChild,
    this.getChild2,
    this.color,
    this.size=SizeE.medium
  });

  /// + par

  late Widget? child;
  bool isIconText;
  Color? color;
  SizeE size=SizeE.medium;

  Widget Function(TextStyle,IconThemeData)? getChild;

  Widget Function(ColorScheme,TextStyle,IconThemeData)? getChild2;

  /// + var
  IconThemeData? iconThemeData;
  TextStyle? textStyle;

  /// + func

  ColorScheme getColorScheme(BuildContext context){
    final theme = Theme.of(context);
    final ColorScheme colorScheme;

    if(color!=null) colorScheme=ColorScheme.fromSeed(seedColor: color!,brightness: theme.brightness);
    else colorScheme=theme.colorScheme;

    return colorScheme;
  }

  void buildIconTextTheme(SizeE size, BuildContext context)
  {
    ColorScheme colorScheme=getColorScheme(context);

    double sizeItem=18;
    Color colorItem=colorScheme.onSecondaryContainer;
    FontWeight? fontWeightItem;

    /// + set value
    if(size==SizeE.small) {
      sizeItem=18;
      //colorItem=theme.colorScheme.onSecondaryContainer;
      colorItem=colorScheme.tertiary;
      fontWeightItem=null;
    } else if(size==SizeE.medium)
    {
      sizeItem=24;
      //colorItem=theme.colorScheme.onSecondaryContainer;
      colorItem=colorScheme.secondary;

      fontWeightItem=null;
    }else if(size==SizeE.large)
    {
      sizeItem=32;
      //colorItem=theme.colorScheme.onPrimaryContainer;
      colorItem=colorScheme.primary;

      //fontWeightItem=FontWeight.bold;
    }

    /// + set Style
    if(getChild!=null || getChild2!=null || (isIconText))
    {
      iconThemeData=IconThemeData(size: sizeItem,color: colorItem);
    }

    if(getChild!=null ||getChild2!=null || (!isIconText))
    {
      textStyle=TextStyle(fontSize:sizeItem,color: colorItem,fontWeight: fontWeightItem);
    }

  }


  @override
  Widget build(BuildContext context) {
    if(child==null && getChild==null && getChild2==null) return SizedBox();

    ColorScheme colorScheme=getColorScheme(context);
    buildIconTextTheme(size, context);

    if(getChild!=null)  return getChild!(textStyle!,iconThemeData!);
    if(getChild2!=null)  return getChild2!(colorScheme,textStyle!,iconThemeData!);

    if(isIconText)
    {
      return IconTheme(
          data: IconThemeData(size: iconThemeData!.size,
              color: iconThemeData!.color ),
          child: child!);
    }else{
      return DefaultTextStyle(
        style: TextStyle(
          fontSize: textStyle!.fontSize,
          fontWeight: textStyle!.fontWeight,
          color: textStyle!.color /*theme.colorScheme.onSurface*/,
        ),
        child: child!,
      );
    }

  }


}
