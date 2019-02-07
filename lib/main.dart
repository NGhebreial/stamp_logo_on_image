import 'dart:collection';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart' as imP;
import 'package:flutter/services.dart';

import 'package:image/image.dart' as im;
import 'package:path_provider/path_provider.dart';
import 'package:simple_permissions/simple_permissions.dart';
import 'package:photo_view/photo_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_share_content/flutter_share_content.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';

import 'bottom_app_bar/fab_bottom_app_bar.dart';
import 'bottom_app_bar/fancy_fab.dart';

import 'auxiliar/imageSave.dart';
import 'auxiliar/widgetUtils.dart';
import 'auxiliar/toCompute.dart';
import 'auxiliar/modalBottomSheet.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: "Logo on image",
      debugShowCheckedModeBanner: false,
      home: CameraUpload(),
    );
  }
}

class _LogoOnImage extends State<CameraUpload> {
  // Variables to save the current image data
  File _imageFile;
  im.Image _image;

  //Reference to the context necessary for some widgets
  BuildContext _context;

  im.Image _logo;

  /*Widgets used in the app*/

  //This widget is to update the main part of the app
  //and show loading widget or the picture widget
  Widget _bodyWidget;

  //Main widget which shows the picture loaded
  Widget _imageWidget;

  //If the process take a lot of time we show
  //a loading window instead of the image
  Widget _loadingWidget;

  //Show the screen to choose the position of the logo
  Widget _positionLogoWidget;

  //To save the width and height of the phone screen
  double _widthScreen;
  double _heightScreen;

  //With this variable we will know if there is any logo selected
  //to show the positionLogoWidget or not
  String _logoSelected = "";

  //The directory which is going to be saved the temporary images
  //Is easier to have them saved and eventually erase them
  String _temporalDir = "/Pictures/LogoOnImageTemporal";

  //List of the paths of every image that is saved on the temporal dir
  List<String> _savedImagesPaths = new List();

  //Used like the context, necessary in some widgets
  final _key = new GlobalKey<ScaffoldState>();

  HashMap<String, im.Image> _userLogos = new HashMap();

  String _logosDir = "/Pictures/LogoOnImageLogos";

  //Angles for the rotation of the image
  double _angleRad = 0.0;

  double _angleDeg = 0.0;

  HashMap<String, bool> selectedDelete = new HashMap();

  bool saving = false;

  Color _backButtonColor;

  Directory _dir;

  AppBar _appBar;

  FABBottomAppBar _bottomBar;

  FancyFab _bottomButton;

  /// Create the widget to show the logo with the possibles positions
  /// It will show the widget only if there is any logo selected
  void _onLogoDragWidget() {
    var widthLogo = _widthScreen * 0.3;
    var heightLogo = _heightScreen * 0.1;

    _bottomBar = _logoSelected != ""
        ? FABBottomAppBar(
            backgroundColor: Colors.white,
            selectedColor: new Color.fromRGBO(40, 68, 86, 1.0),
            notchedShape: CircularNotchedRectangle(),
            items: [],
          )
        : _fullFabBottomAppBar();

    var appBarHeight = _appBar.preferredSize.height;
    var appBottomBarHeight = _bottomBar.height;

    _positionLogoWidget = _logoSelected != ""
        ? new Stack(
            fit: StackFit.expand,
            alignment: Alignment.bottomCenter,
            children: <Widget>[
              /// These four are the boxes to select the position
              new WidgetUtils().createDragTarget(
                  _widthScreen,
                  _heightScreen - appBottomBarHeight - appBarHeight,
                  new Offset(0.0, 0.0),
                  "TL",
                  _showLogoOnImage,
                  new Text(
                    "Show in Top Left",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                        color: Colors.white),
                  )),

              new WidgetUtils().createDragTarget(
                  _widthScreen,
                  _heightScreen - appBottomBarHeight - appBarHeight,
                  new Offset(_widthScreen * 0.5, 0.0),
                  "TR",
                  _showLogoOnImage,
                  new Text(
                    "Show in Top Right",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                        color: Colors.white),
                  )),

              new WidgetUtils().createDragTarget(
                  _widthScreen,
                  _heightScreen - appBottomBarHeight - appBarHeight,
                  new Offset(0.0, (_heightScreen * 0.5) - appBottomBarHeight),
                  "BL",
                  _showLogoOnImage,
                  new Text(
                    "Show in Bottom Left",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                        color: Colors.white),
                  )),

              new WidgetUtils().createDragTarget(
                  _widthScreen,
                  _heightScreen - appBottomBarHeight - appBarHeight,
                  new Offset(_widthScreen * 0.5,
                      (_heightScreen * 0.5) - appBottomBarHeight),
                  "BR",
                  _showLogoOnImage,
                  new Text(
                    "Show in Bottom Right",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                        color: Colors.white),
                  )),

              ///This is the logo that will be showed in the middle of the screen
              new Positioned(
                  left: (_widthScreen * 0.5) - widthLogo / 2,
                  top: (_heightScreen * 0.5) -
                      appBottomBarHeight -
                      (heightLogo / 2),
                  child: new Container(
                    width: widthLogo,
                    height: heightLogo,
                    child: new Draggable(
                        child: new Container(
                            width: widthLogo,
                            height: heightLogo,
                            child: Card(
                              color: Color.fromRGBO(255, 255, 255, 0.5),
                              child: new Image.asset(
                                _logoSelected,
                              ),
                            )),
                        feedback: new Container(
                          width: widthLogo,
                          height: heightLogo,
                          child: Card(
                            color: Color.fromRGBO(255, 255, 255, 0.5),
                            child: new Image.asset(
                              _logoSelected,
                            ),
                          ),
                        )),
                  )),
            ],
          )
        : new Container(width: 0.0, height: 0.0);

    _bottomButton = _logoSelected != ""
        ? FancyFab(
            [],
            new DragTarget(
              builder: (BuildContext context, accepted, rejects) {
                return new InkWell(
                  child: new Container(
                    alignment: Alignment.center,
                    decoration: new BoxDecoration(
                        shape: BoxShape.circle,
                        color: accepted.isEmpty ? Colors.red : Colors.red[100],
                        border: new Border.all(
                            width: accepted.isEmpty ? 0.0 : 2.0,
                            color: accepted.isEmpty
                                ? Colors.red[100]
                                : Colors.red)),
                    child: new Icon(
                      Icons.delete,
                      color: accepted.isEmpty ? Colors.white : Colors.black,
                    ),
                  ),
                  onTap: () {
                    _logoSelected = "";
                    _setStateImage();
                  },
                );
              },
              onWillAccept: (data) {
                return true;
              },
              onAccept: (data) {
                _logoSelected = "";
                _setStateImage();
              },
            ))
        : FancyFab([getImageCamera, getImageFile], null);
  }

  ///To set the widgets every time that we set the state
  void _setWidgets() {
    ///Setting the position of the logo in case there is any logo selected
    _onLogoDragWidget();

    ///Main body with the image selected and the buttons
    _imageWidget = new Stack(fit: StackFit.expand, children: <Widget>[
      _setImage(),
      _positionLogoWidget,
    ]);

    ///The loading widget that shows the loading with the image selected
    ///and the buttons in the background
    _loadingWidget = new Container(
      child: new Stack(
        fit: StackFit.expand,
        children: <Widget>[
          _setImage(),
          new Container(
            alignment: AlignmentDirectional.center,
            decoration: new BoxDecoration(
              color: Colors.white70,
            ),
            child: new Container(
              width: 300.0,
              height: 200.0,
              alignment: AlignmentDirectional.center,
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Center(
                    child: new SizedBox(
                      height: 50.0,
                      width: 50.0,
                      child: new CircularProgressIndicator(
                        value: null,
                        strokeWidth: 7.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  ///Method used by flutter when that the app is opened
  @override
  void initState() {
    _initData();
    super.initState();
  }

  ///The initialization of the variables and data necessary
  void _initData() async {
    await SimplePermissions.requestPermission(Permission.WriteExternalStorage);

    _appBar = AppBar(
      centerTitle: false,
      leading: new Image.asset("assets/icon.png", width: 35.0),
      title: Text(
        'Logo on image',
        textAlign: TextAlign.left,
      ),
      backgroundColor: Color.fromRGBO(112, 217, 224, 1.0),
      elevation: 6.0,
      actions: <Widget>[
        new IconButton(
          icon: new Icon(Icons.save),
          onPressed: _clickSaveImage,
        ),
      ],
    );

    _bottomBar = _fullFabBottomAppBar();

    ///In the beginning there is no logo selected
    _positionLogoWidget = new Container();

    _backButtonColor = Color.fromRGBO(238, 239, 240, 1.0);

    ///The widget to show in the body is the image selection
    _bodyWidget = _imageWidget;

    ///The first screen is the camera to take a picture
    //getImageCamera();
    _loadNewImage(null);

    if (Platform.isAndroid) {
      _dir = await getExternalStorageDirectory();
    } else {
      _dir = await getApplicationDocumentsDirectory();
    }

    _logosDir = _dir.path + _logosDir;
    compute(createDirectories, _dir).then((void logoDir) {
      //In the beginning we load the data of every logo
      //to make faster the posterior treatment
      _loadListLogos();
    });
  }

  /// Make the treatment of logos uploaded for the user
  void _loadListLogos() async {
    /// Loading the directory of logos uploaded for the user
    Directory _logosDirectory = new Directory(_logosDir);
    compute(loadUserLogos, _logosDirectory)
        .then((HashMap<String, im.Image> userLogos) {
      _userLogos = userLogos;
    });
  }

  ///To show the image widget when the screen is reload
  void _setStateImage() {
    setState(() {
      _setWidgets();
      _bodyWidget = _imageWidget;
    });
  }

  ///To show the loading widget when the screen is reload
  void _setStateLoading() {
    setState(() {
      _bodyWidget = _loadingWidget;
      _bottomBar = FABBottomAppBar(
        backgroundColor: Colors.white,
        selectedColor: new Color.fromRGBO(40, 68, 86, 1.0),
        notchedShape: CircularNotchedRectangle(),
        items: [],
      );
    });
  }

  /* Update the main screen:
   * - If there is no image selected, show text and the initial buttons
   * - If there is an image: preview it and show new buttons*/
  Widget _setImage() {
    if (_imageFile == null) {
      return new Center(
          child: new Text(
        'Pick image or upload from files',
        style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w700),
        textAlign: TextAlign.center,
      ));
    } else {
      return new Container(
        alignment: Alignment.center,
        height: _heightScreen * 0.5,
        width: _widthScreen * 0.5,
        child: new Transform.rotate(
          alignment: Alignment.center,
          angle: _angleRad,
          transformHitTests: false,
          child: new PhotoViewInline(
            imageProvider: new FileImage(_imageFile),
            backgroundColor: Color.fromRGBO(242, 242, 242, 1.0),
          ),
        ),
      );
    }
  }

  ///Open the camera and save the image in variable
  getImageCamera() async {
    File image = await imP.ImagePicker.pickImage(
        source: imP.ImageSource.camera, maxWidth: 2048.0);

    _loadNewImage(image);
  }

  ///Open the gallery and save the image choose in variable
  getImageFile() async {
    File image = await imP.ImagePicker.pickImage(
        source: imP.ImageSource.gallery, maxWidth: 2048.0);
    _loadNewImage(image);
  }

  ///The initialization of the variables necessary when the picture is changed
  _loadNewImage(File image) async {
    ///By default the image should be rotated
    _angleRad = 0.0;
    _angleDeg = 0.0;

    ///We need to make some heavy operations so we show the loading widget
    _setStateLoading();

    ///Deleting the temporal images
    compute(deleteImagesTemporaryFolder, _savedImagesPaths);

    _savedImagesPaths.clear();

    _imageFile = image == null && _imageFile != null ? _imageFile : image;

    if (_imageFile != null) {
      ///This is a trick. In some mobiles the image is showed rotated from the
      ///beginning, so I made some adjustment in this plugin to check if it's
      ///necessary rotate the image before show it
      _imageFile = await FlutterExifRotation.rotateImage(path: _imageFile.path);

      _savedImagesPaths.add(_imageFile.path);
      _changeColorBackButton();

      ///Is necessary decode the image to have the data. This is made in a new
      ///thread to make the app faster
      compute(decodeImage, _imageFile).then((im.Image imageDecode) {
        _image = imageDecode;

        ///Show the image selected
        _setStateImage();
      });
    } else {
      ///If there is not image selected just show the main screen
      _setStateImage();
    }
  }

  // Choose the app to share
  void _shareImage() {
    if (_image == null) {
      Fluttertoast.showToast(
          msg: "Pick an image to share",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIos: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white);
      _setStateImage();
      return;
    }

    //First of all rotate the image
    if (_angleDeg > 0) {
      _setStateLoading();
      List<Object> args = new List();
      args.add(_image);
      args.add(_angleDeg);
      args.add(_imageFile.path);

      compute(rotateImage, args).then((File file) {
        _imageFile = file;
        FlutterShareContent.shareContent(imageUrl: _imageFile.path)
            .then((void value) {
          //_toggleShareButtons();
          _setStateImage();
          new ImageSave().saveImage(_imageFile).then((String path) {
            _angleDeg = 0.0;
            _angleRad = 0.0;

            ///After save the image we clean the temporary path
            compute(deleteImagesTemporaryFolder, _savedImagesPaths);

            _savedImagesPaths.clear();

            _savedImagesPaths.add(_imageFile.path);
            _changeColorBackButton();
          });
        });
      });
    } else {
      FlutterShareContent.shareContent(imageUrl: _imageFile.path);
    }
  }

  ///Save the image in the gallery
  void _clickSaveImage() {
    if (_image == null) {
      Fluttertoast.showToast(
          msg: "Pick an image to save",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIos: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white);
      return;
    }
    //_setStateLoading();
    ///First check if the image was rotated to compute it
    if (!saving) {
      saving = true;
      _setStateLoading();

      Fluttertoast.showToast(
          msg: "Saving, wait...",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIos: 3,
          backgroundColor: Colors.blueAccent,
          textColor: Colors.white);
      if (_angleDeg > 0.0) {
        List<Object> args = new List();
        args.add(_image);
        args.add(_angleDeg);
        args.add(_imageFile.path);

        compute(rotateImage, args).then((File file) {
          _imageFile = file;
          _angleDeg = 0.0;
          _angleRad = 0.0;

          _saveImage();
        });
      }

      ///Otherwise just save it
      else {
        _saveImage();
      }
    }
  }

  void _saveImage() {
    new ImageSave().saveImage(_imageFile).then((String path) {
      _imageFile = new File(path);
      _setStateImage();

      ///After save the image we clean the temporary path
      compute(deleteImagesTemporaryFolder, _savedImagesPaths);

      _savedImagesPaths.clear();

      _savedImagesPaths.add(_imageFile.path);
      _changeColorBackButton();
      saving = false;

      ///Show a toaster message the user can tap the message to open the gallery
      Fluttertoast.showToast(
          msg: "Image saved",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIos: 1,
          backgroundColor: Colors.greenAccent,
          textColor: Colors.white);
    });
  }

  ///Load the previous picture taking it from the temporary path
  void _back() {
    ///Showing loading because the process is heavy
    int length = _savedImagesPaths.length;

    if (length >= 2) {
      _setStateLoading();
      _imageFile = new File(_savedImagesPaths[length - 2]);

      List<String> last = new List();
      last.add(_savedImagesPaths[length - 1]);

      ///Delete the last picture in the temporary folder
      compute(deleteImagesTemporaryFolder, last);

      _savedImagesPaths.removeLast();

      ///Decode the image loaded
      compute(decodeImage, _imageFile).then((im.Image imageDecode) {
        _setStateImage();
        _image = imageDecode;
      });
    }
    _changeColorBackButton();
  }

  ///Set the angles and refresh the main screen
  void _rotateImage() {
    _angleRad += 1.5708;
    _angleDeg = (_angleDeg + 90) % 360;
    _setStateImage();
  }

  ///Modal bottom sheet with the possible logos to select
  void _showPossibleLogos() {
    showModalBottomSheet(
        context: _context,
        builder: (BuildContext context) {
          return new MyModalBottomSheet(
            setStateLogo: _setStateLogo,
            uploadLogo: _uploadLogo,
            logos: _userLogos,
            context: context,
            height: _heightScreen,
            width: _widthScreen,
          );
        });
  }

  Future<HashMap<String, im.Image>> _uploadLogo() async {
    File logo = await imP.ImagePicker.pickImage(
        source: imP.ImageSource.gallery, maxWidth: 400.0);

    if (logo != null) {
      logo = new ImageSave().saveLogo(logo, _logosDir);
      im.Image imageDecode = await compute(decodeImage, logo);
      _userLogos[logo.path] = imageDecode;
    }
    return _userLogos;
  }

  ///To set the size of the logo based on the size of the selected image
  void _setStateLogo(String image) {
    _logoSelected = image;

    _logo = _userLogos[image];
    _setStateImage();

    int sizeImage = _image != null ? (_image.width / 5.12).round() : 400;

    if (sizeImage < 400) {
      _logo = im.copyResize(_logo, sizeImage);
    }
  }

  ///Once the user has selected the position and the logo, draw it in the picture
  _showLogoOnImage(positionLogo) {
    if (_image == null) {
      Fluttertoast.showToast(
          msg: "Pick an image before set the logo",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIos: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white);
      _logoSelected = "";
      _setStateImage();
      return;
    }

    ///The process is heavy, show loading widget
    _setStateLoading();

    var dstX = 0;
    var dstY = 0;

    //First check if the image is rotated
    if (_angleDeg > 0) _image = im.copyRotate(_image, _angleDeg);

    switch (positionLogo) {
      case "TR":
        dstX = _image.width - _logo.width;
        break;
      case "BL":
        dstY = _image.height - _logo.height;
        break;
      case "BR":
        dstY = _image.height - _logo.height;
        dstX = _image.width - _logo.width;
        break;
    }

    new ImageSave()
        .saveImageTemporal(_imageFile, _temporalDir)
        .then((File file) {
      _imageFile = new File(file.path);

      ///This is not nice but necessary. To compute drawing the logo on the image
      ///we need to pass all that data to the method
      List<Object> args = new List();
      args.add(_image);
      args.add(_logo);
      args.add(dstX);
      args.add(dstY);
      args.add(file.path);

      compute(drawLogoOnImage, args).then((List<Object> returnObject) {
        _imageFile = returnObject[0];
        _image = returnObject[1];

        _savedImagesPaths.add(_imageFile.path);
        _changeColorBackButton();

        ///Let's reset all the variables and the main screen
        _logoSelected = "";
        _onLogoDragWidget();
        _angleRad = 0.0;
        _angleDeg = 0.0;
        _setStateImage();
      });
    });
  }

  void _changeColorBackButton() {
    if (_savedImagesPaths.length >= 2) {
      _backButtonColor = Colors.blueGrey;
    } else {
      _backButtonColor = Color.fromRGBO(238, 239, 240, 1.0);
    }
  }

  FABBottomAppBar _fullFabBottomAppBar() {
    return FABBottomAppBar(
      backgroundColor: Colors.white,
      selectedColor: new Color.fromRGBO(40, 68, 86, 1.0),
      notchedShape: CircularNotchedRectangle(),
      items: [
        FABBottomAppBarItem(
            widgetIcon: new Icon(Icons.reply, color: _backButtonColor),
            text: '',
            tap: _back),
        FABBottomAppBarItem(
            widgetIcon: new Icon(Icons.rotate_right, color: Colors.blueGrey),
            text: '',
            tap: _rotateImage),
        FABBottomAppBarItem(
            widgetIcon: new Icon(
              Icons.share,
              color: Colors.blueGrey,
            ),
            text: '',
            tap: _shareImage),
        FABBottomAppBarItem(
            widgetIcon: new Icon(
              Icons.create,
              color: Colors.blueGrey,
            ),
            text: '',
            tap: _showPossibleLogos),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    ///Avoid rotation on the mobile
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    SystemChrome.setEnabledSystemUIOverlays([]);

    _context = context;

    _heightScreen = MediaQuery.of(context).size.height;
    _widthScreen = MediaQuery.of(context).size.width;

    return Scaffold(
      key: _key,
      // First part
      appBar: _appBar,

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      //TODO: maybe when they fix the bug..
      //floatingActionButton: _buildFab(),
      floatingActionButton: _bottomButton,

      bottomNavigationBar: _bottomBar,
      //Body
      body: _bodyWidget,

      backgroundColor: Color.fromRGBO(242, 242, 242, 1.0),
    );
  }
}

class CameraUpload extends StatefulWidget {
  @override
  _LogoOnImage createState() => new _LogoOnImage();
}
