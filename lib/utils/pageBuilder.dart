import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_app/models/book.dart';
import 'package:flutter_app/models/bookChapter.dart';
import 'package:flutter_app/utils/parser.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class PageBuilder {
  final double readerHeight;
  final double readerWidth;
  final int bookId;
  final int chapter;
  final Stream<dynamic> broadcast;
  final SendPort port;
  final double editorFontSize;
  final String readerFontFamily;
  final String directory;


  List<dynamic> pages = [];
  List<dynamic> currentPageWidgets = [];
  bool isPagesBuilt = false;
  double totalHeight = 0;
  Parser parser = Parser();

  PageBuilder({
     this.readerHeight = 0, 
     this.readerWidth = 0, 
     this.bookId, 
     this.chapter, 
     this.broadcast, 
     this.port,
     this.editorFontSize,
     this.readerFontFamily,
     this.directory,
  });

  build() async {            
    var response = await getContents();
    var json = jsonDecode(response);
    
    for (var block in json['blocks']) {    
        await addBlock(block);            
      }

      if (currentPageWidgets.length !=0 ) {
        pages.add(List<dynamic>.from(currentPageWidgets));
      }

      return pages;
  }

  getContents() async {
    String filename = directory + '/book-' + this.bookId.toString() + '-chapter-' + chapter.toString() + '.json';
    if (!await File(filename).exists()) {
      return null;//await http.read(this.getUrl());
    }
    return await File(filename).readAsString();
  }

  addBlock(block) async {    
    double measuredHeight;
    bool isText = false;
    bool isHeader = false;
    bool isImage = false;
    Widget c;
    switch (block['type']) {
      case 'header':
        // c = this.parser.renderHeader(block);
        isText = true;
        isHeader = true;
        break;
      case 'paragraph':
        // c = this.parser.renderParagraph(block);
        isText = true; 
        break;
      case 'list':
        // c = this.parser.renderList(block);
        break;
      case 'image':
        // c = this.parser.renderImage(block);
        isImage = true;
        break;
      case 'delimiter':
        // c = this.parser.renderDivider(block);
        break;
      default:
        print ('Unknown block: ' + block['type']);
        break;
    }
    
    if (isText) {
      measuredHeight = await measureTextParagraph(block['data']['text'], isHeader: isHeader);
    } else {        
      measuredHeight = await measure(block);     
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

        searchFit(List<String> parts, double freespace, { int cutIndex, bool isHeader = false }) async {          
          if (cutIndex == null) {
            cutIndex = parts.length -1;
          }

          if (cutIndex <= 2) {
            return null;
          }

          int testIndex = cutIndex ~/2;

          double size = await measureTextParagraph(parts.sublist(0, testIndex).join(' '), isHeader: isHeader);
          
          if (size > freespace){
            return await searchFit(parts, freespace, cutIndex: testIndex);
          }

          bool fits = true;
          int tIndex = testIndex;
          while(fits && tIndex < parts.length) {
            tIndex++;            
            double s = await measureTextParagraph(parts.sublist(0, tIndex).join(' '), isHeader: isHeader);
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
        currentTestIndex = await searchFit(parts, freeSpace, isHeader: isHeader);
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

  static Future<dynamic> spawn({
      double readerHeight, 
      double readerWidth, 
      int bookId, 
      int chapter,
      Function onMeasure,
      Function onMeasureText,
      double editorFontSize,
      String readerFontFamily,

  }) async {
    Completer completer = new Completer<dynamic>();
    
    ReceivePort isolateToMainStream = ReceivePort();
    SendPort mainToIsolateStream;
    Isolate myIsolateInstance;

    isolateToMainStream.listen((data) async {
      if (data is SendPort) {
        mainToIsolateStream = data;    
        mainToIsolateStream.send({
          'readerHeight': readerHeight,
          'readerWidth': readerWidth,
          'bookId': bookId,
          'chapter':chapter,
          'editorFontSize': editorFontSize,
          'readerFontFamily': readerFontFamily,
          'directory': (await getApplicationDocumentsDirectory()).path
        });  
      } else {
        if (data['type'] == 'exit') {
          myIsolateInstance.kill();
          isolateToMainStream.close();
          completer.complete(data['response']);
          return;
        }            
        if (data['type'] == 'measure') {
          var res = await onMeasure(data['block']);
          mainToIsolateStream.send(res);
        }
        if (data['type'] == 'measureText') {
          var res = await onMeasureText(data['text'], data['isHeader']);
          mainToIsolateStream.send(res);
        }        
      }
    });

    myIsolateInstance = await Isolate.spawn(myIsolate, isolateToMainStream.sendPort);

    return completer.future;
  }

  double measureText(String text, {bool isHeader = false}) {
    double size = isHeader? (editorFontSize + 12.0): editorFontSize.toDouble();
    List<String> words = text.split(' ');
    double cWidth = 0;
    int lines = 1;
    for (String word in words) {
      if (cWidth + word.length * size * 0.92> readerWidth) {
        lines++;
        cWidth = 0;
      } else {
        cWidth += word.length * size * 0.92;
      }
    }
    
    double height = lines * (size + 3) + 0;
    return height;

  }

  measure(block) async {
    port.send({
      'type': 'measure',
      'block': block,
    });
    return (await broadcast.take(1).toList()).first;
  }

  measureTextParagraph(text, {isHeader = false}) async {
    port.send({
      'type': 'measureText',
      'text': text,
      'isHeader': isHeader,
    });
    return (await broadcast.take(1).toList()).first;
  }
}

void myIsolate(SendPort isolateToMainStream) async {
  ReceivePort mainToIsolateStream = ReceivePort();
  isolateToMainStream.send(mainToIsolateStream.sendPort);
  Stream<dynamic> broadcast = mainToIsolateStream.asBroadcastStream();
  var config = (await broadcast.take(1).toList()).first;  

  PageBuilder builder = PageBuilder(
    readerHeight: config['readerHeight'], 
    readerWidth: config['readerWidth'], 
    bookId: config['bookId'],
    chapter: config['chapter'],
    broadcast: broadcast,
    port: isolateToMainStream,
    editorFontSize: config['editorFontSize'],
    readerFontFamily: config['readerFontFamily'],
    directory: config['directory'],
  );

  var response = await builder.build();  

  isolateToMainStream.send({
    'type': 'exit',
    'response': response
  });
}