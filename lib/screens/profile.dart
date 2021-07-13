import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/parts/bottomNavBar.dart';
import 'package:flutter_app/parts/button.dart';
import 'package:flutter_app/parts/input.dart';
import 'package:flutter_app/screens/subscriptionBuy.dart';
import 'package:flutter_app/ui/button.dart';
import 'package:flutter_app/ui/loader.dart';
import 'package:flutter_app/utils/modal.dart';
import 'package:flutter_app/utils/transparent.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import '../colors.dart';
import '../globals.dart';

class ProfileScreen extends StatefulWidget {

  const ProfileScreen({
    Key key,
  }) : super(key: key);

  _ProfileScreenState createState() => _ProfileScreenState();

  static open(context) async {
    await Navigator.of(context).push(
        TransparentRoute(builder: (BuildContext context) => ProfileScreen())
    );
  }
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {

  int currentTab = 0;
  TabController _tabController;
  bool mainInfoEdit = false;
  bool editPassword = false;

  final searchController = TextEditingController();

  TextEditingController userNameController = TextEditingController();
  TextEditingController userLastNameController = TextEditingController();
  TextEditingController userEmailController = TextEditingController();

  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordConfirmController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    snackBarContext = context;
    userNameController.text = user.name;
    userLastNameController.text = user.lastName;
    userEmailController.text = user.email;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavBar(
        title: 'Профиль'
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 15),
        margin: EdgeInsets.only(top: 30),
        child:NestedScrollView(
          headerSliverBuilder: (context, value){
            return [
              SliverToBoxAdapter(child: this.header(),),
            ];
          }, 
          body: this.tabs()
        )
      ),
    );
  }

  Widget header()
  {
    return Container(
      child: Column(
        children: [
          GestureDetector(
            onTap: () async {

              showFloatingModalBottomSheet(context: context, builder: (_){
                return Container(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      UiButton(
                        padding: EdgeInsets.all(5),
                        backgroundColor: Colors.white,
                        borderColor: AppColors.grey,
                        child: Row(
                          children: [
                            Icon(Icons.camera, size: 30, color: AppColors.grey),
                            SizedBox(width: 10,),
                            Text('Сделать фото', style: TextStyle(
                              color: AppColors.grey
                            )),
                          ],
                        ),
                        onPressed: (){
                          selectImage(ImageSource.camera);
                        },
                      ),
                      SizedBox(height: 12,),
                      UiButton(
                        padding: EdgeInsets.all(5),
                        backgroundColor: Colors.white,
                        borderColor: AppColors.grey,
                        child: Row(
                          children: [
                            Icon(Icons.photo, size: 30, color: AppColors.grey),
                            SizedBox(width: 10,),
                            Text('Выбрать фото', style: TextStyle(
                              color: AppColors.grey
                            )),
                          ],
                        ),
                        onPressed: (){
                          selectImage(ImageSource.gallery);
                        },
                      ),
                    ],
                  ),
                );
              });
              return;
              
            },
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.grey),
                borderRadius: BorderRadius.circular(40),
                image: user.picture == null? DecorationImage(image: AssetImage("assets/logo.png")) : DecorationImage(image: CachedNetworkImageProvider(user.picture), fit: BoxFit.cover),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 12),
            child: Text((user.name ?? '<нет имени>') + ' ' + (user.lastName ?? ''), style: TextStyle(color: Colors.black, fontSize: 16)),
          ),
        ],
      ),
    );
  }


  selectImage(ImageSource source) async {
    Navigator.pop(context);
    final ImagePicker picker = ImagePicker();
    final PickedFile  pickedFile = await picker.getImage(source: source);
    if (pickedFile == null) {
      return;
    }
    UiLoader.showLoader(context);
    try {
      await serverApi.uploadAvatar(pickedFile.path);
      await serverApi.getUser();
      await UiLoader.doneLoader(context);     
      await DefaultCacheManager().removeFile(user.picture);   
      await CachedNetworkImage.evictFromCache(user.picture);        
      String pic = user.picture;
      setState(() {
        user.picture = null;
      });
      await Future.delayed(Duration(seconds:1));
      setState(() {
        user.picture = pic;
      });
    } catch (e) {
      await UiLoader.errorLoader(context);
      throw e;
    }
  }



  Widget tabs()
  {
    return Stack(
      children: [        
        Container(
          margin: EdgeInsets.only(top: 60),
          child: TabBarView(
              controller: _tabController,
              children: [
                this.mainInfoTab(),
                this.security(),                
              ]
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          left: 0,
          child: Container(
            decoration: BoxDecoration(              
                color: Colors.white.withOpacity(0.0),
                border: Border(bottom: BorderSide(color: AppColors.primary, width: 0.8))),
            child: TabBar(
              labelColor: AppColors.secondary,
              unselectedLabelColor: AppColors.grey,
              indicatorColor: AppColors.secondary,
              controller: _tabController,
              tabs: [
                Tab(text: 'Общее'),
                Tab(text: 'Безопасность'),                
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget mainInfoItem(String label, Function value, {List<Widget> editWidgets, TextEditingController controller, Function onChanged}) {
    return Container(
      margin: EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(margin:EdgeInsets.only(bottom: 8), child: Text(label, style: TextStyle(color: AppColors.secondary, fontSize: 14))),
          !mainInfoEdit?
            Container(child: Text(value(), style: TextStyle(color: AppColors.grey, fontSize: 16)))
          :
          (
              editWidgets != null ? Column(children: editWidgets) : Container(child: AppInputWidget( onChanged: onChanged, controller: controller, )
              ,
            )
          ),
        ],
      ),
    );
  }

  Widget mainInfoTab(){    
    return SingleChildScrollView(
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(margin: EdgeInsets.only(bottom: 24),child: Text('Основная информация', style: TextStyle(color: AppColors.grey, fontSize: 20))),
            this.mainInfoItem('Мое имя', (){return '${user.getName()} ${user.getLastName()}';}, editWidgets: [
              Container(child: AppInputWidget( onChanged: (value){
                setState(() {
                  user.name = value;
                });
              }, controller: userNameController, placeholder: 'Имя',  )),
              Container(child: AppInputWidget( onChanged: (value){
                setState(() {
                  user.lastName = value;
                });
              }, controller: userLastNameController, placeholder: 'Фамилия',))
            ]),
            this.mainInfoItem('Электронная почта', (){return user.email;}, controller: userEmailController, onChanged: (value) {
              setState(() {
                user.email = value;
              });
            }),
            AppButtonWidget(
              text: mainInfoEdit? 'Сохранить' : 'Редактировать',
              color: AppColors.getColor('white'),
              textColor: AppColors.grey,
              border: Border.all(color: AppColors.primary),
              onPress: (){
                if (mainInfoEdit) {
                  user.store();
                }
                setState(() {
                  mainInfoEdit = !mainInfoEdit;
                });
              },
            )
          ],
        ),
      ),
    );
  }

  Widget subscriptionTab() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(margin: EdgeInsets.only(bottom: 24),child: Text('Основная информация', style: TextStyle(color: AppColors.grey, fontSize: 20))),
          Container(
              margin: EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Text('Ваша подписка: ', style: TextStyle(color: AppColors.secondary, fontSize: 14)),
                  Text(user.subscription == null? 'Нет' : user.subscription.name, style: TextStyle(color: AppColors.grey, fontSize: 14)),
                ],
              )
          ),
          (user.subscription != null ? Container(margin: EdgeInsets.only(bottom: 24),child: Text('Срок действия вашего пакета истечет ' + user.getExpiration(), style: TextStyle(color: AppColors.grey, fontSize: 20))) : Container() ),
          Container(
            margin: EdgeInsets.only(top: 50),
            child: AppButtonWidget(
              text: 'Измеить',
              border: Border.all(color: AppColors.primary),
              color: AppColors.getColor('white'),
              textColor: AppColors.grey,
              onPress: (){
                SubscriptionBuyScreen.open(context, (){
                  setState((){});
                });
              },
            ),
          )

        ],
      ),
    );
  }

  Widget security(){
    return SingleChildScrollView(
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin:EdgeInsets.only(bottom: 24),
              child: Text('Безопасность', style: TextStyle(color: AppColors.grey, fontSize: 20)),
            ),
            Text('Сменить пароль', style: TextStyle(color: AppColors.grey, fontSize: 16)),
            editPassword? Container() : Container(
              margin:EdgeInsets.only(top: 24, bottom: 8),
              child: Text('Текущий пароль', style: TextStyle(color: AppColors.secondary, fontSize: 14)),
            ),
            editPassword? Container(
              margin: EdgeInsets.only(top: 20),
              child: (
                Column(
                  children: [
                    AppInputWidget(
                      placeholder: 'Новый пароль',
                      controller: passwordController,
                      obscure: true,
                    ),
                    AppInputWidget(
                      placeholder: 'Подтверждение',
                      controller: passwordConfirmController,
                      obscure: true,
                    ),
                  ],
                )
              ),
            ) :
            Container(
              margin:EdgeInsets.only(bottom: 24),
              child: Text('********', style: TextStyle(color: AppColors.grey, fontSize: 16)),
            ),
            InkWell(
              onTap: () async {

                if (editPassword == true) {
                  if (passwordConfirmController.text != passwordController.text) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(
                      'Пароль и подтверждение не совпадают'
                    )));
                    return;
                  }
                  if (passwordController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(
                      'Пароль не должен быть пустым'
                    )));
                    return;
                  }
                  UiLoader.showLoader(context);
                  try {
                    await serverApi.changePassword(passwordController.text.trim());
                    await UiLoader.doneLoader(context);
                  } catch (e) {
                    await UiLoader.errorLoader(context);
                    throw e;
                  }
                }

                setState(() {
                  editPassword = !editPassword;
                });
                
              },
              child: Container(
                width: MediaQuery.of(context).size.width - 48,
                margin:EdgeInsets.only(bottom: 40),
                child: Text(editPassword? 'Сохранить' : 'Изменить мой пароль', style: TextStyle(color: AppColors.grey, fontSize: 16, decoration: TextDecoration.underline,)),
              ),
            ),
            // Divider(
            //   color: AppColors.secondary,
            //   height: 1,
            // ),
            // Container(
            //   margin:EdgeInsets.only(top: 30, bottom: 8),
            //   child: Text('Удалить учетную запись', style: TextStyle(color: AppColors.grey, fontSize: 16)),
            // ),
            // Container(
            //   margin:EdgeInsets.only(top: 24, bottom: 24),
            //   child: Text('Навсегда удалите свою учетную запись и весь ваш контент.', style: TextStyle(color: AppColors.secondary, fontSize: 14)),
            // ),
            // Container(
            //   child: Text('Удалить мой аккаунт', style: TextStyle(color: AppColors.grey, fontSize: 16, decoration: TextDecoration.underline,)),
            // ),
          ],
        ),
      ),
    );
  }
}


class FloatingModal extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;

  const FloatingModal({Key key, this.child, this.backgroundColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Material(
          color: backgroundColor,
          clipBehavior: Clip.antiAlias,
          borderRadius: BorderRadius.circular(12),
          child: child,
        ),
      ),
    );
  }
}

Future<T> showFloatingModalBottomSheet<T>({
  BuildContext context,
  WidgetBuilder builder,
  Color backgroundColor,
}) async {
  final result = await showCustomModalBottomSheet(
      context: context,
      builder: builder,
      containerWidget: (_, animation, child) => FloatingModal(
            child: child,
          ),
      expand: false);

  return result;
}