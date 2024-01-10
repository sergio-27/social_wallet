import 'package:bloc/bloc.dart';
import 'package:social_wallet/models/db/shared_payment_users.dart';
import 'package:social_wallet/models/smart_contract_shared_payment.dart';
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
    emit(state.copyWith(status: SharedPaymentStatus.loading));
    User? currUser = AppConstants.getCurrentUser();
    if (currUser != null) {
      List<SharedPaymentResponseModel>? result = await getDbHelper().retrieveUserSharedPayments(currUser.id ?? 0);
      List<SharedPaymentResponseModel> resultAux = List.empty(growable: true);

      if (result != null) {
        await Future.forEach(result, (element) async {
          SmartContractSharedPayment? smartContractSharedPayment = await getSharedPaymentInfoFromSC((element.sharedPayment.id ?? 0) - 1, element.sharedPayment.networkId);
          await Future.delayed(const Duration(milliseconds: 1500));
          bool? hasUserConfirmedTx = await getHasUserConfirmedTx(txIndex: (element.sharedPayment.id ?? 0) - 1, blockchainNetwork: element.sharedPayment.networkId, userAddress: currUser.accountHash);

          if (smartContractSharedPayment != null && hasUserConfirmedTx != null) {
            resultAux.add(element.copyWith(
                sharedPayment: element.sharedPayment.copyWith(
                    status: AppConstants.getSharedPaymentStatus(
                        sharedPayment: element, isExecuted: smartContractSharedPayment.executed, txCurrNumConfirmation: smartContractSharedPayment.numConfirmations, hasUserConfirmedTx: hasUserConfirmedTx))));
          } else {
            resultAux.add(element.copyWith(
                sharedPayment: element.sharedPayment.copyWith(
                    status: 'STARTED'
                )));
          }

          if (element.sharedPayment.ownerId != currUser.id) {
          } else {}
        });
      }

      emit(state.copyWith(sharedPaymentResponseModel: resultAux, status: SharedPaymentStatus.success));
    } else {
      emit(state.copyWith(status: SharedPaymentStatus.error, sharedPaymentResponseModel: null));
    }
  }

  Future<SmartContractSharedPayment?> getSharedPaymentInfoFromSC(int txIndex, int blockchainNetwork) async {
    try {
      List<dynamic>? response = await getWeb3CoreRepository().querySmartContract(SendTxRequestModel(
          blockchainNetwork: blockchainNetwork,
          contractAddress: ConfigProps.sharedPaymentCreatorAddress,
          method: "getSharedPayment",
          params: [txIndex]));


      if (response != null) {
        if (response[3] is bool && response[4] is int) {
          return SmartContractSharedPayment(
              executed: response[3], numConfirmations: response[5]
          );
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
          blockchainNetwork: blockchainNetwork,
          contractAddress: ConfigProps.sharedPaymentCreatorAddress,
          method: "isParticipantConfirmedTx",
          params: [
            txIndex,
            userAddress
          ]
      ));
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
