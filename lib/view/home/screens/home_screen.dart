import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloudinary_sdk/cloudinary_sdk.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:okoto/backend/user/user_provider.dart';
import 'package:okoto/package/my_coverflow_package.dart';
import 'package:okoto/view/common/components/my_screen_background.dart';
import 'package:okoto/view/device/screens/devices_screen.dart';
import 'package:okoto/view/profile_screen/screens/profile_screen.dart';
import 'package:provider/provider.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import '../../../configs/styles.dart';
import '../../../model/user/user_model.dart';
import '../../../package/slider_widget_package.dart';
import '../../../utils/my_print.dart';
import '../../authentication/screens/login_screen.dart';
import '../../common/components/common_loader.dart';
import '../../common/components/common_text.dart';
import '../../common/components/image_slider.dart';
import '../../common/components/modal_progress_hud.dart';
import '../../common/components/my_profile_avatar.dart';
import '../../subscription/screens/subscription_list_screen.dart';
import 'dart:math';

class HomeScreen extends StatefulWidget {
  static const String routeName = "/HomeScreen";
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>  with SingleTickerProviderStateMixin {
  late ThemeData themeData;
  int screenSelected = 0;
  late UserProvider userProvider;
  bool isLoading = false;
  TabController? tabController;
  List<String> bannerImages = <String>[];



  void initializeBannerImages() {
    bannerImages = [
      "https://res.cloudinary.com/dxegfkhzd/image/upload/v1677566819/pexels-sound-on-3761118_v4fec1.jpg",
      "https://res.cloudinary.com/dxegfkhzd/image/upload/v1677566812/Asphalt_wpjhwy.png",
      "https://res.cloudinary.com/dxegfkhzd/image/upload/v1677566812/CSGO_ocbjdq.jpg",
      "https://res.cloudinary.com/dxegfkhzd/image/upload/v1677566811/pubg_zvj0fi.jpg",
    ];
    if(bannerImages.isNotEmpty) {
      tabController =  TabController(length: bannerImages.length, vsync: this);
    }
    else {
      tabController = null;
    }
  }

  @override
  void initState() {
    super.initState();
    initializeBannerImages();
    userProvider = Provider.of<UserProvider>(context);
  }

  @override
  Widget build(BuildContext context) {
    themeData = Theme.of(context);
    MyPrint.printOnConsole("HomeScreen Build Called");
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      progressIndicator: const CommonLoader(),
      child:  Consumer<UserProvider>(
          builder: (BuildContext context, UserProvider userProvider, Widget? child) {
            UserModel? userModel = userProvider.getUserModel();
            if(userModel == null){
              return SizedBox();
            }
            return Scaffold(
              body: MyScreenBackground(
                child: SafeArea(
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              getMyAppBar(),
                              const SizedBox(height: 15,),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: getImageSlider(bannerImages: bannerImages),
                              ),
                              const SizedBox(height: 25,),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const CommonText(text: 'My Account', fontSize: 19, fontWeight: FontWeight.bold),
                                    const SizedBox(height: 25),
                                    getMyAccountCard(),
                                    const SizedBox(height: 35),
                                    const CommonText(text: 'Explore', fontSize: 19, fontWeight: FontWeight.bold),
                                    const SizedBox(height: 25),
                                    getExploreWidget(),
                                    const SizedBox(height: 150),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              floatingActionButton: getLetsPlayButton(),
              floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
            );
          } ),
    );
  }

  // ClipPath(
  // clipper: _CustomClipper(),
  // clipBehavior: Clip.antiAlias,
  // child: getImageSlider(bannerImages: bannerImages),
  // ),

  Widget getMyAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 20),
      child: Row(
        children: [
          GradientText(
            "Okoto",
            textAlign: TextAlign.start,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              fontSize: 26,
            ),
            gradientDirection: GradientDirection.ttb,
            colors: [
              Styles.myLogoBlueColor,
              Styles.myLogoVioletColor,
            ],
          ),
          const Spacer(),
          Image.asset(
            "assets/images/vr_icon.png",
            height: 20,
            width: 26,
            fit: BoxFit.fill,
          ),
          const SizedBox(width: 14,),
          const Icon(MdiIcons.bell,color: Colors.white,size: 24,),
          const SizedBox(width: 14,),
          MyProfileAvatar(),
        ],
      ),
    );
  }

  //region ImageSlider

  Widget getImageSlider({required List<String> bannerImages}){
    if(bannerImages.isEmpty || tabController == null) {
      return const SizedBox();
    }

    double width = MediaQuery.of(context).size.width;
   // double width = double.maxFinite;

    return ImageSlider(
      showTabIndicator: true,
      tabIndicatorColor: const Color(0xffE4E4E4),
      tabIndicatorSelectedColor:Styles.myVioletShade4,
      tabIndicatorHeight: 16,
      tabIndicatorSize: 6,
      tabController: tabController!,
      curve: Curves.fastOutSlowIn,
      width: width,
      height: 218,
      //height: 280,
      autoSlide: true,
      duration:   const Duration(seconds: 5),
      allowManualSlide: true,
      children: bannerImages.map((image) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 0),
          child: CachedNetworkImage(
            imageUrl: CloudinaryImage(image)
                .transform()
                .width(700)
                .height(394)
                .crop("fill")
                .generate() ??
                image,
            fit: BoxFit.fill,
            placeholder: (context, _) {
              return const Center(
                child: CommonLoader(),
              );
            },
            errorWidget: (___, __, _) {
              return Container(
                color: Colors.grey[200],
                child: Icon(
                  Icons.image_outlined,
                  color: Colors.grey[400],
                  size: 100,
                ),
              );
            },
          ),
        );
      }).toList(),
    );
  }

  //endregion

  //region My Account

  Widget getMyAccountCard(){
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
              gradient: LinearGradient(
                colors: [
                  Styles.cardGradient1,
                  Styles.cardGradient2,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          getMyProfileRow(userName: 'viren1904'),
          const SizedBox(height: 8,),
          const CommonText(text: 'Premium Subscription',fontSize: 19,fontWeight: FontWeight.bold),
          const SizedBox(height: 12,),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child:Padding(
                    padding:  const EdgeInsets.symmetric(vertical: 5.0),
                    child: getMyPlanDetails(),
                  ) ,
                ),
                const VerticalDivider(color: Colors.white,width: 5,thickness: 1.2,),
                Expanded(
                  child:Padding(
                    padding:  const EdgeInsets.symmetric(vertical: 5.0),
                    child: MyValidityCircle(),
                  ) ,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget getMyProfileRow({String userName = 'username'}){
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        MyProfileAvatar(size: 23),
        const SizedBox(width: 8,),
        CommonText(text: userName,fontSize: 14,)
      ],
    );
  }

  Widget getMyPlanDetails(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
            text: TextSpan(
              text: '160 ₹  ',
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w500
              ),
              children: [
                TextSpan(
                  text: 'monthly ',
                  style: TextStyle(
                      fontWeight: FontWeight.normal,
                    fontSize: 13,
                    color: Colors.white.withOpacity(.7)


                  ),
                )
              ]

            ),
        ),
        const SizedBox(height: 10,),
        showDetailsRichText(
          heading:'Subscribed on',
          mainText: '26 Aug 22',
        ),
        const SizedBox(height: 10,),
        showDetailsRichText(
          heading:'Most played game',
          mainText: 'Cricket',
        ),
      ],
    );
  }

  Widget showDetailsRichText({required String heading,required String mainText}){
    return RichText(
      text: TextSpan(
          text: '$heading :\n',
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: Colors.white.withOpacity(.7)
          ),
          children: [
            TextSpan(
              text: '$mainText ',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 15,
                color: Colors.white,
              ),
            )
          ]

      ),
    );
  }

  Widget MyValidityCircle(){
    return Stack(
      alignment: Alignment.center,
      children: [
      SizedBox(
        height: 100,
        width: 100,
        child: Transform.scale(
          scaleX: -1,
          child: CircularProgressIndicator(
          value: 0.9,
          strokeWidth: 4.5,
          color:Styles.myLightVioletShade1,
          ),
        ),
      ),
        Container(
          padding: const EdgeInsets.only(bottom: 5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CommonText(text: '26',fontWeight: FontWeight.bold,fontSize: 30),
              const SizedBox(height: 2,),
              CommonText(text: 'Days left',fontSize: 11,color: Colors.white.withOpacity(.8),textAlign: TextAlign.center),
            ],
          ),
        ),
      ],
    );
  }

//endregion

  //region Explore

  Widget getExploreWidget(){
    double spacing = 15;
    return Column(
      children: [
        Row(
          children: [
            exploreBox(imageUrl: 'assets/icons/device.png',title: 'Device'),
            SizedBox(width:spacing ,),
            exploreBox(imageUrl: 'assets/icons/subscriptions.png',title: 'Subscription'),
            SizedBox(width:spacing ,),
            exploreBox(imageUrl: 'assets/icons/payment.png',title: 'Payment History'),
          ],
        ),
        SizedBox(height:spacing,),
        Row(
          children: [
            exploreBox(imageUrl: 'assets/icons/my_games.png',title: 'Play time'),
            SizedBox(width:spacing ,),
            exploreBox(imageUrl: 'assets/icons/myplans.png',title: 'My games'),
            SizedBox(width:spacing ,),
            exploreBox(imageUrl: 'assets/icons/recomended_plans.png',title: 'Recommended Plans'),

          ],
        )

      ],
    );
   }

  Widget exploreBox({String imageUrl ="assets/images/vr_icon.png", String title = 'Device'}){
      return Expanded(
        child: Container(
          height: 85,
          padding: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(
              colors: [
                Styles.cardGradient1,
                Styles.cardGradient2,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                imageUrl,
                height: 19,
                width: 23,
                fit: BoxFit.fill,
              ),
              const SizedBox(height: 5,),
              CommonText(text: title,textAlign: TextAlign.center,fontSize: 12),
            ],
          ),
        ),
      );
   }

   //endregion

  Widget getLetsPlayButton(){
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 60).copyWith(bottom: 20),
      child: SliderWidgetPackage(
        alignment: Alignment.bottomCenter,
        sliderButtonIconPadding: 16,
       // innerColor: Colors.green,
        outerColor: Colors.white,
        submittedIcon:getSubmitIcon(),
        borderRadius: 120,
        height: 65,
        sliderButtonIcon: const Icon(Icons.person_outline),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            SizedBox(width: 70,),
            Expanded(
              child: CommonText(
                text: 'Swipe to play game',
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: 18,
              ),
            ),
            SizedBox(width: 20,),
          ],
        ),


        onSubmit: (){},



      ),
    );
  }

  Widget getSubmitIcon() {
    return  Container(
      height: double.maxFinite,
      width: double.maxFinite,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              Styles.gameButtonShade1,
              Styles.gameButtonShade2,
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          )
      ),
      child: Image.asset(
        'assets/icons/game_remote.png',
        width: 38,
        height: 27,
        color: Colors.white,
      ),
    );
  }

}