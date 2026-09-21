import 'dart:math' as Math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Wello.dart';
import 'BuildThemeIconText.dart';
import 'IconExpandedList.dart';



enum SizeE
{
  ssmall,small,medium,large;

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

/// -



class ComponentE3 extends StatelessWidget
{
  ComponentE3({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.settings,
    this.children,

    this.size=SizeE.medium,
    this.align=AlignE.left,
    this.color,
    this.isBorder=false,
    this.isBorderChildren=true,
    this.heightChildren,
    this.isChildrenColumnOrListView=true,
    this.isNotFatherListView=false,
    this.isExpandedChildrenColumn=false,
    this.isExpandedChildren=true,

    this.getLeading,
    this.getTitle,
    this.getSubtitle,
    this.getSettings,

    this.getBackground,
    this.getFatherWidget,
    this.getFatherChildren
  }){
    if(settings!=null)
      {
        for(var item in settings!)
          {
            if(item is IconExpandedList )
              {
                item.onPressedInternal=(isOnOff){isExpandedChildren=isOnOff; we?.setStateWello(); } ;
                item.callPressInternal();
              }

          }
      }
  }

  /// + par
  Widget? leading;
  Widget? title;
  Widget? subtitle;
  List<Widget>? settings;
  List<Widget>? children;
  SizeE size=SizeE.medium;
  AlignE align=AlignE.left;
  Color? color;
  bool isBorder;
  double? heightChildren;
  bool isChildrenColumnOrListView;
  bool isNotFatherListView;
  bool isBorderChildren;
  bool isExpandedChildrenColumn;

  // + withStyle
  Widget Function(ColorScheme,TextStyle,IconThemeData)? getTitle;
  Widget Function(ColorScheme,TextStyle,IconThemeData)? getLeading;
  Widget Function(ColorScheme,TextStyle,IconThemeData)? getSubtitle;
  List<Widget> Function(ColorScheme,TextStyle,IconThemeData)? getSettings;

  Color Function(ColorScheme)? getBackground;
  Widget Function(Widget)? getFatherWidget;
  Widget Function(Widget)? getFatherChildren;

  /// + const
  final double heightChildrenDefault=200;

  /// + var
  Wello? we;
  bool isExpandedChildren;

  /// + func

  ColorScheme getColorScheme(BuildContext context){
    final theme = Theme.of(context);
    final ColorScheme colorScheme;

    if(color!=null) colorScheme=ColorScheme.fromSeed(seedColor: color!,brightness: theme.brightness);
    else colorScheme=theme.colorScheme;

    return colorScheme;
  }

  double get heightChildrenGet => heightChildren??heightChildrenDefault;


  MainAxisAlignment getAlignMainAxis(AlignE align)
  {
    if(align==AlignE.left)return MainAxisAlignment.start;
    else if(align==AlignE.center)return MainAxisAlignment.center;
    else return MainAxisAlignment.end;
  }

  bool isNotNull(List list)
  {
    return list.any((i)=>i!=null);
  }

  /// + build
  @override
  Widget build(BuildContext context) {

    final ColorScheme colorScheme=getColorScheme(context);
    final isDark = colorScheme.brightness == Brightness.dark;

    SizeE sizeMinus=size-1;
    int lengthGetSetting=getSettings?.call(colorScheme,TextStyle(),IconThemeData()).length??0;

    /// + body
    getFatherChildren??=(i)=>i;
    Widget getChild()=>thisColumnOrListView(
      isExpandedChildrenColumn:isExpandedChildrenColumn,
      isColumnOrListView: true,
      colorScheme: colorScheme, isDark: isDark, isBorder: isBorder,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // + leading, title, subtitle
            Expanded(
              child: Row(
                mainAxisAlignment:  getAlignMainAxis(align),
                children: [
                  if( isNotNull([leading,getLeading]) )
                    BuildThemeIconText.all2(
                      color: color,
                      getChild2: getLeading,
                      isIconText: true,
                      size: size,
                      child: leading,),

                  if( isNotNull([leading,getLeading]) && ( isNotNull([title,getTitle]) || isNotNull([subtitle,getSubtitle]) ) )
                    const SizedBox(width: 10),

                  if(isNotNull([title,getTitle]) || isNotNull([subtitle,getSubtitle]) )
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BuildThemeIconText.all2(
                          color: color,
                          getChild2: getTitle,
                          isIconText: false,
                          size: size,
                          child: title,),
                        BuildThemeIconText.all2(
                          color: color,
                          size: sizeMinus,
                          getChild2: getSubtitle,
                          isIconText: false,
                          child: subtitle,),
                      ],
                    ),
                ],),
            ),
            // + settings
            if( isNotNull([settings,getSettings]) )
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  for(var item in settings??[])
                    BuildThemeIconText.all(
                      color: color,
                      child: item,
                      isIconText: true,
                      size: sizeMinus, // size
                    ),
                  for(int cGetSetting=0; cGetSetting<lengthGetSetting;cGetSetting++)
                    BuildThemeIconText.all2(
                      color: color,
                      getChild2: (c,t,i){ return getSettings!.call(c,t,i)[cGetSetting]; },
                      isIconText: true,
                      size: size,
                    ),
                ],
              ),
          ],
        ),
        // + children
        if(children!=null && isExpandedChildren)
          getFatherChildren!(thisColumnOrListView(
            isColumnOrListView: isChildrenColumnOrListView,
            colorScheme: colorScheme,
            isBorder: isBorderChildren,
            isDark: isDark,
            children: children??[],
          ))
      ],
    );
    getFatherWidget ??= (i)=>getChild();

    return
      Wello(
        builder: (we)=>this.we=we,
        view: (Wello we) {
        return thisExpanded(
          isColumnOrListView: isNotFatherListView,
          child: getFatherWidget!(getChild()),
        );
        }
      );
  }

  Widget thisContainer({
    required ColorScheme colorScheme,
    required bool isDark,
    required Widget child,
    required bool isBorder,
    double? height,
    EdgeInsetsGeometry margin=const EdgeInsets.only(left: 8,right: 8,top: 8,bottom: 8),
    EdgeInsetsGeometry padding=const EdgeInsets.symmetric(horizontal: 10, vertical: 3), // (horizontal: 4, vertical: 0),
  })
  {
    Color background=getBackground!=null? getBackground!(colorScheme): colorScheme.surfaceContainerHighest;//theme.colorScheme.surfaceContainerHighest.withValues(alpha:isDark ? 0.3 : 0.7),
    return Container(
      height: height,
      margin: margin,
      padding: padding ,
      decoration: !isBorder?null:BoxDecoration(
        color: background.withValues(alpha:isDark ? 0.3 : 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    )
        ;
  }

  Widget thisExpanded({required bool isColumnOrListView, required Widget child})
  {
    if(isColumnOrListView) return Expanded(child: child);
    else return child;
  }

  Widget thisColumnOrListView( {required ColorScheme colorScheme, required bool isDark,required bool isColumnOrListView, required List<Widget> children, bool isBorder=true, bool isExpandedChildrenColumn=false,})
  {
    if(isColumnOrListView) {
      return
        /*thisExpanded(
            isColumnOrListView: isExpandedChildrenColumn,
            child:*/
        thisContainer(
          colorScheme: colorScheme,
          isDark: isDark,
          isBorder: isBorder,
          height: heightChildren,
          margin: const EdgeInsetsGeometry.only(bottom: 8,top: 5),
          padding: const EdgeInsetsGeometry.only(right: 10,left: 10),
          child:Column(
           mainAxisSize: MainAxisSize.min,
            children: children??[],)
      //)
        );
    }
    else {
      return
      thisContainer(
          colorScheme: colorScheme,
          isDark: isDark,
          isBorder: true,
          height: heightChildrenGet,
  margin: const EdgeInsetsGeometry.all(8),
  padding: const EdgeInsetsGeometry.all(10),
  child: ListView(
  children: children??[],
  )
  );
    }
  }



}




