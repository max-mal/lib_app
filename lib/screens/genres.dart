import 'package:flutter/material.dart';
import 'package:flutter_app/models/userGenre.dart';
import '../models/genre.dart';
import '../colors.dart';
import '../globals.dart';

class GenresScreen extends StatefulWidget {
  final Function goTo;

  const GenresScreen({
    Key key,
    this.goTo
  }) : super(key: key);

  _GenresScreenState createState() => _GenresScreenState();
}

class _GenresScreenState extends State<GenresScreen> with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;

  List<dynamic> genreList = [];
  List<Genre> filteredGenreList = [];
  List<int> selectedGenres = [];
  bool isLoading = true;

  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    this.getGenres();
  }

  @override
  Widget build(BuildContext context) {
//  return this.genresList();
    return new Container(
      child: SizedBox(
        height: MediaQuery.of(context).size.height, // or something simular :)
        child: Stack(
          children: [
            new Container (
              margin: EdgeInsets.symmetric(horizontal: 24),
              child: new Column(
                children: [
                  this.genresText(),
                  this.genresDescriptionText(),
                  this.genresSearch(),
                  isLoading? Container(margin: EdgeInsets.only(top: 20),child: Text('Загрузка...'))  : Container(),
                  new Expanded(
                    child: new SizedBox(
                      child: this.genresList(),
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

  Widget genresText()
  {
    return new Container(
      margin: EdgeInsets.only(top: 55),
      child: new Center(
        child:
        new Text(
          'Жанры',
          style: new TextStyle(
              fontSize: 32
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
  Widget genresDescriptionText()
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

  Widget genresSearch()
  {
    return new Container(
      margin: EdgeInsets.only(top: 30),
      child: new TextFormField(
        controller: searchController,
        onChanged: (text) {
          filteredGenreList = [];
          for (Genre genre in genreList) {
            if (genre.name.toLowerCase().indexOf(text.toLowerCase()) != -1) {
              filteredGenreList.add(genre);
            }
          }

          setState(() {});
        },
        decoration: new InputDecoration(
          hintText: 'Поиск по жанрам',
          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
        )
      )
    );
  }

  void getGenres() async {
    setState(() {
      isLoading = true;
    });
    genreList = await new Genre().all();
    serverApi.getGenres().then((data) async {
      genreList = await new Genre().all();
      setState((){ isLoading = false; });
    });
    setState((){});
  }

  Widget genresList()
  {

    return ListView.builder(
      itemBuilder: (BuildContext ctx, int index) {
        Genre currentGenre = searchController.text.length > 0? filteredGenreList[index]: genreList[index];
        return new Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            image: DecorationImage(image: NetworkImage(currentGenre.picture), fit: BoxFit.cover),
            color: Colors.grey,
          ),
          padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    new Container(
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),
                      margin: EdgeInsets.only(bottom: 4),
                      child: Text(currentGenre.name, textAlign: TextAlign.left, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white))
                    ),
                    new Container(
                        margin: EdgeInsets.only(bottom: 4),
                        child: Text(currentGenre.count.toString() + ' книги', textAlign: TextAlign.left, style: TextStyle(fontSize: 14, color: Colors.white))
                    ),
                  ],
                ),
              ),
              GestureDetector(
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle
                  ),
                  child: Icon(selectedGenres.contains(currentGenre.id)? Icons.block : Icons.add),

                ),
                onTap: () {
                      print('Tapped!');

                    if (!selectedGenres.contains(currentGenre.id)) {
                      print('Added ' + currentGenre.id.toString());
                      selectedGenres.add(currentGenre.id);
                      UserGenre item = new UserGenre();
                      item.genreId = currentGenre.id;
                      item.store();
                    } else {
                      print('Removed ' + currentGenre.id.toString());
                      selectedGenres.remove(currentGenre.id);
                      new UserGenre().where('genreId = ? ', [currentGenre.id]).delete();
                    }
                    setState(() {});
                  }
                )

            ],
          ),
        );
      },
      itemCount: searchController.text.length > 0? filteredGenreList.length : genreList.length,
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
            await serverApi.setUserGenres();
            widget.goTo('authors');
          },
          child: new Text('Далее', style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold
          )),
        )
    );
  }


}