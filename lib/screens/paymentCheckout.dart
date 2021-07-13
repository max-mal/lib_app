import 'package:flutter/material.dart';
import 'package:flutter_app/dialogs/selectPromoCode.dart';
import 'package:flutter_app/models/book.dart';
import 'package:flutter_app/models/promocode.dart';
import 'package:flutter_app/parts/button.dart';
import 'package:flutter_app/parts/input.dart';
import 'package:flutter_app/utils/transparent.dart';
import '../colors.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class PaymentCheckoutScreen extends StatefulWidget {
  final Function goTo;
  final Book book;

  const PaymentCheckoutScreen({
    Key key,
    this.goTo,
    this.book,
  }) : super(key: key);

  _PaymentCheckoutScreenState createState() => _PaymentCheckoutScreenState();

  static void open(context, Book book, Function goTo) {
    Navigator.of(context).push(
        TransparentRoute(builder: (BuildContext context) => PaymentCheckoutScreen(goTo: goTo, book: book))
    );
  }
}

class _PaymentCheckoutScreenState extends State<PaymentCheckoutScreen>  {

  PromoCode promoCode;
  var cardMaskFormatter = new MaskTextInputFormatter(mask: '#### #### #### ####', filter: { "#": RegExp(r'[0-9]') });
  var termMaskFormatter = new MaskTextInputFormatter(mask: '##/##', filter: { "#": RegExp(r'[0-9]') });
  var cvcMaskFormatter = new MaskTextInputFormatter(mask: '###', filter: { "#": RegExp(r'[0-9]') });

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
                        child: Text('Проверка', style: TextStyle(
                          color: Colors.black,
                          fontSize: 32,
                        )),
                      ),
                      this.input('Имя и фамилия на карте', null,  TextInputType.text),
                      this.input('Номер карты', cardMaskFormatter, TextInputType.number),
                      this.input('Дата истечения срока', termMaskFormatter, TextInputType.number),
                      this.input('CVC', cvcMaskFormatter, TextInputType.number),
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
                      Container(
                        margin: EdgeInsets.only(top: 50),
                        child: RawMaterialButton(
                          child: Center(child: Text('Купить через ApplePay', style: TextStyle(fontSize: 14, color: AppColors.getColor('black')),),),
                          onPressed: (){},
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
      ),
    );
  }

  Widget input(String placeholder, var mask, TextInputType type)
  {
    return AppInputWidget(
      mask: mask,
      placeholder: placeholder,
      type: type,
    );
  }

  Widget payButton() {
    return AppButtonWidget(text: ('Купить за ' + widget.book.price.toString() + '₽'), textColor: AppColors.grey, color: AppColors.secondary, onPress: (){},);
  }
}