import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_wallet/models/db/shared_payment.dart';
import 'package:social_wallet/models/db/shared_payment_users.dart';
import 'package:social_wallet/models/send_tx_request_model.dart';
import 'package:social_wallet/models/send_tx_response_model.dart';
import 'package:social_wallet/models/tokens_info_model.dart';
import 'package:social_wallet/routes/app_router.dart';
import 'package:social_wallet/utils/app_constants.dart';
import 'package:social_wallet/utils/config/config_props.dart';
import 'package:social_wallet/utils/helpers/extensions/context_extensions.dart';
import 'package:social_wallet/views/screens/main/shared_payments/cubit/end_shared_payment_cubit.dart';
import 'package:social_wallet/views/screens/main/shared_payments/cubit/shared_payment_contacts_cubit.dart';
import 'package:social_wallet/views/screens/main/wallet/verification_code_component.dart';
import 'package:social_wallet/views/widget/cubit/toggle_state_cubit.dart';

import '../../../../di/injector.dart';
import '../../../../models/db/shared_payment_response_model.dart';
import '../../../../models/db/user.dart';
import '../../../../models/direct_payment_model.dart';
import '../../../../utils/app_colors.dart';
import '../../../widget/custom_button.dart';

class SharedPaymentVerificationCodeBottomDialog extends StatelessWidget {


  String pin = "";
  int strategy;
  SharedPayment sharedPayment;
  List<String> userAddressList;
  String sharedPayUsersName;
  SharedPaymentContactsCubit sharedPaymentContactsCubit;
  Function(SendTxResponseModel sendTxResponseModel, int? sharedPayId) onCreatedSharedPayment;
  ToggleStateCubit createButtonStateCubit = getToggleStateCubit();

  SharedPaymentVerificationCodeBottomDialog(
      {super.key, required this.userAddressList, required this.sharedPayUsersName, required this.sharedPayment, required this.sharedPaymentContactsCubit, required this.strategy, required this.onCreatedSharedPayment});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                            child: Text(
                              "OTP Verification",
                              maxLines: 1,
                              textAlign: TextAlign.center,
                              style: context.bodyTextLarge.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20,
                                  overflow: TextOverflow.ellipsis),
                            )),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Requested to: ",
                            maxLines: 1,
                            style: context.bodyTextLarge.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                                overflow: TextOverflow.ellipsis),
                          ),
                        ),
                        Expanded(
                            flex: 2,
                            child: Text(
                              sharedPayUsersName,
                              maxLines: 5,
                              textAlign: TextAlign.end,
                              style: context.bodyTextLarge.copyWith(
                                  fontSize: 18, overflow: TextOverflow.ellipsis),
                            ))
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Requested amount: ",
                            maxLines: 1,
                            style: context.bodyTextLarge.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                                overflow: TextOverflow.ellipsis),
                          ),
                        ),
                        Expanded(
                            child: Text(
                              sharedPayment.totalAmount.toString(),
                              maxLines: 1,
                              textAlign: TextAlign.end,
                              style: context.bodyTextLarge.copyWith(
                                  fontSize: 18, overflow: TextOverflow.ellipsis),
                            ))
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Network: ",
                            maxLines: 1,
                            style: context.bodyTextLarge.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                                overflow: TextOverflow.ellipsis),
                          ),
                        ),
                        Expanded(
                            flex: 2,
                            child: Text(
                              sharedPayment.currencyName,
                              maxLines: 1,
                              textAlign: TextAlign.end,
                              style: context.bodyTextLarge.copyWith(
                                  fontSize: 18, overflow: TextOverflow.ellipsis),
                            ))
                      ],
                    ),
                    const SizedBox(height: 20),
                    VerificationCodeComponent(
                      strategy: strategy,
                      onWriteCode: (value) {
                        if (value != null) {
                          pin = value;
                          createButtonStateCubit.toggleState();
                        }
                      },
                    )
                  ],
                ),
              ),
            ),
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          AppRouter.pop();
                        },
                        child: Text("Cancelar",
                            textAlign: TextAlign.end,
                            style: context.bodyTextMedium
                                .copyWith(fontSize: 18, color: Colors.blue)),
                      ),
                    ),
                  ],
                ),
                BlocBuilder<ToggleStateCubit, ToggleStateState>(
                  bloc: createButtonStateCubit,
                  builder: (context, state) {
                    return Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            buttonText: "Create",
                            radius: 10,
                            enabled: state.isEnabled,
                            elevation: 0,
                            backgroundColor: AppColors.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            onTap: () async {
                              //todo call to init transaction
                              int? sharedPaymentCurrId = await sharedPaymentContactsCubit.getTxCounts(sharedPayment.networkId);

                              if (sharedPaymentCurrId != null) {
                                SendTxResponseModel? sendTxResponseModel = await sharedPaymentContactsCubit.submitTxReq(SendTxRequestModel(
                                    sender: getKeyValueStorage().getUserAddress() ?? "",
                                    blockchainNetwork: sharedPayment.networkId,
                                    contractSpecsId: ConfigProps.contractSpecsId,
                                    method: "initTransaction",
                                    value: 0,
                                    params: [
                                      sharedPayment.ownerAddress,
                                      userAddressList,
                                      //total shared payment xvalue
                                      AppConstants.toWei(sharedPayment.totalAmount, sharedPayment.tokenDecimals ?? 0).toInt(),
                                      userAddressList.length
                                    ],
                                    pin: pin
                                ));

                                if (sendTxResponseModel != null) {

                                  //todo pass to cubit
                                  int? entityId = await getDbHelper().createSharedPayment(sharedPayment.copyWith(id: sharedPaymentCurrId + 1));
                                  if (entityId != null) {
                                    await sharedPaymentContactsCubit.updateSharedPaymentStatus(sharedPayment.copyWith(id: sharedPaymentCurrId + 1), "PENDING");
                                    onCreatedSharedPayment(sendTxResponseModel, sharedPaymentCurrId + 1);
                                    AppRouter.pop();
                                  }

                                }
                              }

                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

}
