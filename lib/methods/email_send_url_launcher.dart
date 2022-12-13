import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/reusable_widgets.dart';

class SendEmailUrlLauncher {
  send(attachments, context) async {
    String? encodeQueryParameters(Map<String, String> params) {
      return params.entries
          .map((MapEntry<String, String> e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
          .join('&');
    }

    String platformResponse;
    final mailtoUri = Uri(
      scheme: 'mailto',
      path: 'amey.joshi@wishtreetech.com',
      query: encodeQueryParameters({
        'cc': 'mahesh.nalwade@wishtreetech.com',
        'subject': 'POC completed: This mail is sent using the POC.',
        'body':
            '''Please find attachments for the "result.pdf" file generated from the responses of the form-Builder.\n\nDetails of the POC: This POC is a automated procedure of converting the responses of a form to a PDF and attaching it to mail of sender.\n\nCurrently the recipients, subject and body are provided manually but can be automated or dynamically filled.\n\nRegards, Amey Joshi''',
        'attachments': '${attachments.first}'
      }),
    );
    print(mailtoUri);

    try {
      if (await launchUrl(mailtoUri)) {
        platformResponse = 'success';
      } else {
        platformResponse = 'failed';
      }
    } catch (e) {
      platformResponse = e.toString();
    }

    return popUpWidget(
        title: platformResponse,
        onCancelPressed: () {
          Navigator.pop(context);
        },
        onOkPressed: () async {
          await launchUrl(mailtoUri, mode: LaunchMode.platformDefault);
        },
        leftButtonTitle: "Cancel",
        rightButtonTitle: "Retry");
  }
}
