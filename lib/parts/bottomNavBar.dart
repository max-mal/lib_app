import 'package:flutter/material.dart';

import '../colors.dart';

class BottomNavBar extends StatelessWidget {

  final String title;
  final String subtitle;

  BottomNavBar({this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container( 
      padding: EdgeInsets.all(5),
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.grey))
      ),        
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            // margin: EdgeInsets.only(left: 20),
            child: InkWell(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                child: Icon(Icons.arrow_back, color: AppColors.grey)
              ),
              onTap: (){
                Navigator.pop(context);
              },
            ),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(right: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  title == null? Container() : Text(title, style: TextStyle(
                    fontSize: subtitle == null? 18: 15,
                    color: AppColors.grey,                  
                  ),overflow: TextOverflow.ellipsis, textAlign: TextAlign.right,),                
                  subtitle == null? Container() : Text(subtitle,style: TextStyle(color: AppColors.secondary, fontSize: 12),overflow: TextOverflow.ellipsis, textAlign: TextAlign.right),                  
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}