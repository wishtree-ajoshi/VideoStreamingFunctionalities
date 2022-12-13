import 'dart:io';
import 'package:demo_app/methods/image_picker.dart';
import 'package:demo_app/methods/request_permissions.dart';
import 'package:demo_app/widgets/reusable_widgets.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class UploadFile extends StatefulWidget {
  const UploadFile({super.key});

  @override
  State<UploadFile> createState() => _UploadFileState();
}

class _UploadFileState extends State<UploadFile> {
  File? image;
  String? imageUrl;

  showErrorDialog({required bool isCamera}) async {
    return showDialog(
      context: context,
      builder: (context) => popUpWidget(
          title: (isCamera)
              ? "Camera permission is denied.. Please enable permissions in settings."
              : "Gallery or Storage permission is denied.. Please enable permissions in settings.",
          onCancelPressed: () {
            Navigator.pop(context);
          },
          onOkPressed: () {
            Navigator.pop(context);
            openAppSettings();
          },
          leftButtonTitle: "Cancel",
          rightButtonTitle: "Go to settings"),
    );
  }

  uploadImageFromCamera() async {
    imageUrl = await ImageSelector().pickImageCamera(imageUrl, image);
    print("///////////// ${imageUrl}");
    if (imageUrl == '') {
      return;
    }
    final croppedFile = await ImageSelector().cropImage(imageUrl);
    if (croppedFile != null) {
      final File newImage = File(croppedFile.path);
      if (mounted) {
        setState(() {
          image = newImage;
        });
      }
    }
  }

  uploadImageFromGallery() async {
    imageUrl = await ImageSelector().pickImageGallery(imageUrl, image);
    print("*/*/*/*/*/*/  $imageUrl");
    if (imageUrl == '') {
      return;
    }
    final croppedFile = await ImageSelector().cropImage(imageUrl);
    if (croppedFile != null) {
      final File newImage = File(croppedFile.path);
      if (mounted) {
        setState(() {
          image = newImage;
        });
      }
    }
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
                child: (image == null)
                    ? Image.asset(
                        "assets/noImage.png",
                      )
                    : Image.file(
                        image!,
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
                  showErrorDialog(isCamera: true);
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
                  showErrorDialog(isCamera: false);
                }
              },
              color: Colors.orange,
              child: const Text(
                "Upload from Gallery",
                style: TextStyle(color: Colors.white),
              ),
            ),
            // MaterialButton(
            //   onPressed: () async {
            //     await RequestPermissions().checkPermission(Permission.storage);
            //   },
            //   color: Colors.orange,
            //   child: const Text(
            //     "Upload File",
            //     style: TextStyle(color: Colors.white),
            //   ),
            // ),
          ],
        )),
      ),
    );
  }
}
