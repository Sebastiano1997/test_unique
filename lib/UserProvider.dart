import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'dart:math';





void main() {

  runApp(

      MultiProvider(
          providers:
          [
            ChangeNotifierProvider(create:  (context) => UserProvider(),),
          ],

          child:MyApp()

      )

  );

}



class MyApp extends StatelessWidget {

  MyApp({super.key});



  int getRandom()

  {

    return Random().nextInt(101)+10000;

  }



  @override

  Widget build(BuildContext context) {

    UserProvider userProvider=Provider.of<UserProvider>(context);



    return MaterialApp(

      debugShowCheckedModeBanner: false,

      home: Scaffold(

        body: Center(

            child:Column(

                children:[

                  Text('Hello, World!'),



                  Consumer<UserProvider>(builder: (context, user,_) => Text(user.name+" ${user.area1}")),



                  TextButton(onPressed:(){

                    userProvider.name+="b";

                  },child:Text("click")),



                  TextButton(onPressed:(){

                    userProvider.notify1();

                    userProvider.area2=getRandom();

                  },child:Text("click1")),



                  TextButton(onPressed:(){

                    userProvider.notify2();

                  },child:Text("click2")),



                  TextButton(onPressed:(){

                    userProvider.name+="c";

                    context.watch<UserProvider>().name;

                  },child:Text("click notify")),



                  TextButton(onPressed:(){

                    userProvider.x1++;

                  },child:Text("click11")),







                  Selector<UserProvider, int>(

                    selector: (context, data) => data.area1,

                    builder: (context, nameValue, child) {

                      return Text("Nome: ${userProvider.name} $nameValue ${userProvider.x1}");

                    },

                  ),

                  Selector<UserProvider, int>(

                    selector: (context, data) => data.area2,

                    builder: (context, nameValue, child) {

                      return Text("Nome: ${userProvider.name} $nameValue");

                    },

                  ),

                  Container(

                      height:300,

                      child:

                      ListView(

                          children:[

                            for(int c=0; c<getRandom();c++)

                              Text("$c"),

                          ])

                  )



                ])

        ),

      ),

    );

  }

}





class UserProvider with ChangeNotifier

{

  int area1=0;



  void notify1()

  {

    area1++;

    notifyListeners();

  }

  int area2=0;



  void notify2()

  {

    area2++;

    notifyListeners();

  }



  String _name="a";

  String get name=>_name;

  set name(v){

    _name=v;

    notifyListeners();

  }



  int x1=0;

  int x2=0;

}