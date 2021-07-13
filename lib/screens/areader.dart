import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/colors.dart';
import 'package:flutter_app/database/core/models/preferences.dart';
import 'package:flutter_app/dialogs/collectionAdd.dart';
import 'package:flutter_app/dialogs/shareBook.dart';
import 'package:flutter_app/globals.dart';
import 'package:flutter_app/models/book.dart';
import 'package:flutter_app/models/bookChapter.dart';
import 'package:flutter_app/screens/profile.dart';
import 'package:flutter_app/ui/button.dart';
import 'package:flutter_app/ui/loader.dart';
import 'package:flutter_app/utils/pageBuilder.dart';
import 'package:flutter_app/utils/parser.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audio_service/audio_service.dart';
import 'package:wakelock/wakelock.dart';

class AReaderScreeen extends StatefulWidget {
  
  @required
  final Book book;
  AReaderScreeen({this.book});

  @override
  State<StatefulWidget> createState() => AReaderScreenState();
}

class AReaderScreenState extends State<AReaderScreeen> {
  
  bool downloadingBook = false; // Идет получение книги
  String bookDownloadStatus = ''; // Статус при получении книги
  GlobalKey<UiReaderScrollModeState> scrollModeKey = GlobalKey<UiReaderScrollModeState>();
  GlobalKey<_UiReaderPagedModeState> pageModeKey = GlobalKey<_UiReaderPagedModeState>();
  bool initialLaunch = true;  
  String readStatus;
  double readPercents = 0;

  @override
  void initState() {
    Wakelock.enable();
    getBookForReading();    
    super.initState();
  }

  processTtsEvents() async {
    if (!AudioService.connected){
      await AudioService.connect();
    }
    if (!AudioService.running) {
      return;
    }    
    AudioService.customEventStream.listen((event) {
      print(event);
      if (event['type'] == 'chapterChanged'){
        widget.book.currentChapter = event['chapter'];
        this.reRender();
      }
    });
  }

  setInitialLaunch(bool value) {
    setState(() {
      initialLaunch = value;
    });
  }

  void getBookForReading() async {
    setState(() {
      downloadingBook = true;
    });

    await widget.book.downloadBook(onProgress: (status){
      setState(() {
        bookDownloadStatus = status;
      });
    });

    setState(() {
      downloadingBook = false;
    });
  }

  @override
  Widget build(BuildContext context){    
    return Scaffold(
      backgroundColor: AppColors.getColor('background'),
      drawer: Container(
        margin: EdgeInsets.only(right: 50),
        padding: EdgeInsets.all(10),
        color: AppColors.getColor('background'),
        child: ListView.builder(
          itemCount: widget.book.chapters.length,
          itemBuilder: (_, int index){
            BookChapter chapter = widget.book.chapters[index];
            return InkWell(
              onTap: (){
                widget.book.currentChapter = index;
                this.reRender();
                if (readerModeType == 'scroll') {
                  this.scrollModeKey.currentState.blocks = null;
                  this.scrollModeKey.currentState.getChapterBlocks();
                }
              },
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.secondary, width: 0.8))
                ),
                child: Text(chapter.title, style: TextStyle(
                  color: index == widget.book.currentChapter? AppColors.secondary: AppColors.grey,
                )),
              ),
            );
          },
        ),
      ),
      body: SlidingUpPanel(
        parallaxEnabled: true,
        parallaxOffset: .5,
        minHeight: 30,
        panelBuilder: (sc){          
          return MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: Stack(
              children: [
                Container(              
                  padding: EdgeInsets.symmetric(horizontal: 20),       
                  decoration: BoxDecoration(
                    color: AppColors.getColor('background'),  
                    border: Border(top: BorderSide(color: AppColors.grey, width: 0.5)),
                    boxShadow: [
                      BoxShadow(color: Colors.white, blurRadius: 10,)
                    ]
                  ), 
                  child: ListView(
                    controller: sc,
                    children: [
                      SizedBox(height: 5,),
                      Row(
                        children: [
                          widget.book.chapters != null && widget.book.chapters.length > widget.book.currentChapter? Expanded(
                            child: Text(widget.book.chapters[widget.book.currentChapter].title + (readStatus != null? ' ($readStatus)' : ''), style: TextStyle(
                              color: AppColors.grey,
                            ),),                    
                          ): Container(),
                          Center(child: Icon(Icons.expand_less_sharp, color: AppColors.getColor('black')))
                        ],
                      ),              
                      Divider(color: AppColors.grey,),
                      SizedBox(height: 10,),              
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,            
                        children: [
                          UiReaderButton(icon: Icon(Icons.arrow_back, color: Colors.white,), label: 'Назад', onTap: (){
                            Navigator.pop(context);
                          }),
                          UiReaderButton(icon: Icon(Icons.bookmark, color: Colors.white,), label: 'Сохранить', onTap: (){
                            CollectionAddDialog.open(context, widget.book, (){});
                          },),
                          UiReaderButton(icon: Icon(Icons.file_upload, color: Colors.white,), label: 'Поделиться', onTap: (){
                            BookShareDialog.open(context, widget.book, (){});
                          },),
                          UiReaderButton(icon: Icon(Icons.volume_up, color: Colors.white,), label: 'Слушать', onTap: () async {
                            if (!AudioService.connected) {
                              await AudioService.connect();
                            }    
                            if (AudioService.running) {
                              return;
                            }
                            await AudioService.start(
                              backgroundTaskEntrypoint: _entrypoint,
                              androidNotificationChannelName: 'TTS',
                              androidNotificationColor: 0xFF000000,
                              androidNotificationIcon: 'mipmap/ic_launcher_foreground',  

                              params: {
                                'book': widget.book.id
                              }        
                            );
                            processTtsEvents();
                            await AudioService.play();
                          }),              
                        ]
                      ),                                  
                      SizedBox(height: 20,), 
                      UiReaderSettings(onChanged: ({bool resetBlocks = false}){ 
                        reRender(resetBlocks: resetBlocks); 
                      }),
                    ],
                  ),
                ),
                Positioned(                  
                  child: LinearProgressIndicator(
                    minHeight: 2,
                    value: readPercents,
                    backgroundColor: AppColors.grey,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
                  ),
                )
              ],
            ),
          );
        },        
        body: Container(
          padding: EdgeInsets.only(bottom: 55),
          child: readerBody(),
        )
      ),
    );
  }

  readerBody() {
    print(readerModeType);
    if (downloadingBook){
      return UiReaderDownloadingBookMessage(bookDownloadStatus);
    }

    if (widget.book.chapters.isEmpty) {
      return UiReaderBookUnavailableMessage();
    }

    if (readerModeType == null) {
      return Container();
    }

    if (readerModeType == 'page') {
      return UiReaderPagedMode(book: widget.book, readerState: this, key: pageModeKey,);
    }
    return UiReaderScrollMode(widget.book, key: scrollModeKey, readerState: this);
    
  }

  reRender({bool resetBlocks = false }){
    setState(() {});

    if (readerModeType == 'scroll' && scrollModeKey.currentState != null) {
      scrollModeKey.currentState.setState(() {});
    }

    if (readerModeType == 'page' && pageModeKey.currentState != null) {
      if (resetBlocks) {
        pageModeKey.currentState.chapterPages = {};
      }
      pageModeKey.currentState.setState(() {});
      pageModeKey.currentState.buildPages();
    }
  }
}

class UiReaderButton extends StatelessWidget {

  @required
  final Widget icon;
  @required
  final String label;
  final Function onTap;

  UiReaderButton({this.icon, this.label, this.onTap});
  @override
  Widget build(BuildContext context) {    
    return Container(
      constraints: BoxConstraints(minWidth: 70),
      child: InkWell(
        onTap: (){
          onTap();
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.getColor('secondary'),
              ),
              child: icon,
            ),         
            Text(label, style: TextStyle(color: AppColors.getColor('secondary')))
          ],
        ),
      ),
    );
  }
}

class UiReaderDownloadingBookMessage extends StatelessWidget{

  final String bookDownloadStatus;

  UiReaderDownloadingBookMessage(this.bookDownloadStatus);
  @override
  Widget build(BuildContext context) {
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
}

class UiReaderBookUnavailableMessage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(child: Icon(Icons.error, color: AppColors.secondary), margin: EdgeInsets.only(right: 20),),
          Text('Ошибка. Книга недоступна', style: TextStyle(color: AppColors.getColor('black'))),
        ]
    );
  }
}

class UiReaderScrollMode extends StatefulWidget {

  final Book book;  
  final AReaderScreenState readerState;
  UiReaderScrollMode(this.book, {Key key, this.readerState}): super(key: key);

  @override
  State<StatefulWidget> createState() => UiReaderScrollModeState();
}

class UiReaderScrollModeState extends State<UiReaderScrollMode> {

  Parser parser;
  List<dynamic> blocks;
  ScrollController scrollController = ScrollController();
  int lastBuiltIndex = 0;

  @override
  void initState() {
    getChapterBlocks();
    processScrollEvents();
    super.initState();
  }

  getChapterBlocks() async {
    parser = new Parser();
    blocks = await parser.parse(widget.book.chapters[widget.book.currentChapter], returnBlocks: true);

    double scrollPosition = double.parse(await Preferences.get('book-' + widget.book.id.toString() + '-scroll', value: '0'));
    if (scrollPosition != null && widget.readerState.initialLaunch == true) {
      print('jump to $scrollPosition');      
      scrollController = ScrollController(initialScrollOffset: scrollPosition);
      widget.readerState.setInitialLaunch(false);
      processScrollEvents();
    }
    setState((){});
    setReadProgress();
  }

  setReadProgress() async {    
    while(!scrollController.hasClients) {
      await Future.delayed(Duration(milliseconds: 100));
    }
    double currentOffset = scrollController.offset;
    double maxOffset = scrollController.position.maxScrollExtent;

    int percents = currentOffset * 100 ~/ maxOffset;
    widget.readerState.readStatus = '$percents%';
    widget.readerState.readPercents = currentOffset / maxOffset;
    widget.readerState.setState(() {});
  }

  processScrollEvents() {
    Timer saveTimer;
    scrollController.addListener(() {      
      if (saveTimer != null) {
        saveTimer.cancel();
        saveTimer = null;
      }
      saveTimer = new Timer(Duration(milliseconds: 500), () async {
        print('Progress set!');
        setReadProgress();
        widget.book.progress = ((widget.book.currentChapter + 1) /  widget.book.chapters.length * 100).toInt() - 1;
        await widget.book.save();
        await serverApi.setProgress(widget.book);
        await Preferences.set('book-' + widget.book.id.toString() + '-scroll', scrollController.offset.toString());
      });          
    });
  }

  @override
  Widget build(BuildContext context) {

    if (blocks == null) {
      return Center(
        child: Text('Загрузка...', style: TextStyle(color: AppColors.getColor('black'))),
      );
    }
    return Container(      
      margin: EdgeInsets.symmetric(horizontal: 5),
      child: ListView.builder(         
        controller: scrollController,        
        itemBuilder: (_, int index){
          if (index == blocks.length) {
            if (widget.book.currentChapter == widget.book.chapters.length -1) {
              return UiReaderDoneButton(book: widget.book);
            }
            
            return UiReaderChapterButton(
              book: widget.book,
              chapter: widget.book.currentChapter + 1,
              onPress: (){
                widget.book.currentChapter = widget.book.currentChapter + 1;                
                setState(() {
                  blocks = [];  
                });
                widget.readerState.reRender();
                getChapterBlocks(); 
              },
            );
          }
          return parser.renderBlock(blocks[index]);
        },
        itemCount: blocks.length + 1,
      ),
    );
  }
}

class UiReaderSettings extends StatefulWidget {

  final Function onChanged;

  UiReaderSettings({this.onChanged});

  @override
  _UiReaderSettingsState createState() => _UiReaderSettingsState();
}

class _UiReaderSettingsState extends State<UiReaderSettings> {

  @override
  void initState() {
    loadPreferences();
    super.initState();
  }

  @override
  void setState(VoidCallback fn) {    
    super.setState(fn);
    widget.onChanged();
    // savePreferences();
  }

  savePreferences() async {
    await Preferences.set('editorFontSize', editorFontSize.toString());
    await Preferences.set('readerNightMode', readerNightMode ? '1' : '0');
    await Preferences.set('readerFontColor', [readerFontColor.alpha, readerFontColor.red, readerFontColor.green, readerFontColor.blue].join(','));
    await Preferences.set('readerFontFamily', readerFontFamily);
    await Preferences.set('readerModeType', readerModeType);
    print('Save: $readerModeType');
  }

  loadPreferences() async {
    editorFontSize = int.parse(await Preferences.get('editorFontSize', value: '16'));
    readerNightMode = (await Preferences.get('readerNightMode', value: '0')) == '1' ? true : false;
    String readerFontColorString = await Preferences.get('readerFontColor', value: null);
    if (readerFontColorString != null) {
      List<String> parts = readerFontColorString.split(',');
      readerFontColor = Color.fromARGB(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]), int.parse(parts[3]));
    }
    readerFontFamily = (await Preferences.get('readerFontFamily', value: readerFontFamily));
    print('preLoaded: $readerModeType');
    readerModeType = await Preferences.get('readerModeType', value: 'scroll');
    print('Loaded: $readerModeType');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ReaderTtsSettings(),
        fontSize(),
        SizedBox(height: 5),
        fontColor(),
        SizedBox(height: 5),
        nightMode(),
        SizedBox(height: 5),
        readerMode(),
        SizedBox(height: 5),
        fontFamily()
      ],
    );
  }

  fontSize(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Размер текста', style: TextStyle(color: AppColors.grey),),
        SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [   
            FloatingActionButton(onPressed: (){
              editorFontSize--;
              widget.onChanged(resetBlocks: true);
              savePreferences();
              setState(() {});
            }, child: Icon(Icons.remove), mini: true, heroTag: 'font-size-minus',),                      
            Text('Aa - $editorFontSize px', style: TextStyle(fontSize: editorFontSize.toDouble(), color: AppColors.grey, fontFamily: readerFontFamily)),
            FloatingActionButton(onPressed: (){
              editorFontSize++;
              widget.onChanged(resetBlocks: true);
              savePreferences();
              setState(() {});
            }, child: Icon(Icons.add), mini: true, heroTag: 'font-size-plus',),                       
          ],
        ),
      ],
    );
  }

  fontColor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Цвет текста', style: TextStyle(color: AppColors.grey),),
        SizedBox(height: 5),
        Row(
          children: [
            this.fontColorOption(AppColors.grey),
            this.fontColorOption(AppColors.secondary),
            this.fontColorOption(readerFontColor, pickColor: true),
          ],
        )
      ],
    );
  }

  Color pickedColor = Colors.blue;
  Widget fontColorOption(Color color, {bool pickColor = false}) {    
    return RawMaterialButton(      
      onPressed: () async {
        if (pickColor) {
          await showDialog(context: context, builder: (ctx){
            return AlertDialog(
              scrollable: true,
              content: ColorPicker(
                pickerColor: pickedColor,
                enableAlpha: false,                
                onColorChanged: (Color value){
                  setState(() {
                    pickedColor = value;
                  });
                },
              ),
              actions: [
                TextButton(
                  child: Text('OK'),
                  onPressed: (){
                    Navigator.pop(context);
                  },
                )
              ],
            );
          });
          print(pickedColor);
          setState((){
            readerFontColor = pickedColor;
          });  
          savePreferences();
          return;
        }
        setState((){
          readerFontColor = color;
        });        
      },
      constraints: BoxConstraints.tight(Size(36, 36)),
      shape: CircleBorder(),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: !pickColor? (color): (color != AppColors.grey && color != AppColors.secondary? color: Colors.blue),
          borderRadius: BorderRadius.circular(18),
        ),
        child: 
        pickColor? (color != AppColors.grey && color != AppColors.secondary? Icon(Icons.check, color: Colors.white,): Icon(Icons.color_lens, color: Colors.white))
        : (readerFontColor == color? Icon(Icons.check, color: Colors.white,) : Container()),
      ),
    );
  }

  Widget fontFamily()
  {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Шрифт', style: TextStyle(color: AppColors.grey),),
        SizedBox(height: 5),
        this.font('Roboto', 'Roboto'),
        this.font('TimesNewRoman', 'Times New Roman'),
        this.font('Georgia', 'Georgia'),
        this.font('Barlow', 'Barlow'),
        this.font('ComicSans', 'Comic Sans'),
      ],
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
              });
              savePreferences();
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

  Widget nightMode() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),      
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Ночной режим', style: TextStyle(
              fontSize: 14,
              color: AppColors.grey
          )),
          CupertinoSwitch(
            value: readerNightMode,
            onChanged: (bool value) { setState(() { readerNightMode = value; }); savePreferences(); },
          )
        ],
      ),
    );
  }

  Widget readerMode() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),      
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(readerModeType == 'scroll'? 'Прокрутка': 'Страницы', style: TextStyle(
              fontSize: 14,
              color: AppColors.grey
          )),
          CupertinoSwitch(
            value: readerModeType == 'scroll'? true: false,
            onChanged: (bool value) { readerModeType = value == true? 'scroll': 'page'; setState(() {}); savePreferences(); },
          )
        ],
      ),
    );
  }
}

class UiReaderChapterButton extends StatelessWidget {
  
  final Book book;
  final Function onPress;
  final int chapter;

  UiReaderChapterButton({this.book, this.onPress, this.chapter});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: EdgeInsets.only(bottom: 80),
        child: Column(
          children: [
            Divider(color: AppColors.secondary,),
            SizedBox(height: 10,),
            Text('К главе: ${book.chapters[chapter].title}', 
              style: TextStyle(
                color: AppColors.getColor('black'),
                fontWeight: FontWeight.w400
              )
            ),
            SizedBox(height: 10),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(AppColors.secondary)
              ),
              onPressed: (){
                onPress();
              }, 
              child: Text('Перейти', style: TextStyle(color: Colors.white))
            )
          ],
        ),
      ),
    );
  }
}

class UiReaderDoneButton extends StatelessWidget {
  final Book book;
  UiReaderDoneButton({this.book});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: EdgeInsets.only(bottom: 80),
        child: Column(
          children: [
            Divider(color: AppColors.secondary,),
            SizedBox(height: 10,),
            Text('Конец книги', 
              style: TextStyle(
                color: AppColors.getColor('black'),
                fontWeight: FontWeight.w400
              )
            ),
            SizedBox(height: 10),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(AppColors.secondary)
              ),
              onPressed: () async {
                book.progress = 100;
                await book.save();
                serverApi.setProgress(book);
                Navigator.pop(context);
              }, 
              child: Text('Закончить чтение', style: TextStyle(color: Colors.white))
            )
          ],
        ),
      ),
    );
  }
}

class UiReaderPagedMode extends StatefulWidget {

  final Book book;  
  final AReaderScreenState readerState;
  
  UiReaderPagedMode({this.book, this.readerState, Key key}) : super(key: key);

  @override
  _UiReaderPagedModeState createState() => _UiReaderPagedModeState();
}

class _UiReaderPagedModeState extends State<UiReaderPagedMode> {
  
  Map<int, List<dynamic>> chapterPages = {};
  PageController pageController = PageController();

  double readerHeight; // Высота читалки
  List<dynamic> pages = [];
  List<dynamic> currentPageWidgets = [];
  bool isPagesBuilt = false;
  double totalHeight = 0;
  Parser parser;
  Widget measureWidget;
  GlobalKey buildColumnKey = GlobalKey();
  int lastBuiltIndex = 0;

  @override
  void initState() {
    parser = new Parser();    
    buildPages();
    processPageTurnEvents();
    super.initState();    
  }

  processPageTurnEvents() {   
    
    pageController.addListener(() async {
      if (pageController.page - pageController.page.floor() > 0) {
        return;
      }

      await Preferences.set('book-' + widget.book.id.toString() + '-page', pageController.page.toInt().toString());        
      widget.book.progress = ((widget.book.currentChapter + 1) /  widget.book.chapters.length * 100).toInt() - 1;
      await widget.book.save();
      await serverApi.setProgress(widget.book);
      print('page Turned!');    
      setReadPercentage();

    });
  }
  Orientation currentOrientation;

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (context, orientation) {
      if (currentOrientation == null) {
        currentOrientation = orientation;
      }

      if (currentOrientation != orientation) {
        currentOrientation = orientation;
        chapterPages[widget.book.currentChapter] = null;
        buildPages();
      }
      return Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Opacity(
                opacity: 0,
                child: Container(
                  margin: EdgeInsets.only(left: 10, right: 10),
                  color: Colors.red,
                  child: measureWidget,
                  key: buildColumnKey,
                ),
              )
            ],
          ),
          readerBodyPaged()
        ],
      );
    });
          
  }

  setReadPercentage({int page}) {
    int cPage = page != null? page: pageController.page.toInt();
    widget.readerState.readStatus = "${cPage + 1}/${chapterPages[widget.book.currentChapter].length} стр.";
    widget.readerState.readPercents = (cPage + 1) / chapterPages[widget.book.currentChapter].length;
    widget.readerState.setState(() {
      
    });
  }

  readerBodyPaged() {    

    if (chapterPages[widget.book.currentChapter] == null ) {
      return Center(
        child: Text('Построение страниц...', style: TextStyle(color: AppColors.getColor('black')),),
      );
    }

    return Container(      
      child: PageView.builder(
        controller: pageController,
        itemBuilder: (_, int index) {
          List<dynamic> page = chapterPages[widget.book.currentChapter][index];    
          List<Widget> pageWidgets = page.map((e) {            
            lastBuiltIndex = index;            
            if (e['type'] == 'nextChapter') {
              return UiReaderChapterButton(
                book: widget.book,
                chapter: widget.book.currentChapter + 1,
                onPress: (){
                  widget.book.currentChapter++;
                  setState(() {});
                  widget.readerState.reRender();
                },
              );
            }

            if (e['type'] == 'doneBook') {
              return UiReaderDoneButton(book: widget.book);            
            }

            return this.parser.renderBlock(e);
          }).toList();         
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: pageWidgets,
            ),
          );
        },
        itemCount: chapterPages[widget.book.currentChapter].length,
      ),
    );
  }

  buildPages({int chapter = -1}) async {    
    while(buildColumnKey.currentContext == null) {   // Ждем начального рендеринга    
      await Future.delayed(Duration(milliseconds: 10));
    }

    if (chapter == -1) {
      chapter = widget.book.currentChapter;
    }

    readerHeight = MediaQuery.of(context).size.height - 70;
    String response = await widget.book.chapters[chapter].getContents();
    var json = jsonDecode(response);

    pages = [];
    currentPageWidgets = [];
    isPagesBuilt = false;
    totalHeight = 0;
    setState((){});

    if (chapterPages[chapter] == null) {

      // for (var block in json['blocks']) {    
      //   await addBlock(block);            
      // }

      // if (currentPageWidgets.length !=0 ) {
      //   pages.add(List<dynamic>.from(currentPageWidgets));
      // }

      // if (chapter + 1 < widget.book.chapters.length) {
      //   pages.add([
      //     {'type': 'nextChapter'}
      //   ]);
      // }
      
      pages = await PageBuilder.spawn(
        readerHeight: readerHeight,
        readerWidth: MediaQuery.of(context).size.width - 20,
        bookId: widget.book.id,
        chapter: chapter,
        editorFontSize: editorFontSize.toDouble(),
        readerFontFamily: readerFontFamily,
        onMeasure: (block) async {
          Widget c = this.parser.renderBlock(block);
          return (await measure(c)).height;
        },
        onMeasureText: (text, isHeader) async {
          return measureText(text, isHeader: isHeader);
        }
      );

      if (chapter + 1 < widget.book.chapters.length) {
        pages.add([
          {'type': 'nextChapter'}
        ]);
      }   

      if (chapter == widget.book.chapters.length) {
        pages.add([{
          'type': 'doneBook'
        }]);
      }
      
      chapterPages[chapter] = pages;
    }

    if (!mounted || widget.book.currentChapter != chapter) {
      return;
    }

    int page = int.tryParse(await Preferences.get('book-' + widget.book.id.toString() + '-page', value: '0'));
    if (widget.readerState.initialLaunch && page != null){
      print('initial page: $page');
      pageController = PageController(initialPage: page);
      widget.readerState.setInitialLaunch(false);
      processPageTurnEvents();
      setReadPercentage(page: page);
    } else {
      pageController = PageController(initialPage: 0);      
      processPageTurnEvents();
      setReadPercentage(page: 0);
    }
    
    setState((){});    

  }

  addBlock(block) async {    
    double measuredHeight;
    bool isText = false;
    bool isHeader = false;
    bool isImage = false;
    Widget c;
    switch (block['type']) {
      case 'header':
        c = this.parser.renderHeader(block);
        isText = true;
        isHeader = true;
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
      measuredHeight = measureText(block['data']['text'], isHeader: isHeader);
    } else {        
      measuredHeight = (await measure(c)).height;      
    }      

    currentPageWidgets.add(block);      

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

        searchFit(List<String> parts, double freespace, { int cutIndex, bool isHeader = false }) {          
          if (cutIndex == null) {
            cutIndex = parts.length -1;
          }

          if (cutIndex <= 2) {
            return null;
          }

          int testIndex = cutIndex ~/2;

          double size = measureText(parts.sublist(0, testIndex).join(' '), isHeader: isHeader);
          
          if (size > freespace){
            return searchFit(parts, freespace, cutIndex: testIndex);
          }

          bool fits = true;
          int tIndex = testIndex;
          while(fits && tIndex < parts.length) {
            tIndex++;            
            double s = measureText(parts.sublist(0, tIndex).join(' '), isHeader: isHeader);
            if (s > freespace) {
              return tIndex - 1;
            }
          }
          return tIndex;          
        }     

        // while (!fits && currentTestIndex > 0) {
        //   currentTestIndex --;
        //   String testText = parts.sublist(0, currentTestIndex).join(' ');
        //   double testHeight = measureText(testText);
        //   if (testHeight < freeSpace) {
        //     fits = true; // Влазит
        //   }
        // }
        // 
        currentTestIndex = searchFit(parts, freeSpace, isHeader: isHeader);
        if (currentTestIndex == null) {
          fits = false;
        } else {
          fits = true;
        }
        
        if (fits) { // Если влазит, добавляем на страницу
          var testBlock = {
            'type': 'paragraph',
            'data': {'text': parts.sublist(0, currentTestIndex).join(' ')}
          };
          
          currentPageWidgets.removeLast();
          currentPageWidgets.add(testBlock);

          pages.add(List<dynamic>.from(currentPageWidgets));
          totalHeight = 0;
          currentPageWidgets = [];
          
          // А теперь надо добавить остаток на другую страницу
          
          await addBlock({
            'data': {'text': parts.sublist(currentTestIndex).join(' ')},
            'type': 'paragraph',
          });
          
        } else { // Нифига не влазит - на след. страницу
          currentPageWidgets.removeLast();
          pages.add(List<dynamic>.from(currentPageWidgets));
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
        pages.add(List<dynamic>.from(currentPageWidgets));
        currentPageWidgets = List<dynamic>.from([block]);
        // print('Page ended!');            
        totalHeight = measuredHeight;
      }
    } else {
      // Все влазит
      totalHeight += measuredHeight;
    }
  }

  double measureText(String text, {bool isHeader = false}) {
    ParagraphBuilder pBuilder = ParagraphBuilder(ParagraphStyle(
      fontSize: isHeader? (editorFontSize + 12.0): editorFontSize.toDouble(),          
      fontFamily: readerFontFamily
    ));

    pBuilder.addText(text);    
    Paragraph p = pBuilder.build();
    p.layout(ParagraphConstraints(width: MediaQuery.of(context).size.width - 20));
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

  waitUntilRender() async {    
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
}


// Must be a top-level function
void _entrypoint() => AudioServiceBackground.run(() => ReaderBackgroundTask());

class ReaderBackgroundTask extends BackgroundAudioTask {
  final _tts = FlutterTts();
  Book book;

  int currentPart = 0;
  Map<int, List<dynamic>> chapterParts = {};

  bool stopPlaying = false;
  bool pausePlaying = false;
  onStart(params) async {
    book = await Book().where('id = ?', [params['book'].toString()]).first();
    await book.getChapters();
    
    print('started!');    
    
    await AudioServiceBackground.setState(
      playing: true,
      processingState: AudioProcessingState.ready,
      controls: [MediaControl.skipToPrevious, MediaControl.stop, MediaControl.skipToNext]
    ); 
    
    AudioServiceBackground.androidForceEnableMediaButtons();
    print('tts goes!1');

    currentPart = int.parse(await Preferences.get('${book.id}-${book.currentChapter}-tts-part', value: '0'));
    print('start from part: $currentPart');

    String pitch = await Preferences.get('ttsPitch');
    if (pitch != null) {
      await _tts.setPitch(double.parse(pitch));
    }

    String speechRate = await Preferences.get('ttsSpeechRate');
    if (speechRate != null) {
      await _tts.setSpeechRate(double.parse(speechRate));
    }

    String voiceName = await Preferences.get('ttsVoice');
    if (voiceName != null) {
      List<dynamic> voices = List<dynamic>.from(await _tts.getVoices);
      var voice = voices.where((element) => element['name'] == voiceName).toList().first;        
      await _tts.setVoice({
        'name': voice['name'],
        'locale': voice['locale'],
      });
    }
    
    AudioServiceBackground.sendCustomEvent({
      'type': 'settings',
      'voice': voiceName,
      'speechRate': speechRate,
      'pitch': pitch,
    });

    _tts.setStartHandler(() {
      AudioServiceBackground.setState(
        playing: true,
        processingState: AudioProcessingState.ready,
        controls: [MediaControl.skipToPrevious, MediaControl.stop, MediaControl.skipToNext]
      );
    });

    _tts.setCompletionHandler(() {
      AudioServiceBackground.setState(
        playing: false,
        processingState: AudioProcessingState.ready,
        controls: [MediaControl.play, MediaControl.stop]
      );
    });

    _tts.setProgressHandler((String text, int startOffset, int endOffset, String word) {
      
    });

    _tts.setErrorHandler((msg) {
      AudioServiceBackground.setState(
        playing: false,
        processingState: AudioProcessingState.error,
        controls: [MediaControl.play, MediaControl.stop]
      );
    });

    _tts.setCancelHandler(() {
      AudioServiceBackground.setState(
        playing: false,
        processingState: AudioProcessingState.stopped,
        controls: [MediaControl.play, MediaControl.stop]
      );
    });

    // iOS and Web
    _tts.setPauseHandler(() {
      AudioServiceBackground.setState(
        playing: false,
        processingState: AudioProcessingState.stopped,
        controls: [MediaControl.play, MediaControl.stop ]
      );
    });

    _tts.setContinueHandler(() {
      AudioServiceBackground.setState(
        playing: true,
        processingState: AudioProcessingState.ready,
        controls: [MediaControl.skipToPrevious, MediaControl.stop, MediaControl.skipToNext]
      );
    });
  }
  
  onStop() async {
    await _tts.stop();   
    await super.onStop();
  }

  play() async {
    
    while(book == null) {
      await Future.delayed(Duration(milliseconds: 10));
    }

    if (chapterParts[book.currentChapter] == null) {      
      BookChapter chapter = book.chapters[book.currentChapter];
      String json = await chapter.getContents();
      chapterParts[book.currentChapter] = jsonDecode(json)['blocks'];
    }

    await AudioServiceBackground.setMediaItem(
      MediaItem(
        album: book.title, 
        title: book.chapters[book.currentChapter].title, 
        id: '${book.id}-${book.currentChapter}', 
        artUri: Uri.parse(book.picture),
    ));
    int startFrom = currentPart;
    int index = 0;
    for (var block in chapterParts[book.currentChapter]) {      
      try {
        Preferences.set('${book.id}-${book.currentChapter}-tts-part', index.toString());
        AudioServiceBackground.sendCustomEvent({
          'type': 'indexChanged',
          'index': index,
          'total': chapterParts[book.currentChapter].length - 1, 
        });

        if (index < startFrom) {
          index++;
          print('continue');
          continue;
        }

        currentPart = index;

        String text = (block['data']?? {})['text'];
        if (text == null) {
          index++;
          continue;
        }
        print(text); 
        await _tts.speak(block['data']['text'].toString());
        await _tts.awaitSpeakCompletion(true);
        if (stopPlaying) {
          print('Stop playing!');
          stopPlaying = false;          
          break;
        }
        index++;
      } catch (e) {
        print('Catched:');
        print(e);
        await AudioServiceBackground.setState(
          playing: false,
          processingState: AudioProcessingState.error,
          controls: [MediaControl.play]
        );         
      }
    }

    if (book.currentChapter + 1 < book.chapters.length) {
      book.currentChapter++;
      await book.save();
      AudioServiceBackground.sendCustomEvent({
        'type': 'chapterChanged',
        'chapter': book.currentChapter,
      });
      currentPart = 0;
      play();
    }
  }

  @override
  Future<void> onPlay() async {
    print('play');

    play();
    
    return super.onPlay();
  }

  @override
  Future<void> onSkipToNext() async {
    stopPlaying = true;
    await _tts.stop();
    currentPart++;
    if (currentPart >= chapterParts[book.currentChapter].length){
      if (book.currentChapter + 1< book.chapters.length) {
        book.currentChapter++;
        currentPart = 0;
        await book.save();
        AudioServiceBackground.sendCustomEvent({
          'type': 'chapterChanged',
          'chapter': book.currentChapter,
        });
      } else {
        currentPart--;
        return super.onSkipToNext();
      }
    }
    stopPlaying = false;
    play();
    return super.onSkipToNext();
  }

  @override
  Future<void> onSkipToPrevious() async {
    stopPlaying = true;
    await _tts.stop();
    currentPart--;
    if (currentPart < 0) {
      currentPart = 0;      
      return super.onSkipToPrevious();
    } 
    stopPlaying = false;
    play();
    return super.onSkipToPrevious();
  }

  @override
  Future<void> onPause() {
    
    pause();
    
    return super.onPause();
  }

  pause() async {
    stopPlaying = true;
    await _tts.stop(); 
  }

  @override
  Future onCustomAction(String name, arguments) async {
    switch(name){
      case 'pitch':
        await pause();
        await _tts.setPitch(arguments[0]);
        Preferences.set('ttsPitch', arguments[0].toString());
        play();
        break;
      case 'speechRate':
        await pause();
        await _tts.setSpeechRate(arguments[0]);
        Preferences.set('ttsSpeechRate', arguments[0].toString());
        play();
        break;
      case 'setVoice':
        await pause();
        String voiceName = arguments[0];
        Preferences.set('ttsVoice', arguments[0].toString());
        List<dynamic> voices = List<dynamic>.from(await _tts.getVoices);
        var voice = voices.where((element) => element['name'] == voiceName).toList().first;        
        await _tts.setVoice({
          'name': voice['name'],
          'locale': voice['locale'],
        });
        play();
        break;
      case 'setIndex':        
        await pause();
        currentPart = arguments[0];
        stopPlaying = false;
        play();
        break;
      default:
        print('Unknown action: $name');
    }
    return super.onCustomAction(name, arguments);
  }
}

class ReaderTtsSettings extends StatefulWidget {
  @override
  _ReaderTtsSettingsState createState() => _ReaderTtsSettingsState();
}

class _ReaderTtsSettingsState extends State<ReaderTtsSettings> {

  FlutterTts tts;
  List<dynamic> voices;  
  int currentVoice;
  double speechRate = 0.5;
  double pitch = 1;

  int currentIndex = 0;
  int maxIndex = 0;

  StreamSubscription<dynamic> playbackSubscription;
  StreamSubscription<dynamic> customEventSubscription;

  @override
  void dispose() {
    Wakelock.disable();
    playbackSubscription.cancel();
    customEventSubscription.cancel();
    super.dispose();
  }

  @override
  void initState() {
    tts = FlutterTts();
    getVoices();
    // скорость tts.setSpeechRate(0 -> 1)
    // тон(высота) tts.setPitch(0.5 -> 2.0)
    // голос tts.setVoice    
    
    playbackSubscription = AudioService.playbackStateStream.listen((event) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });

    customEventSubscription = AudioService.customEventStream.listen((event) {
      if (event['type'] == 'indexChanged') {
        if (!mounted) {
          return;
        }
        setState(() {
          currentIndex = event['index'];
          maxIndex = event['total'];
        });
      }

      if (event['type'] == 'settings') {
        if (event['pitch'] != null) {
          pitch = double.parse(event['pitch']);
        }
        if (event['speechRate'] != null) {
          speechRate = double.parse(event['speechRate']);
        }
        if (event['voice'] != null) {
          getVoices().then((_){
            int index = 0;            
            for (var voice in voices) {
              if (event['voice'] == voice['name']) {                
                setState((){
                  currentVoice = index;
                });
              }
              index++;
            }
          });
        }
        if (!mounted) {
          return;
        }
        setState(() {});
      }
    });

    super.initState();
  }

  getVoices() async {
    voices = (await tts.getVoices).where((e) => e['locale'].toString().toLowerCase() == 'ru-ru').toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!AudioService.connected || !AudioService.running) {
      return Container();
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.grey,
        ),
        borderRadius: BorderRadius.circular(10)
      ),
      padding: EdgeInsets.all(5),
      margin: EdgeInsets.only(bottom: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('TTS', style: TextStyle(
              fontSize: 14,
              color: AppColors.secondary
          )),
          SizedBox(height: 5),
          controls(),
          SizedBox(height: 5),
          indexSlider(),
          SizedBox(height: 5),
          voiceSettings(),
          SizedBox(height: 5),
          speechRateSettings(),
          SizedBox(height: 5),
          pitchSettings(),          
        ],
      ),
    );
  }

  voiceSettings(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Голос', style: TextStyle(
            fontSize: 14,
            color: AppColors.grey
        )),
        SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(currentVoice == null? 'По умолчанию': 'Голос ${currentVoice + 1}: ${voices[currentVoice]['name']}')),
            FloatingActionButton(
              mini: true,
              child: Icon(Icons.list, color: Colors.white,),
              onPressed: () async {
                UiLoader.showLoader(context);                
                voices = List<dynamic>.from(await tts.getVoices);
                setState(() {});
                await Future.delayed(Duration(seconds: 1));
                await UiLoader.doneLoader(context);
              }
            ),
            FloatingActionButton(
              mini: true,
              child: Icon(Icons.more_horiz, color: Colors.white,),
              onPressed: (){
                showFloatingModalBottomSheet(
                  context: context,
                  builder: (_) {
                    return ListView.builder(
                      itemCount: voices.length,
                      shrinkWrap: true,
                      itemBuilder: (_, int index) {
                        return UiButton(
                          padding: EdgeInsets.all(5),
                          backgroundColor: Colors.white,
                          child: Align(child: Text('Голос ${index + 1}. ${voices[index]['name']}', style: TextStyle(color: AppColors.grey)), alignment: Alignment.centerLeft),
                          onPressed: () async {
                            setState(() {
                              currentVoice = index;
                            });
                            print(voices[index]['name']);                            
                            AudioService.customAction('setVoice', [voices[index]['name'].toString()]);
                            Navigator.pop(context);
                          },
                        );
                      }                      
                    );
                  }
                );
              },              
            ),            
          ],
        ),
      ],
    );
  }

  speechRateSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Скорость', style: TextStyle(
            fontSize: 14,
            color: AppColors.grey
        )),
        SizedBox(height: 5),
        Container(
          child: Slider(
            value: speechRate,
            min: 0,
            max: 1,
            onChanged: (double value){
              setState(() {
                speechRate = value;
              });
            },
            onChangeEnd: (double value){
              AudioService.customAction('speechRate', [speechRate]);
            },
          ),
        )
      ],
    );
  }

  pitchSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Тон', style: TextStyle(
            fontSize: 14,
            color: AppColors.grey
        )),
        SizedBox(height: 5),
        Container(
          child: Slider(
            value: pitch,
            min: 0.5,
            max: 2.0,
            onChanged: (double value){
              setState(() {
                pitch = value;
              });
            },
            onChangeEnd: (double value){
              AudioService.customAction('pitch', [pitch]).then((data){
                print(data);
              });
            },
          ),
        )
      ],
    );
  }

  controls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Управление', style: TextStyle(
            fontSize: 14,
            color: AppColors.grey
        )),
        SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            FloatingActionButton(
              mini: true,
              child: Icon(Icons.skip_previous, color: Colors.white),
              onPressed: (){
                AudioService.skipToPrevious();
              },
            ),
            FloatingActionButton(
              mini: true,
              child: Icon(AudioService.playbackState.playing? Icons.pause: Icons.play_arrow, color: Colors.white),
              onPressed: (){
                if (AudioService.playbackState.playing) {
                  AudioService.pause();                
                } else {
                  AudioService.play();
                }                
              },
            ),
            FloatingActionButton(
              mini: true,
              child: Icon(Icons.stop, color: Colors.white),
              onPressed: (){
                AudioService.stop();
              },
            ),
            FloatingActionButton(
              mini: true,
              child: Icon(Icons.skip_next, color: Colors.white),
              onPressed: (){
                AudioService.skipToNext();
              },
            ),
          ],
        ),
      ],
    );
  }

  indexSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Воспроизведение: $currentIndex / $maxIndex', style: TextStyle(
            fontSize: 14,
            color: AppColors.grey
        )),
        SizedBox(height: 5),
        Slider(
          min: 0,
          max: maxIndex.toDouble(),
          value: currentIndex.toDouble(),
          onChanged: (double value){
            setState(() {
              currentIndex = value.toInt();
            });            
          },
          onChangeEnd: (double value){
            AudioService.customAction('setIndex', [value.toInt()]);
          },
        )
      ]
    );
  }
}