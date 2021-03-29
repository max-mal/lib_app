import 'package:flutter/material.dart';
import 'package:flutter_app/models/collection.dart';
import 'package:flutter_app/utils/transparent.dart';
import '../colors.dart';

class CollectionRenameDialog extends StatefulWidget {

  final Collection collection;
  final Function doAfter;

  CollectionRenameDialog(this.collection, this.doAfter);

  @override
  CollectionRenameDialogState createState() => new CollectionRenameDialogState();

  static void open(context, Collection collection, Function after) {
    Navigator.of(context).push(
        TransparentRoute(builder: (BuildContext context) => CollectionRenameDialog(collection, after))
    );
  }
}




class CollectionRenameDialogState extends State<CollectionRenameDialog> {

  TextEditingController controller = TextEditingController();

  void initState() {
    super.initState();
    controller.text = widget.collection.name;

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
                          child: Text('Изменить коллекцию', style: TextStyle(color: AppColors.grey, fontSize: 20),)
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 24, left: 28, right: 28),
                        child: TextFormField(
                            controller: controller,
                            onChanged: (value) {
                              setState(() {});
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


                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                        child: this.button('Изменить', AppColors.secondary, AppColors.grey, () async {
                          widget.collection.name = controller.text;
                          await widget.collection.update();
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
        child: TextButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(color),
            padding: MaterialStateProperty.all(EdgeInsets.all(10))
          ),
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