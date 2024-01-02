import 'package:flutter/material.dart';
import 'package:social_wallet/views/screens/main/contacts/contacts_screen.dart';


import 'package:social_wallet/views/screens/main/direct_payment/main_direct_payment_screen.dart';
import 'package:social_wallet/views/screens/main/shared_payments/shared_payments_screen.dart';
import 'package:social_wallet/views/screens/main/wallet/wallet_screen.dart';
import 'package:social_wallet/views/widget/top_toolbar.dart';

import '../../../utils/app_colors.dart';


class MainScreen extends StatefulWidget {

  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {

  int pageIndex = 0;

  static const indexHome = 0;
  static const indexChat = 1;
  static const indexProfile = 2;
  late PageController _pageController;
  //bool isRegistered = getKeyValueStorage().getIsUserRegistered();
  PreferredSizeWidget? topToolbar;

  final bottomPages = [
    MainDirectPaymentScreen(),
    SharedPaymentsScreen(),
    WalletScreen(),
    ContactsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    topToolbar = TopToolbar();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: TopToolbar(),
          body: Column(
            children: [
              Expanded(
                child: SizedBox.expand(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                    child: bottomPages.elementAt(pageIndex),
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: buildMyNavBar(context, pageIndex)),
    );
  }

  Widget buildMyNavBar(BuildContext context, int currIndex) {
   return BottomNavigationBar(
      currentIndex: currIndex,
      fixedColor: AppColors.primaryColor,
     backgroundColor: AppColors.bgPendingTag,
      onTap: (index) {
        setState(() {
          pageIndex = index;
        });
      },
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.directions, color: AppColors.primaryColor),
          label: 'Dir. Pay',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.share_outlined, color: AppColors.primaryColor),
          label: 'Shared Pay',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.wallet, color: AppColors.primaryColor),
          label: 'Wallet',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.group, color: AppColors.primaryColor),
          label: 'Contacts',
        ),
      ],
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

}
