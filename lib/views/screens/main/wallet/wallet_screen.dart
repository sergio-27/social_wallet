
import 'package:convert/convert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_wallet/di/injector.dart';
import 'package:social_wallet/models/db/update_user_wallet_info.dart';
import 'package:social_wallet/models/wallet_hash_request_model.dart';
import 'package:social_wallet/routes/app_router.dart';
import 'package:social_wallet/routes/routes.dart';
import 'package:social_wallet/utils/helpers/extensions/context_extensions.dart';
import 'package:social_wallet/views/screens/main/wallet/create_wallet_webview_bottom_dialog.dart';
import 'package:social_wallet/views/screens/main/wallet/cubit/balance_cubit.dart';
import 'package:social_wallet/views/screens/main/wallet/cubit/wallet_cubit.dart';
import 'package:social_wallet/views/screens/main/wallet/wallet_nfts_screen.dart';
import 'package:social_wallet/views/screens/main/wallet/wallet_tokens_screen.dart';
import 'package:social_wallet/views/widget/custom_button.dart';
import 'package:social_wallet/views/widget/network_selector.dart';

import '../../../../models/db/user.dart';
import '../../../../models/network_info_model.dart';
import '../../../../models/wallet_hash_response_model.dart';
import '../../../../utils/app_constants.dart';


class WalletScreen extends StatefulWidget {

  bool emptyFormations = false;
  NetworkInfoModel? selectedNetwork;

  WalletScreen({super.key});

  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin<WalletScreen> {

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
        child: userAddress.isEmpty ? getCreateWalletBody() : BlocBuilder<WalletCubit, WalletState>(
          bloc: getWalletCubit(),
          builder: (context, state) {
            return Column(
              children: [
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                        child: Text(
                          AppConstants.trimAddress(address: getKeyValueStorage().getUserAddress()),
                          textAlign: TextAlign.center,
                          style: context.bodyTextMedium.copyWith(
                              fontSize: 25,
                              fontWeight: FontWeight.w500
                          ),
                        )
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: DefaultTabController(
                      length: 2,
                      child: Column(
                        children: [
                          TabBar(
                              labelStyle: context.bodyTextMedium.copyWith(
                                  fontSize: 20
                              ),
                              tabs: const [
                                Tab(text: "Tokens"),
                                Tab(text: "NFTs")
                              ]
                          ),
                          Expanded(
                            child: TabBarView(
                                physics: const NeverScrollableScrollPhysics(),
                                children: [
                                  WalletTokensScreen(),
                                  WalletNFTsScreen()
                                ]
                            ),
                          ),
                        ],
                      )
                  ),
                ),

              ],
            );
          },
        ),
      ),
    );
  }

  Widget getCreateWalletBody() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Expanded(
              child: CustomButton(
                  buttonText: "CREATE WALLET",
                  elevation: 3,
                  onTap: () async {
                    User? user = AppConstants.getCurrentUser();

                    if (user != null) {
                      WalletHashResponseModel? response = await getWalletCubit().createWallet(
                          WalletHashRequestModel(
                              username: user.userEmail,
                              strategies: [2, 3],
                              callbackUrl: "https://callback.vottun.tech/rest/v1/success/",
                              fallbackUrl: "https://fallback.vottun.tech/rest/v1/error/",
                              cancelUrl: "https://fallback.vottun.tech/rest/v1/cancel/"
                          )
                      );

                      if (response != null) {
                        if (mounted) {
                          AppConstants.showBottomDialog(
                              context: context,
                              isScrollControlled: true,
                              heightBoxConstraintRate: 0.95,
                              body: CreateWalletWebViewBottomDialog(
                                username: user.userEmail,
                                hash: response.hash,
                                onCreatedWallet: (createdWalletResponse, selectedStrategy) async {
                                  if (createdWalletResponse.accountAddress.isNotEmpty) {
                                    int? response = await getDbHelper().updateUserWalletInfo(
                                        user.id!,
                                        UpdateUserWalletInfo(
                                            strategy: selectedStrategy,
                                            accountHash: createdWalletResponse.accountAddress
                                        )
                                    );

                                    if (response != null && getKeyValueStorage().getCurrentUser() != null) {
                                      getKeyValueStorage().setUserAddress(createdWalletResponse.accountAddress);
                                      getKeyValueStorage().setCurrentModel(getKeyValueStorage().getCurrentUser()!.copyWith(
                                        accountHash: createdWalletResponse.accountAddress,
                                        strategy: selectedStrategy
                                      ));
                                      setState(() {
                                        isWalletCreated = true;
                                      });
                                    }
                                  }
                                },
                              ));
                        }
                      }
                    }

                    //todo get hash to create wallet and pass to web view


                    /*AppConstants.showBottomDialog(
                            context: context,
                            body: CreateWalletBottomDialog()
                        );*/
                  }
              ),
            ),
          ],
        )
      ],
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
