import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DocViewer extends StatefulWidget {
  const DocViewer({super.key});

  @override
  State<DocViewer> createState() => _DocViewerState();
}

class _DocViewerState extends State<DocViewer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Document Viewer"),
      ),
      body: const WebView(
        initialUrl:
            "https://docs.google.com/presentation/d/17u8ZMgYQBFeHWh1Cnn4XjlWLUi7Ca2O7_04B6HphWWY/edit#slide=id.p1",
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}
