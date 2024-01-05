import 'package:bloc/bloc.dart';
import 'package:social_wallet/api/repositories/wallet_repository.dart';
import 'package:social_wallet/di/injector.dart';
import 'package:social_wallet/models/send_tx_request_model.dart';
import 'package:social_wallet/models/send_tx_response_model.dart';

import '../../../../../models/db/user.dart';



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
      User? currUser = await getDbHelper().retrieveUserByEmail(getKeyValueStorage().getUserEmail() ?? "");
      if (currUser != null) {
        if (currUser.strategy != null) {
          if (currUser.strategy != 0) {
            SendTxResponseModel? sendTxResponseModel = await walletRepository.sendTx(reqBody: sendTxRequestModel, strategy: currUser.strategy!);
            return sendTxResponseModel;
          }
        }
      }
    } catch (exception) {
      print(exception);
      return null;
    }
  }

  void getTxStatus() async {

  }

}
