import 'package:flutter/material.dart';
import 'package:flutter_app/models/collection.dart';
import 'package:flutter_app/models/promocode.dart';
import 'package:flutter_app/utils/transparent.dart';
import '../colors.dart';
import '../globals.dart';

class SelectPromoCodeDialog extends StatefulWidget {

  Function doAfter;

  SelectPromoCodeDialog(this.doAfter);

  @override
  SelectPromoCodeDialogState createState() => new SelectPromoCodeDialogState();

  static void open(context, Function after) {
    Navigator.of(context).push(
        TransparentRoute(builder: (BuildContext context) => SelectPromoCodeDialog(after))
    );
  }
}




class SelectPromoCodeDialogState extends State<SelectPromoCodeDialog> {

  TextEditingController controller = TextEditingController();
  
  PromoCode selectedCode;

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
                  height: 565,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    color: Colors.white,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          margin: EdgeInsets.only(top: 40, bottom: 24, left: 28, right: 28),
                          child: Text('Мои промокоды', style: TextStyle(color: AppColors.getColor('black'), fontWeight: FontWeight.bold, fontSize: 20),)
                      ),
                      Container(
                        height: 300,
                        margin: EdgeInsets.only(left: 28, right: 28),
                        child: ListView.builder(
                            itemCount: user.getPromoCodes().length,
                            itemBuilder: (BuildContext ctx, index) {
                              PromoCode code = user.getPromoCodes()[index];

                              if (code.isExpired()) {
                                return Container();
                              }

                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    selectedCode = code;
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.all(16),
                                  margin: EdgeInsets.only(bottom: 24),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: selectedCode == code? AppColors.grey : AppColors.primary, width: 1)
                                  ),
                                  child: Column(
                                    children: [
                                      Container(child: Text(code.description, style: TextStyle(fontSize: 14, color: AppColors.grey))),
                                      Container(margin: EdgeInsets.only(top: 8),child: Text('Истекает ' + code.getDifference(), style: TextStyle(fontSize: 14, color: AppColors.secondary)))
                                    ],
                                  ),
                                ),
                              );
                            }

                        ),
                      ),


                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                        child: this.button('Примените этот код', AppColors.secondary, AppColors.grey, () {
                          Navigator.pop(context);
                          widget.doAfter(selectedCode);

                        }),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 28),
                        child: this.button('Использовать позже', Colors.white, Colors.black, () {
                          Navigator.pop(context);
                          widget.doAfter(null);
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