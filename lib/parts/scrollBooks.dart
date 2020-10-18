import 'package:flutter/material.dart';

class ScrollBooks extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ScrollBooksState();
  }
}

class ScrollBooksState extends State<ScrollBooks> {
  ScrollController booksScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 1), () {
      booksAnimate();
    });
  }

  booksAnimate() {
    booksScrollController.animateTo(booksScrollController.offset + 20,
        duration: Duration(seconds: 1), curve: Curves.linear);

    Future.delayed(Duration(seconds: 1), () {
      booksAnimate();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: booksScrollController,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext ctx, int index) {
        return Column(
          children: [
            Container(
              width: 105,
              height: index % 2 == 0 ? 130 : 110,
              margin: EdgeInsets.only(right: 20, bottom: 20),
              color: Colors.grey,
            ),
            Container(
              width: 105,
              height: 150,
              margin: EdgeInsets.only(right: 20),
              color: Colors.grey,
            )
          ],
        );
      },
      scrollDirection: Axis.horizontal,
    );
  }
}
