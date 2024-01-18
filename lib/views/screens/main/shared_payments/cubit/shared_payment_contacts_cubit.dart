import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:social_wallet/models/db/shared_payment.dart';
import 'package:social_wallet/models/send_tx_request_model.dart';

import '../../../../../di/injector.dart';
import '../../../../../models/db/shared_payment_users.dart';
import '../../../../../models/db/user.dart';
import '../../../../../models/send_tx_response_model.dart';
import '../../../../../models/shared_contact_model.dart';
import '../../../../../utils/app_constants.dart';
import '../../../../../utils/config/config_props.dart';

part 'shared_payment_contacts_state.dart';

class SharedPaymentContactsCubit extends Cubit<SharedPaymentContactsState> {

  SharedPaymentContactsCubit() : super(SharedPaymentContactsState());

  Future<int?> initTx({required SharedPayment sharedPayment, required List<String> userAddressList, required String pin}) async {
    try {
      int? sharedPaymentCurrId = await getTxCounts(sharedPayment.networkId);

      if (sharedPaymentCurrId != null) {
        sharedPaymentCurrId += 1;
        SendTxResponseModel? sendTxResponseModel = await submitTxReq(SendTxRequestModel(
            sender: getKeyValueStorage().getUserAddress() ?? "",
            blockchainNetwork: sharedPayment.networkId,
            contractSpecsId: ConfigProps.contractSpecsId,
            method: "initTransaction",
            value: 0,
            params: [
              sharedPayment.ownerAddress,
              sharedPayment.currencyAddress,
              userAddressList,
              //total shared payment xvalue
              AppConstants.toWei(sharedPayment.totalAmount, sharedPayment.tokenDecimals ?? 0),
              userAddressList.length
            ],
            pin: pin
        ));
        if (sendTxResponseModel != null) {
          SharedPayment spAux = sharedPayment.copyWith(id: sharedPaymentCurrId, numConfirmations: userAddressList.length);
          //todo pass to cubit
          int? entityId = await getDbHelper().createSharedPayment(spAux);
          if (entityId != null) {
            return sharedPaymentCurrId;
          }
        }
        return sharedPaymentCurrId;
      }
      return null;
    } catch (exception) {
      print(exception);
      return null;
    }
  }

  Future<int?> updateSharedPaymentUsers({
    required int entityId,
    required SharedPayment sharedPayment,
    required List<SharedContactModel> selectedContactsList,
  }) async {
    try {
      List<SharedPaymentUsers> sharedPaymentUsers = List.empty(growable: true);
      for (var element in selectedContactsList) {
        sharedPaymentUsers.add(SharedPaymentUsers(
            userId: element.userId,
            sharedPaymentId: entityId,
            username: element.contactName,
            hasPayed: 0,
            userAddress: element.userAddress,
            userAmountToPay: element.amountToPay));
      }
      int? result = await getDbHelper().insertSharedPaymentUser(sharedPaymentUsers);
      if (result == null) {
        //delete created shared payment
        //todo delete shared payments users too
        int? result = await getDbHelper().deleteSharedPayment(entityId, sharedPayment.ownerId);
        return result;
      }
      return result;
    } catch(exception) {
      print(exception);
      return null;
    }
  }

  void setUserAmountToPay(BuildContext context, {
    required List<String> resultsCurrUserAmount,
    required List<SharedContactModel> selectedContactsList,
    required SharedContactModel sharedContactModel,
    required SharedPayment sharedPayment,
    required double allSumAmount,
  }) async {
    if (resultsCurrUserAmount.isNotEmpty) {
      if (resultsCurrUserAmount.first.isNotEmpty) {
        double totalAmount = 0.0;
        try {
          totalAmount = double.parse(resultsCurrUserAmount.first);
        } on Exception catch (e) {
          print(e.toString());
        }
        if (totalAmount > (sharedPayment.totalAmount)) {
          totalAmount = 0.0;
          if (context.mounted) {
            AppConstants.showToast(context, "Exceeded total amount");
          }
        } else {
          SharedContactModel sharedAux = sharedContactModel.copyWith(amountToPay: totalAmount);
          List<SharedContactModel> newList = List.empty(growable: true);

          selectedContactsList.forEach((element) {
            if (element.contactName == sharedAux.contactName) {
              newList.add(sharedAux);
            } else {
              newList.add(element);
            }
          });
          updateSelectedContactsList(newList);
          allSumAmount += totalAmount;

          if (allSumAmount > (state.totalAmount ?? 0.0)) {
            allSumAmount -= totalAmount;
          }
          updatePendingAmount(allSumAmount);
        }
      }
    }
  }

  Future<SendTxResponseModel?> submitTxReq(SendTxRequestModel sendTxRequestModel) async {
    try {
      User? currUser = AppConstants.getCurrentUser();
      if (currUser != null) {
        if (currUser.strategy != null) {
          if (currUser.strategy != 0) {
            SendTxResponseModel? sendTxResponseModel = await getWalletRepository().sendTx(reqBody: sendTxRequestModel.copyWith(contractAddress: ConfigProps.sharedPaymentCreatorAddress), strategy: currUser.strategy!);

            return sendTxResponseModel;
          }
        }
      }
      return null;
    } catch (exception) {
      print(exception);
      return null;
    }
  }

  Future<int?> getTxCounts(int blockchainNetwork) async {
    try {
      List<dynamic>? response = await getWeb3CoreRepository().querySmartContract(
          SendTxRequestModel(
              blockchainNetwork: blockchainNetwork,
              contractAddress: ConfigProps.sharedPaymentCreatorAddress,
              method: "getSharedPaymentCount"
          )
      );

      if (response != null) {
        if (response.first is int?) {
          return response.first;
        }
      }
      return null;
    } catch(exception) {
      print(exception);
      return null;
    }
  }

  void updateAmount(double totalAmount) {
    emit(state.copyWith(totalAmount: totalAmount));
  }

  void updatePendingAmount(double newAmount) {
    emit(state.copyWith(allSumAmount: newAmount));
  }

  void updateSelectedContactsList(List<SharedContactModel> sharedContactModel) {
    emit(state.copyWith(selectedContactsList: sharedContactModel));
  }
}
