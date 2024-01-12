import 'package:bloc/bloc.dart';
import 'package:social_wallet/api/repositories/wallet_repository.dart';
import 'package:social_wallet/di/injector.dart';
import 'package:social_wallet/models/allowance_request_model.dart';
import 'package:social_wallet/models/allowance_response_model.dart';
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


  Future<SendTxResponseModel?> approveToken({
    required int shaPayId,
    required String tokenAddress,
    required int blockchainNetwork,
    required String sender,
    required List<dynamic> params,
    required String pin
  }) async {
    emit(state.copyWith(status: EndSharedPaymentStatus.loading));
    try {
      User? currUser = AppConstants.getCurrentUser();
      SendTxResponseModel? sendTxResponseModel;
      if (currUser != null) {
        if (currUser.strategy != null) {
          if (currUser.strategy != 0) {
            sendTxResponseModel = await walletRepository.sendTx(
                reqBody: SendTxRequestModel(
                    contractAddress: tokenAddress,
                    blockchainNetwork: blockchainNetwork,
                    sender: sender,
                    method: "approve",
                    value: 0,
                    gasLimit: 250000,
                    contractSpecsId: ConfigProps.contractSpecsId,
                    params: params,
                    pin: pin
                ),
                strategy: currUser.strategy!);
            return sendTxResponseModel;
          }
        }
      }

      return sendTxResponseModel;
    } catch (exception) {
      print(exception);
      return null;
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
      return null;
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
    num? value,
    required String pin,
  }) async {
    User? currUser = AppConstants.getCurrentUser();

    if (currUser != null) {
      if (currUser.strategy != null) {
        SendTxResponseModel? sendTxResponseModel = await walletRepository.sendTx(
            reqBody: SendTxRequestModel(
                sender: getKeyValueStorage().getUserAddress() ?? "",
                blockchainNetwork: networkId,
                value: value,
                contractSpecsId: ConfigProps.contractSpecsId,
                contractAddress: ConfigProps.sharedPaymentCreatorAddress,
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
