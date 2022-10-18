import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class FullScreen extends StatefulWidget {
  const FullScreen({super.key, required this.controller});
  final VideoPlayerController controller;
  @override
  State<FullScreen> createState() => _FullScreenState();
}

class _FullScreenState extends State<FullScreen> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: () => Navigator.pop(context),
      onTap: () {
        widget.controller.value.isPlaying
            ? widget.controller.pause()
            : widget.controller.play();
      },
      child: RotatedBox(
        quarterTurns: 1,
        child: AspectRatio(
          aspectRatio: widget.controller.value.aspectRatio,
          child: VideoPlayer(widget.controller),
        ),
      ),
    );
  }
}
