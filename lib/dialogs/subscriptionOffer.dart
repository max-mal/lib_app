import 'package:flutter/material.dart';
import 'package:flutter_app/models/collection.dart';
import 'package:flutter_app/screens/subscriptionBuy.dart';
import 'package:flutter_app/utils/transparent.dart';
import '../colors.dart';

class SubscriptionOfferDialog extends StatefulWidget {

  Function doAfter;

  SubscriptionOfferDialog(this.doAfter);

  @override
  SubscriptionOfferDialogState createState() => new SubscriptionOfferDialogState();

  static void open(context, Function after) {
    Navigator.of(context).push(
        TransparentRoute(builder: (BuildContext context) => SubscriptionOfferDialog(after))
    );
  }
}




class SubscriptionOfferDialogState extends State<SubscriptionOfferDialog> {


  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Color.fromRGBO(159, 159, 159, 0.8),
      body: new Stack(
        children: [
          Container(
            child: Align(
              alignment: Alignment.center,
              child: Container(
//                width: 200,
                  height: 305,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    color: Colors.white,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          margin: EdgeInsets.only(top: 40, left: 28, right: 28),
                          child: Center(child: Text('Let save your money', style: TextStyle(color: AppColors.grey, fontSize: 20),))
                      ),
                      Container(
                          margin: EdgeInsets.only(top: 12, bottom: 14, left: 28, right: 28),
                          child: Center(child: Text('Став подпсчиком, вы можете получить доступ ко всем аудиокнигам и слушать их без интрента', textAlign: TextAlign.center, style: TextStyle(color: AppColors.secondary, fontSize: 14),))
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                        child: this.button('Да я хочу оформить подписку', AppColors.secondary, AppColors.grey, () {
                          Navigator.pop(context);
                          SubscriptionBuyScreen.open(context, () {
                            widget.doAfter();
                          });

                        }),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 28),
                        child: this.button('Нет, мне все равно', Colors.white, Colors.black, () {
                          Navigator.pop(context);
                          widget.doAfter();
                        }),
                      ),
                    ],
                  )
              ),
            ),
          )
        ],
      ),
    );

  }

  Widget button(text, Color color, Color textColor, Function action) {
    return ButtonTheme(
        minWidth: MediaQuery.of(context).size.width,
        height: 52,
        child: FlatButton(
          color: color,
          padding: EdgeInsets.all(10),
          onPressed: action,
          child: new Text(text, style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: textColor,
          )),
        )
    );
  }
}