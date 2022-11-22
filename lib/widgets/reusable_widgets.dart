import 'package:demo_app/widgets/text_styles.dart';
import 'package:flutter/material.dart';

Widget questionContainer({required context, required String title}) {
  return Padding(
    padding: const EdgeInsets.only(top: 5),
    child: Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Colors.red,
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
