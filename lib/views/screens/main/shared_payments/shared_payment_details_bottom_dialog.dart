
import 'dart:io';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_wallet/models/db/shared_payment.dart';
import 'package:social_wallet/models/db/shared_payment_users.dart';
import 'package:social_wallet/utils/app_constants.dart';
import 'package:social_wallet/utils/helpers/extensions/context_extensions.dart';
import 'package:social_wallet/views/screens/main/shared_payments/cubit/shared_payment_cubit.dart';
import 'package:social_wallet/views/screens/main/wallet/balance_item.dart';
import 'package:social_wallet/views/widget/network_selector.dart';


import '../../../../di/injector.dart';
import '../../../../models/db/shared_payment_response_model.dart';
import '../../../../models/db/user.dart';
import '../../../../routes/app_router.dart';
import '../../../../routes/routes.dart';
import '../../../../utils/app_colors.dart';
import '../../../widget/custom_button.dart';
import '../wallet/cubit/balance_cubit.dart';


class SharedPaymentDetailsBottomDialog extends StatelessWidget {


  SharedPaymentResponseModel sharedPaymentResponseModel;
  Function() onBackFromCreateDialog;

  SharedPaymentDetailsBottomDialog({
    super.key,
    required this.onBackFromCreateDialog,
    required this.sharedPaymentResponseModel
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: DefaultTabController(
        length: 1,
        child: Column(
          children: [
            TabBar(
              labelStyle: context.bodyTextMedium.copyWith(
                fontSize: 21,
              ), indicatorSize: TabBarIndicatorSize.tab,
              tabs: const  [
                Tab(text: "Tx Details"),
                //Tab(text: "Tx History"),
              ],
            ),
            Expanded(
                child: TabBarView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "${sharedPaymentResponseModel.sharedPayment.ownerUsername} has requested you to PAY ${sharedPaymentResponseModel.sharedPayment.totalAmount} ${sharedPaymentResponseModel.sharedPayment.currencySymbol} (x€). \n\nReason: ${sharedPaymentResponseModel.sharedPayment.currencyName}",
                                  textAlign: TextAlign.start,
                                  style: context.bodyTextMedium.copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: CustomButton(
                                    buttonText: "Submit Tx",
                                    elevation: 3,
                                    inverseColors: true,
                                    radius: 10.0,
                                    onTap: () {

                                    },
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    /*Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: CustomButton(
                                      buttonText: "Submit Tx",
                                      elevation: 3,
                                      radius: 10.0,
                                      onTap: () {

                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: CustomButton(
                                      buttonText: "Submit Tx",
                                      elevation: 3,
                                      inverseColors: true,
                                      radius: 10.0,
                                      onTap: () {

                                      },
                                    ),
                                  ),
                                ],
                              )
                            ],
                          )

                        ],
                      ),
                    ),*/
                  ],
                )
            )
          ],
        ),
      ),
    );
  }
}