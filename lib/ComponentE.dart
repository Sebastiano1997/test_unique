import 'dart:math' as Math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ComponentE extends StatelessWidget
{
  ComponentE({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.settings,
    this.children,

    this.size=SizeE.medium,
    this.align=AlignE.left,
    this.color,
    this.isBorder=true,

    this.getLeading,
    this.getTitle,
    this.getSubtitle,
    this.getSetting
  });


  Widget? leading;
  Widget? title;
  Widget? subtitle;
  List<Widget>? settings;
  List<Widget>? children;
  SizeE size=SizeE.medium;
  AlignE align=AlignE.left;
  Color? color;
  bool isBorder;

  // + withStyle
  Widget Function(TextStyle,IconThemeData)? getTitle;
  Widget Function(TextStyle,IconThemeData)? getLeading;
  Widget Function(TextStyle,IconThemeData)? getSubtitle;
  Widget Function(TextStyle,IconThemeData)? getSetting;


  /// + func

  MainAxisAlignment getAlignMainAxis(AlignE align)
  {
    if(align==AlignE.left)return MainAxisAlignment.start;
    else if(align==AlignE.center)return MainAxisAlignment.center;
    else return MainAxisAlignment.end;
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    SizeE sizeMinus=size-1;

    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: !isBorder?null:BoxDecoration(
          color: theme.colorScheme.surfaceVariant.withOpacity(isDark ? 0.3 : 0.7),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment:  getAlignMainAxis(align),
                    children: [
                      /*CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    radius: 18,
                    child:*/ BuildThemeIconText.all(
                        getChild: getLeading,
                        isIconText: true,
                        size: size,
                        child: leading,),
                      //),

                      const SizedBox(width: 12),
                      // Expanded(
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BuildThemeIconText.all(
                            getChild: getTitle,
                            isIconText: false,
                            size: size,
                            child: title,),
                          BuildThemeIconText.all(
                            size: sizeMinus,
                            getChild: getSubtitle,
                            isIconText: false,
                            child: subtitle,),
                        ],
                      ),
                    ],),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    for(var item in settings??[])
                      BuildThemeIconText.all(
                        child: item,
                        getChild: getSetting,
                        isIconText: true,
                        size: size,
                      ),
                  ],
                ),
              ],
            ),
            Column(
              children: children??[],)
          ],
        ),
      ),
    );
  }



}

enum SizeE
{
  small,medium,large;

  SizeE operator +(int num) {
    return SizeE.values[Math.min(this.index+num,SizeE.values.length-1) ];
  }

  SizeE operator -(int num)
  {
    return SizeE.values[Math.min( Math.max(this.index-num,0), SizeE.values.length-1 )];
  }

}
enum AlignE
{
  left,center,right
}

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

  late Widget? child;
  bool isIconText;
  Color? color;
  SizeE size=SizeE.medium;

  Widget Function(TextStyle,IconThemeData)? getChild;

  /// + var
  IconThemeData? iconThemeData;
  TextStyle? textStyle;

  /// + func
  void buildIconTextTheme(SizeE size, BuildContext context)
  {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    double sizeItem=18;
    Color colorItem=theme.colorScheme.onSecondaryContainer;
    FontWeight? fontWeightItem;

    /// + set value
    if(size==SizeE.small) {
      sizeItem=18;
      colorItem=theme.colorScheme.onSecondaryContainer;
      fontWeightItem=null;
    } else if(size==SizeE.medium)
    {
      sizeItem=24;
      colorItem=theme.colorScheme.onSecondaryContainer;
      fontWeightItem=null;
    }else if(size==SizeE.large)
    {
      sizeItem=32;
      colorItem=theme.colorScheme.onPrimaryContainer;
      //fontWeightItem=FontWeight.bold;
    }

    /// + set Style
    if(getChild!=null || (isIconText))
    {
      iconThemeData=IconThemeData(size: sizeItem,color: colorItem);
    }

    if(getChild!=null || (!isIconText))
    {
      textStyle=TextStyle(fontSize:sizeItem,color: colorItem,fontWeight: fontWeightItem);
    }

  }


  @override
  Widget build(BuildContext context) {
    if(child==null && getChild==null) return SizedBox();

    buildIconTextTheme(size, context);

    if(getChild!=null)  return getChild!(textStyle!,iconThemeData!);

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