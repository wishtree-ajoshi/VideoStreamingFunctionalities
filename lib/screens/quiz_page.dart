import 'dart:io';
import 'package:demo_app/methods/email_send_url_launcher.dart';
import 'package:demo_app/methods/email_sender_standalone.dart';
import 'package:demo_app/screens/email_sender.dart';
import 'package:demo_app/methods/make_pdf.dart';
import 'package:demo_app/widgets/text_styles.dart';
import 'package:demo_app/widgets/reusable_widgets.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_extra_fields/form_builder_extra_fields.dart';
import 'package:form_builder_file_picker/form_builder_file_picker.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  Color color = Colors.red;
  getQuiz() async {}

  // navigateToSendEmail(pdf) {
  //   Navigator.pushReplacement(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => EmailSender(
  //         pdf: pdf,
  //         recipient: 'amey.joshi@wishtreetech.com',
  //         subject: 'Please find attachments',
  //         body: 'lorem ipsum dolor sit',
  //       ),
  //     ),
  //   );
  // }

  isValid(value) async {
    if (value != null) {
      print("$value");
      return true;
    } else {
      return false;
    }
  }

  onSubmit() async {
    _formKey.currentState!.validate();
    if (_formKey.currentState!.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        customSnackbar(
          title: "Form Submitted..",
          width: MediaQuery.of(context).size.width - 120,
        ),
      );
      print("valid");
      print("formData: ${_formKey.currentState!.value}");
      final responseKeys = _formKey.currentState!.value.keys.cast().toList();
      final responseValues =
          _formKey.currentState!.value.values.cast().toList();

      File pdf = await makePdf(
          responseValues: responseValues,
          responseKeys: responseKeys,
          pdfName: "Quiz_Responses");
      print("*SIZE**********${pdf.lengthSync()}");

      final attachments =
          await SendEmail().attachFileToEmail(pdf.path, context);

      if (await attachments.isNotEmpty) {
        await SendEmail().send(
          context: context,
          recipients: ['supriya.karanje@wishtreetech.com'],
          subject:
              'POC for automated process of sending email with attachments',
          body:
              '''Please find attachments for the PDF file generated from the responses of the form-Builder.\n\nDetails of the POC: This POC is a automated procedure of converting the responses of a form to a PDF and attaching it to mail of sender.\n\nCurrently the recipients, subject and body are provided manually but can be automated or dynamically filled.\n\nRegards, Amey Joshi''',
          attachments: await attachments,
        );
      }

      ///Using Url_Launcher library..
      // if (await attachments.isNotEmpty) {
      //   await SendEmailUrlLauncher().send(attachments, context);
      // }

      ///Dummy email page...
      //navigateToSendEmail(pdf);

      ///Preview pdf...
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => PdfPreview(
      //       initialPageFormat: PdfPageFormat.a4,
      //       build: (format) async => await pdf.save(),
      //     ),
      //   ),
      // );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        customSnackbar(
          title: "Please fill all required fields..",
          width: MediaQuery.of(context).size.width - 60,
        ),
      );
      print("invalid");
      print("formData: ${_formKey.currentState!.value}");
    }
  }

  @override
  void initState() {
    getQuiz();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quiz"),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 60, left: 10, right: 10),
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.vertical,
            child: FormBuilder(
              skipDisabled: true,
              key: _formKey,
              enabled: true,
              autoFocusOnValidationFailure: true,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  questionContainer(
                      context: context, title: "What is a century?"),

                  ///Radio buttons
                  answerContainer(
                    answer: FormBuilderRadioGroup(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: FormBuilderValidators.required(),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                      name: "What is a century?",
                      wrapAlignment: WrapAlignment.center,
                      options: const [
                        FormBuilderChipOption(value: 100),
                        FormBuilderChipOption(value: 10),
                        FormBuilderChipOption(value: 1),
                        FormBuilderChipOption(value: 1000),
                      ],
                      onChanged: (value) => print(value),
                    ),
                  ),

                  questionContainer(
                      context: context, title: "Which language do you know?"),

                  ///Multiple option selection in an advanced way...
                  answerContainer(
                    answer: FormBuilderFilterChip<String>(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                      enabled: true,
                      spacing: 100,
                      validator: FormBuilderValidators.required(),
                      name: 'Which language do you know?',
                      alignment: WrapAlignment.center,
                      selectedColor: Colors.red,
                      options: const [
                        FormBuilderChipOption(
                          value: 'Dart',
                          avatar: CircleAvatar(child: Text('A')),
                        ),
                        FormBuilderChipOption(
                          value: 'Kotlin',
                          avatar: CircleAvatar(child: Text('B')),
                        ),
                        FormBuilderChipOption(
                          value: 'Java',
                          avatar: CircleAvatar(child: Text('C')),
                        ),
                        FormBuilderChipOption(
                          value: 'Swift',
                          avatar: CircleAvatar(child: Text('D')),
                        ),
                      ],
                      onChanged: (value) => print(value),
                    ),
                  ),

                  questionContainer(
                      context: context, title: "The Language of my people?"),

                  ///CheckBox use in Form-Builder
                  answerContainer(
                    answer: FormBuilderCheckboxGroup<String>(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      wrapAlignment: WrapAlignment.center,
                      wrapSpacing: 40,
                      validator: FormBuilderValidators.required(),
                      name: 'The Language of my people?',
                      decoration:
                          const InputDecoration(border: InputBorder.none),
                      options: const [
                        FormBuilderFieldOption(value: 'Dart'),
                        FormBuilderFieldOption(value: 'Kotlin'),
                        FormBuilderFieldOption(value: 'Java'),
                        FormBuilderFieldOption(value: 'Swift'),
                        FormBuilderFieldOption(value: 'Objective-C'),
                      ],
                      separator: const VerticalDivider(
                        width: 10,
                        thickness: 5,
                        color: Colors.red,
                      ),
                    ),
                  ),

                  questionContainer(
                      context: context,
                      title: "Select an option which means a century."),

                  ///Dropdown Module
                  answerContainer(
                    answer: FormBuilderDropdown(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: FormBuilderValidators.required(),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide(width: 1, color: Colors.black),
                        ),
                      ),
                      alignment: Alignment.center,
                      enabled: true,
                      name: "Select an option which means a century.",
                      onChanged: (value) => {
                        if (mounted)
                          {
                            setState(() {
                              print(value);
                            }),
                          }
                      },
                      initialValue: 1,
                      iconEnabledColor: Colors.red,
                      dropdownColor: Colors.red.shade200,
                      focusColor: Colors.white,
                      items: const [
                        DropdownMenuItem(
                          value: 1,
                          child: Text("10"),
                        ),
                        DropdownMenuItem(
                          value: 2,
                          child: Text("100"),
                        ),
                        DropdownMenuItem(
                          value: 3,
                          child: Text("1000"),
                        ),
                        DropdownMenuItem(
                          value: 4,
                          child: Text("1"),
                        ),
                      ],
                    ),
                  ),

                  ///TextField Module
                  questionContainer(
                      context: context, title: "What is century in words?"),

                  ///TextInput Field
                  answerContainer(
                    answer: FormBuilderTextField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: FormBuilderValidators.required(),
                      decoration: InputDecoration(
                        errorBorder: const OutlineInputBorder(
                          borderSide: BorderSide(width: 2, color: Colors.red),
                        ),
                        hintText: "Enter answer",
                        hintStyle: hintStyle(),
                        border: const OutlineInputBorder(
                          borderSide: BorderSide(width: 1),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 10),
                      ),
                      enabled: true,
                      maxLength: 20,
                      name: "What is century in words?",
                    ),
                  ),

                  questionContainer(context: context, title: "Attach a file"),

                  ///File Upload..
                  answerContainer(
                    answer: FormBuilderFilePicker(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: FormBuilderValidators.required(),
                      decoration:
                          const InputDecoration(border: InputBorder.none),
                      typeSelectors: const [
                        TypeSelector(
                          type: FileType.custom,
                          selector: SizedBox(
                            child: Icon(
                              Icons.file_upload,
                              size: 30,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                      name: "Attach a file",
                      previewImages: false,
                      allowCompression: true,
                      allowMultiple: false,
                      allowedExtensions: const [
                        "pdf",
                        "png",
                        "jpg",
                        "docx",
                        "pptx",
                        "ppsx"
                      ],
                    ),
                  ),

                  questionContainer(context: context, title: "Select Time"),

                  ///Time picker or Date-Picker...
                  answerContainer(
                    answer: FormBuilderDateTimePicker(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: FormBuilderValidators.required(),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide(width: 1, color: Colors.black),
                        ),
                        hintText: "HH:MM:SS",
                      ),
                      name: "Select Time",
                      initialTime: TimeOfDay.now(),
                      format: DateFormat.Hms(),
                      inputType: InputType.time,
                      enabled: true,
                      timePickerInitialEntryMode: TimePickerEntryMode.dial,
                    ),
                  ),

                  questionContainer(
                      context: context, title: "How much are you happy?"),

                  ///Rating Bar...
                  answerContainer(
                    answer: FormBuilderRatingBar(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: FormBuilderValidators.required(),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                      wrapAlignment: WrapAlignment.center,
                      glow: false,
                      name: "How much are you happy?",
                      direction: Axis.horizontal,
                      initialRating: 0,
                      maxRating: 5,
                      itemPadding: const EdgeInsets.symmetric(horizontal: 2),
                      ratingWidget: RatingWidget(
                        full: Image.asset(
                          "assets/smiling.png",
                          scale: 1,
                          width: 20,
                          fit: BoxFit.fitHeight,
                        ),
                        half: Image.asset(
                          "assets/neutral.png",
                          scale: 1,
                          width: 20,
                          fit: BoxFit.fitHeight,
                        ),
                        empty: Image.asset(
                          "assets/neutral.png",
                          scale: 1,
                          width: 20,
                          fit: BoxFit.fitHeight,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          ///Submit Button..
          Align(
            alignment: Alignment.bottomCenter,
            child: RawMaterialButton(
              onPressed: () async {
                _formKey.currentState!.save();
                onSubmit();
              },
              fillColor: Colors.red,
              elevation: 20,
              padding: const EdgeInsets.all(0),
              shape: const RoundedRectangleBorder(side: BorderSide(width: 1)),
              constraints: BoxConstraints(
                  minWidth: MediaQuery.of(context).size.width, minHeight: 50),
              child: Text(
                "Submit".toUpperCase(),
                style: questionStyle(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
