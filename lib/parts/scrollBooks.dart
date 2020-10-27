import 'package:flutter/material.dart';

import '../globals.dart';

class ScrollBooks extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ScrollBooksState();
  }
}

class ScrollBooksState extends State<ScrollBooks> {
  ScrollController booksScrollController = ScrollController();
  List<dynamic> promoBooks;
  int counter = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 1), () {
      booksAnimate();
    });
    serverApi.getPromoBooks().then((data) {
      setState(() {
        promoBooks = data;
      });
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
        String firstImage;
        String secondImage;

        if (promoBooks != null && promoBooks.length > counter) {
          firstImage = promoBooks[counter]['picture'].toString();
          counter++;
        } else if (promoBooks != null) {
          counter = 0;
          firstImage = promoBooks[counter]['picture'].toString();
        }

        if (promoBooks != null && promoBooks.length > counter) {
          secondImage = promoBooks[counter]['picture'].toString();
          counter++;
        } else if (promoBooks != null) {
          counter = 0;
          secondImage = promoBooks[counter]['picture'].toString();
        }

        return Column(
          children: [
            Container(
              width: 105,
              height: index % 2 == 0 ? 130 : 110,
              margin: EdgeInsets.only(right: 20, bottom: 20),
              decoration: BoxDecoration(
                image: firstImage == null
                    ? null
                    : DecorationImage(
                        image: NetworkImage(firstImage),
                        fit: BoxFit.fitWidth,
                      ),
                color: Colors.grey,
              ),
            ),
            Container(
                width: 105,
                height: 150,
                margin: EdgeInsets.only(right: 20),
                decoration: BoxDecoration(
                  image: firstImage == null
                      ? null
                      : DecorationImage(
                          image: NetworkImage(secondImage),
                          fit: BoxFit.fitWidth,
                        ),
                  color: Colors.grey,
                ))
          ],
        );
      },
      scrollDirection: Axis.horizontal,
    );
  }
}
