import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

class PreviewPage extends StatefulWidget {
  const PreviewPage({Key? key, required this.picture}) : super(key: key);

  final XFile picture;

  @override
  State<PreviewPage> createState() => _PreviewPageState();
}

class _PreviewPageState extends State<PreviewPage> {
  Image? croppedImage;

  @override
  void initState() {
    super.initState();
    cropImage();
  }

  Future<dynamic> cropImage() async {
    final decodedImage = await img.decodeImageFile(widget.picture.path);

    // Calculate crop coordinates
    if (decodedImage != null) {
      // Calculate crop dimensions
      final int cropWidth = decodedImage.width - 60;
      final int cropHeight = decodedImage.height ~/ 3;

      const int cropX = 30;

      final int cropY =
          (decodedImage.height - cropHeight) ~/ 2; // Center vertically

      final croppedImage = img.copyCrop(decodedImage,
          x: cropX, y: cropY, width: cropWidth, height: cropHeight);

      setState(() {
        this.croppedImage =
            Image(image: MemoryImage(img.encodeJpg(croppedImage)));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preview Page')),
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          if (croppedImage != null) // Display cropped image
            croppedImage!,
          // Image.file(
          //   File(widget.picture.path),
          //   fit: BoxFit.contain,
          //   // height: 600,
          //   width: 250,
          //   // height: MediaQuery.of(context).size.height,
          // ),
        ]),
      ),
    );
  }
}
