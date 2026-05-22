
import 'package:flutter/material.dart';

import '../Wello.dart';

class IconExpandedList extends StatelessWidget
{
  IconExpandedList({super.key, IconData? icon,IconData? iconOff,this.onPressed})
  {
    this.icon=icon??Icons.arrow_drop_up;
    this.iconOff=iconOff??icon??Icons.arrow_drop_down;
  }

  late IconData icon;
  late IconData iconOff;

  bool isOnOff=true;

  Function()? onPressed;
  Function() onPressedInternal=(){};

  @override
  Widget build(BuildContext context) {
    return Wello(view: (we){
      return IconButton(onPressed: (){onPressedInternal(); isOnOff=!isOnOff;  onPressed?.call(); we.setStateWello(); } , icon: Icon(isOnOff?icon:iconOff) );
    });
  }

}
