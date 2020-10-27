import 'package:flutter/material.dart';

class UiFormInput extends StatelessWidget {
  String label;
  Function validator;
  bool obscure;
  TextEditingController controller;
  UiFormInput(
      {this.label = '', this.validator, this.obscure = false, this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
        border: OutlineInputBorder(
            borderSide: BorderSide(
              color: Color(0xff6B727B),
            ),
            borderRadius: BorderRadius.all(Radius.circular(12))),
      ),
    );
  }
}
