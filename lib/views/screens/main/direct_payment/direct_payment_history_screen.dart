import 'dart:io';
import 'dart:math';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:social_wallet/models/owned_token_account_info_model.dart';
import 'package:social_wallet/models/send_tx_request_model.dart';
import 'package:social_wallet/models/tokens_info_model.dart';
import 'package:social_wallet/routes/app_router.dart';
import 'package:social_wallet/utils/helpers/extensions/context_extensions.dart';
import 'package:social_wallet/views/screens/main/direct_payment/crypto_payment_bottom_dialog.dart';
import 'package:social_wallet/views/screens/main/direct_payment/cubit/direct_payment_cubit.dart';
import 'package:social_wallet/views/screens/main/direct_payment/cubit/dirpay_history_cubit.dart';
import 'package:social_wallet/views/widget/select_contact_bottom_dialog.dart';
import 'package:social_wallet/views/widget/select_currency_bottom_dialog.dart';
import 'package:social_wallet/views/screens/main/wallet/balance_item.dart';
import 'package:social_wallet/views/widget/cubit/toggle_state_cubit.dart';
import 'package:social_wallet/views/widget/network_selector.dart';


import '../../../../di/injector.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_constants.dart';
import '../../../../utils/helpers/form_validator.dart';
import '../../../widget/custom_button.dart';
import '../../../widget/custom_text_field.dart';
import '../wallet/cubit/balance_cubit.dart';


class DirectPaymentHistoryScreen extends StatefulWidget {

  DirectPaymentHistoryScreen({super.key});

  @override
  _DirectPaymentHistoryScreenState createState() => _DirectPaymentHistoryScreenState();
}

class _DirectPaymentHistoryScreenState extends State<DirectPaymentHistoryScreen>
    with WidgetsBindingObserver {


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    getDirPayHistoryCubit().getDirPayHistory(11);
    return BlocBuilder<DirPayHistoryCubit, DirPayHistoryState>(
      bloc: getDirPayHistoryCubit(),
      builder: (context, state) {
        if (state.dirPaymentHistoryList == null) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
            ],
          );
        }
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              children: state.dirPaymentHistoryList!.map((e) =>
                  Material(
                    elevation: 0,
                    color: AppColors.appBackgroundColor,
                    child: InkWell(
                      onTap: () {
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: AppColors.primaryColor),
                                  borderRadius: BorderRadius.circular(50)
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(50.0),
                                //make border radius more than 50% of square height & width
                                child: Image.asset(
                                  "assets/nano.jpg",
                                  height: 60.0,
                                  width: 60.0,
                                  fit: BoxFit.cover, //change image fill type
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Text(
                                  "Direct payment ${e.id} ",
                                  textAlign: TextAlign.start,
                                  maxLines: 2,
                                  style: context.bodyTextMedium,
                                ),
                                Text(
                                  "Total amount: ${AppConstants.parseTokenBalance(e.payedAmount.toString(), 18)} ${e.currencySymbol}",
                                  textAlign: TextAlign.start,
                                  maxLines: 2,
                                  style: context.bodyTextMedium.copyWith(
                                      color: Colors.grey,
                                      overflow: TextOverflow.ellipsis,
                                      fontSize: 13
                                  ),
                                ),
                              ],
                            )),
                            const SizedBox(width: 10),
                          ],
                        ),
                      ),
                    ),
                  )
              ).toList(),
            ),
          ),
        );
      },
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
