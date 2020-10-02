import 'package:flutter/material.dart';
import 'package:flutter_app/models/userAuthor.dart';
import '../globals.dart';
import '../models/author.dart';
import '../colors.dart';

class AuthorsScreen extends StatefulWidget {
  final Function goTo;

  const AuthorsScreen({
    Key key,
    this.goTo
  }) : super(key: key);

  _AuthorsScreenState createState() => _AuthorsScreenState();
}

class _AuthorsScreenState extends State<AuthorsScreen> with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;

  List<dynamic> authorList = [];
  List<dynamic> filteredAuthorList = [];
  List<int> selectedAuthors = [];
  bool isLoading = false;

  final searchController = TextEditingController();

  void getAuthors() async {
    authorList = await new Author().all();
    isLoading = true;
    serverApi.getAuthors().then((data) async {
      authorList = await new Author().all();
      setState((){
        isLoading = false;
      });
    });
    setState((){});
  }

  @override
  void initState() {
    this.getAuthors();
    super.initState();
    snackBarContext = context;
  }

  @override
  Widget build(BuildContext context) {
//  return this.authorsList();
    return new Container(
        child: SizedBox(
          height: MediaQuery.of(context).size.height, // or something simular :)
          child: Stack(
            children: [
              new Container (
                margin: EdgeInsets.symmetric(horizontal: 24),
                child: new Column(
                  children: [
                    this.authorsText(),
                    this.authorsDescriptionText(),
                    this.authorsSearch(),
                    isLoading? Container(margin: EdgeInsets.only(top: 20),child: Text('Загрузка...'))  : Container(),
                    new Expanded(
                      child: new SizedBox(
                        child: this.authorsList(),
                        height: 200,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 40,
                left: 20,
                right: 20,
                child: this.nextButton(),
              )
            ],
          ),
        )
    );
  }

  Widget authorsText()
  {
    return new Container(
      margin: EdgeInsets.only(top: 55),
      child: new Center(
        child:
        new Text(
          'Авторы',
          style: new TextStyle(
              fontSize: 32
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
  Widget authorsDescriptionText()
  {
    return new Container(
      margin: EdgeInsets.only(top: 24),
      child: new Center(
        child:
        new Text(
          'Настройте свои интересы так, чтобы вы могли\n открыть для себя свои самые любимые книги.',
          style: new TextStyle(
              fontSize: 14
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget authorsSearch()
  {
    return new Container(
        margin: EdgeInsets.only(top: 60),
        child: new TextFormField(
            controller: searchController,
            onChanged: (text) {
              filteredAuthorList = [];
              for (Author author in authorList) {
                if (author.name.toLowerCase().indexOf(text.toLowerCase()) != -1 || author.surname.toLowerCase().indexOf(text.toLowerCase()) != -1) {
                  filteredAuthorList.add(author);
                }
              }

              serverApi.getAuthors(query: searchController.text).then((data) async {
                authorList = await new Author().all();
                setState((){
                  isLoading = false;
                });
              });

              setState(() {
                isLoading = true;
              });
            },
            decoration: new InputDecoration(
              hintText: 'Поиск по авторам',
              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
            )
        )
    );
  }

  Widget authorsList()
  {

    return ListView.builder(
      itemBuilder: (BuildContext ctx, int index) {
        Author currentAuthor = searchController.text.length > 0? filteredAuthorList[index]: authorList[index];
        return new Container(
          margin: EdgeInsets.symmetric(vertical: 10),

          padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              Row(
                children: [
                  Container(
                    margin: EdgeInsets.only(right: 24),
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      image: DecorationImage(image: NetworkImage(currentAuthor.picture), fit: BoxFit.cover),
                      color: Colors.grey,
                    ),

                  ),
                  Container(

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        new Container(
                            constraints: BoxConstraints(maxWidth: 250),
                            margin: EdgeInsets.only(bottom: 4),
                            child: Text(currentAuthor.name + ' ' + currentAuthor.surname, textAlign: TextAlign.left, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold))
                        ),
                        new Container(
                            margin: EdgeInsets.only(bottom: 4),
                            child: Text(currentAuthor.count.toString() + ' книги', textAlign: TextAlign.left, style: TextStyle(fontSize: 14, color: Colors.grey))
                        ),
                      ],
                    ),
                  ),

                ],
              ),

              GestureDetector(
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle
                    ),
                    child: Icon(selectedAuthors.contains(currentAuthor.id)? Icons.block : Icons.add),

                  ),
                  onTap: () {
                    print('Tapped!');

                    if (!selectedAuthors.contains(currentAuthor.id)) {
                      print('Added ' + currentAuthor.id.toString());
                      selectedAuthors.add(currentAuthor.id);
                      UserAuthor item = new UserAuthor();
                      item.authorId = currentAuthor.id;
                      item.store();
                    } else {
                      print('Removed ' + currentAuthor.id.toString());
                      selectedAuthors.remove(currentAuthor.id);
                      new UserAuthor().where('authorId = ? ', [currentAuthor.id]).delete();
                    }
                    setState(() {});
                  }
              )

            ],
          ),
        );
      },
      itemCount: searchController.text.length > 0? filteredAuthorList.length : authorList.length,
    );
  }

  Widget nextButton() {
    return new ButtonTheme(
        minWidth: MediaQuery.of(context).size.width,
        height: 52,
        child: RaisedButton(
          color: AppColors.primary,
          padding: EdgeInsets.all(10),
          onPressed: () async {
            await serverApi.setUserAuthors();
            widget.goTo('congratulation');
          },
          child: new Text('Далее', style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold
          )),
        )
    );
  }


}