import 'package:flutter/material.dart';

import '../colors.dart';

class ListMoreButton extends StatelessWidget {

  final bool isLoading;
  final bool showMoreButton;
  final bool isMoreLoading;
  final Function onMore;

  ListMoreButton({this.isLoading, this.showMoreButton, this.isMoreLoading, this.onMore});

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container();
    }

    if (!showMoreButton) {
      return Container(child: Text('Больше книг нет'));
    }

    return Center(
      child: new ButtonTheme(
          minWidth: MediaQuery.of(context).size.width,
          height: 52,
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(AppColors.secondary),
              padding: MaterialStateProperty.all(EdgeInsets.all(10)),
              minimumSize: MaterialStateProperty.all(Size(150, 0))
            ),          
            onPressed: () {
              if (isMoreLoading) {
                return;
              }   

              onMore();           
            },
            child: new Text(isMoreLoading ? 'Загрузка...' : 'Далее', style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white60
            )),
          )
      ),
    );
  }
}