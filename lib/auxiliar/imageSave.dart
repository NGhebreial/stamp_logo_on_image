import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:image_picker_saver/image_picker_saver.dart';
import 'package:image/image.dart' as im;
import 'package:uuid/uuid.dart';

///This class is to separate some functionality we need for the image treatment
class ImageSave {
  ///Makes the decode of an image and resize it
  im.Image decodeImage(ByteData byteData, {int size: 400}) {
    var _imageDecode = im.decodeImage(byteData.buffer.asUint8List());
    _imageDecode = im.copyResize(_imageDecode, size);

    return _imageDecode;
  }

  Future<String> saveImage(File image) async {
    var now = new DateTime.now()
        .toUtc()
        .toString()
        .replaceAll(" ", "_")
        .replaceAll("Z", "");

    if (Platform.isAndroid) {
      return await ImagePickerSaver.saveFile(
          fileData: image.readAsBytesSync(),
          title: "LogoOnImage_" + now + ".png",
          description: "LogoOnImage_" + now + ".png",
          directory: "LogoOnImagePictures");
    } else {
      return await ImagePickerSaver.saveFile(fileData: image.readAsBytesSync());
    }
  }

  ///Save the image in the temporary folder
  Future<File> saveImageTemporal(File image, String temporalDir) async {
    temporalDir = await _createTemporalPath(temporalDir);

    var file = File('$temporalDir/' + _generateUuidJpg().toString())
      ..writeAsBytesSync(image.readAsBytesSync());

    File('$temporalDir/' + '.nomedia')..writeAsStringSync('');

    print('saving... ' + file.path);
    return file;
  }

  ///Create the temporal folder if it doesn't exists
  Future<String> _createTemporalPath(String temporalDir) async {
    Directory dirFinal;
    var sdCard;
    if (Platform.isAndroid) {
      sdCard = await getExternalStorageDirectory();
    } else {
      sdCard = await getApplicationDocumentsDirectory();
    }
    dirFinal =
        await new Directory(sdCard.path + temporalDir).create(recursive: true);

    return dirFinal.path;
  }

  File saveLogo(File image, String logosDir) {
    var file = File('$logosDir/' + _generateUuidJpg().toString())
      ..writeAsBytesSync(image.readAsBytesSync());

    print('saving logo... ' + file.path);
    return file;
  }

  ///The name of the image to save
  String _generateUuidJpg() {
    Uuid _uuid = new Uuid();
    return _uuid.v1().toString() + ".jpg";
  }
}
