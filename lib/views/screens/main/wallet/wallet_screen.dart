
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
import '../../../../models/wallet_hash_response_model.dart';
import '../../../../utils/app_constants.dart';


class WalletScreen extends StatefulWidget {

  bool emptyFormations = false;

  WalletScreen({super.key});

  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen>
    with WidgetsBindingObserver {

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
                          AppConstants.trimAddress(getKeyValueStorage().getUserAddress()),
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
                NetworkSelector(
                  balanceCubit: balanceCubit,
                  selectedNetwork: state.selectedNetwork,
                  showDefaultSelected: true,
                  onClickNetwork: (networkInfoModel) {
                    if (networkInfoModel != null) {
                      //todo replace account
                      getWalletCubit().setSelectedNetwork(networkInfoModel);
                      balanceCubit.getCryptoNativeBalance(
                          accountToCheck: getKeyValueStorage().getUserAddress() ?? "",
                          networkInfoModel: networkInfoModel,
                          networkId: networkInfoModel.id
                      );
                    }
                  },
                ),
                const SizedBox(height: 10),
                BlocBuilder<BalanceCubit, BalanceState>(
                  bloc: balanceCubit,
                  builder: (context, state) {
                    switch (state.status) {
                      case BalanceStatus.initial:
                      case BalanceStatus.loading:
                        return const Expanded(child: Center(
                          child: CircularProgressIndicator(),
                        ));
                      case BalanceStatus.success:
                        return Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              //todo change to get all tokens from user from given network
                              children: List.generate(1, (index) =>
                                  InkWell(
                                    onTap: () {

                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Image.asset("assets/ic_polygon.png", height: 32, width: 32),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  state.networkInfoModel != null ? state.networkInfoModel!.symbol : "",
                                                  style: context.bodyTextMedium.copyWith(
                                                      fontSize: 18,
                                                      color: Colors.black,
                                                      fontWeight: FontWeight.w500
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                "${state.balance ?? 0.0} ${state.networkInfoModel != null ? state.networkInfoModel!.symbol : ""}",
                                                style: context.bodyTextMedium.copyWith(
                                                    color: Colors.black,
                                                    fontSize: 15
                                                ),
                                              ),
                                              Text(
                                                "Pending calculate...",
                                                style: context.bodyTextMedium.copyWith(
                                                    color: Colors.grey,
                                                    fontSize: 14
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                              ),
                            ),
                          ),
                        );
                      case BalanceStatus.error:
                        return const Expanded(child: Center(
                          child: Text("Error"),
                        ));
                    }
                  },
                )
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
                    User? user = await AppConstants.getCurrentUser();

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

                                    if (response != null) {
                                      getKeyValueStorage().setUserAddress(createdWalletResponse.accountAddress);
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
