import 'package:demo_app/widgets/text_styles.dart';
import 'package:flutter/material.dart';

Widget questionContainer({required context, required String title}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Colors.red.shade800,
        border: Border.all(
          color: Colors.black,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Text(
          title,
          style: questionStyle(),
        ),
      ),
    ),
  );
}

Widget answerContainer({required Widget answer}) {
  return Container(
    alignment: Alignment.center,
    padding: const EdgeInsets.all(5),
    decoration: BoxDecoration(
      color: Colors.red.shade200,
      border: Border.all(
        color: Colors.black,
        width: 1,
      ),
      borderRadius: BorderRadius.circular(10),
    ),
    child: answer,
  );
}

SnackBar errorSnackbar({required double width, required String title}) {
  return SnackBar(
    behavior: SnackBarBehavior.floating,
    width: width,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(50))),
    content: Text(
      title,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Colors.black,
      ),
    ),
  );
}
