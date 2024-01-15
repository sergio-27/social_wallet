import 'package:convert/convert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_wallet/di/injector.dart';
import 'package:social_wallet/models/db/update_user_wallet_info.dart';
import 'package:social_wallet/models/wallet_hash_request_model.dart';
import 'package:social_wallet/utils/app_colors.dart';
import 'package:social_wallet/utils/helpers/extensions/context_extensions.dart';
import 'package:social_wallet/views/screens/main/wallet/create_wallet_webview_bottom_dialog.dart';
import 'package:social_wallet/views/screens/main/wallet/cubit/balance_cubit.dart';
import 'package:social_wallet/views/screens/main/wallet/cubit/wallet_cubit.dart';
import 'package:social_wallet/views/screens/main/wallet/cubit/wallet_nfts_cubit.dart';
import 'package:social_wallet/views/widget/custom_button.dart';
import 'package:social_wallet/views/widget/network_selector.dart';

import '../../../../models/db/user.dart';
import '../../../../models/network_info_model.dart';
import '../../../../models/wallet_hash_response_model.dart';
import '../../../../utils/app_constants.dart';


class WalletNFTsScreen extends StatefulWidget {

  bool emptyFormations = false;

  WalletNFTsScreen({super.key});

  @override
  _WalletNFTsScreenState createState() => _WalletNFTsScreenState();
}

class _WalletNFTsScreenState extends State<WalletNFTsScreen>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin<WalletNFTsScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 5),
            NetworkSelector(
              selectedNetworkInfoModel: getWalletNFTsCubit().state.selectedInfoNetwork,
              showMakePaymentText: false,
              showList: false,
              onClickNetwork: (selectedValue) {
                if (selectedValue != null) {
                  getWalletNFTsCubit().setSelectedNetwork(selectedValue);
                  getWalletNFTsCubit().getAccountNFTs(selectedNetworkInfo: selectedValue, networkId: selectedValue.id);
                }
              },
            ),
            const SizedBox(height: 10),
            BlocBuilder<WalletNFTsCubit, WalletNFTsState>(
              bloc: getWalletNFTsCubit(),
              builder: (context, state) {
                if (state.ownedNFTsList == null && state.status != WalletNFTsStatus.loading) {
                  if ( state.status == WalletNFTsStatus.initial) {
                    return Expanded(
                      child: Center(
                        child: Text("No NFTs found"),
                      ),
                    );
                  }
                  return Center(
                    child: Column(
                      children: [
                        Text("Something happened, thanks for your patience :)!"),
                      ],
                    ),
                  );
                }
                if (state.status == WalletNFTsStatus.loading) {
                  return Expanded(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                if (state.ownedNFTsList?.isEmpty == true) {
                  return Expanded(
                    child: Center(
                      child: Text("No NFTs found"),
                    ),
                  );
                }
                return Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    children: state.ownedNFTsList?.map((e) =>
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: InkWell(
                            onTap: () {

                            },
                            child: Material(
                              elevation: 3,
                              borderRadius: BorderRadius.all(Radius.circular(20)),
                              color: AppColors.appBackgroundColor,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20.0),
                                child: Image.asset(
                                  "assets/ic_default_nft.jpg",
                                  fit: BoxFit.fitWidth,
                                ),
                              )
                            ),
                          ),
                        )
                    ).toList() ?? [],
                  ),

                  /*SingleChildScrollView(
                    child: Column(
                      children: state.ownedNFTsList?.map((e) =>
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Material(
                              color: AppColors.appBackgroundColor,
                              child: Container(
                                child: Row(
                                  children: [
                                    Text("NFT name #1"),
                                  ],
                                ),
                              ),
                            ),
                          )
                      ).toList() ?? [],
                    ),
                  ),*/
                );
              },
            ),
          ],
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
