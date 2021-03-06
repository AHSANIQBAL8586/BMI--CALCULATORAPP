import 'dart:math';

import 'package:bmicalculator/Utils/bmiLegends.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'BMIGauge.dart';
import 'Utils/RegExInputFormatter.dart';
import 'Utils/sizeconfig.dart';
import 'View/legendsTable.dart';

String bmiResult = '0';

class AppBody extends StatefulWidget {
  @override
  _AppBodyState createState() => _AppBodyState();
}

double calculateBMI({String weight, String height}) {
  double _weight;
  double _height;

  try {
    _weight = double.parse(weight);
    _height = double.parse(height);
  } on FormatException {
    print('Invalid format');
  }

  var result = (_weight / pow(_height, 2));
  print('result is $result');

  if (result < 7.5) {
    Fluttertoast.showToast(
        msg: 'Your BMI is too low. Make sure your entered data is correct',
        backgroundColor: Colors.green[900],
        toastLength: Toast.LENGTH_LONG);
  } else if (result > 41) {
    Fluttertoast.showToast(
      msg: 'Your BMI is too high. Make sure your entered data is correct',
      backgroundColor: Colors.yellow[900],
    );
  }

  return result;
}

class _AppBodyState extends State<AppBody> {
  String calculatedBmi = 'Fill in your data';
  final _amountValidator = RegExInputFormatter.withRegex(
      '^\$|^(0|([1-9][0-9]{0,}))(\\.[0-9]{0,})?\$');
  final weightController = TextEditingController();
  final heightController = TextEditingController();
  final snackBar = SnackBar(
    content: Text('Cannot calculate\nOne or more field is empty'),
    elevation: 20.0,
    behavior: SnackBarBehavior.floating,
    duration: Duration(seconds: 2),
  );

  BmiLegends bmiLegends = BmiLegends();

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: SizeConfig.screenWidth,
              height: SizeConfig.screenHeight / 4,
              decoration: BoxDecoration(
                  gradient:  LinearGradient(
                      colors: [
                        Colors.red[700],
                        Colors.blue,
                      ],
                  ),

                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40)),
              ),
              padding: EdgeInsets.all(10.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: SizedBox(
                      child: BmiGauge(
                        bmiValue: double.tryParse(bmiResult),
                      ),
                    ),
                  ),
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.fitWidth,
                      child: Text(
                        //change to status
                        '$calculatedBmi',
                        style: GoogleFonts.montserrat(),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  gradient:  LinearGradient(
                      begin: Alignment.topCenter,
                      colors: [
                        Colors.red[200],
                        Colors.blue,


                      ],
                  ),
              ),

              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 20.0,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.all(10.0),
                          child: TextField(
                            controller: weightController,
                            maxLength: 5,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "Weight ",
                                counter: Offstage(),
                                hintText: "Eg: 57.2",
                                suffixText: "kg",
                                alignLabelWithHint: false,
                                filled: true),
                            keyboardType: TextInputType.number,
                            inputFormatters: [_amountValidator],
                            textInputAction: TextInputAction.next,
                            onSubmitted: (_) =>
                                FocusScope.of(context).nextFocus(),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.all(10.0),
                          child: TextField(
                            controller: heightController,
                            maxLength: 4,
                            decoration: InputDecoration(
                                counter: Offstage(),
                                border: OutlineInputBorder(),
                                labelText: "Height",
                                hintText: "Eg: 1.73",
                                suffixText: "m",
                                alignLabelWithHint: false,
                                filled: true),
                            keyboardType: TextInputType.number,
                            inputFormatters: [_amountValidator],
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) =>
                                FocusScope.of(context).unfocus(),
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 20.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: RaisedButton(
                          child: Text(
                            "CALCULATE",
                            style: TextStyle(color: Colors.black),
                          ),
                          color: Colors.blue,
                          onPressed: () {
                            FocusManager.instance.primaryFocus.unfocus();
                            print('Button calculate pressed');
                            print('height is ' + heightController.text);
                            print('weight is ' + weightController.text);
                            if (weightController.text == "" ||
                                heightController.text == "") {
                              Scaffold.of(context).showSnackBar(snackBar);
                            } else {
                              setState(() {
                                double answer = calculateBMI(
                                    height: heightController.text,
                                    weight: weightController.text);
                                String answerText = answer.toStringAsFixed(1);
                                calculatedBmi = bmiLegends.getLegends(answer);
                                LegendsDataTable.bmiValue = answer;
                                bmiResult = answerText;
                              });
                            }
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: RaisedButton(
                          child: Text(
                            "RESET",
                            style: TextStyle(color: Colors.black),
                          ),
                          color: Colors.red,
                          onPressed: () {
                            FocusManager.instance.primaryFocus.unfocus();
                            weightController.clear();
                            heightController.clear();
                            setState(() {
                              calculatedBmi = 'Enter new data';
                              bmiResult = "0.0";
                            });
                            Fluttertoast.showToast(
                              msg: "Cleared",
                              toastLength: Toast.LENGTH_SHORT,
                              backgroundColor: Colors.orange,
                              textColor: Colors.white,
                            );
                          },
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 30),
                  LegendsDataTable(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
