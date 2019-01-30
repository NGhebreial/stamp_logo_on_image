import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as im;
import 'toCompute.dart';

class MyModalBottomSheet extends StatefulWidget {

  MyModalBottomSheet({
    this.height,
    this.width,
    this.context,
    this.logos,
    this.setStateLogo,
    this.uploadLogo,
  });

  double height;
  double width;
  BuildContext context;
  HashMap<String, im.Image> logos;
  Function setStateLogo;
  Function uploadLogo;

  @override
  MyModalBottomSheetState createState() => new MyModalBottomSheetState();
}

class MyModalBottomSheetState extends State<MyModalBottomSheet> {

  bool showDelete = false;
  List<String> selectedDelete;

  Widget loadContainer() {

    Widget text = new Text("Upload your own logos",
      style: TextStyle(fontSize: 23.0, fontWeight: FontWeight.w700,
        color: Colors.blueGrey, ),
      textAlign: TextAlign.center,);

    var heightContainer = widget.height * 0.3;
    var _widthScreen = widget.width;
    var _heightScreen = widget.height;
    var _logos = widget.logos;

    return new Container(
      color: Colors.white70,
      height: heightContainer,
      child: new Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          //Title
          new Positioned(
            left: _widthScreen * 0.02,
            top: heightContainer * 0.05,
            child:
            new Container(
                width: _widthScreen ,
                height: _heightScreen * 0.15,
                child:
                new Text("Your logos", style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w700, ), textAlign: TextAlign.center,)

            ),
          ),

          new Container(
            padding: EdgeInsets.only(right: 10.0, bottom: 125.0),
            child: new Divider(height: heightContainer , color: Colors.black12, indent: 6.0, ),
          ),

          new Positioned(
            top: _logos.length > 0?  heightContainer * 0.2: heightContainer * 0.4,
            child:
            new Container(
              width: _widthScreen ,
              height: _heightScreen * 0.15,
              child: _logos.length > 0?
              new ListCards(
                height: _heightScreen,
                context: widget.context,
                listLogos: _logos,
                setStateLogo: widget.setStateLogo,
                delete: true,
                inDeleteMode: showDeleteButton,
                listToDelete: syncListToDelete,
              ): text,
            ),
          ),


          //Upload picture
          bottomButton(),
        ],
      ),
    );
  }

  Widget bottomButton(){
    var heightContainer = widget.height * 0.5;
    return showDelete?
    new Positioned(
        bottom: heightContainer * 0.01,
        child:
        new FloatingActionButton(
            highlightElevation: 0.0,
            elevation: 0.0,
            child: new Icon(Icons.delete),
            backgroundColor: Colors.red,
            onPressed: (){
              _showDialog();
            }
        )
    ):
    new Positioned(
        bottom: heightContainer * 0.01,
        child:
        new FloatingActionButton(
            highlightElevation: 0.0,
            elevation: 0.0,
            child: new Icon(Icons.file_upload),
            backgroundColor: Color.fromRGBO(112, 217, 224, 1.0),
            onPressed: (){
              widget.uploadLogo().then((HashMap<String, im.Image> newUserLogos){
                setState(() {
                  widget.logos = newUserLogos;
                });
              });

            }
        )
    );
  }

  void _showDialog() {
    // flutter defined function
    showDialog(
      context: widget.context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Delete logos?"),
          content: new Text("Are you sure you want to delete the selected logos?"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new FlatButton(
              child: new Text("Accept"),
              onPressed: () {
                compute(deleteImages, selectedDelete).then((bool deleted) {
                  widget.logos.removeWhere((name, bytes) => selectedDelete.contains(name));
                  selectedDelete.clear();

                  setState(() {
                    showDeleteButton(false);
                    Navigator.of(context).pop();
                  });

                });
              },
            ),
          ],
        );
      },
    );
  }

  void showDeleteButton(bool showDelete){
    setState(() {
      this.showDelete = showDelete;
    });

  }

  void syncListToDelete(List<String> toDelete){
    selectedDelete = toDelete;
  }

  @override
  Widget build(BuildContext context) {
    return loadContainer();
  }

}

class ListCards extends StatefulWidget {

  ListCards({
    this.height,
    this.context,
    this.listLogos,
    this.setStateLogo,
    this.delete,
    this.inDeleteMode,
    this.listToDelete,
  });

  double height;
  BuildContext context;
  HashMap<String, im.Image> listLogos;
  Function setStateLogo;
  bool delete;
  Function inDeleteMode;
  Function listToDelete;

  @override
  _ListCardsState createState() => new _ListCardsState();
}

class _ListCardsState extends State<ListCards> {

  List<String> selectedDelete = new List();

  List<Widget> loadLogos() {
    List<Widget> logos = new List();
    widget.listLogos.forEach((String name, im.Image image){
      logos.add(
          new Container(
            color: selectedDelete.contains(name)?
            Colors.blue: Colors.transparent,
            margin: EdgeInsets.only(right: 5.0),
            child:
            new Card(
              elevation: 2.0,
              color: Color.fromRGBO(238, 239, 240, 1.0),
              child: new InkWell(
                child: new Image.asset(
                  name,
                  width: (widget.height * 0.5 ) / 3,
                  fit: BoxFit.fitWidth,
                ),

                onTap: () {

                  if(selectedDelete.length > 0){
                    _setStateSelectedDelete(name);
                  }
                  else{
                    Navigator.pop(widget.context);
                    widget.setStateLogo(name);
                  }

                },
                onLongPress: () {
                  if( widget.delete ){
                    _setStateSelectedDelete(name);
                  }
                },
              ),
            ),
          )
      );
    });
    return logos;
  }

  void _setStateSelectedDelete(String name){
    setState(() {
      selectedDelete.contains(name)? selectedDelete.remove(name):
      selectedDelete.add(name);
    });

    selectedDelete.length > 0? widget.inDeleteMode(true):
    widget.inDeleteMode(false);

    widget.listToDelete(selectedDelete);
  }

  @override
  Widget build(BuildContext context) {
    return
      new ListView(
        children: loadLogos(),
        scrollDirection: Axis.horizontal,
      );
  }

}