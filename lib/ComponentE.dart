import 'dart:math' as Math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Wello.dart';


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
    this.isBorder=true,
    this.heightChildren,
    this.isChildrenColumnOrListView=true,
    this.isNotFatherListView=false,

    this.getLeading,
    this.getTitle,
    this.getSubtitle,
    this.getSettings
  }){
    if(settings!=null)
      {
        for(var item in settings!)
          {
            if(item is IconExpandedList )
              {
                item.onPressedInternal=(){isExpandedChildren=!isExpandedChildren; we?.setStateWello(); };
              }

          }
      }
  }


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

  // + withStyle
  Widget Function(TextStyle,IconThemeData)? getTitle;
  Widget Function(TextStyle,IconThemeData)? getLeading;
  Widget Function(TextStyle,IconThemeData)? getSubtitle;
  List<Widget> Function(TextStyle,IconThemeData)? getSettings;

  /// + const
  final double heightChildrenDefault=200;

  /// + var
  bool isExpandedChildren=true;
  Wello? we;

  /// + func

  double get heightChildrenGet => heightChildren??heightChildrenDefault;


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
    int lengthGetSetting=getSettings?.call(TextStyle(),IconThemeData()).length??0;

    return
      Wello(
        builder: (we)=>this.we=we,
        view: (Wello we) {
        return thisExpanded(
          isColumnOrListView: isNotFatherListView,
          child:
        thisContainer(
        isDark: isDark,
        theme: theme,
        isBorder: isBorder,
        child:  Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment:  getAlignMainAxis(align),
                      children: [
                        if(leading!=null)
                          BuildThemeIconText.all(
                          getChild: getLeading,
                          isIconText: true,
                          size: size,
                          child: leading,),

                        if(leading!=null && (title!=null || subtitle!=null))const SizedBox(width: 10),

                        if(title!=null || subtitle!=null)
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
                  if(settings!=null)
                    Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      for(var item in settings??[])
                        BuildThemeIconText.all(
                          child: item,
                          isIconText: true,
                          size: size,
                        ),
                      for(int cGetSetting=0; cGetSetting<lengthGetSetting;cGetSetting++)
                        BuildThemeIconText.all(
                          getChild: (t,i){ return getSettings!.call(t,i)[cGetSetting]; },
                          isIconText: true,
                          size: size,
                        ),
                    ],
                  ),
                ],
              ),
              if(children!=null && isExpandedChildren)
                thisColumnOrListView(
                      isColumnOrListView: isChildrenColumnOrListView,
                      theme: theme,
                      isDark: isDark,
                      children: children??[],
                  ),
            ],
        ),
            )
        );}
      );
  }

  Widget thisContainer({
    required ThemeData theme,
    required bool isDark,
    required Widget child,
    required bool isBorder,
    double? height,
    EdgeInsetsGeometry margin=const EdgeInsets.all(8),
    EdgeInsetsGeometry padding=const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
  })
  {
    return Container(
      height: height,
      margin: margin,
      padding: padding ,
      decoration: !isBorder?null:BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha:isDark ? 0.3 : 0.7),//theme.colorScheme.surfaceContainerHighest.withValues(alpha:isDark ? 0.3 : 0.7),
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
      child: child,
    )
        ;
  }

  Widget thisExpanded({required bool isColumnOrListView, required Widget child})
  {
    if(isColumnOrListView) return Expanded(child: child);
    else return child;
  }

  Widget thisColumnOrListView({required ThemeData theme, required bool isDark,required bool isColumnOrListView, required List<Widget> children})
  {
    if(isColumnOrListView) {
      return thisContainer(
          theme: theme,
          isDark: isDark,
          isBorder: true,
          height: heightChildren,
          margin: const EdgeInsetsGeometry.all(0),
          padding: const EdgeInsetsGeometry.all(10),
          child: Column(
            children: children??[],
          )
      );
    }
    else {
      return
      thisContainer(
      theme: theme,
      isDark: isDark,
          isBorder: true,
          height: heightChildrenGet,
  margin: const EdgeInsetsGeometry.all(0),
  padding: const EdgeInsetsGeometry.all(10),
  child: ListView(
  children: children??[],
  )
  );
    }
  }



}

class IconExpandedList extends StatelessWidget
{
  IconExpandedList({super.key,required this.icon,this.iconOff,this.onPressed});

  IconData icon;
  IconData? iconOff;

  bool isOnOff=true;

  Function()? onPressed;
  Function() onPressedInternal=(){};

  @override
  Widget build(BuildContext context) {
    return Wello(view: (we){
      return IconButton(onPressed: (){onPressedInternal(); isOnOff=!isOnOff;  onPressed?.call(); we.setStateWello(); } , icon: Icon(isOnOff?icon:(iconOff??icon)) );
    });
  }

}