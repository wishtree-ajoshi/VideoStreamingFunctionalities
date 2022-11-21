import 'dart:io';

import 'package:demo_app/methods/image_picker.dart';
import 'package:demo_app/methods/request_permissions.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class UploadFile extends StatefulWidget {
  const UploadFile({super.key});

  @override
  State<UploadFile> createState() => _UploadFileState();
}

class _UploadFileState extends State<UploadFile> {
  File? _image;
  String? imageUrl;

  uploadImageFromCamera() async {
    imageUrl = await ImageSelector().pickImageCamera(imageUrl, _image);
    if (imageUrl == null) {
      if (_image == null) {
        return;
      } else {
        imageUrl = _image!.path;
      }
    }
    final File newImage = File(imageUrl!);
    setState(() {
      _image = newImage;
    });
  }

  uploadImageFromGallery() async {
    imageUrl = await ImageSelector().pickImageGallery(imageUrl, _image);
    if (imageUrl == null) {
      if (_image == null) {
        return;
      } else {
        imageUrl = _image!.path;
      }
    }
    final File newImage = File(imageUrl!);
    setState(() {
      _image = newImage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.blueGrey,
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipOval(
              child: CircleAvatar(
                radius: 70,
                backgroundColor: Colors.orangeAccent,
                child: (_image == null)
                    ? Image.asset(
                        "assets/noImage.png",
                      )
                    : Image.file(
                        _image!,
                        width: 140,
                        fit: BoxFit.fitWidth,
                      ),
              ),
            ),
            MaterialButton(
              onPressed: () async {
                if (await RequestPermissions()
                    .checkPermission(Permission.camera)) {
                  print("checking permissions");
                  uploadImageFromCamera();
                } else {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return const AlertDialog(
                        title: Text("Camera permission not granted"),
                      );
                    },
                  );
                }
              },
              color: Colors.orange,
              child: const Text(
                "Upload from Camera",
                style: TextStyle(color: Colors.white),
              ),
            ),
            MaterialButton(
              onPressed: () async {
                if (await RequestPermissions()
                    .checkPermission(Permission.storage)) {
                  uploadImageFromGallery();
                } else {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return const AlertDialog(
                        title: Text("Storage access permission not granted"),
                      );
                    },
                  );
                }
              },
              color: Colors.orange,
              child: const Text(
                "Upload from Gallery",
                style: TextStyle(color: Colors.white),
              ),
            ),
            MaterialButton(
              onPressed: () async {
                await RequestPermissions().checkPermission(Permission.storage);
              },
              color: Colors.orange,
              child: const Text(
                "Upload File",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        )),
      ),
    );
  }
}
