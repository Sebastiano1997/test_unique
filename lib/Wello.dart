
import 'package:flutter/material.dart';


// < IW >

class Wello extends StatefulWidget{
  Wello({super.key, required Widget Function(Wello) this.view, this.id, this.father,Function(Wello)? this.builder})
  {
    print("dsa");
  }
  Wello.Model({super.key, Function(Wello)? this.builder,required Widget child, /*required  Wello? weOut,*/ this.id, this.father})
  {
    view=(we){ return child;};
    //builder=(we){weOut=we;}; // pass by value language of dart
  }

  // static
  static Wello iwGranFather=Wello(view: (iw){
    return Container();
  },);

  // --------------request and setting
  Widget? child;
  Function setStateWello=(){};
  Function(Wello)? builder;
  late Widget Function(Wello)  view;
  String? id;
  Wello? father;

  bool _bCallBuilder=false;

  // --------------use
  BuildContext? context;

  // -------------properties



  // ---------------- other function

  List<Wello> _listWeChildren=[];
  List<Map> _listMap=[]; // map generica usate

  List<String> _listID=[]; // lista dei tag dei iw figli
  List<String> get listID{
    return _listID;
  }

  Map<String,List<Wello>> mapReview={}; // map per fare la review di più iw per argomento


  // ---------------funzioni

  Wello getWe(String? id)
  {
    Wello? iw;
    if(getListWe(id: id,bFirst: true).isNotEmpty) {
      iw=getListWe(id: id,bFirst: true).first;
    } else {
      iw=null;
    }

    if(iw==null)
    {
      print("Errore getw==null");
      return Wello(view:(iw){return Container();},father: null);
    }
    else
    {
      return iw;
    }
  }

  List<Wello> getListWe({String? id,bool bFirst=false})
  {
    List<Wello> xliw=[];

    for(int i=0;i<_listWeChildren.length;i++)
    {
      if(id!=null)
      {
        if(_listWeChildren[i].id==id)
        {
          xliw.add(_listWeChildren[i]);
          if(bFirst) {
            return xliw;
          }
        }
        else
        {
          _find(id,_listWeChildren[i]._listWeChildren, xliw,bFirst);
        }
      }
      else
      {
        xliw.add(_listWeChildren[i]);
        _find(id,_listWeChildren[i]._listWeChildren, xliw,false);
      }

    }

    return xliw;
  }

  void _find(String? clas,List<Wello> kliw,List<Wello> xliw,bool bFirst) {
    for (int i = 0; i < kliw.length; i++)
    {
      if (kliw[i].id == clas)
      {
        xliw.add(kliw[i]);

        if(bFirst) {
          break;
        }
      }
      else
      {
        _find(clas,kliw[i]._listWeChildren, xliw,bFirst);
      }
    }
  }

  // map

  T? getMapElement<T>(String key,{bool index_value =false})
  {
    List<Map<dynamic,dynamic>> lm=_listMap;
    for(int i=0;lm.length>i;i++)
    {
      if(lm[i].keys.first==key) {

        if(index_value) {
          return i as T?;
        }

        return lm[i].values.first ;

      }
    }
    return null;
  }

  T? setMapElement<T>(String key,{ dynamic update,double updateSum=0,bool bIsetState=false})
  {
    List<Map<dynamic,dynamic>> lm=_listMap;
    Function fBisetstate=(){ if(bIsetState) {setStateWello();}};

    for(int i=0;lm.length>i;i++)
    {
      if(lm[i].keys.contains(key)) {

        if(updateSum!=0)
        {
          lm[i][key]=(lm[i][key]+updateSum);
          fBisetstate();
          return lm[i][key] ;
        }

        if(true) // update
            {
          lm[i][key]=update ;
          fBisetstate();
          return  true as T?;
        }

      }
    }

    if(updateSum==0) // se ci serve l'update
        {
      lm.add({key:update as T});
      fBisetstate();
      return  true as T?;
    }
    return null;
  }

  // review

  T getReview<T>(T valueReturn,String key,Wello we)
  {
    if(mapReview[key] !=null)
    {
      mapReview[key]!.contains(we)?() : mapReview[key]!.add(we);
    }
    else{
      List<Wello> liw1=[we];
      mapReview[key]=liw1;
    }
    return valueReturn;
  }

  void setReview(String key,Function set)
  {
    set();

    if(mapReview[key] !=null)
    {
      mapReview[key]!.forEach((element) {
        element.setStateWello();
      });
    }


  }

  void setStateWelloAll(){
    builder!(this);
    setStateWello();
  }

  // print

  void printListKey({String word=""})
  {
    List<String> lsClassCut=[];
    if(word!="")
    {
      word=word.toUpperCase();
      for(String value in _listID)
      {
        String valueUpper=value.toUpperCase();
        if(valueUpper.contains(word) || word.contains(valueUpper)) {
          lsClassCut.add(value);
        }
      }}else {
      lsClassCut=_listID;
    }
    print("lsClas==$lsClassCut");
  }

  // create state
  @override
  _Wello createState() => _Wello();

}

class _Wello extends State<Wello> {


  // function

  void mainState(){

    if(widget.builder!=null) {
      widget.builder!(widget);
    }


    widget.father=widget.father??Wello.iwGranFather;

    widget.father!._listWeChildren.add(widget);

    if(widget.id!=null && !widget.father!.listID.contains(widget.id))
    {
      widget.father!.listID.add(widget.id!);
    }
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    //mainState();
  }

  @override
  void initState() {
    super.initState();
    // Il widget è stato inserito nell'albero widget

  }


  @override
  Widget build(BuildContext context) {
    if(!widget._bCallBuilder )
    {
      mainState();
      widget._bCallBuilder=true;
    }

    widget.child=widget.view(widget);
    widget.setStateWello=({bool bChildren=false}){
      if(mounted) {
        if(bChildren)
        {
          for(Wello iw in widget._listWeChildren)
          {
            for(Wello iw in widget._listWeChildren)
            {
              iw.setStateWello(bChildren:bChildren);
            }
          }
        }

        setState(() {});
      }
    };
    widget.context=context;

    return widget.child!;
  }

}

// </ IW >