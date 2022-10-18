import 'package:flutter/material.dart';

class SavedVideos extends StatefulWidget {
  SavedVideos({super.key, required this.data});
  Map? data;

  @override
  State<SavedVideos> createState() => _SavedVideosState();
}

class _SavedVideosState extends State<SavedVideos> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: (widget.data != null)
            ? SingleChildScrollView(
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: (widget.data == null) ? 0 : widget.data?.length,
                    itemBuilder: (context, index) => ListTile(
                          title: Text("${widget.data?['id']}"),
                        )),
              )
            : const Text(
                "No videos saved",
              ),
      ),
    );
  }
}
