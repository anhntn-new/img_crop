import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
   XFile? _image;
   int? _width;
   int? _height;
  CroppedFile? imageCrop;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 0.8 * screenWidth,
                maxHeight: 0.8 * screenHeight,
              ),
              child: _image  != null ? Image.file(
                File(_image?.path ?? ''),
              ) : const Text('pls chosse file'),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                _cropImage();
              },
              child: Container(
                width:  0.3 * screenWidth,
                height: 0.1 * screenWidth ,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.blueAccent,
                      width: 2,
                    )),
                child: const Text(
                  'Crop Image',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
            const SizedBox(height: 20),
            imageCrop != null ?
                Text('width : ${_width} x  height: ${_height}'): SizedBox(),
            const SizedBox(height: 10),

            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 0.7 * screenWidth,
                maxHeight: 0.5 * screenHeight,
              ),
              child: imageCrop != null
                  ? Image.file(
                      File(imageCrop?.path ??''),
                    )
                  : Icon(
                      Icons.camera_alt_outlined,
                      size: 0.9 * screenWidth,
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _initGallery,
            child: const Icon(Icons.image),
          ),
          const SizedBox(height: 30),
          FloatingActionButton(
            onPressed: _initCamera,
            child: const Icon(Icons.camera_alt_outlined),
          ),
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }


  void _initGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      var decodedImage = await decodeImageFromList(await image.readAsBytes());
      print('Image: ${decodedImage.width} - ${decodedImage.height}');
      setState(() {
        _image = image;

      });
    }
  }

  void _initCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);

    if (photo != null) {
      var decodedImage = await decodeImageFromList(await photo.readAsBytes());
      print('Image: ${decodedImage.width} - ${decodedImage.height}');
      setState(() {
        _image = photo;
      });
    }
  }

  Future<void> _cropImage() async {
    if (_image != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: _image!.path ,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 100,
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'Cropper',
              toolbarColor: Colors.deepOrange,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
          IOSUiSettings(
            title: 'Cropper',
          ),
          WebUiSettings(
            context: context,
            presentStyle: CropperPresentStyle.dialog,
            boundary: const CroppieBoundary(
              width: 520,
              height: 520,
            ),
            viewPort:
            const CroppieViewPort(width: 480, height: 480, type: 'circle'),
            enableExif: true,
            enableZoom: true,
            showZoomer: true,
          ),
        ],
      );
      if (croppedFile != null) {
        var decodedImage = await decodeImageFromList(await croppedFile.readAsBytes());
        print('Image: ${decodedImage.width} - ${decodedImage.height}');
        setState(() {
          imageCrop = croppedFile;
          _width = decodedImage.width;
          _height = decodedImage.height;
        });
      }
    }
  }
}
