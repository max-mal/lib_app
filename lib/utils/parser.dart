import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/models/bookChapter.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'dart:convert';

import 'package:html2md/html2md.dart' as html2md;
import 'package:flutter_markdown/flutter_markdown.dart';

import '../globals.dart';

class Parser {
  BuildContext context;

  Future<dynamic> parse(BookChapter chapter, {bool returnBlocks = false}) async {
    List<Widget> widgets = [];
    String response = await chapter.getContents();
    var json = jsonDecode(response);
    
    if (returnBlocks == true) {
      return List<dynamic>.from(json['blocks']);
    }

    for (var block in json['blocks']) {
      widgets.add(renderBlock(block));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  Widget renderBlock(block) {    
    switch (block['type']) {
      case 'header':
        return renderHeader(block);        
      case 'paragraph':
        return renderParagraph(block);        
      case 'list':
        return renderList(block);        
      case 'image':
        return renderImage(block);        
      case 'delimiter':
        return renderDivider(block);        
      default:
        print ('Unknown block: ' + block['type']);
        return Container();        
    }
  }

  Widget renderHeader(var block)
  {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Text(
          block['data']['text'],
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: block['data']['level'] == 1? (editorFontSize + 12.0): editorFontSize.toDouble(),
              color: readerFontColor,
              fontWeight: FontWeight.bold,
            fontFamily: readerFontFamily
          )
        ),
      ),
    );
  }

  Widget renderParagraph(var block)
  {
    return Container(      
      margin: EdgeInsets.symmetric(vertical: 5),
      child: parseText(block['data']['text'],)
    );
  }

  Widget renderList(var block)
  {
    List<Widget> listChildren = [];

    for (String item in block['data']['items']) {
      String prefix = '';
      if (block['data']['style'] == 'unordered') {
        prefix = ' - ';
      }
      listChildren.add(Container(
        margin: EdgeInsets.only(left: 12),
        child: Row(
          children: [
            Text(prefix),
            Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 85),
                child: parseText(item)
            ),
          ],
        )
      ));
    }
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: listChildren,
      ),
    );
  }

  Widget renderImage(var block)
  {
    return Container(
      color: Colors.white,
      margin: EdgeInsets.symmetric(vertical: 5),
      child: Column(
        children: [
          CachedNetworkImage(
            cacheManager: DefaultCacheManager(),
            imageUrl: block['data']['file']['url'],
            placeholder: (context, url) => Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) => Icon(Icons.error),
            height: 300,
            fit: BoxFit.scaleDown,
          ),
        block['data']['caption'] != null ? (Container(
            margin: EdgeInsets.symmetric(vertical: 2),
            child: parseText(block['data']['text'])
          )) : (Container())
        ],
      ),
    );
  }

  Widget renderDivider(var block)
  {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 12),
      child: Divider(
        color: readerFontColor,
        height: 2,
      ),
    );
  }

  Widget parseText(text, {TextStyle style}){
//    return Text(text);
    if (style == null) {
      style = TextStyle(
          fontSize: editorFontSize.toDouble(),
          color: readerFontColor,
        fontFamily: readerFontFamily
      );
    }
    String data = html2md.convert(text, styleOptions: { 'headingStyle': 'atx' }, ignore: ['script', 'style']);
    return MarkdownBody(data: data, styleSheet: MarkdownStyleSheet(
      p: style
    ),);
  }

  Future<List<String>> parseToText(BookChapter chapter) async {
    List<String> text = [];
    String response = await chapter.getContents();
    var json = jsonDecode(response);

    print(json);

    for (var block in json['blocks']) {
      switch (block['type']) {
        case 'header':
          text.add(block['data']['text']);
          break;
        case 'paragraph':
          text.add(block['data']['text']);
          break;
        case 'list':
          for (String item in block['data']['items']) {
            text.add(item);
          }
          break;
      }
    }

    return text;
  }
}