import 'package:flutter/material.dart';
import 'package:flutter_app/parts/button.dart';
import 'package:flutter_app/parts/input.dart';
import 'package:flutter_app/screens/subscriptionBuy.dart';
import 'package:flutter_app/utils/transparent.dart';
import '../colors.dart';
import '../globals.dart';

class ProfileScreen extends StatefulWidget {

  const ProfileScreen({
    Key key,
  }) : super(key: key);

  _ProfileScreenState createState() => _ProfileScreenState();

  static void open(context) {
    Navigator.of(context).push(
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    snackBarContext = context;
    userNameController.text = user.name;
    userLastNameController.text = user.lastName;
    userEmailController.text = user.email;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 24),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Container(
                  child: IconButton(icon: Icon(Icons.arrow_back_ios), onPressed: () {
                    Navigator.pop(context);
                  }),
                ),
              ),
            ),
            Container(
//              height: MediaQuery.of(context).size.height - 80,
              width: MediaQuery.of(context).size.width,
              child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        this.header(),
                        this.tabs(),
                      ],
                    ),
                  )
              ),
          ],
        ),
      ),
    );
  }

  Widget header()
  {
    return Container(
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.grey,
              borderRadius: BorderRadius.circular(40),
              image: user.picture == null? null :DecorationImage(image: NetworkImage(user.picture), fit: BoxFit.cover),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 12),
            child: Text((user.name ?? '') + ' ' + (user.lastName ?? ''), style: TextStyle(color: Colors.black, fontSize: 16)),
          ),
          user.subscription != null? Container(
            margin: EdgeInsets.only(top: 4),
            child: Text(user.subscription.name, style: TextStyle(color: AppColors.secondary, fontSize: 14)),
          ) : Container()
        ],
      ),
    );
  }






  Widget tabs()
  {

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            //This is for background color
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
              Tab(text: 'Подписка'),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 40),
          width: MediaQuery.of(context).size.width - 48,
          height: MediaQuery.of(context).size.height - 250,
          child: TabBarView(
              controller: _tabController,
              children: [
                this.mainInfoTab(),
                Container(
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
                              ),
                              AppInputWidget(
                                placeholder: 'Подтверждение',
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
                        onTap: () {
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
                      Divider(
                        color: AppColors.secondary,
                        height: 1,
                      ),
                      Container(
                        margin:EdgeInsets.only(top: 30, bottom: 8),
                        child: Text('Удалить учетную запись', style: TextStyle(color: AppColors.grey, fontSize: 16)),
                      ),
                      Container(
                        margin:EdgeInsets.only(top: 24, bottom: 24),
                        child: Text('Навсегда удалите свою учетную запись и весь ваш контент.', style: TextStyle(color: AppColors.secondary, fontSize: 14)),
                      ),
                      Container(
                        child: Text('Удалить мой аккаунт', style: TextStyle(color: AppColors.grey, fontSize: 16, decoration: TextDecoration.underline,)),
                      ),
                    ],
                  ),
                ),
                this.subscriptionTab(),
              ]
          ),
        )
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
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(margin: EdgeInsets.only(bottom: 24),child: Text('Основная информация', style: TextStyle(color: AppColors.grey, fontSize: 20))),
          this.mainInfoItem('Мое имя', (){return (user.name ?? '')  + ' ' + (user.lastName ?? '');}, editWidgets: [
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


}