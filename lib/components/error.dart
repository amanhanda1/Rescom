import 'package:flutter/material.dart';
void displayerror(String message,BuildContext context){
  showDialog(context: context, builder: (context)=>AlertDialog(
    title: Text(message),
  ));
}