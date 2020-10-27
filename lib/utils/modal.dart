import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

showCupertinoModal(BuildContext context,
    {Widget child, bool dismissable = false}) {
  showCupertinoModalBottomSheet(
    context: context,
    isDismissible: dismissable,
    backgroundColor: Colors.transparent,
    builder: (context, scrollController) => Container(
      // margin: EdgeInsets.only(top: 40),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          )),
      child: Column(
        children: [
          SizedBox(height: 22),
          Container(
            width: 48,
            height: 5,
            decoration: BoxDecoration(
                color: Color(0xffEAEEF2),
                borderRadius: BorderRadius.all(Radius.circular(3))),
          ),
          Expanded(
              child: SingleChildScrollView(
                  child: Card(
            child: child,
            shadowColor: Colors.transparent,
          )))
        ],
      ),
    ),
  );
}
