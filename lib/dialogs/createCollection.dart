import 'package:flutter/material.dart';
import 'package:flutter_app/models/collection.dart';
import 'package:flutter_app/utils/transparent.dart';
import '../colors.dart';
import '../globals.dart';

class CollectionCreateDialog extends StatefulWidget {

  Function doAfter;

  CollectionCreateDialog(this.doAfter);

  @override
  CollectionCreateDialogState createState() => new CollectionCreateDialogState();

  static void open(context, Function after) {
    Navigator.of(context).push(
        TransparentRoute(builder: (BuildContext context) => CollectionCreateDialog(after))
    );
  }
}




class CollectionCreateDialogState extends State<CollectionCreateDialog> {

  TextEditingController controller = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
                  height: 350,
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
                          child: Text('Создать коллекцию', style: TextStyle(color: AppColors.grey, fontSize: 20),)
                      ),
                      Form(
                        key: _formKey,
                        child: Container(
                          margin: EdgeInsets.only(top: 24, left: 28, right: 28),
                          child: TextFormField(
                              controller: controller,
                              onChanged: (value) {
                                setState(() {});
                              },
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Название не может быть пустым';
                                }
                                return null;
                              },
                              decoration: new InputDecoration(
                                hintText: 'Название коллекции',
                                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                                hintStyle: TextStyle(fontSize: 14, color: AppColors.secondary),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: AppColors.secondary,
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
                        ),
                      ),


                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                        child: this.button('Создать коллекцию', AppColors.secondary, AppColors.grey, () async {
                          if (!_formKey.currentState.validate()) {
                            return;
                          }
                          Collection collection = new Collection();
                          collection.name = controller.text;

                          await collection.create();
                          userCollections.add(collection);

                          Navigator.pop(context);
                          widget.doAfter();
                        }),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 28),
                        child: this.button('Отменить', Colors.white, Colors.black, () {
                          Navigator.pop(context);
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