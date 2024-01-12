
import 'package:convert/convert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_wallet/di/injector.dart';
import 'package:social_wallet/models/db/update_user_wallet_info.dart';
import 'package:social_wallet/models/wallet_hash_request_model.dart';
import 'package:social_wallet/utils/helpers/extensions/context_extensions.dart';
import 'package:social_wallet/views/screens/main/wallet/create_wallet_webview_bottom_dialog.dart';
import 'package:social_wallet/views/screens/main/wallet/cubit/balance_cubit.dart';
import 'package:social_wallet/views/screens/main/wallet/cubit/wallet_cubit.dart';
import 'package:social_wallet/views/widget/custom_button.dart';
import 'package:social_wallet/views/widget/network_selector.dart';

import '../../../../models/db/user.dart';
import '../../../../models/network_info_model.dart';
import '../../../../models/wallet_hash_response_model.dart';
import '../../../../utils/app_constants.dart';


class WalletTokensScreen extends StatefulWidget {

  bool emptyFormations = false;
  NetworkInfoModel? selectedNetwork;

  WalletTokensScreen({super.key});

  @override
  _WalletTokensScreenState createState() => _WalletTokensScreenState();
}

class _WalletTokensScreenState extends State<WalletTokensScreen>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin<WalletTokensScreen> {

  bool isWalletCreated = false;
  late String userAddress;
  BalanceCubit balanceCubit = getBalanceCubit();


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    userAddress = getKeyValueStorage().getUserAddress() ?? "";
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: NetworkSelector(
            selectedNetworkInfoModel: widget.selectedNetwork,
            showMakePaymentText: false,
            onClickNetwork: (selectedValue) {
              widget.selectedNetwork = selectedValue;
            },
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
