import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';

class IngredientsPictureWidget extends StatefulWidget {
  final Image image;
  final List<TextElement> textElements;

  IngredientsPictureWidget(
    this.image,
    this.textElements,
  );

  @override
  _IngredientsPictureWidget createState() => _IngredientsPictureWidget();
}

class _IngredientsPictureWidget extends State<IngredientsPictureWidget> {
  ImageInfo _imageInfo;
  ImageStream _imageStream;

  @override
  Widget build(BuildContext context) {
    var image = Image(
      image: widget.image.image,
    );

    /// check if [ImageInfo] already loaded
    if (_imageInfo == null) {
      print('ImageInfo not yet ready ... using placeholder');
      return image;
    }

    var ingredientsPainter = CustomPaint(
      foregroundPainter: new IngredientsPainter(
        textElements: widget.textElements,
        imageInfo: _imageInfo,
      ),
      child: image,
    );

    var container = Center(
      child: Container(
        child: ingredientsPainter,
        alignment: AlignmentDirectional(0.0, 0.0),
      ),
    );

    return container;
  }

  @override
  void didChangeDependencies() {
    _resolveImage();
    super.didChangeDependencies();
  }

  @override
  void reassemble() {
    _resolveImage(); // in case the image cache was flushed
    super.reassemble();
  }

  /// resolve [ImageInfo]
  void _resolveImage() {
    if (!mounted) {
      return;
    }
    _imageStream =
        widget.image.image.resolve(createLocalImageConfiguration(context));
    _imageStream.addListener(ImageStreamListener((imageInfo, _) {
      print("image loaded: $imageInfo");
      setState(() {
        _imageInfo = imageInfo;
      });
    }));
  }
}

/// A [CustomPainter] which draws [TextElement]s
class IngredientsPainter extends CustomPainter {
  final ImageInfo imageInfo;
  final List<TextElement> textElements;

  IngredientsPainter({
    this.textElements,
    this.imageInfo,
  });

  /// Paint a rectangle around each ingredient
  @override
  void paint(Canvas canvas, Size size) {
    if (imageInfo == null) {
      print('ImageInfo not yet ready');
      return;
    }

    var aspectRatio = imageInfo.image.height / imageInfo.image.width;
    print("aspect ratio: $aspectRatio");
    print("image info: $imageInfo");
    print("image width: ${imageInfo.image.width}");
    print("image height: ${imageInfo.image.height}");
    print("width: ${size.width}");
    print("height: ${size.height}");

    var scaleX = imageInfo.image.width / size.width;
    var scaleY = imageInfo.image.height / size.height;
    print("scaleX: $scaleX");
    print("scaleY: $scaleY");

    textElements.forEach((TextElement textElement) {
      Paint complete2 = new Paint()
        ..color = Colors.red
        ..strokeCap = StrokeCap.square
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;

      var rect = textElement.boundingBox;
      print('"${textElement.text}" @$rect');

      canvas.drawRect(
          Rect.fromLTRB(rect.left / scaleX, rect.top / scaleY,
              rect.right / scaleX, rect.bottom / scaleY),
          complete2);
    });
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
