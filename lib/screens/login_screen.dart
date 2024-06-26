import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:newtesst/provider/internet_provider.dart';
import 'package:newtesst/provider/sign_in_provider.dart';
import 'package:newtesst/screens/home_screen.dart';
import 'package:newtesst/utils/config.dart';
import 'package:newtesst/utils/snack_bar.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

import '../utils/next_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey _scaffoldkey = GlobalKey<ScaffoldState>();
  final RoundedLoadingButtonController googleController =
      RoundedLoadingButtonController();
  final RoundedLoadingButtonController facebookController =
      RoundedLoadingButtonController();

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldkey,
      backgroundColor: Colors.white,
      body: SafeArea(
          child: Padding(
        padding:
            const EdgeInsets.only(left: 40, right: 40, top: 90, bottom: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image(
                    image: AssetImage(Config.app_icon),
                    height: 80,
                    width: 135,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text("Welcome Flutter_FireBase_Authentication",
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.w500)),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Learn Authentication with Provider",
                    style: TextStyle(fontSize: 15, color: Colors.grey[500]),
                  )
                ],
              ),
            ),

            //roundedbutton
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RoundedLoadingButton(
                  onPressed: () {
                    handleGoogleSignin();
                  },
                  controller: googleController,
                  successColor: Colors.red,
                  width: MediaQuery.of(context).size.width * 0.80,
                  elevation: 0,
                  borderRadius: 25,
                  color: Colors.red,
                  child: const Wrap(
                    children: [
                      Icon(
                        FontAwesomeIcons.google,
                        size: 20,
                        color: Colors.white,
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Text("Sign in with Google",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),

                //facebook
                RoundedLoadingButton(
                  onPressed: () {handleFacebookAuth();
                  },
                  controller: googleController,
                  successColor: Colors.blue,
                  width: MediaQuery.of(context).size.width * 0.80,
                  elevation: 0,
                  borderRadius: 25,
                  color: Colors.blue,
                  child: const Wrap(
                    children: [
                      Icon(
                        FontAwesomeIcons.facebook,
                        size: 20,
                        color: Colors.white,
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Text("Sign in with Facebook",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      )),
    );
  }

  //handling google signin
  Future handleGoogleSignin() async {
    final sp = context.read<SignInProvider>();
    final ip = context.read<InternetProvider>();
    await ip.checkInternetConnection();

    if (ip.hasInternet == false) {
      openSnackBar(context, "Check Your Internet Connection", Colors.red);
      googleController.reset();
      facebookController.reset();
    }
    else{
      await sp.signInWithGoogle().then((value)
      {
        if(sp.hasError==true){
          openSnackBar(context, sp.errorCode.toString(), Colors.red);
          googleController.reset();
        }
        else
        {
          sp.checkUserExists().then((value) async
          {
            if(value ==true)
            {
              //user already exists
              await sp.getUserDataFromFirestore(sp.uid).then((value) => sp
                  .saveDataToSharedPreferences()
                  .then((value) => sp.setSignIn().then((value) 
                  {
                        googleController.success();
                        handleAfterSignIn();
            })));}
            
            else
            {
              //user does not exist
              sp.saveDataToFirestore().then((value) => sp.saveDataToSharedPreferences()).then((value) => sp.setSignIn().then((value)
              {
                googleController.success();
                handleAfterSignIn();
              }));
            }
          });
        }
      });
    }
  }
  
  //handling facebook auth
  Future handleFacebookAuth() async {
    final sp = context.read<SignInProvider>();
    final ip = context.read<InternetProvider>();
    await ip.checkInternetConnection();

    if (ip.hasInternet == false) {
      openSnackBar(context, "Check your Internet connection", Colors.red);
      facebookController.reset();
    } else {
      await sp.signInWithFacebook().then((value) {
        if (sp.hasError == true) {
          openSnackBar(context, sp.errorCode.toString(), Colors.red);
          facebookController.reset();
        } else {
          // checking whether user exists or not
          sp.checkUserExists().then((value) async {
            if (value == true) {
              // user exists
              await sp.getUserDataFromFirestore(sp.uid).then((value) => sp
                  .saveDataToSharedPreferences()
                  .then((value) => sp.setSignIn().then((value) {
                        facebookController.success();
                        handleAfterSignIn();
                      })));
            } else {
              // user does not exist
              sp.saveDataToFirestore().then((value) => sp
                  .saveDataToSharedPreferences()
                  .then((value) => sp.setSignIn().then((value) {
                        facebookController.success();
                        handleAfterSignIn();
                      })));
            }
          });
        }
      });
    }
  }


  //handle after sign in
  handleAfterSignIn() {
    Future.delayed(const Duration(milliseconds: 1000)).then((value){
      nextScreenReplace(context, const HomeScreen());
    });
  }
}
