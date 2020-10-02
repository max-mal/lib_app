import 'package:flutter/material.dart';
import 'package:flutter_app/models/event.dart';
import '../colors.dart';

class NewsScreen extends StatefulWidget {
  final Function goTo;

  const NewsScreen({
    Key key,
    this.goTo
  }) : super(key: key);

  _NewsScreenState createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;

  List<Event> news = [];


  final searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return new SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              this.newsBlock(),
            ],
          ),
        )
    );
  }

  void getNews() {
    if (news.length != 0) {
      return;
    }

    news = Event.generate(10);
  }

  Widget newsBlock()
  {
    this.getNews();
    return Container(
      margin: EdgeInsets.only(top: 32),
      padding: EdgeInsets.symmetric(horizontal: 26, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                child: Text('Новости', style: TextStyle(
                  color: Colors.black,
                  fontSize: 32,
                )),
              ),
              Container(
                child: IconButton(icon: Icon(Icons.playlist_add_check), onPressed: () {
                  for (Event item in news) {
                    item.isRead = true;
                  }
                  setState((){});
                }),
              ),
            ],
          ),
          Container(
            child: this.newsListView(),

          )
        ],
      ),
    );
  }

  Widget newsListView()
  {
    List<Event> cNews = [];

    for (Event event in news) {
      if (!event.isRead) {
        cNews.add(event);
      }
    }

    if (cNews.length == 0) {
      return Container(
        margin: EdgeInsets.only(top: 24),
        child: Text(
          'Новых событий нет.',
              style: TextStyle(fontSize: 14, color: AppColors.secondary),
        ),
      );
    }

    return ListView.separated(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        separatorBuilder: (BuildContext ctx, int index) {
          return Container(
            margin: EdgeInsets.only(top: 24, bottom: 24),
            child: Divider(
              color: AppColors.primary,
              height: 2,
            ),
          );
        },
        itemBuilder: (BuildContext ctx, int index) {
          Event item = cNews[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: Text(item.title, style: TextStyle(color: AppColors.grey, fontSize: 14)),
              ),
              Container(
                margin: EdgeInsets.only(top: 8),
                child: Text(item.description, style: TextStyle(color: AppColors.secondary, fontSize: 14)),
              ),
            ],
          );
        },
        itemCount: cNews.length
    );

  }


}