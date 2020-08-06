import 'dart:async';
import 'dart:io';

import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart' as pathProvider;
import 'image.dart';
import 'paint.dart';

bool useFlutterImageCompress = true;
bool keepExif = true;
bool autoCorrectionAngle = true;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String exif = "";
  // get image from camera
  File imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
  print("doFixOrientation: $useFlutterImageCompress");

  exif = await readExif(imageFile.readAsBytesSync());
  print(exif);
  if (useFlutterImageCompress) {
    String imagePathFixed =
        await fixOrientation(imageFile.path, "exifCorrection");
    print("fixed: $imagePathFixed");
    exif = await readExif(File(imagePathFixed).readAsBytesSync());
    print(exif);
    imageFile = File(imagePathFixed);
  }

  FirebaseVisionImage image = FirebaseVisionImage.fromFile(imageFile);
  TextRecognizer textRecognizer = FirebaseVision.instance.cloudTextRecognizer();

  // print text
  String text = "";
  List<TextElement> textElements = [];
  VisionText visionText = await textRecognizer.processImage(image);
  for (TextBlock block in visionText.blocks) {
    for (TextLine line in block.lines) {
      for (TextElement element in line.elements) {
        text += " ${element.text}";
        textElements.add(element);
      }
    }
  }

  Image imageFixed = Image.memory(imageFile.readAsBytesSync());

  // show text
  runApp(OCRDisplay(text, exif, textElements, imageFixed));
}

class OCRDisplay extends StatelessWidget {
  final String text;
  final String exif;
  final List<TextElement> textElements;
  final Image image;

  const OCRDisplay(this.text, this.exif, this.textElements, this.image,
      {Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Flutter Meetup Demo'),
        ),
        body: IngredientsPictureWidget(
          image,
          textElements,
        ),
      ),
    );
  }
}

Future<String> fixOrientation(String inFile, String fileName) async {
  Directory directory = await pathProvider.getTemporaryDirectory();
  List<int> imageDataCompressed =
      await compressAndRotateImage(File(inFile).readAsBytesSync(), 90);
  String imageForOCR = '${directory.path}/$fileName.jpg';
  await File(imageForOCR).writeAsBytes(imageDataCompressed);

  return imageForOCR;
}

Future<List<int>> compressAndRotateImage(List<int> image, int quality) async {
  print('compressing image');

  List<int> imageDataCompressed = await FlutterImageCompress.compressWithList(
    image,
    quality: quality,
    autoCorrectionAngle: autoCorrectionAngle,
    keepExif: keepExif,
  );

  return imageDataCompressed;
}
