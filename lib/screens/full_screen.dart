import 'dart:async';

import 'package:demo_app/widgets/reusable_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class FullScreen extends StatefulWidget {
  const FullScreen({super.key, required this.controller});
  final VideoPlayerController controller;
  @override
  State<FullScreen> createState() => _FullScreenState();
}

class _FullScreenState extends State<FullScreen> {
  Timer? timer; //Timer for changing visibility of overlay
  bool isVisible = true;

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    super.initState();
  }

  ///Function to hide overlay automatically
  visibilityOnOff() {
    timer?.cancel();
    if (mounted) {
      setState(() {
        isVisible = true;
      });
    }
    timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) {
        setState(() {
          isVisible = false;
          timer?.cancel();
        });
      }
    });
  }

  ///Function to play or pause the video...
  playPause() {
    if (mounted) {
      setState(() {
        widget.controller.value.isPlaying
            ? widget.controller.pause()
            : widget.controller.play();
      });
    }
  }

  ///Function to skip 10s backwards...
  onBackward10() {
    if (mounted) {
      setState(() {
        visibilityOnOff();
        widget.controller.seekTo(
          Duration(seconds: widget.controller.value.position.inSeconds - 10),
        );
      });
    }
  }

  ///Function to skip 10s forward...
  onForward10() {
    if (mounted) {
      setState(() {
        visibilityOnOff();
        widget.controller.seekTo(
          Duration(seconds: widget.controller.value.position.inSeconds + 10),
        );
      });
    }
  }

  ///Navigate to a full screen page for video player...
  onFullScreen() {
    if (mounted) {
      Navigator.pop(context);
    }
  }

  ///Function to convert the duration of video...
  String videoDuration(Duration duration) {
    String hh(int n) => n.toString().padLeft(2, "0");
    String mm = hh(duration.inMinutes.remainder(60));
    String ss = hh(duration.inSeconds.remainder(60));
    if (hh(duration.inHours) == "00") {
      return "$mm:$ss";
    } else {
      return "${hh(duration.inHours)}:$mm:$ss";
    }
  }

  @override
  dispose() {
    super.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          visibilityOnOff();
        },
        child: AspectRatio(
          aspectRatio: MediaQuery.of(context).size.aspectRatio,
          child: Stack(
            children: [
              VideoPlayer(widget.controller),

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
                      ///Duration of elapsed video to total video..
                      ValueListenableBuilder(
                        valueListenable: widget.controller,
                        builder: (context, VideoPlayerValue value, child) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "${videoDuration(widget.controller.value.position)}/${videoDuration(widget.controller.value.duration)}",
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ),
                          );
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: VideoProgressIndicator(
                          widget.controller, //video player controller
                          allowScrubbing: true,
                          colors: const VideoProgressColors(
                            //video player progress bar
                            backgroundColor: Colors.black26,
                            playedColor: Colors.red,
                            bufferedColor: Colors.grey,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          videoPlayerButtons(
                              onButtonTap: () {
                                visibilityOnOff();
                                onBackward10();
                              },
                              iconStyle: Icons.replay_10_rounded),
                          videoPlayerButtons(
                              onButtonTap: () {
                                visibilityOnOff();
                                playPause();
                              },
                              iconStyle: (widget.controller.value.isPlaying)
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded),
                          videoPlayerButtons(
                              onButtonTap: () {
                                visibilityOnOff();
                                onForward10();
                              },
                              iconStyle: Icons.forward_10_rounded),
                          videoPlayerButtons(
                              onButtonTap: () {
                                onFullScreen();
                              },
                              iconStyle: Icons.fullscreen_rounded),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
