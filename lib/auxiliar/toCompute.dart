import 'dart:collection';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:image/image.dart' as im;

import 'imageSave.dart';

///Auxiliary file that has the methods we will compute in another thread

///Calls the method decode image on imageUtils
im.Image decodeImage(File file) {
  return im.decodeImage(file.readAsBytesSync());
}

///Decode the logos to return the image
HashMap<String, im.Image> loadFixedLogos(
    HashMap<String, ByteData> byteDataLogos) {
  HashMap<String, im.Image> finalLogos = new HashMap();

  byteDataLogos.forEach((String logo, ByteData value) {
    finalLogos[logo] = new ImageSave().decodeImage(value, size: 400);
  });

  return finalLogos;
}

HashMap<String, im.Image> loadUserLogos(Directory _logosDirectory) {
  HashMap<String, im.Image> _finalLogos = new HashMap();
  List<FileSystemEntity> logos = _logosDirectory.listSync();

  for (FileSystemEntity logo in logos) {
    File logoFile = logo as File;
    if (!logoFile.path.contains(".nomedia")) {
      _finalLogos[logoFile.path] = decodeImage(logoFile);
    }
  }

  return _finalLogos;
}

///Draw the logo on the image in the position selected and return the
///file and the image
List<Object> drawLogoOnImage(List<Object> args) {
  im.Image finalImage = args[0];
  im.Image logo = args[1];
  int dstX = args[2];
  int dstY = args[3];
  String path = args[4];

  im.Image finalIm =
      im.drawImage(finalImage, logo, srcX: 0, srcY: 0, dstX: dstX, dstY: dstY);

  List<int> png = im.encodeJpg(finalIm);

  List<Object> returnObjects = new List();

  returnObjects.add(new File(path)..writeAsBytesSync(png));
  returnObjects.add(finalIm);

  return returnObjects;
}

///Delete the images on the temporary folder
bool deleteImagesTemporaryFolder(List<String> imagesPath) {
  print("Deleting on temporary folder... " + imagesPath.length.toString());
  for (int i = 1; i < imagesPath.length; i++) {
    new File(imagesPath[i]).delete();
  }
  return true;
}

///Delete the images on a folder
bool deleteImages(List<String> imagesPath) {
  print("Deleting... " + imagesPath.length.toString());
  for (int i = 0; i < imagesPath.length; i++) {
    print(imagesPath[i] + " " + i.toString());
    new File(imagesPath[i]).delete();
  }
  return true;
}

///Delete the temporary folder
bool deleteTemporal(String temporalDir) {
  new Directory(temporalDir).exists().then((bool exists) {
    if (exists) new Directory(temporalDir).deleteSync(recursive: true);
  });

  return true;
}

///Rotate the image and return the file
File rotateImage(List<Object> args) {
  im.Image image = args[0];
  double angleDeg = args[1];
  String path = args[2];
  image = im.copyRotate(image, angleDeg);
  List<int> png = im.encodeJpg(image);
  return new File(path)..writeAsBytesSync(png);
}

///In case the temporal dir exists delete it.
///For iOS there is no way to ask for that permission
///Get the directory for logos
void createDirectories(Directory dir) {
  String temporalDir = "/Pictures/LogoOnImageTemporal";
  String logosDir = "/Pictures/LogoOnImageLogos";
  String picturesDir = "/Pictures/LogoOnImagePictures";

  String pathTemporal = dir.path + temporalDir;
  String pathLogos = dir.path + logosDir;
  String pathPictures = dir.path + picturesDir;
  //Delete temporal to clean it
  deleteTemporal(pathTemporal);
  //Create temporal and logos
  new Directory(pathTemporal).createSync(recursive: true);
  new Directory(pathLogos).createSync(recursive: true);
  new Directory(pathPictures).createSync(recursive: true);
  File(pathTemporal + '/' + '.nomedia')..writeAsStringSync('');
  File(pathLogos + '/' + '.nomedia')..writeAsStringSync('');
}

///Save the image in the gallery
File saveImage2(List<Object> objects) {
  File file = objects[0];
  Directory dir = objects[1];

  var now = new DateTime.now()
      .toUtc()
      .toString()
      .replaceAll(" ", "_")
      .replaceAll("Z", "");
  im.Image image = im.decodeImage(file.readAsBytesSync());

  File f = new File(dir.path + "/Pictures/LogoOnImagePictures/" + now + ".png")
    ..writeAsBytesSync(im.encodePng(image));

  return f;
}
