import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:PetDex/data/enums/species.dart';

class CustomMarkerHelper {
  static Future<BitmapDescriptor> createAnimalPinMarker({
    required Species species,
    String? imageUrl,
  }) async {
    try {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final paint = Paint()..isAntiAlias = true;

      const double markerSize = 80;
      const double borderWidth = 6.0;
      const Color pinColor = Color(0xFFF39200);

      canvas.drawCircle(
        const Offset(markerSize / 2, markerSize / 2),
        markerSize / 2,
        paint..color = pinColor,
      );

      canvas.drawCircle(
        const Offset(markerSize / 2, markerSize / 2),
        (markerSize / 2) - borderWidth,
        paint..color = Colors.white,
      );

      final picture = recorder.endRecording();
      final img = await picture.toImage(markerSize.toInt(), markerSize.toInt());
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      final uint8List = byteData!.buffer.asUint8List();

      return BitmapDescriptor.bytes(uint8List);
    } catch (e) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
    }
  }
}
