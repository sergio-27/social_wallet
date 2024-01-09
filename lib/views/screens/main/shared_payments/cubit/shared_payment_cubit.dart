import 'package:bloc/bloc.dart';
import 'package:social_wallet/models/db/shared_payment_users.dart';
import 'package:social_wallet/models/tx_status_response_model.dart';
import 'package:social_wallet/utils/app_constants.dart';

import '../../../../../di/injector.dart';
import '../../../../../models/db/shared_payment_response_model.dart';
import '../../../../../models/db/user.dart';
import '../../../../../models/network_info_model.dart';
import '../../../../../models/send_tx_request_model.dart';
import '../../../../../utils/config/config_props.dart';

part 'shared_payment_state.dart';

class SharedPaymentCubit extends Cubit<SharedPaymentState> {
  SharedPaymentCubit() : super(SharedPaymentState());

  Future<void> getUserSharedPayments() async {
    User? currUser = await getDbHelper().retrieveUserByEmail(getKeyValueStorage().getUserEmail() ?? "");
    if (currUser != null) {
      List<SharedPaymentResponseModel>? result = await getDbHelper().retrieveUserSharedPayments(currUser.id ?? 0);
      List<SharedPaymentResponseModel> resultAux = List.empty(growable: true);

      if (result != null) {
        await Future.forEach(result, (element) async {
          int? txCurrNumConfirmations = await getTxNumConfirmations((element.sharedPayment.id ?? 0) - 1, element.sharedPayment.networkId);
          await Future.delayed(const Duration(milliseconds: 500));
          bool? hasUserConfirmedTx = await getHasUserConfirmedTx(txIndex: (element.sharedPayment.id ?? 0) - 1, blockchainNetwork: element.sharedPayment.networkId);

          if (txCurrNumConfirmations != null && hasUserConfirmedTx != null) {
            resultAux.add(element.copyWith(
                sharedPayment: element.sharedPayment.copyWith(
                    status: AppConstants.getSharedPaymentStatus(
                        sharedPayment: element, txCurrNumConfirmation: txCurrNumConfirmations, hasUserConfirmedTx: hasUserConfirmedTx))));
          }

          if (element.sharedPayment.ownerId != currUser.id) {

          } else {}
        });
      }

      emit(state.copyWith(sharedPaymentResponseModel: resultAux));
    } else {
      emit(state.copyWith(status: SharedPaymentStatus.error, sharedPaymentResponseModel: null));
    }
  }

  Future<int?> getTxNumConfirmations(int txIndex, int blockchainNetwork) async {
    try {
      List<dynamic>? response = await getWeb3CoreRepository().querySmartContract(
          SendTxRequestModel(blockchainNetwork: blockchainNetwork, contractAddress: ConfigProps.sharedPaymentCreatorAddress, method: "getSharedPayment", params: [txIndex]));

      if (response != null) {
        if (response[4] is int?) {
          return response[4];
        }
      }
      return null;
    } catch (exception) {
      print(exception);
      return null;
    }
  }

  Future<bool?> getHasUserConfirmedTx({required int txIndex, required int blockchainNetwork, String? userAddress}) async {
    try {
      List<dynamic>? response = await getWeb3CoreRepository().querySmartContract(SendTxRequestModel(
          blockchainNetwork: blockchainNetwork, contractAddress: ConfigProps.sharedPaymentCreatorAddress, method: "getHasParticipantConfirmed", params: [txIndex]));

      if (response != null) {
        if (response.first is bool?) {
          return response.first;
        }
      }
      return null;
    } catch (exception) {
      print(exception);
      return null;
    }
  }

  void setSelectedNetwork(NetworkInfoModel networkInfoModel) {
    emit(state.copyWith(selectedNetwork: networkInfoModel));
  }
}
