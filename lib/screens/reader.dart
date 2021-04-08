import 'dart:async';
import 'dart:convert';
import 'dart:ui';

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
import 'package:wakelock/wakelock.dart';

import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../colors.dart';
import '../globals.dart';

enum TtsState { playing, stopped, paused, continued }

class ReaderScreen extends StatefulWidget {

  final Book book;

  @override
  ReaderScreenState createState() => new ReaderScreenState();

  ReaderScreen({Key key, this.book});

  static open(context, Book book) async {
    await Navigator.of(context).push(
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
  int currentPage = 0;
  @override
  void initState()
  {
    super.initState();

    Wakelock.enable(); 
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
        pagingController.addListener(() {
          if (isPagesBuilt) {
            currentPage = pagingController.page.toInt();
            Preferences.set('book-' + widget.book.id.toString() + '-page', pagingController.page.toInt().toString());
            // print('Turned page');
            setState(() {});
          }   
        });
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
      } else {
        Preferences.set('book-' + widget.book.id.toString() + '-scroll', scrollController.offset.toString());
      }
      
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
            isPaged && isPagesBuilt? Positioned(
              bottom: -15,
              left: 0,
              right: 0,
              child: Slider(
                min: 0,                
                value: currentPage.toDouble(),
                max: chapterPages[widget.book.currentChapter] == null? 0: chapterPages[widget.book.currentChapter].length - 1.0,
                // divisions: 1,
                onChanged: (value){
                  pagingController.jumpToPage(value.round());
                  currentPage = value.round();
                  setState(() {});
                },
              ),
            ): Container(),
            showSettings? Container(child: this.settings()): Container(),
            showTts? Container(child: this.ttsSettings()): Container(),
          ],
        )
    );
  }

  List<Widget> currentPageWidgets = [];
  List<List<Widget>> pages = [];
  Map<int, List<List<Widget>>> chapterPages = {};
  GlobalKey buildColumnKey = GlobalKey();
  bool isPagesBuilt = false;
  bool canRead = false;
  Widget measureWidget;

  bool isPaged = false;

  waitUntilRender() async {
    rendered = false;
    double initialHeight = await getBuildHeight();
    double currentHeight = await getBuildHeight();
    setState((){});
    while(initialHeight == currentHeight) {
      await Future.delayed(Duration(milliseconds: 10));
      currentHeight = await getBuildHeight();
    }

    return await getBuildHeight();
  }

  getBuildHeight() async {
    while(buildColumnKey.currentContext == null) {
      // Do nothing...
      await Future.delayed(Duration(milliseconds: 10));
    }
    RenderBox rBox = buildColumnKey.currentContext.findRenderObject();
    Size size = rBox.size;
    return size.height;
  }


  double totalHeight;

  chapterButton({bool prev = false}){

    if (prev == true && widget.book.currentChapter == 0) {
      return null;
    }

    if (prev == false && widget.book.currentChapter == widget.book.chapters.length - 1){
      return null;
    }

    return Align(
      alignment: Alignment.center,
        child: Column(        
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(prev? Icons.arrow_back: Icons.arrow_forward, color: AppColors.getColor('black'),),
              SizedBox(width: 20),
              Expanded(child: Text(widget.book.chapters[prev? (widget.book.currentChapter-1):(widget.book.currentChapter+1)].title, textAlign: TextAlign.center, style: TextStyle(color: AppColors.getColor('black'))))
            ],
          ),
          SizedBox(height: 10),
          TextButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(AppColors.getColor('secondary'))
            ),              
            onPressed: () {
              setState((){
                currentPage = 0;
                if (prev) {
                  widget.book.currentChapter = widget.book.currentChapter - 1;
                } else {
                  widget.book.currentChapter = widget.book.currentChapter + 1;
                }
                if (isPaged) {
                  buildPages();
                  jumpedBack = prev;
                }
                loadTtsChapter();
              });
            },
            child: Text(prev? 'Назад': 'Далее', style: TextStyle(color: Colors.white))
          ),
        ],
      ),
    );
  }

  bool jumpedBack = false;

  buildPages({int chapter = -1}) async {
    if (chapter == -1) {
      chapter = widget.book.currentChapter;
    }
    readerHeight = MediaQuery.of(context).size.height - 145;
    String response = await widget.book.chapters[chapter].getContents();
    var json = jsonDecode(response);

    pages = [];
    currentPageWidgets = [];
    isPagesBuilt = false;
    totalHeight = 0;
    setState((){});

    if (chapterPages[chapter] == null) {
      Widget chapterButtonWidget = chapterButton(prev: true);
      if (chapterButtonWidget != null) {
        pages.add([chapterButtonWidget]);
      }

      for (var block in json['blocks']) {    
        await addBlock(block);
        setState((){});      
      }

      if (currentPageWidgets.length !=0 ) {
        pages.add(List<Widget>.from(currentPageWidgets));
      }

      isPagesBuilt = true;

      Widget chapterNextButtonWidget = chapterButton(prev: false);
      if (chapterNextButtonWidget != null) {
        pages.add([chapterNextButtonWidget]);
      }

      chapterPages[chapter] = pages;
    }
    
    setState((){});

    if (initialLaunch && widget.book.progress > 0) {
      int page = int.parse((await Preferences.get('book-' + widget.book.id.toString() + '-page')) ?? '2');
      Future.delayed(Duration(seconds: 1), (){
        print('NEED Jump to page ' + page.toString());
        pagingController.jumpToPage(page);        
        initialLaunch = false;
        currentPage = page;
      });      
    }

    if (jumpedBack == true) {
      // Future.delayed(Duration(seconds: 1), (){
        pagingController.jumpToPage(chapterPages[chapter].length - 2);   
        jumpedBack = false;     
        currentPage = chapterPages[chapter].length - 2;
      // });
    } else if (initialLaunch == false && chapter > 0) {
      pagingController.jumpToPage(1);   
      currentPage = 1;
    }  

    setState(() {

    });
  }

  addBlock(block) async {
    double measuredHeight;
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
    
    if (isText) {
      measuredHeight = measureText(block['data']['text']);
    } else {        
      measuredHeight = (await measure(c)).height;      
    }      

    currentPageWidgets.add(c);      

    if (isImage && measuredHeight < 50) {
      measuredHeight = 320;
    }
    
    if (totalHeight + measuredHeight > readerHeight) {
      // Если есть переполнение
      if (isText) {
        // и это текст
        List<String> parts = block['data']['text'].toString().split(' ');
        bool fits = false;
        int currentTestIndex = parts.length - 1;

        double freeSpace = readerHeight - totalHeight; // Нужно уложиться в это место
        // print('FREE: $freeSpace');
        while (!fits && currentTestIndex > 0) {
          currentTestIndex --;
          String testText = parts.sublist(0, currentTestIndex).join(' ');
          double testHeight = measureText(testText);
          if (testHeight < freeSpace) {
            fits = true; // Влазит
          }
        }
        
        if (fits) { // Если влазит, добавляем на страницу
          Widget testWidget = this.parser.renderParagraph({'data': {'text': parts.sublist(0, currentTestIndex).join(' ')}});
          currentPageWidgets.removeLast();
          currentPageWidgets.add(testWidget);

          pages.add(List<Widget>.from(currentPageWidgets));
          totalHeight = 0;
          currentPageWidgets = [];
          // print('Page Ended!');
          // А теперь надо добавить остаток на другую страницу
          
          await addBlock({
            'data': {'text': parts.sublist(currentTestIndex).join(' ')},
            'type': 'paragraph',
          });
          
        } else { // Нифига не влазит - на след. страницу
          currentPageWidgets.removeLast();
          pages.add(List<Widget>.from(currentPageWidgets));
          totalHeight = 0;
          currentPageWidgets = [];
          // print('Page ended!');

          await addBlock({
            'data': {'text': parts.join(' ')},
            'type': 'paragraph',
          });              
        } 

      } else {
        // и это не текст. добавим на след. страницу            
        currentPageWidgets.removeLast();
        pages.add(List<Widget>.from(currentPageWidgets));
        currentPageWidgets = List<Widget>.from([c]);
        // print('Page ended!');            
        totalHeight = measuredHeight;
      }
    } else {
      // Все влазит
      totalHeight += measuredHeight;
    }
  }

  double measureText(String text) {
    ParagraphBuilder pBuilder = ParagraphBuilder(ParagraphStyle(
      fontSize: editorSmallText? 16: 20,          
      fontFamily: readerFontFamily
    ));

    pBuilder.addText(text);    
    Paragraph p = pBuilder.build();
    p.layout(ParagraphConstraints(width: MediaQuery.of(context).size.width - 50));
    // print('Computed - ${p.height}');
    return p.height + 10;
  }

  Future<Size> measure(c) async {
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

    if (downloadingBook) {
      return downloadingBookMessage();
    }

    if (widget.book.chapters.length == 0) {
      return bookUnavailableMessage();
    }

    if (chapterPages[widget.book.currentChapter] == null ) {
      return Center(
        child: Text('Построение страниц... ${pages.length}', style: TextStyle(color: AppColors.getColor('black')),),
      );
    }
    return PageView(
      controller: pagingController,
      children: chapterPages[widget.book.currentChapter].map((e) => Container(
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

  downloadingBookMessage(){
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

  bookUnavailableMessage() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(child: Icon(Icons.error, color: AppColors.secondary), margin: EdgeInsets.only(right: 20),),
          Text('Ошибка. Книга недоступна', style: TextStyle(color: AppColors.getColor('black'))),
        ]
    );
  }

  readerBody() {

    if (downloadingBook) {
      return downloadingBookMessage();
    }

    if (widget.book.chapters.length == 0) {
      return bookUnavailableMessage();
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
                    items: ttsVoices.map((e) => DropdownMenuItem(child: Container(constraints: BoxConstraints(maxWidth: 130),child: Text('${e['locale']} ${e['name']}', overflow: TextOverflow.ellipsis, style: TextStyle(color: AppColors.getColor('black')))), value: e,)).toList(),
                    value: ttsVoice == null? null: ttsVoices[ttsVoice],
                    onChanged: (value) async {      
                      ttsVoice = ttsVoices.indexOf(value);
                      setState(() {});
                      await flutterTts.setVoice(value);
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
      chapterPages = {};
      isPagesBuilt = false;
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
    Wakelock.disable();
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
  int ttsVoice;
  List<dynamic> ttsVoices = [];

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
    print(voices);

    for (var voice in voices) {
      if (voice.toString().indexOf(ttsLanguage.toLowerCase()) != -1) {
        ttsVoices.add(voice);
      }
    }

    if (ttsVoice != null) {
      flutterTts.setVoice(ttsVoices[ttsVoice]);
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