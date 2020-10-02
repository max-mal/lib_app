import 'package:flutter/material.dart';
import 'package:flutter_app/dialogs/bookOption.dart';
import 'package:flutter_app/models/book.dart';
import 'package:flutter_app/parts/book.dart';
import '../colors.dart';
import '../globals.dart';

class RecommendationsScreen extends StatefulWidget {
  final Function goTo;

  const RecommendationsScreen({
    Key key,
    this.goTo
  }) : super(key: key);

  _RecommendationsScreenState createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;

  List<Book> recommendations = [];
  bool isLoading = true;

  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    snackBarContext = context;
    this.getRecommendations();
  }

  @override
  Widget build(BuildContext context) {
//  return this.genresList();
    return new SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              this.recBooksBlock(),
            ],
          ),
        )
    );
  }

  void getRecommendations() async {
    setState(() {
      isLoading = true;
    });

    if (serverApi.hasConnection) {
      recommendations = List<Book>.from(await serverApi.getRecommendationBooks());
    }

    setState((){
      isLoading = false;
    });
  }

  Widget recBooksBlock()
  {
    return Container(
      margin: EdgeInsets.only(top: 32),
      padding: EdgeInsets.symmetric(horizontal: 26, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: Text('Рекомендации', style: TextStyle(
              color: Colors.black,
              fontSize: 32,
            )),
          ),
          Container(
            margin: EdgeInsets.only(top: 12),
            child: Text('Сохраните ваши любимые книги сейчас и откройте их позже. Только вы можете увидеть свою коллекцию.', style: TextStyle(
              color: AppColors.secondary,
              fontSize: 14,
            )),
          ),
          Container(
            child: this.recBooksListView(),

          )
        ],
      ),
    );
  }

  Widget recBooksListView()
  {
    if (!serverApi.hasConnection) {
      return Container(
          margin: EdgeInsets.only(top: 20),
          child: Center(
              child: ListTile(
                leading: Icon(Icons.signal_wifi_off),
                title: Text('Нет соединения с сервером'),
              )
          )
      );
    }

    if (isLoading) {
      return Container(margin: EdgeInsets.only(top: 20, bottom: 40),child: Center(child: CircularProgressIndicator()));
    }
    return ListView.separated(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        separatorBuilder: (BuildContext ctx, int index) {
          return Container(
            child: Divider(
              color: AppColors.primary,
              height: 2,
            ),
          );
        },
        itemBuilder: (BuildContext ctx, int index) {
          Book item = recommendations[index];
          return BookWidget(book: item);
        },
        itemCount: recommendations.length
    );

  }


}