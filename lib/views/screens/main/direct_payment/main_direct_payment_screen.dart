import 'package:flutter/material.dart';

import 'package:social_wallet/utils/helpers/extensions/context_extensions.dart';
import 'package:social_wallet/views/screens/main/direct_payment/direct_payment_history_screen.dart';
import 'package:social_wallet/views/screens/main/direct_payment/direct_payment_screen.dart';
import 'package:social_wallet/views/widget/cubit/toggle_state_cubit.dart';


import '../../../../di/injector.dart';
import '../../../../models/network_info_model.dart';
import '../wallet/cubit/balance_cubit.dart';


class MainDirectPaymentScreen extends StatefulWidget {

  bool emptyFormations = false;
  String? imagePath = "euro.svg";
  String contactName = "Search in contacts";
  NetworkInfoModel? selectedNetwork;


  MainDirectPaymentScreen({super.key});

  @override
  _MainDirectPaymentScreenState createState() => _MainDirectPaymentScreenState();
}

class _MainDirectPaymentScreenState extends State<MainDirectPaymentScreen>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin<MainDirectPaymentScreen> {

  String? userAddress;
  ToggleStateCubit cubit = getToggleStateCubit();
  BalanceCubit balanceCubit = getBalanceCubit();

  @override
  void initState() {
    userAddress = getKeyValueStorage().getUserAddress();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: DefaultTabController(
          length: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TabBar(
                  labelStyle: context.bodyTextMedium.copyWith(
                    fontSize: 20
                  ),
                  tabs: const [
                    Tab(text: "DirPayment"),
                    Tab(text: "History")
                  ]
              ),
              Expanded(
                child: TabBarView(
                  physics: NeverScrollableScrollPhysics(),
                    children: [
                      DirectPaymentScreen(
                        netInfoModel: widget.selectedNetwork,
                        onClickSelectedNetwork: (selectedNetwork) {
                          widget.selectedNetwork = selectedNetwork;
                        }
                      ),
                      DirectPaymentHistoryScreen()
                    ]
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

// @override
// void didChangeAppLifecycleState(AppLifecycleState state) {
//   switch (state) {
//     case AppLifecycleState.resumed:
//       setState(() {
//       });
//       break;
//     case AppLifecycleState.inactive:
//       break;
//     case AppLifecycleState.paused:
//       break;
//     case AppLifecycleState.detached:
//       break;
//   }
// }
}
