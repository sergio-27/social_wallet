import 'package:bloc/bloc.dart';
import 'package:social_wallet/api/repositories/wallet_repository.dart';
import 'package:social_wallet/di/injector.dart';
import 'package:social_wallet/models/send_tx_request_model.dart';
import 'package:social_wallet/models/send_tx_response_model.dart';
import 'package:social_wallet/utils/config/config_props.dart';

import '../../../../../models/db/user.dart';
import '../../../../../utils/app_constants.dart';

part 'end_shared_payment_state.dart';

class EndSharedPaymentCubit extends Cubit<EndSharedPaymentState> {
  WalletRepository walletRepository;

  EndSharedPaymentCubit({required this.walletRepository}) : super(EndSharedPaymentState());

  Future<void> submitTx(SendTxRequestModel sendTxRequestModel) async {
    emit(state.copyWith(status: EndSharedPaymentStatus.loading));
    try {
      SendTxResponseModel? sendTxResponseModel = await submitTxReq(sendTxRequestModel);

      if (sendTxResponseModel != null) {
        emit(state.copyWith(status: EndSharedPaymentStatus.success));
        return;
      }
      emit(state.copyWith(status: EndSharedPaymentStatus.error));
      return;
    } catch (exception) {
      print(exception);
      emit(state.copyWith(status: EndSharedPaymentStatus.error));
    }
  }

  Future<SendTxResponseModel?> submitTxReq(SendTxRequestModel sendTxRequestModel) async {
    try {
      User? currUser = AppConstants.getCurrentUser();
      if (currUser != null) {
        if (currUser.strategy != null) {
          if (currUser.strategy != 0) {
            SendTxResponseModel? sendTxResponseModel = await walletRepository.sendTx(
                reqBody: sendTxRequestModel.copyWith(contractAddress: ConfigProps.sharedPaymentCreatorAddress), strategy: currUser.strategy!);

            return sendTxResponseModel;
          }
        }
      }
    } catch (exception) {
      print(exception);
      return null;
    }
  }

  Future<void> getTxNumConfirmations(int txIndex, int blockchainNetwork) async {
    emit(state.copyWith(status: EndSharedPaymentStatus.loading));
    try {
      List<dynamic>? response = await getWeb3CoreRepository().querySmartContract(SendTxRequestModel(
          blockchainNetwork: blockchainNetwork,
          contractAddress: ConfigProps.sharedPaymentCreatorAddress,
          method: "getSharedPayment",
          params: [txIndex]));

      if (response != null) {
        if (response[4] is int?) {
          emit(state.copyWith(txCurrentNumConfirmations: response[4], status: EndSharedPaymentStatus.success));
        }
      }
    } catch (exception) {
      print(exception);
      emit(state.copyWith(txCurrentNumConfirmations: -1, status: EndSharedPaymentStatus.error));
    }
  }

  Future<SendTxResponseModel?> sendTxToSmartContract({
    required int networkId,
    required String methodName,
    required List<dynamic> params,
    int? value,
    required String pin,
  }) async {
    User? currUser = AppConstants.getCurrentUser();

    if (currUser != null) {
      if (currUser.strategy != null) {
        SendTxResponseModel? sendTxResponseModel = await walletRepository.sendTx(
            reqBody: SendTxRequestModel(
                sender: getKeyValueStorage().getUserAddress() ?? "",
                blockchainNetwork: networkId,
                //todo check why not accepting value param for native token transaction to sc
                // value: AppConstants.toWei(sharedPaymentUsers?.userAmountToPay ?? 0.0, sharedPaymentResponseModel.sharedPayment.tokenDecimals ?? 0).toInt(),
                value: value,
                contractSpecsId: ConfigProps.contractSpecsId,
                method: methodName,
                params: params,
                pin: pin),
            strategy: currUser.strategy!);

        return sendTxResponseModel;
      }
    }

    return null;
  }

  void getTxStatus() async {}
}
