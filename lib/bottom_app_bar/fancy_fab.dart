import 'package:flutter/material.dart';

class FancyFab extends StatefulWidget {
  final List<Function> onTapChildren;
  final Widget middleButton;

  FancyFab(this.onTapChildren, this.middleButton);

  @override
  _FancyFabState createState() => _FancyFabState();
}

class _FancyFabState extends State<FancyFab>
    with SingleTickerProviderStateMixin {
  bool isOpened = false;
  AnimationController _animationController;
  Animation<Color> _buttonColor;
  Icon _icon;
  Animation<double> _translateButton;
  Curve _curve = Curves.easeOut;
  double _fabHeight = 56.0;

  @override
  initState() {
    _icon = new Icon(
      Icons.add,
    );

    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500))
          ..addListener(() {
            setState(() {});
          });

    _buttonColor = ColorTween(
      begin: Color.fromRGBO(112, 217, 224, 1.0),
      end: Colors.red,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.00,
        1.00,
        curve: Curves.elasticInOut,
      ),
    ));
    _translateButton = Tween<double>(
      begin: _fabHeight,
      end: -14.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.0,
        0.75,
        curve: _curve,
      ),
    ));

    super.initState();
  }

  @override
  dispose() {
    _animationController.dispose();
    super.dispose();
  }

  animate() {
    if (!isOpened) {
      _animationController.forward().whenComplete(() {
        _icon = new Icon(Icons.close, color: Colors.white);
      });
    } else {
      _animationController.reverse().whenComplete(() {
        _icon = new Icon(Icons.add);
      });
    }
    isOpened = !isOpened;
  }

  Widget takePicture() {
    return Container(
      padding: EdgeInsets.only(top: 20.0, bottom: 7.0),
      height: 70.0,
      width: 56.0,
      child: FloatingActionButton(
        elevation: 0.0,
        highlightElevation: 0.0,
        backgroundColor: Color.fromRGBO(112, 217, 224, 1.0),
        onPressed: () {
          widget.onTapChildren[0]();
          animate();
        },
        tooltip: 'Take new picture',
        child: Icon(Icons.add_a_photo),
      ),
    );
  }

  Widget uploadPicture() {
    return Container(
      padding: EdgeInsets.only(top: 10.0, bottom: 7.0),
      height: 60.0,
      width: 56.0,
      child: FloatingActionButton(
        elevation: 0.0,
        highlightElevation: 0.0,
        backgroundColor: Color.fromRGBO(112, 217, 224, 1.0),
        onPressed: () {
          widget.onTapChildren[1]();
          animate();
        },
        tooltip: 'Upload new picture',
        child: Icon(Icons.file_upload),
      ),
    );
  }

  Widget toggle() {
    return Container(
      padding: EdgeInsets.only(bottom: 5.0),
      //margin: EdgeInsets.only(bottom: 1.0),
      height: 55.0,
      width: 56.0,
      //alignment: FractionalOffset.topCenter,
      child: widget.middleButton == null
          ? FloatingActionButton(
              elevation: 0.0,
              highlightElevation: 0.0,
              backgroundColor: _buttonColor.value,
              onPressed: animate,
              tooltip: 'Add new picture',
              child: _icon,
            )
          : widget.middleButton,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Transform(
          transform: Matrix4.translationValues(
            0.0,
            _translateButton.value * 2.0,
            0.0,
          ),
          child: takePicture(),
        ),
        Transform(
          transform: Matrix4.translationValues(
            0.0,
            _translateButton.value,
            0.0,
          ),
          child: uploadPicture(),
        ),
        toggle(),
      ],
    );
  }
}
