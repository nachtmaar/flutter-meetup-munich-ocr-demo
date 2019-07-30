import 'package:exif/exif.dart';

Future<String> readExif(List<int> image) async {
  String exifInfo = "";
  Map<String, IfdTag> exif = await readExifFromBytes(image);

  if (exif == null || exif.isEmpty) {
    print("No EXIF information found");
  } else {
    print("Found EXIF information");
    // http://sylvana.net/jpegcrop/exif_orientation.html
    exif.forEach((key, value) {
      print("$key => $value");
    });
    exifInfo += "Image Orientation: ${exif["Image Orientation"]}\n";
    exifInfo += "EXIF ExifImageWidth: ${exif["EXIF ExifImageWidth"]}\n";
    exifInfo += "EXIF ExifImageLength: ${exif["EXIF ExifImageLength"]}\n";
  }
  return exifInfo;
}
