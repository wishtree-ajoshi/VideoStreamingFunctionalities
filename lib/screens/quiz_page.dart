import 'package:demo_app/widgets/text_styles.dart';
import 'package:demo_app/widgets/reusable_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_extra_fields/form_builder_extra_fields.dart';
import 'package:form_builder_file_picker/form_builder_file_picker.dart';
import 'package:intl/intl.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  String url =
      "https://opentdb.com/api.php?amount=10&category=9&difficulty=easy&type=multiple";
  final _formKey = GlobalKey<FormBuilderState>();
  Color color = Colors.red;
  getQuiz() async {}

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
            padding: const EdgeInsets.only(bottom: 50),
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.vertical,
            child: FormBuilder(
              skipDisabled: true,
              key: _formKey,
              enabled: true,
              autoFocusOnValidationFailure: true,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                children: [
                  questionContainer(
                      context: context, title: "What is a century?"),

                  ///Radio buttons
                  FormBuilderRadioGroup(
                    decoration: const InputDecoration(border: InputBorder.none),
                    name: "options",
                    options: const [
                      FormBuilderChipOption(
                        value: 100,
                      ),
                      FormBuilderChipOption(value: 10),
                      FormBuilderChipOption(value: 1),
                      FormBuilderChipOption(value: 1000),
                    ],
                    onChanged: (value) => print(value),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),

                  ///Multiple option selection in an advanced way...
                  questionContainer(
                      context: context, title: "Which language do you know?"),
                  FormBuilderFilterChip<String>(
                    decoration: const InputDecoration(border: InputBorder.none),
                    enabled: true,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    name: 'languages_filter',
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

                  ///CheckBox use in Form-Builder
                  questionContainer(
                      context: context, title: "The Language of my people?"),
                  FormBuilderCheckboxGroup<String>(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    name: 'languages',
                    decoration: const InputDecoration(border: InputBorder.none),
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

                  ///Dropdown Module
                  questionContainer(
                      context: context,
                      title: "Select an option which means a century."),

                  ///Radio buttons
                  FormBuilderDropdown(
                    decoration: const InputDecoration(border: InputBorder.none),
                    enabled: true,
                    name: "dropdown_options",
                    onChanged: (value) => setState(() {
                      print(value);
                    }),
                    initialValue: 1,
                    iconEnabledColor: Colors.red,
                    dropdownColor: Colors.red,
                    focusColor: Colors.white,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
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

                  ///TextField Module
                  questionContainer(
                      context: context, title: "What is century in words?"),

                  ///TextInput Field
                  FormBuilderTextField(
                    decoration: InputDecoration(
                        hintText: "Enter answer",
                        hintStyle: hintStyle(),
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(width: 1),
                          borderRadius: BorderRadius.circular(0),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 10)),
                    enabled: true,
                    name: "textField",
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),

                  ///File Upload..
                  Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(10)),
                    child: const Padding(
                      padding: EdgeInsets.all(5),
                      child: Text("Attach a file"),
                    ),
                  ),
                  FormBuilderFilePicker(
                    typeSelectors: [
                      TypeSelector(
                        type: FileType.any,
                        selector: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: const Icon(
                            Icons.file_upload,
                            size: 30,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                    name: "file_upload",
                    previewImages: false,
                    allowCompression: true,
                    allowMultiple: false,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  questionContainer(context: context, title: "Select Time"),
                  FormBuilderDateTimePicker(
                    decoration: const InputDecoration(
                      hintText: "HH:MM:SS",
                      hintStyle: TextStyle(color: Colors.black),
                    ),
                    name: "time_picker",
                    initialTime: TimeOfDay.now(),
                    format: DateFormat.Hms(),
                    inputType: InputType.time,
                    enabled: true,
                    timePickerInitialEntryMode: TimePickerEntryMode.dial,
                  ),
                  questionContainer(
                      context: context, title: "How much are you happy?"),
                  FormBuilderRatingBar(
                    glow: false,
                    name: "rating_bar",
                    direction: Axis.horizontal,
                    initialRating: 0,
                    maxRating: 5,
                    itemPadding: const EdgeInsets.all(2),
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
                ],
              ),
            ),
          ),

          ///Submit Button..
          Align(
            alignment: Alignment.bottomCenter,
            child: RawMaterialButton(
              onPressed: () {
                _formKey.currentState!.save();
                print("formData: ${_formKey.currentState!.value}");
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
