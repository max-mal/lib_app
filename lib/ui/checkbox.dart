import 'package:flutter/material.dart';
import 'package:flutter_app/parts/svg.dart';
import 'package:flutter_svg/svg.dart';

import 'button.dart';

class UiCheckbox extends StatelessWidget {
  final bool checked;
  final Function onChanged;
  final Widget child;
  UiCheckbox({this.checked, this.onChanged, this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onChanged(!checked);
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(width: 27),
          AnimatedContainer(
            curve: Curves.easeInOutQuad,
            duration: Duration(milliseconds: 200),
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              border: Border.all(
                color: checked ? Colors.transparent : Color(0xffCBD3DB),
              ),
              borderRadius: BorderRadius.circular(6),
              color: checked ? UiButtonColors.primaryColor : Colors.white,
            ),
            child: AnimatedSwitcher(
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(child: child, scale: animation);
              },
              duration: Duration(milliseconds: 300),
              child: checked
                  ? Container(
                      key: ValueKey(true),
                      child: SvgPicture.string(SvgIcons.checkMark),
                    )
                  : Container(key: ValueKey(false)),
            ),
          ),
          SizedBox(width: 26),
          Expanded(child: child),
          SizedBox(width: 27),
        ],
      ),
    );
  }
}
