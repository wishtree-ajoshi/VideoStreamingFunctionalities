import 'dart:async';
import 'dart:io';
import 'package:demo_app/full_screen.dart';
import 'package:demo_app/methods/download_video.dart';
import 'package:demo_app/methods/store_video.dart';
import 'package:demo_app/saved_videos.dart';
import 'package:demo_app/methods/database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class MainPage extends StatefulWidget {
  MainPage({super.key, required this.videoList});
  Map videoList;
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late VideoPlayerController controller;
  bool isVisible = true;
  int id = 0;
  Timer? timer;
  bool loading = false;
  double progress = 0;
  String url =
      'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4';

  downloadFile() async {
    setState(() {
      loading = true;
      progress = 0;
    });
    // saveVideo will download and save file to Device and will return a boolean
    // for if the file is successfully or not
    bool downloaded = await StoreVideo().saveVideo(
      url: url,
      fileName: "Video_${(id == 0) ? 1 : id}.mp4",
      id: id,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        width: 200,
        backgroundColor: Colors.red.withOpacity(0.7),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(50))),
        content: Text(
          (downloaded) ? "File Downloaded" : "Error Downloading File",
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );

    widget.videoList = await HiveDb.getVideoList();
    print("/////////${widget.videoList}");
    setState(() {
      loading = false;
    });
  }

  onClearAll() async {
    for (int i = 0; i < widget.videoList.length; i++) {
      File("${widget.videoList[i]}.path").delete();
    }
    await HiveDb.deleteData();
    widget.videoList = await HiveDb.getVideoList();
    print("*********${widget.videoList}");
  }

  ///Function to hide iverlay automatically
  visibilityOnOff() {
    timer?.cancel();
    setState(() {
      isVisible = true;
    });
    timer = Timer.periodic(const Duration(seconds: 3), (_) {
      setState(() {
        isVisible = false;
        timer?.cancel();
      });
    });
  }

  @override
  void initState() {
    controller = VideoPlayerController.network(url)
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
    id = (widget.videoList.isEmpty) ? 0 : widget.videoList.length;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => DownloadVideo(),
      child: Scaffold(
        appBar: AppBar(title: const Text("Video Streaming")),
        body: (controller.value.isInitialized)
            ? SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Center(
                  child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: Column(children: [
                        GestureDetector(
                          onTap: (() {
                            visibilityOnOff();
                          }),
                          child: AspectRatio(
                            aspectRatio: controller.value.aspectRatio,
                            child: Stack(children: [
                              VideoPlayer(controller),

                              ///Hide overlay after few seconds...
                              Visibility(
                                visible: isVisible,

                                ///Stick overlay to bottom of video player...
                                child: Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: VideoProgressIndicator(
                                          controller, //video player controller
                                          allowScrubbing: true,
                                          colors: const VideoProgressColors(
                                            //video player progress bar
                                            backgroundColor: Colors.black12,
                                            playedColor: Colors.red,
                                            bufferedColor: Colors.grey,
                                          ),
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          videoPlayerButtons(
                                              onButtonTap: () {
                                                setState(() {
                                                  visibilityOnOff();
                                                  controller.seekTo(
                                                    Duration(
                                                        seconds: controller
                                                                .value
                                                                .position
                                                                .inSeconds -
                                                            10),
                                                  );
                                                });
                                              },
                                              iconStyle:
                                                  Icons.replay_10_rounded),
                                          const SizedBox(
                                            width: 30,
                                          ),
                                          videoPlayerButtons(
                                              onButtonTap: () {
                                                visibilityOnOff();
                                                setState(() {
                                                  controller.value.isPlaying
                                                      ? controller.pause()
                                                      : controller.play();
                                                });
                                              },
                                              iconStyle: (controller
                                                      .value.isPlaying)
                                                  ? Icons.pause_rounded
                                                  : Icons.play_arrow_rounded),
                                          const SizedBox(
                                            width: 30,
                                          ),
                                          videoPlayerButtons(
                                              onButtonTap: () {
                                                visibilityOnOff();
                                                setState(() {
                                                  controller.seekTo(
                                                    Duration(
                                                        seconds: controller
                                                                .value
                                                                .position
                                                                .inSeconds +
                                                            10),
                                                  );
                                                });
                                              },
                                              iconStyle:
                                                  Icons.forward_10_rounded),
                                          const SizedBox(
                                            width: 30,
                                          ),
                                          videoPlayerButtons(
                                              onButtonTap: () {
                                                setState(() {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          FullScreen(
                                                              controller:
                                                                  controller),
                                                    ),
                                                  );
                                                });
                                              },
                                              iconStyle:
                                                  Icons.fullscreen_rounded),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ]),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(
                                size: 35,
                                Icons.download_rounded,
                                color: Colors.red,
                              ),
                              color: Colors.blue,
                              onPressed: downloadFile,
                              padding: const EdgeInsets.all(10),
                            ),
                            MaterialButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        SavedVideos(data: widget.videoList),
                                  ),
                                );
                              },
                              color: Colors.red,
                              child: const Text(
                                "Saved Videos",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            IconButton(
                              onPressed: () async {
                                await onClearAll();
                              },
                              icon: const Icon(Icons.clear_all_rounded),
                            ),
                          ],
                        ),
                        loading
                            ? Consumer(
                                builder: (BuildContext context, value,
                                        Widget? child) =>
                                    Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: LinearProgressIndicator(
                                    minHeight: 10,
                                    value: progress,
                                  ),
                                ),
                              )
                            : const SizedBox(),
                      ])),
                ),
              )
            : const Center(
                child: Text("Please check your internet connection")),
      ),
    );
  }
}

Widget videoPlayerButtons(
    {required Function() onButtonTap, required iconStyle}) {
  return IconButton(
    onPressed: () {
      onButtonTap();
    },
    icon: Icon(iconStyle),
    iconSize: 35,
    color: Colors.white.withOpacity(0.8),
  );
}
