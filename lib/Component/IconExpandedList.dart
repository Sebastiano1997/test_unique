
import 'package:flutter/material.dart';
import '../Wello.dart';

class IconExpandedList extends StatelessWidget
{
  IconExpandedList({
    super.key,
    IconData? icon,
    IconData? iconOff,
    this.onPressed,
    this.isOnOff=true})
  {
    this.icon=icon??Icons.arrow_drop_up;
    this.iconOff=iconOff??icon??Icons.arrow_drop_down;
  }

  late IconData icon;
  late IconData iconOff;
  //late bool? isOnOffOrDefault;

  bool isOnOff;

  bool? Function()? onPressed;
  Function(bool) onPressedInternal=(i){};

  void callPressInternal()
  {
    onPressedInternal(isOnOff);
  }

  @override
  Widget build(BuildContext context) {
    return Wello(view: (we){
      return IconButton(onPressed: (){
        isOnOff=!isOnOff;
        isOnOff=onPressed?.call()??isOnOff;
        onPressedInternal(isOnOff);
        we.setStateWello();
        } , icon: Icon(isOnOff?icon:iconOff) );
    });
  }

}
