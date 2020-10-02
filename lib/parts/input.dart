import 'package:flutter/material.dart';

import '../colors.dart';

class AppInputWidget extends StatelessWidget {

  final mask;
  final TextInputType type;
  final String placeholder;
  final Function onChanged;
  final TextEditingController controller;

  const AppInputWidget({
    Key key,
    this.mask,
    this.type,
    this.placeholder,
    this.onChanged,
    this.controller,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 24),
      child: TextFormField(
          inputFormatters: mask != null? [mask] : null,
          controller: controller,
          onChanged: onChanged,
          keyboardType: type,
          decoration: new InputDecoration(
            hintText: placeholder,
            border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
            hintStyle: TextStyle(fontSize: 14, color: AppColors.secondary),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: AppColors.primary,
                width: 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: AppColors.secondary,
                  width: 1.0
              ),
            ),
          )
      ),
    );
  }
}
