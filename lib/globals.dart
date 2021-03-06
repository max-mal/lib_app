import 'dart:io';

import 'package:flutter/material.dart';
import 'api.dart';
import 'colors.dart';
import 'models/collection.dart';
import 'models/subscription.dart';
import 'models/user.dart';

GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
List<Collection> userCollections = [];
BuildContext snackBarContext;

bool editorSmallText = true;
int editorFontSize = 16; 
bool readerNightMode = false;
String readerModeType;
Color readerFontColor = AppColors.grey;
String readerFontFamily = 'Roboto';

Directory documentDirectory;
User user;

List<Subscription> subscriptions = Subscription.generate();

ServerApi serverApi = new ServerApi();
List<int> readingBooksHideIds = [];