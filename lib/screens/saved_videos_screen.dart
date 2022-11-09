import 'dart:io';
import 'package:demo_app/methods/encryption_decryption.dart';
import 'package:demo_app/screens/main_page.dart';
import 'package:demo_app/methods/database.dart';
import 'package:flutter/material.dart';

class SavedVideos extends StatefulWidget {
  SavedVideos({super.key, required this.id});
  int id;
  @override
  State<SavedVideos> createState() => _SavedVideosState();
}

class _SavedVideosState extends State<SavedVideos> {
  @override
  void initState() {
    getData();
    super.initState();
  }

  Map data = {};

  deleteVideo(index) async {
    if (await File("${data[index]}").exists()) {
      await File("${data[index]}").delete();
    }
    await HiveDb.deleteDataAt(index);
    data = await HiveDb.getVideoList();
    widget.id = widget.id - 1;
    print(widget.id);
    if (mounted) {
      setState(() {});
    }
  }

  getData() async {
    data = await HiveDb.getVideoList();
    if (mounted) {
      setState(() {});
    }
  }

  onTilePressed({
    required int index,
  }) async {
    if (await File(data[index]).exists()) {
      File file = await EncryptionDecryption().decryptFile(data[index]);
      print("***********${file.path}");

      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainPage(
              videoList: data,
              filePath: file.path,
              offline: true,
            ),
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    print("------$data");
    print("*-*-*-*-*-${widget.id}");
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Saved Videos"),
          centerTitle: true,
        ),
        body: (data.isNotEmpty)
            ? ListView.builder(
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: (data.isEmpty) ? 0 : data.length,
                itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.all(2),
                      child: ListTile(
                        trailing: IconButton(
                            onPressed: () async {
                              await deleteVideo(index);
                            },
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.black,
                            )),
                        shape: Border.all(width: 0.7, color: Colors.black),
                        tileColor: Colors.redAccent,
                        onTap: () {
                          onTilePressed(index: index);
                        },
                        title: Text(
                            "${data[index]}".substring(60).split(".mp4").first),
                      ),
                    ))
            : const Center(
                child: Text(
                  "No videos saved",
                ),
              ),
      ),
    );
  }
}
