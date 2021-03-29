import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/database/core/models/preferences.dart';
import 'package:flutter_app/dialogs/bookChapters.dart';
import 'package:flutter_app/dialogs/collectionAdd.dart';
import 'package:flutter_app/dialogs/shareBook.dart';
import 'package:flutter_app/models/book.dart';
import 'package:flutter_app/utils/pageTurn.dart';
import 'package:flutter_app/utils/parser.dart';
import 'package:flutter_app/utils/transparent.dart';
import 'package:flutter_tts/flutter_tts.dart';


import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../colors.dart';
import '../globals.dart';

enum TtsState { playing, stopped, paused, continued }

class ReaderScreen extends StatefulWidget {

  final Book book;

  @override
  ReaderScreenState createState() => new ReaderScreenState();

  ReaderScreen({Key key, this.book});

  static void open(context, Book book) {
    Navigator.of(context).push(
        TransparentRoute(builder: (BuildContext context) => ReaderScreen(book: book))
    );
  }
}

class ReaderScreenState extends State<ReaderScreen> {

  int navBarSelectedIndex = 0;
  Widget bookText;
  Parser parser;
  bool showSettings = false;
  bool downloadingBook = false;
  ScrollController scrollController = ScrollController();
  Timer timer;
  bool initialLaunch = true;
  bool showTts = false;
  String bookDownloadStatus = '';

  GlobalKey<PageTurnState> pageTurnController = GlobalKey<PageTurnState>();

  FlutterTts flutterTts;

  PageController pagingController = PageController();


  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();

  void onNavBarTap(index) {
    setState(() {
      this.navBarSelectedIndex = index;

      switch (navBarSelectedIndex) {
        case 0 :
          Navigator.pop(context);
          break;
        case 1:
          CollectionAddDialog.open(context, widget.book, () {});
          break;
        case 2:
          BookShareDialog.open(context, widget.book, () {});
          break;
        case 4:
          showSettings = !showSettings;
          showTts = false;
          break;

        case 3:
          showTts = !showTts;
          initTts();
          break;

      }
    });
  }

  bool rendered = false;
  double readerHeight = 0;

  @override
  void initState()
  {
    super.initState();
    parser = new Parser();
    parser.context = context;

    loadPreferences().then((data) {
      setState((){});
    });

    setState(() {
      downloadingBook = true;
    });

    widget.book.downloadBook(onProgress: (status){
      setState(() {
        bookDownloadStatus = status;
      });
    }).then((result) async {
      setState(() {
        downloadingBook = false;
      });

      if (isPaged) {
        buildPages();
      }

      readingBooksHideIds.remove(widget.book.id);
      Preferences.set('readingBooksHideIds', readingBooksHideIds.join(','));
    });


    timer = Timer.periodic(new Duration(seconds: 5), (timer) async {

      if (downloadingBook || initialLaunch) {
        return false;
      }



      widget.book.progress = ((widget.book.currentChapter + 1) /  widget.book.chapters.length * 100).toInt();
      widget.book.save();

      serverApi.setProgress(widget.book);
      if (isPaged) {
        if (isPagesBuilt) {
          Preferences.set('book-' + widget.book.id.toString() + '-page', pagingController.page.toInt().toString());
        }
        return false;
      }
      Preferences.set('book-' + widget.book.id.toString() + '-scroll', scrollController.offset.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: AppColors.getColor('background'),
      bottomNavigationBar: BottomNavigationBar(
          backgroundColor: AppColors.getColor('background'),
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.grey,
          unselectedItemColor: AppColors.secondary,
          items: [
            new BottomNavigationBarItem(icon: new Icon(Icons.home), label: 'Домой'),
            new BottomNavigationBarItem(icon: new Icon(Icons.bookmark), label: 'Сохранить'),
            new BottomNavigationBarItem(icon: new Icon(Icons.file_upload), label: 'Делиться'),
            new BottomNavigationBarItem(icon: new Icon(Icons.volume_up), label: 'Слушать'),
            new BottomNavigationBarItem(icon: new Icon(Icons.settings), label: 'Настройки'),
          ],
          currentIndex: this.navBarSelectedIndex,
          onTap: this.onNavBarTap,
        ),
        body: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Opacity(
                  opacity: 0,
                  child: Container(
                    margin: EdgeInsets.only(left: 25, right: 25),
                    color: Colors.red,
                    child: measureWidget,
                    key: buildColumnKey,
                  ),
                )
              ],
            ),
            Column(
              children: [
                SizedBox(height: 89),
                isPaged? Container(
                  height: MediaQuery.of(context).size.height - 145,
                  child: readerBodyPaged(),
                  ) : Container(
                    height: MediaQuery.of(context).size.height - 146,
                    margin: EdgeInsets.symmetric(horizontal: 24),
                    child: readerBody(),
                ),

              ],
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                color: AppColors.getColor('background'),
                padding: EdgeInsets.only(top: 40, left: 24, right: 24, bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      child: IconButton(
                        icon: Icon(Icons.list, color: AppColors.getColor('black')),
                        onPressed: () {
                          BookChapterDialog.open(context, widget.book, (chapter) {

                            setState(() {
                              widget.book.currentChapter = chapter;
                              loadTtsChapter();
                              if (isPaged) {
                                buildPages();
                              }
                            });

                          });
                        },
                      ),
                    ),
                    Container(
                        constraints: BoxConstraints(maxHeight: 40),
                        width: MediaQuery.of(context).size.width - 127,
                        child: Center(child: Text(widget.book.chapters.length  != 0 ? widget.book.chapters[widget.book.currentChapter].title : '',textAlign: TextAlign.center, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14, color: AppColors.grey),))
                    ),
                  ],
                ),
              ),
            ),
            showSettings? Container(child: this.settings()): Container(),
            showTts? Container(child: this.ttsSettings()): Container(),
          ],
        )
    );
  }

  List<Widget> currentPageWidgets = [];
  List<List<Widget>> pages = [];
  GlobalKey buildColumnKey = GlobalKey();
  bool isPagesBuilt = false;
  bool canRead = false;
  Widget measureWidget;

  bool isPaged = false;

  waitUntilRender() async {
    rendered = false;
    double initialHeight = getBuildHeight();
    double currentHeight = getBuildHeight();
    setState((){});
    while(initialHeight == currentHeight) {
      await Future.delayed(Duration(milliseconds: 10));
      currentHeight = getBuildHeight();
    }

    return getBuildHeight();
  }

  getBuildHeight() {
    RenderBox rBox = buildColumnKey.currentContext.findRenderObject();
    Size size = rBox.size;
//    print("SIZE of Red: $size");

    return size.height;
  }

  buildPages() async {
    readerHeight = MediaQuery.of(context).size.height - 145;
    String response = await widget.book.chapters[widget.book.currentChapter].getContents();
    var json = jsonDecode(response);

    pages = [];
    currentPageWidgets = [];
    isPagesBuilt = false;
    double totalHeight = 0;
    setState((){});

    if (widget.book.currentChapter > 0) {
      currentPageWidgets.add(
        Align(
          alignment: Alignment.center,
          child: TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(AppColors.getColor('secondary'))
              ),              
              onPressed: () {
                setState((){
                  widget.book.currentChapter = widget.book.currentChapter - 1;
                  buildPages();
                  loadTtsChapter();
                });
              },
              child: Text('Назад', style: TextStyle(color: Colors.white))
          ),
        )
      );
      totalHeight = 40;
    }


    RenderBox rBox = buildColumnKey.currentContext.findRenderObject();
    Size size = rBox.size;
    print("[BeforeBuild] SIZE: ${size.height}");

    int jumpTo;

    if (initialLaunch && widget.book.progress > 0) {
      int page = int.parse((await Preferences.get('book-' + widget.book.id.toString() + '-page')) ?? '1');
      Future.delayed(Duration(seconds: 1), (){
        print('NEED Jump to page ' + page.toString());
        jumpTo = page;
        initialLaunch = false;
      });
    }


    for (var block in json['blocks']) {
      bool isText = false;
      bool isImage = false;
      Widget c;
      switch (block['type']) {
        case 'header':
         c = this.parser.renderHeader(block);
          break;
        case 'paragraph':
          c = this.parser.renderParagraph(block);
          isText = true;
          break;
        case 'list':
          c = this.parser.renderList(block);
          break;
        case 'image':
          c = this.parser.renderImage(block);
          isImage = true;
          break;
        case 'delimiter':
          c = this.parser.renderDivider(block);
          break;
        default:
          print ('Unknown block: ' + block['type']);
          break;
      }

      if (measureWidget != null) {
        measureWidget = null;
        await waitUntilRender();
      }

      currentPageWidgets.add(c);
      measureWidget = c;
      await waitUntilRender();

      RenderBox rBox = buildColumnKey.currentContext.findRenderObject();
      Size size = rBox.size;
      print("SIZE: $size");

      if (isImage) {
        size = Size.fromHeight(320);
      }


      print("H: $totalHeight / $readerHeight");
      if (totalHeight + size.height > readerHeight) {


        List<Widget> nextPageWidgets = [];

        if (isText && readerHeight - totalHeight > 50) {
          List<String> parts = block['data']['text'].toString().split(' ');

          c = this.parser.renderParagraph({'data': {'text': parts.sublist(0, parts.length ~/2 ).join(' ')}});
          Size s = await measure(c);

          int sIndex;

          if (totalHeight + s.height > readerHeight) {
            for(int i=parts.length ~/2; i > 2; i-=2) {
              c = this.parser.renderParagraph({'data': {'text': parts.sublist(0, i).join(' ')}});
              Size s = await measure(c);

              if (totalHeight + s.height <= readerHeight) {
                sIndex = i;
                break;
              }
            }
          } else {
            for(int i=parts.length ~/2; i < parts.length -1; i+=2) {
              c = this.parser.renderParagraph({'data': {'text': parts.sublist(0, i).join(' ')}});
              Size s = await measure(c);

              if (totalHeight + s.height >= readerHeight) {
                sIndex = i - 2;
                break;
              }
            }
          }

          if (sIndex != null) {
            c = this.parser.renderParagraph({'data': {'text': parts.sublist(0, sIndex).join(' ')}});
            currentPageWidgets.removeLast();
            currentPageWidgets.add(c);
            pages.add(List<Widget>.from(currentPageWidgets));
            c = this.parser.renderParagraph({'data': {'text': parts.sublist(sIndex).join(' ')}});
            nextPageWidgets.add(c);
            Size s = await measure(c);
            totalHeight = s.height;
            currentPageWidgets = List<Widget>.from(nextPageWidgets);
            print('Page ended!');
//            break;
          } else {
            nextPageWidgets.add(currentPageWidgets.last);
            currentPageWidgets.removeLast();
            pages.add(List<Widget>.from(currentPageWidgets));
            currentPageWidgets = List<Widget>.from(nextPageWidgets);
            print('Page ended!');
            totalHeight = size.height;
          }

        } else {
          nextPageWidgets.add(currentPageWidgets.last);
          currentPageWidgets.removeLast();
          pages.add(List<Widget>.from(currentPageWidgets));
          currentPageWidgets = List<Widget>.from(nextPageWidgets);
          print('Page ended!');
          totalHeight = size.height;
        }

        if (jumpTo != null && pages.length > jumpTo) {
          pagingController.jumpToPage(jumpTo);
          jumpTo = null;
        }

      } else {
        totalHeight += size.height;
      }

    }

    if (currentPageWidgets.length !=0 ) {
      pages.add(List<Widget>.from(currentPageWidgets));
    }

    isPagesBuilt = true;

    if (widget.book.currentChapter <  widget.book.chapters.length - 1) {
      pages.add([
        Align(
          alignment: Alignment.center,
          child: TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(AppColors.getColor('secondary'))
              ), 
              onPressed: () {
                setState((){
                  widget.book.currentChapter = widget.book.currentChapter + 1;
                  buildPages();
                  loadTtsChapter();
                });
              },
              child: Text('Вперед', style: TextStyle(color: Colors.white))
          ),
        )
      ]);
    }


    setState((){});


  }

  measure(c) async {
    if (measureWidget != null) {
      measureWidget = null;
      await waitUntilRender();
    }

    measureWidget = c;
    await waitUntilRender();

    RenderBox rBox = buildColumnKey.currentContext.findRenderObject();
    Size size = rBox.size;
    return size;
  }

  GlobalKey readerLoadingKey = GlobalKey();

  readerBodyPaged() {

      return PageView(
        controller: pagingController,
        children: pages.map((e) => Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.only(right: 25, left: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: e,
          ),
        )).toList(),
      );
  }

  readerBody() {

    if (downloadingBook) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(child: CircularProgressIndicator(), margin: EdgeInsets.only(right: 20),),
              Text('Загрузка книги...', style: TextStyle(color: AppColors.getColor('black'))),
            ]
          ),
          Container(
            margin: EdgeInsets.only(top: 20),
            child: Text(bookDownloadStatus, style: TextStyle(color: AppColors.getColor('black'))),
          )
        ],
      );
    }

    if (widget.book.chapters.length == 0) {
      return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(child: Icon(Icons.error, color: AppColors.secondary), margin: EdgeInsets.only(right: 20),),
            Text('Ошибка. Книга недоступна', style: TextStyle(color: AppColors.getColor('black'))),
          ]
      );
    }

    this.getChapterBody(widget.book.currentChapter);
    return SingleChildScrollView(
        controller: scrollController,
        child: Column(
          children: [
            builtChapterBody.containsKey(widget.book.currentChapter) && widget.book.currentChapter > 0? TextButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(AppColors.getColor('secondary'))
                ), 
                onPressed: () {
                  setState((){
                    widget.book.currentChapter = widget.book.currentChapter - 1;
                    scrollController.jumpTo(0);
                    loadTtsChapter();
                  });
                },
                child: Text('Назад', style: TextStyle(color: Colors.white))
            ) : Container(),
            builtChapterBody.containsKey(widget.book.currentChapter)? builtChapterBody[widget.book.currentChapter] : Text('Загрузка...',  style: TextStyle(color: AppColors.getColor('black'))),
            builtChapterBody.containsKey(widget.book.currentChapter) && widget.book.currentChapter < widget.book.chapters.length -1 ?TextButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(AppColors.getColor('secondary'))
                ), 
                onPressed: () {
                  setState((){
                    widget.book.currentChapter = widget.book.currentChapter+1;
                    scrollController.jumpTo(0);
                    loadTtsChapter();
                  });
                },
                child: Text('Далее', style: TextStyle(color: Colors.white))
            ): Container(),
          ],
        )
    );

  }

  Map<int, Widget> builtChapterBody = {};

  void getChapterBody(index) async
  {
    if (widget.book.chapters.length == 0) {
      await widget.book.getChapters();
    }

    if (!builtChapterBody.containsKey(index)) {
      builtChapterBody[index] = await this.parser.parse(widget.book.chapters[index]);
      setState((){});
      if (initialLaunch && widget.book.progress > 0) {
        double scrollPosition = double.parse(await Preferences.get('book-' + widget.book.id.toString() + '-scroll'));
        Future.delayed(Duration(seconds: 1), (){
          print('Jump to ' + scrollPosition.toString());
          scrollController.jumpTo(scrollPosition);
          initialLaunch = false;
        });
      }

      if (initialLaunch) {
        initialLaunch = false;
      }
    }

  }

  Widget settings() {
    return Positioned(
      bottom: 32,
      right: 24,
      child: Container(
        height: 480,
        width: 220,
        decoration: BoxDecoration(
            color: AppColors.getColor('background'),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: AppColors.getColor('settingsFold'),
                blurRadius: 10,
                spreadRadius: readerNightMode? 1000: 10,
              )
            ]
        ),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width,
            maxHeight: MediaQuery.of(context).size.height - 200
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              this.settingsFontSize(),
              this.settingsNightMode(),
              this.settingsPaging(),
              this.settingsFontColor(),
              this.settingsFont(),
            ],
          ),
        ),
      ),
    );
  }

  Widget ttsSettings() {
    return Positioned(
      bottom: 32,
      right: 24,
      child: Container(
        height: 200,
        width: 220,
        decoration: BoxDecoration(
            color: AppColors.getColor('background'),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: AppColors.getColor('settingsFold'),
                blurRadius: 10,
                spreadRadius: readerNightMode? 1000: 10,
              )
            ]
        ),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width,
            maxHeight: MediaQuery.of(context).size.height - 200
        ),
        child: SingleChildScrollView(
          child: textToRead.length == 0? Center(child: Text('Загрузка...', style: TextStyle(color: AppColors.getColor('black')))) : Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.play_arrow, color: ttsState == TtsState.playing? AppColors.grey :  AppColors.getColor('black'),),
                    onPressed: () {
                      if (ttsState != TtsState.playing) {
                        readByItem();
                      }

                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.stop, color: ttsState == TtsState.stopped? AppColors.grey : AppColors.getColor('black')),
                    onPressed: () {
                      if (ttsState != TtsState.stopped) {
                        _stop();
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.pause, color: ttsState == TtsState.stopped ? AppColors.grey :  AppColors.getColor('black'),),
                    onPressed: () {
                      if (ttsState != TtsState.stopped) {
                        _pause();
                      }
                    },
                  )
                ],
              ),
              Container(
                child: Slider(
                  min: 0,
                  max: textToRead.length == 0? 0 : textToRead.length -1.0,
                  value: (textToReadCurrentIndex < textToRead.length && textToReadCurrentIndex >= 0) ? textToReadCurrentIndex.toDouble() : 0,
                  onChanged: (value) async {
                    if (ttsState == TtsState.playing) {
                      await _pause();
                    }
                    setState(() {
                      textToReadCurrentIndex = value.toInt();
                    });

                    if (ttsSliderTimer != null) {
                      ttsSliderTimer.cancel();
                    }

                    ttsSliderTimer = Timer(Duration(milliseconds: 400), () {
                      ttsSliderTimer = null;
                      readByItem();
                    });

                  },
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10),
                child: Text('Голос', style: TextStyle(color: AppColors.getColor('black')),),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: DropdownButton(
                    dropdownColor: AppColors.getColor('white'),
                    items: ttsVoices.map((e) => DropdownMenuItem(child: Container(constraints: BoxConstraints(maxWidth: 130),child: Text(e.toString(), overflow: TextOverflow.ellipsis, style: TextStyle(color: AppColors.getColor('black')))), value: e,)).toList(),
                    value: ttsVoice,
                    onChanged: (value) async {
                      if (value == 'По умолчанию') {
                        return;
                      }
                      setState((){
                        ttsVoices.remove('По умолчанию');
                        ttsVoice = value;
                      });

                      await flutterTts.setVoice(ttsVoice);
                      if (ttsState == TtsState.playing) {
                        await _pause();
                        await readByItem();
                      }
                    }
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Timer ttsSliderTimer;

  void resetBook()
  {
    savePreferences();
    setState((){
      builtChapterBody = {};
      initialLaunch = true;
    });

    if (isPaged) {
      this.buildPages();
    }
  }

  Widget settingsFontSize()
  {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          RawMaterialButton(
            onPressed: (){
              setState((){
                editorSmallText = true;
                this.resetBook();
              });
            },
            child: Container(
              padding: EdgeInsets.all(12),
              child: Text('A', style: TextStyle(fontSize: 14, color: editorSmallText? AppColors.secondary : AppColors.getColor('black'))),
            ),
          ),
          Container(
            height: 52,
            width: 1,
            decoration: BoxDecoration(
                border: Border(
                    right: BorderSide(
                        color: AppColors.secondary,
                        width: 1
                    )
                )
            ),
          ),
          RawMaterialButton(
            onPressed: (){
              setState((){
                editorSmallText = false;
                this.resetBook();
              });
            },
            child: Container(
              padding: EdgeInsets.all(12),
              child: Text('A', style: TextStyle(fontSize: 18, color: !editorSmallText? AppColors.secondary : AppColors.getColor('black'))),
            ),
          )
        ],
      ),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.secondary, width: 1))
      ),
    );
  }

  Widget settingsNightMode() {
    return Container(
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.secondary, width: 1))
      ),
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Ночной режим', style: TextStyle(
              fontSize: 14,
              color: AppColors.grey
          )),
          CupertinoSwitch(
            value: readerNightMode,
            onChanged: (bool value) { setState(() { readerNightMode = value; this.resetBook(); }); },
          )
        ],
      ),
    );
  }

  Widget settingsPaging() {
    return Container(
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.secondary, width: 1))
      ),
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(isPaged? 'Страницы' : 'Прокрутка', style: TextStyle(
              fontSize: 14,
              color: AppColors.grey
          )),
          CupertinoSwitch(
            value: isPaged,
            onChanged: (bool value) { setState(() { isPaged = value ? true: false; this.resetBook(); }); },
          )
        ],
      ),
    );
  }

  Widget settingsFontColor()
  {
    return Container(
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.secondary, width: 1))
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 12),
            child:
            Text('Цвет текста', style: TextStyle(
                fontSize: 14,
                color: AppColors.grey
            )),
          ),
          Container(
            child: Row(
              children: [
                this.fontColor(AppColors.grey),
                this.fontColor(AppColors.secondary),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget fontColor(Color color) {
    return RawMaterialButton(
      onPressed: () {
        setState((){
          readerFontColor = color;
        });
        this.resetBook();
      },
      constraints: BoxConstraints.tight(Size(36, 36)),
      shape: CircleBorder(),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: readerFontColor == color? Icon(Icons.check, color: Colors.white,) : Container(),
      ),
    );
  }

  Widget settingsFont()
  {
    return Container(
      child: Column(
        children: [
          this.font('Roboto', 'Roboto'),
          this.font('TimesNewRoman', 'Times New Roman'),
          this.font('Georgia', 'Georgia'),
          this.font('Barlow', 'Barlow'),
          this.font('ComicSans', 'Comic Sans'),
        ],
      ),
    );
  }

  Widget font(family, name) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RawMaterialButton(
            onPressed: () {
              setState(() {
                readerFontFamily = family;
                this.resetBook();
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(name, style: TextStyle(fontSize: 14, color: AppColors.grey, fontFamily: family)),
                readerFontFamily == family? Icon(Icons.check, color: AppColors.getColor('black')) : Container(),
              ],
            ),
          ),
          Divider(
            color: AppColors.secondary,
            height: 1,
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    timer.cancel();
    if (flutterTts != null) {
      flutterTts.stop();
    }
    super.dispose();
  }

  savePreferences() async {
    await Preferences.set('editorSmallText', editorSmallText ? '1' : '0');
    await Preferences.set('readerNightMode', readerNightMode ? '1' : '0');
    await Preferences.set('readerFontColor', readerFontColor ==  AppColors.grey? 'grey' : 'secondary');
    await Preferences.set('readerFontFamily', readerFontFamily);
    await Preferences.set('readerPaged', isPaged ? '1' : '0');
  }

  loadPreferences() async {
    editorSmallText = (await Preferences.get('editorSmallText', value: '1')) == '1' ? true : false;
    readerNightMode = (await Preferences.get('readerNightMode', value: '0')) == '1' ? true : false;
    readerFontColor = (await Preferences.get('readerFontColor', value: 'grey')) == 'grey' ? AppColors.grey : AppColors.secondary;
    readerFontFamily = (await Preferences.get('readerFontFamily', value: readerFontFamily));
    isPaged = (await Preferences.get('readerPaged', value: '0')) == '1' ? true : false;
    isPaged = (await Preferences.get('readerPaged', value: '0')) == '1' ? true : false;
  }

  var ttsState;
  String ttsLanguage = 'ru-RU';
  dynamic ttsVoice = 'По умолчанию';
  List<dynamic> ttsVoices = ['По умолчанию'];

  initTts() async {
    if (flutterTts != null) {
      return;
    }

    flutterTts = FlutterTts();
    await flutterTts.setSharedInstance(true);
    await flutterTts
        .setIosAudioCategory(IosTextToSpeechAudioCategory.playAndRecord, [
      IosTextToSpeechAudioCategoryOptions.allowBluetooth,
      IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
      IosTextToSpeechAudioCategoryOptions.mixWithOthers
    ]);

    List<dynamic> languages = await flutterTts.getLanguages;
    print(languages.toString());

    await flutterTts.setLanguage(ttsLanguage);
//    await flutterTts.setSilence(2);

    var voices = await flutterTts.getVoices;

    for (var voice in voices) {
      if (voice.toString().indexOf(ttsLanguage.toLowerCase()) != -1) {
        ttsVoices.add(voice);
      }
    }

    if (ttsVoice != null) {
      flutterTts.setVoice(ttsVoice);
    }

    await loadTtsChapter();

    flutterTts.setStartHandler(() {
      setState(() {
        ttsState = TtsState.playing;
      });
    });

    flutterTts.setCompletionHandler(() {
      textToReadCurrentIndex += 1;
      Preferences.set('ttsReadingIndex-book-' + widget.book.id.toString() + '-' + widget.book.currentChapter.toString(), textToReadCurrentIndex.toString());
      readByItem();
      print('Done reading ' + textToReadCurrentIndex.toString() + '/' + textToRead.length.toString());
      setState(() {
        ttsState = TtsState.stopped;
      });
    });

    flutterTts.setProgressHandler((String text, int startOffset, int endOffset, String word) {
      setState(() {
//        _currentWord = word;
      });
    });

    flutterTts.setErrorHandler((msg) {
      setState(() {
        ttsState = TtsState.stopped;
      });
    });

    flutterTts.setCancelHandler(() {
      setState(() {
        ttsState = TtsState.stopped;
      });
    });

// iOS and Web
    flutterTts.setPauseHandler(() {
      setState(() {
        ttsState = TtsState.paused;
      });
    });

    flutterTts.setContinueHandler(() {
      setState(() {
        ttsState = TtsState.continued;
      });
    });
  }

  Future _speak(String text) async{
    var result = await flutterTts.speak(text);
    if (result == 1) setState(() => ttsState = TtsState.playing);
  }

  Future _stop() async {
    textToReadCurrentIndex = 0;
    var result = await flutterTts.stop();
    if (result == 1) setState(() => ttsState = TtsState.stopped);
  }

  Future _pause() async{
    var result = await flutterTts.stop();
    if (result == 1) setState(() => ttsState = TtsState.paused);
  }

  List<String> textToReadChapter = [];
  List<String> textToRead = [];
  int textToReadCurrentIndex = 0;

  readByItem() async {
    if (textToReadCurrentIndex <= textToRead.length - 1) {
      _speak(textToRead[textToReadCurrentIndex]);
    } else if (widget.book.currentChapter <= widget.book.chapters.length -2) {
      textToReadCurrentIndex = 0;
      widget.book.currentChapter += 1;
      await savePreferences();
      await loadTtsChapter();
      setState((){});
      readByItem();
    }

  }

  loadTtsChapter() async {
    if (flutterTts == null) {
      return;
    }
    textToRead = [];
    textToReadChapter = [];
    setState((){});

    textToReadChapter = await this.parser.parseToText(widget.book.chapters[widget.book.currentChapter]);
    textToRead = new List<String>.from(textToReadChapter);
    textToReadCurrentIndex = int.parse(await Preferences.get('ttsReadingIndex-book-' + widget.book.id.toString() + '-' + widget.book.currentChapter.toString(), value: '0'));
    if (textToReadCurrentIndex == textToRead.length -1 || textToReadCurrentIndex > textToRead.length -1) {
      textToReadCurrentIndex = 0;
    }
    print('Loaded ttsChapter ' + textToReadCurrentIndex.toString());
    setState((){});
  }


}