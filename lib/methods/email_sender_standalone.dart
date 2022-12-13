import 'package:demo_app/widgets/reusable_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';

class SendEmail {
  send(
      {context,
      required body,
      required String subject,
      required List<String> recipients,
      required List<String> attachments,
      bool isHTML = false}) async {
    final Email email = Email(
      body: body,
      subject: subject,
      recipients: recipients,
      attachmentPaths: attachments,
      isHTML: isHTML,
    );

    String? platformResponse;

    try {
      await FlutterEmailSender.send(email);
      platformResponse = 'Successfully sent';
      if (platformResponse.isNotEmpty) {
        return showDialog(
          context: context,
          builder: (context) => popUpWidget(
              title: platformResponse!,
              onCancelPressed: () {
                Navigator.pop(context);
              },
              onOkPressed: () async {
                await send(
                    context: context,
                    body: body,
                    subject: subject,
                    recipients: recipients,
                    attachments: attachments);
              },
              leftButtonTitle: "Cancel",
              rightButtonTitle: "Retry"),
        );
      }
    } catch (error) {
      print(error);
      platformResponse = error.toString();
      if (platformResponse.isNotEmpty) {
        return showDialog(
          context: context,
          builder: (context) => popUpWidget(
              title: platformResponse!,
              onCancelPressed: () {
                Navigator.pop(context);
              },
              onOkPressed: () async {
                await send(
                    context: context,
                    body: body,
                    subject: subject,
                    recipients: recipients,
                    attachments: attachments);
              },
              leftButtonTitle: "Cancel",
              rightButtonTitle: "Retry"),
        );
      }
    }
  }

  attachFileToEmail(pdf, context) async {
    try {
      List<String> attachments = [];
      attachments.add(pdf);
      print('attachment added .........................$attachments');
      return attachments;
    } catch (e) {
      print("$e");
      showDialog(
        context: context,
        builder: (context) => popUpWidget(
            title: "$e",
            onCancelPressed: () {
              Navigator.pop(context);
              return false;
            },
            onOkPressed: () async {
              await attachFileToEmail(pdf, context);
            },
            leftButtonTitle: "Cancel",
            rightButtonTitle: "Retry"),
      );
    }
  }
}
