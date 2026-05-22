// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:isolate';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

import 'package:vibration/vibration.dart';

import 'AlarmManagerExampleApp.dart';
import 'Component/ComponentE.dart';
import 'Component/IconExpandedList.dart';
import 'Component/ListViewE.dart';
import 'LineNumberedTextField.dart';
import 'ReorderableListPage.dart';
import 'StyledWordController.dart';
import 'Wello.dart';

/// The [SharedPreferences] key to access the alarm fire count.
const String countKey = 'count';

/// The name associated with the UI isolate's [SendPort].
const String isolateName = 'isolate';

/// A port used to communicate from a background isolate to the UI isolate.
ReceivePort port = ReceivePort();

/// Global [SharedPreferences] object.
SharedPreferences? prefs;

Future<void> main() async {

  Brightness brightness=Brightness.dark;

  ColorScheme colorScheme=ColorScheme.fromSeed(seedColor: Colors.purple,brightness: brightness);

  runApp(
    MaterialApp(
      theme: ThemeData(
        brightness: brightness,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green,brightness: brightness),
      ),
      home: Scaffold(
      body: Container(
        child: ListViewE(
          children: [
            /*
          ComponentE(
            title: Text("+02:10"),
            subtitle: Text("Work done!"),
            leading: Icon(Icons.timer),
            size: SizeE.large,
            children: [
              ComponentE(
                title: Text("aaaaa"),
                isBorder: false,
              ),
              ComponentE(
                title: Text("aaaaa"),
                size: SizeE.small,
              ),
              ComponentE(
                title: Text("Title"),
                children: [
                  ComponentE(
                    leading: Icon(Icons.add_circle),
                    title: Text("07:10"),isBorder: false,)
                ],
              )
            ],
          ),
            */
            /*
            ComponentE2(
              title: Text("Title"),
              leading: Icon(Icons.search_off),
              subtitle: Text("subtitle"),
              settings: [Icon(Icons.settings)],
              size: SizeE.large,
              children: [
                ComponentE2(
                  title: Text("a"),isBorder: false,
                  children: [
                    Text("b"),Text("b"),Text("b"),Text("b"),Text("b"),Text("b"),Text("b"),Text("b"),Text("b"),Text("b"),Text("b"),Text("b"),Text("b"),Text("b"),Text("b"),Text("b"),Text("b"),Text("b"),Text("b"),
                  ],
                ),
                ComponentE2(
                  title: Text("a2"),isBorder: false,size: SizeE.small,
                ),
                Text("a"),
                Text("a"),
                Text("a"),
                Text("a"),
                Text("a"),
                Text("a"),
                Text("a"),
                Text("a"),
                Text("a"),
                Text("a"),
                Text("a"),
                Text("a"),
                Text("a"),
                Text("a"),
                Text("a"),
                Text("a"),
                Text("a"),
                Text("a"),
                Text("a"),
                Text("a"),
                Text("a"),
                Text("a"),
                Text("a"),
                Text("a"),
                Text("a"),
                Text("a"),
                Text("a"),
                Text("a"),
                Text("a"),
                Text("a"),
                Text("a"),
                Text("a"),
                Text("a"),
              ],
            ),
            ComponentE2(
              title: Text("Title2"),
              leading: IconButton(onPressed: (){}, icon: Icon(Icons.send_and_archive)),
              subtitle: Text("subtitle2"),
              size: SizeE.medium,
              settings: [Icon(Icons.security)],
            ),
            ComponentE(title: Text("Page1"),),
             */
            ComponentE3(
              getTitle:(c,t,i)=> TextButton(onPressed: (){}, child: Text("Click here!",style: t,)),
              subtitle: Text("for work!"),
              leading: Icon(Icons.work_history),
              align: AlignE.center,
              size: SizeE.large,
              isBorder: false,
            ),
            ComponentE3(
              color: Colors.red,
              title: Text("+02:16",),
              getTitle: (c,t,i)=>Text("+02:15",style: t,),
              subtitle: Text("work done!"),
              leading: Icon(Icons.timer_outlined),
              settings:[ Icon(Icons.watch_later_outlined),Text("/08:45")],
              size: SizeE.large,
              align: AlignE.center,
              children: [
                ComponentE3(
                  color: Colors.red,
                  title: Text("-03:15"),
                  subtitle: Text("work to do!"),
                  leading: Icon(Icons.timer),
                  size: SizeE.medium,
                  align: AlignE.right,
                  isBorder: false,
                  isNotFatherListView: false,
                ),
                ComponentE3(
                  color: Colors.red,
                  title: Text("00:00"),
                  subtitle: Text("time personal!"),
                  leading: Icon(Icons.timer),
                  size: SizeE.small,
                  align: AlignE.left,
                  isBorder: false,
                  isNotFatherListView: false,
                ),
              ],
            ),
            ComponentE3(
              //color: Colors.blue.withValues(alpha: 0.1),
              title: Text("Settings"),
              leading: Icon(Icons.settings),
              size: SizeE.large,
              align: AlignE.left,
              settings: [IconExpandedList()],
              children: [
                ComponentE3(
                  title: Text("08:25"),
                  subtitle: Text("start work!"),
                  leading: Icon(Icons.work_history_outlined),
                  settings: [IconButton(onPressed: (){}, icon: Icon(Icons.edit))],
                  size: SizeE.small,
                  align: AlignE.left,
                  isBorder: false,
                ),
                ComponentE3(
                  title: Text("17:35"),
                  subtitle: Text("end work!"),
                  leading: Icon(Icons.work_history),
                  settings: [IconButton(onPressed: (){}, icon: Icon(Icons.edit))],
                  size: SizeE.small,
                  align: AlignE.left,
                  isBorder: false,
                ),
                ComponentE3(
                  title: Text("00:00"),
                  subtitle: Text("time personal today!"),
                  leading: Icon(Icons.more_time_rounded),
                  settings: [IconButton(onPressed: (){}, icon: Icon(Icons.edit))],
                  size: SizeE.medium,
                  align: AlignE.left,
                  isBorder: false,
                ),
                ComponentE3(
                  title: Text("08:45"),
                  subtitle: Text("ordinary work day!"),
                  leading: Icon(Icons.timer_sharp),
                  settings: [IconButton(onPressed: (){}, icon: Icon(Icons.edit))],
                  size: SizeE.medium,
                  align: AlignE.left,
                  isBorder: false,
                ),
              ],
            ),
            ComponentE3(
              title: Text("End"),
              subtitle: Text("End sub"),
              size: SizeE.large,),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Usa 'primary' per lo sfondo e 'onPrimary' per il testo
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Usa primary / onPrimary'),
                ),
                const SizedBox(height: 16),

                // Usa 'surfaceContainer' per lo sfondo e 'onSurface' per il testo
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Usa surfaceContainer / onSurface',
                      style: TextStyle(color: colorScheme.onSurface),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Usa 'error' per lo sfondo del badge e 'onError' per il testo interno
                const Center(
                  child: Badge(
                    label: Text('Usa error / onError'),
                    child: Icon(Icons.notifications),
                  ),
                ),
                const SizedBox(height: 16),

                // Estrazione manuale: usa 'secondary' per colorare un testo personalizzato
                Text(
                  'Testo colorato manualmente con secondary',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colorScheme.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            )


          ],),
      ),
    ),)
  );
}
Future<void> main2() async {

  /*
  WidgetsFlutterBinding.ensureInitialized();

  // Register the UI isolate's SendPort to allow for communication from the
  // background isolate.
  IsolateNameServer.registerPortWithName(
    port.sendPort,
    isolateName,
  );
  prefs = await SharedPreferences.getInstance();
  if (!prefs!.containsKey(countKey)) {
    await prefs!.setInt(countKey, 0);
  }
  */
  int x=10;
  int y=3;
  Wello2? we2;
  runApp(
      StartWidget(
      //child:LineNumberedTextEditor()
        child: Wello2(
          clas:"1",
          builder: (we){
            print("buiòder1");
          },
              (we)=>
                  Column(
                    children: [
                      TextButton(
                          onPressed: (){
                                      x++;
                                      y++;
                                      we?.setStateWello();
                                    }, child: Text("x::${x}")),
                      Wello2(
                            clas: "2",
                            builder: (we){
                              print("buiòder2");
                            },
                            (we)=>TextButton(onPressed: (){
                                      y++;
                                      we?.setStateWello();
                                    }, child: Text("y::${y}")),),

                    ],
                  ),
        )
      )
  );
}


/// + Start

class StartWidget extends StatelessWidget
{
  StartWidget({ required this.child});

  Widget child;

  @override
  Widget build(BuildContext context) {
    return
      MaterialApp(home:
      Scaffold(
        appBar: AppBar(
          title: const Text('Title'),
        ),
        body: child
    )
      );
  }

}


/// +  other


class MoveItem extends StatelessWidget
{

  List<String> items=["a","b"];
  Wello? weObj;

  void onReorder(int oldIndex, int newIndex) {

      if (oldIndex < newIndex) {
        newIndex -= 1;
      }

      final item = items.removeAt(oldIndex);
      items.insert(newIndex, item);

      weObj?.setStateWello();
  }
  @override
  Widget build(BuildContext context) {
    return
      Wello(
        builder: (we){weObj=we;},
        view: (we) { return  ReorderableListView.builder(
        itemCount: items.length,
        onReorder: onReorder,
        itemBuilder: (context, index) {
          final item = items[index];

          return ListTile(
            key: ValueKey(index), // chiave stabile = ordine corretto
            title: Text(item),
          );
        },
      ); },);

  }

}


class Wello2 extends StatefulWidget{
  Wello2( this.view,{super.key, this.clas,this.builder=null})
  {
    print("dsa2");
  }

  // static

  // --------------request and setting
  Widget? child;
  Function setStateWello=(){};
  Function(Wello2)? builder;
  late Widget Function(Wello2)  view;
  String? clas;
  Wello? father;

  bool _bCallBuilder=false;

  // --------------use
  BuildContext? context;

  // -------------properties



  // ---------------- other function



  // ---------------funzioni




  // review


  // print


  // create state
  @override
  _Wello2 createState() => _Wello2();

}

class _Wello2 extends State<Wello2> {


  // function

  void mainState(){

    if(widget.builder!=null) {
      widget.builder!(widget);
    }
    //widget.father=widget.father??Wello.iwGranFather;

  }

  @override
  void initState()
  {
    super.initState();
    mainState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    //mainState();
  }


  @override
  void didUpdateWidget(oldWidget)
  {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose()
  {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if(!widget._bCallBuilder )
    {
      mainState();
      widget._bCallBuilder=true;
    }

    widget.child=widget.view(widget);
    widget.setStateWello=(){
      if(mounted) {
        setState(() {});
      }
    };
    widget.context=context;

    return widget.child!;
  }

}

class ItemEllo<T>
{
  Wello2? we2;

  T? _item;
  T? get item{
    return _item;
  }

}

class Item
{
  String _name="";
  String get name{
    //listWe.add(we);
    return _name;
  }
  set name(v){
    _name=v;
    listWe.forEach((i)=>i.setStateWello());
  }

  List<Wello2> listWe=[];


}
