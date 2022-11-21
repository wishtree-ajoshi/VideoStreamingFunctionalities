import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_file_picker/form_builder_file_picker.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  String url =
      "https://opentdb.com/api.php?amount=10&category=9&difficulty=easy&type=multiple";
  Color tileColor = Colors.white;
  final _formKey = GlobalKey<FormBuilderState>();
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SingleChildScrollView(
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
                      child: Text("What is a century?"),
                    ),
                  ),

                  ///Radio buttons
                  FormBuilderRadioGroup(
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
                  FormBuilderFilterChip<String>(
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
                    onSaved: (newValue) => print(newValue),
                  ),

                  ///CheckBox use in Form-Builder
                  FormBuilderCheckboxGroup<String>(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: const InputDecoration(
                        labelText: 'The language of my people'),
                    name: 'languages',
                    //initialValue: const ['Dart'],
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
                      child: Text("Select an option which means a century?"),
                    ),
                  ),

                  ///Radio buttons
                  FormBuilderDropdown(
                    enabled: true,
                    name: "dropdown options",
                    onChanged: (value) => setState(() {
                      print(value);
                    }),
                    alignment: Alignment.bottomCenter,
                    initialValue: 1,
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
                      child: Text("What is a century in words?"),
                    ),
                  ),

                  ///Radio buttons
                  FormBuilderTextField(
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
                    typeSelectors: const [
                      TypeSelector(
                          type: FileType.any,
                          selector: Icon(
                            Icons.file_upload,
                            color: Colors.black,
                          ))
                    ],
                    name: "fileUpload",
                    previewImages: false,
                    allowCompression: true,
                    allowMultiple: false,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                ],
              ),
            ),
          ),

          ///Submit Button..
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              color: Colors.red,
              border: Border(
                top: BorderSide(),
              ),
            ),
            child: const Padding(
              padding: EdgeInsets.all(20),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  "SUBMIT",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
