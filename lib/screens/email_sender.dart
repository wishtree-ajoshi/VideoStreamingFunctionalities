import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class EmailSender extends StatefulWidget {
  const EmailSender(
      {Key? key,
      required this.pdf,
      required this.subject,
      required this.recipient,
      required this.body})
      : super(key: key);
  final pdf;
  final String subject;
  final String recipient;
  final String body;
  @override
  _EmailSenderState createState() => _EmailSenderState();
}

class _EmailSenderState extends State<EmailSender> {
  List<String> attachments = [];
  bool isHTML = false;

  TextEditingController recipientController = TextEditingController();

  TextEditingController subjectController = TextEditingController();

  TextEditingController bodyController = TextEditingController();

  Future<void> send() async {
    final Email email = Email(
      body: bodyController.text,
      subject: subjectController.text,
      recipients: [recipientController.text],
      attachmentPaths: attachments,
      isHTML: isHTML,
    );

    String platformResponse;

    try {
      await FlutterEmailSender.send(email);
      platformResponse = 'success';
    } catch (error) {
      print(error);
      platformResponse = error.toString();
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(platformResponse),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    subjectController = TextEditingController(text: widget.subject);
    recipientController = TextEditingController(text: widget.recipient);
    bodyController = TextEditingController(text: widget.body);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Email'),
        actions: [
          IconButton(
            onPressed: send,
            icon: const Icon(Icons.send),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: recipientController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Recipient',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: subjectController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Subject',
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: bodyController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: const InputDecoration(
                      labelText: 'Body', border: OutlineInputBorder()),
                ),
              ),
            ),
            CheckboxListTile(
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 0.0, horizontal: 8.0),
              title: const Text('HTML'),
              onChanged: (bool? value) {
                if (value != null) {
                  if (mounted) {
                    setState(() {
                      isHTML = value;
                    });
                  }
                }
              },
              value: isHTML,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: <Widget>[
                  for (var i = 0; i < attachments.length; i++)
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            attachments[i],
                            softWrap: false,
                            overflow: TextOverflow.fade,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove_circle),
                          onPressed: () => {_removeAttachment(i)},
                        )
                      ],
                    ),
                  // Align(
                  //   alignment: Alignment.centerRight,
                  //   child: IconButton(
                  //     icon: const Icon(Icons.attach_file),
                  //     onPressed: _openImagePicker,
                  //   ),
                  // ),
                  TextButton(
                    child: const Text('Attach file in app documents directory'),
                    onPressed: () => _attachFileFromAppDocumentsDirectoy(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openImagePicker() async {
    final picker = ImagePicker();
    final pick = await picker.pickImage(source: ImageSource.gallery);
    if (pick != null) {
      if (mounted) {
        setState(() {
          attachments.add(pick.path);
        });
      }
    }
  }

  void _removeAttachment(int index) {
    if (mounted) {
      setState(() {
        attachments.removeAt(index);
      });
    }
  }

  Future<void> _attachFileFromAppDocumentsDirectoy() async {
    try {
      if (mounted) {
        setState(() {
          attachments.add(widget.pdf);
        });
      }
    } catch (e) {
      print("$e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to create file in application directory'),
        ),
      );
    }
  }
}
