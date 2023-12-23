import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:social_wallet/di/injector.dart';

import 'login/login_screen.dart';



class AppStartupScreen extends StatefulWidget {

  const AppStartupScreen({super.key});

  @override
  _AppStartupScreenState createState() => _AppStartupScreenState();
}

class _AppStartupScreenState extends State<AppStartupScreen> with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    getDbHelper().initDB();
    getNetworkCubit().getAvailableNetworks();
    WidgetsBinding.instance.addObserver(this);
    if (Platform.isIOS) {
      //initPlugin();
    }
  }

  @override
  void dispose() {
    //don't forget to dispose of it when not needed anymore
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {

    return LoginScreen();
    /*return MultiBlocProvider(
        providers: [
          BlocProvider.value(value: getAuthCubit()),
          BlocProvider.value(value: getLoginCubit())
        ],
        child: BlocBuilder<AuthCubit, AuthState>(
          bloc: getAuthCubit(),
          builder: (context, state) {
            switch(state.status) {
              case AuthStatus.loged:
                return MainScreen();
              case AuthStatus.not_loged:
                if (hasDoneOnBoarding) {
                  return LoginScreen();
                  //return MainScreen();
                } else {
                  return OnBoardingMainScreen();
                }
              case AuthStatus.init:
                return const Scaffold(
                    body: SafeArea(
                        child: Center(
                          child: SpinKitDoubleBounce(color: AppColors.primaryColor),
                        )
                    )
                );
            }
          },
        )
    );*/



   /* return MultiBlocProvider(
        providers: [
          BlocProvider.value(value: getAuthCubit()),
          BlocProvider.value(value: getLoginCubit())
        ],
        child: BlocBuilder<AuthCubit, AuthState>(
          bloc: getAuthCubit(),
          builder: (context, state) {

            switch(state.status) {
              case AuthStatus.loged:
                return MainScreen();
              case AuthStatus.not_loged:
                return LoginScreen();
              case AuthStatus.init:
                return Scaffold(
                    body: SafeArea(
                        child: Center(
                          child: SpinKitDoubleBounce(color: AppColors.primaryColor),
                        )
                    )
                );
            }
          },
        )
    );*/
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        setState(() {});
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.hidden:
        // TODO: Handle this case.
    }
  }
}