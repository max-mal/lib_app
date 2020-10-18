import 'package:flutter/material.dart';
import 'package:flutter_app/dialogs/selectPromoCode.dart';
import 'package:flutter_app/models/book.dart';
import 'package:flutter_app/models/promocode.dart';
import 'package:flutter_app/models/subscription.dart';
import 'package:flutter_app/utils/transparent.dart';
import '../colors.dart';
import '../globals.dart';

class SubscriptionBuyScreen extends StatefulWidget {
  final Function doAfter;

  const SubscriptionBuyScreen({
    Key key,
    this.doAfter,
  }) : super(key: key);

  _SubscriptionBuyScreenState createState() => _SubscriptionBuyScreenState();

  static void open(context, Function doAfter) {
    Navigator.of(context).push(
        TransparentRoute(builder: (BuildContext context) => SubscriptionBuyScreen(doAfter: doAfter))
    );
  }
}

class _SubscriptionBuyScreenState extends State<SubscriptionBuyScreen>  {

  PromoCode promoCode;
  Subscription subscription;
  bool autoProlongation = true;

  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 24),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Container(
                  child: IconButton(icon: Icon(Icons.arrow_back_ios), onPressed: () {
                    Navigator.pop(context);
                  }),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 24, vertical: 36),
              child: Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(bottom: 60),
                      child: Text('Подписка', style: TextStyle(
                        color: Colors.black,
                        fontSize: 32,
                      )),
                    ),
                    Container(
                      child: Text('Получите доступ ко всем аудиокнигам с  подпиской. Выберите и наслаждайтесь!', style: TextStyle(
                        color: AppColors.secondary,
                        fontSize: 14,
                      )),
                    ),
                    Container(
                      child: ListView.builder(itemBuilder: (BuildContext ctx, index) {

                        if (index > 0) {
                          index = index + 1;
                        }

                        return Row(
                          children: [
                            subscriptions.asMap().containsKey(index)? this.subscriptionItem(subscriptions[index]) : Container(),
                            subscriptions.asMap().containsKey(index + 1)? this.subscriptionItem(subscriptions[index + 1]) : Container(),
                          ],
                        );
                      }, itemCount: subscriptions.length ~/ 2, shrinkWrap: true, physics: NeverScrollableScrollPhysics(),),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 20, bottom: 20),
                      child: Row(
                        children: [
                          Checkbox(value: autoProlongation, onChanged: (value){setState((){ autoProlongation = value; });}, activeColor: AppColors.secondary,),
                          Container(margin: EdgeInsets.only(left: 20),child: Text('Автоматическое продление', style: TextStyle(fontSize: 14, color: AppColors.grey),))
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 24),
                      padding: EdgeInsets.all(16),
                      height: 60,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.primary, width: 1)
                      ),
                      child: InkWell(
                        onTap: () {
                          SelectPromoCodeDialog.open(context, (PromoCode code) {
                            setState(() {
                              promoCode = code;
                            });
                          });
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(this.promoCode == null ? 'Мои промокоды' : this.promoCode.description, style: TextStyle(fontSize: 14, color: AppColors.grey),),
                            Container(
                              child: Icon(
                                Icons.arrow_forward_ios,
                                size: 20,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    this.payButton(),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget subscriptionItem(Subscription subscriptionItem) {
    return InkWell(
      onTap: (){
        setState(() {
          subscription = subscriptionItem;
        });
      },
      child: Container(
        width: 152,
        height: 124,
        padding: EdgeInsets.all(34),
        margin: EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: subscription == subscriptionItem? AppColors.secondary : AppColors.primary,
            width: subscription == subscriptionItem? 2 : 1,
          )
        ),
        child: Column(
          children: [
            Container(
              child: Text(subscriptionItem.price.toString() + '₽', style: TextStyle(color: AppColors.grey, fontSize:20, fontWeight: FontWeight.bold ),),
            ),
            Container(
              margin: EdgeInsets.only(top: 8),
              child: Text(subscriptionItem.name, style: TextStyle(color: AppColors.secondary, fontSize:14,),),
            )
          ],
        ),
      ),
    );
  }


  Widget payButton() {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        this.widget.doAfter();
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: AppColors.secondary,
        ),
        height: 52,
        width: MediaQuery.of(context).size.width - 48,
        child: Center(
          child: new Text('Купить за ' + (subscription == null? '0' : subscription.price.toString()) + '₽', style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.grey,
          ),
          ),
        ),
      ),
    );
  }
}