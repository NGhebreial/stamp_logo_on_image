import 'package:flutter/material.dart';

///For flutter widgets that can be used in different parts of the main file
class WidgetUtils {

  ///Floating button (used on the bottom)
  Positioned createButton(Function onPressed, tooltip, Widget icon, EdgeInsets padding, {double radius: 26.0}){
    return new Positioned(
      top: padding.top,
      bottom: padding.bottom,
      left: padding.left,
      //right: padding.right,
      child: new CircleAvatar(
        radius: radius,
        child:
        FloatingActionButton(
          elevation: 6.0,
          onPressed: onPressed,
          tooltip: tooltip,
          child: icon,
        ),
      ),
    );
  }

  ///For the boxes to select the position of the logo
  Positioned createDragTarget(double width, double height,
      Offset position, String positionLogo,
      Function toExecute, Widget containerDecoration){

    var heightBoxes = height * 0.5;
    var widthBoxes = width* 0.5;
    var bColorG = Colors.blueGrey.withOpacity(0.6);
    var bColorB = Colors.blue.withOpacity(0.6);

    return new Positioned(
        left: position.dx,
        top: position.dy,
        width: widthBoxes,
        height: heightBoxes,
        child:
        new DragTarget(
          builder: (BuildContext context, accepted, rejects){

            return
              new InkWell(

                onTap: () => toExecute(positionLogo),

                child: new Container(
                  width: widthBoxes,
                  height: heightBoxes,
                  alignment: Alignment.center,
                  decoration: new BoxDecoration(
                      color: accepted.isEmpty?
                      bColorG : bColorB,
                      border: new Border.all(
                          width: accepted.isEmpty? 0.0: 2.0,
                          color:
                          accepted.isEmpty ? Colors.grey : Colors.blue[300])),

                  child: containerDecoration,
                ),
              );
          },
          onWillAccept: (data){
            return true;
          },
          onAccept: (data) => toExecute(positionLogo),
        )
    );
  }

}