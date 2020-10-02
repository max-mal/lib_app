import 'package:flutter/material.dart';
import 'package:flutter_app/models/book.dart';
import 'package:flutter_app/screens/paymentCheckout.dart';
import 'package:flutter_app/utils/transparent.dart';
import '../colors.dart';
import '../globals.dart';

class PaymentDetailsScreen extends StatefulWidget {
  final Function goTo;
  final Book book;

  const PaymentDetailsScreen({
    Key key,
    this.goTo,
    this.book,
  }) : super(key: key);

  _PaymentDetailsScreenState createState() => _PaymentDetailsScreenState();

  static void open(context, Book book, Function goTo) {
    Navigator.of(context).push(
        TransparentRoute(builder: (BuildContext context) => PaymentDetailsScreen(goTo: goTo, book: book))
    );
  }
}

class _PaymentDetailsScreenState extends State<PaymentDetailsScreen>  {


  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Stack(
        children: [
          Column(
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
                height: MediaQuery.of(context).size.height - 150,
                child: new SingleChildScrollView(
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.only(bottom: 60),
                            child: Text('Детали покупки', style: TextStyle(
                              color: Colors.black,
                              fontSize: 32,
                            )),
                          ),
                          this.infoItem('Номер', widget.book.id.toString()),
                          this.infoItem('Книга', widget.book.title),
                          this.infoItem('Издатель', ''),
                          this.infoItem('Покупатель', ''),
                          this.infoItem('Цена', widget.book.price.toString() + '₽'),
                        ],
                      ),
                    )
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 40,
            right: 24,
            left: 24,
            child: this.payButton(),
          )
        ],
      ),
    );
  }

  Widget infoItem(name, value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(bottom: 24, top: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: TextStyle(fontSize: 14, color: AppColors.secondary)),
              Text(value, style: TextStyle(fontSize: 14, color: AppColors.grey))
            ],
          ),
        ),
        Divider(
          color: AppColors.primary,
          height: 2,
        )
      ],
    );
  }

  Widget payButton() {
    return InkWell(
      onTap: () {
        PaymentCheckoutScreen.open(context, widget.book, widget.goTo);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: AppColors.secondary,
        ),
        height: 52,
        width: MediaQuery.of(context).size.width - 48,
        child: Center(
          child: new Text('Перейти к оплате', style: TextStyle(
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