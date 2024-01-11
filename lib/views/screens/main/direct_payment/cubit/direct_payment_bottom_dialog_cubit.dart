import 'package:bloc/bloc.dart';
import 'package:social_wallet/api/repositories/wallet_repository.dart';
import 'package:social_wallet/models/send_tx_request_model.dart';
import 'package:social_wallet/models/send_tx_response_model.dart';
import 'package:social_wallet/models/tokens_info_model.dart';
import 'package:social_wallet/models/transfer_request_model.dart';

import '../../../../../di/injector.dart';
import '../../../../../models/currency_model.dart';
import '../../../../../models/db/user.dart';
import '../../../../../models/direct_payment_model.dart';
import '../../../../../models/network_info_model.dart';
import '../../../../../utils/app_constants.dart';
import '../../../../../utils/config/config_props.dart';


part 'direct_payment_bottom_dialog_state.dart';

class DirectPaymentBottomDialogCubit extends Cubit<DirectPaymentBottomDialogState> {

  WalletRepository walletRepository;

  DirectPaymentBottomDialogCubit({
    required this.walletRepository
  }) : super(DirectPaymentBottomDialogState());


  Future<void> doDirectPayment({
    required SendTxRequestModel sendTxRequestModel,
    required TokensInfoModel tokenInfoModel,
    required String recipientAddress,
    required String pin,
  }) async {
    User? currUser = AppConstants.getCurrentUser();

    if (currUser != null) {
      if (pin.isNotEmpty) {
        String verificationCode = pin;

        SendTxRequestModel sendReqModel = sendTxRequestModel.copyWith(pin: verificationCode);

        SendTxResponseModel? response;

        if (tokenInfoModel.isNative) {
          sendReqModel = SendTxRequestModel(
              recipient: recipientAddress,
              sender: sendReqModel.sender,
              value: sendReqModel.params?[1] ?? 0,
              blockchainNetwork: sendReqModel.blockchainNetwork,
              pin: sendReqModel.pin
          );
          response = await sendNativeCryptoTx(sendReqModel, currUser.strategy ?? 0);
        } else {
          response = await sendCryptoTx(sendReqModel, currUser.strategy ?? 0);
        }

        if (response != null) {
          int? savedResponse = await getDbHelper().insertDirectPayment(DirectPaymentModel(
              ownerId: currUser.id ?? 0,
              networkId: tokenInfoModel.networkId,
              creationTimestamp: DateTime
                  .now()
                  .millisecondsSinceEpoch,
              payedAmount: sendReqModel.params?[1] ?? 0,
              ownerUsername: currUser.username ?? "",
              currencyName: tokenInfoModel.tokenName,
              currencySymbol: tokenInfoModel.tokenSymbol));

          if (savedResponse != null) {
            //AppConstants.showToast(context, "Amount send it!");
            //AppRouter.pop();
          }
        }
      }
    }
  }

  Future<SendTxResponseModel?> sendNativeCryptoTx(SendTxRequestModel reqBody, int strategy) async {
    try {
      SendTxResponseModel? response = await walletRepository.sendNativeTx(reqBody: reqBody, strategy:strategy);
      return response;
    } catch(exception) {
      print(exception);
    }
    return null;
  }

  Future<SendTxResponseModel?> sendCryptoTx(SendTxRequestModel reqBody, int strategy) async {
    try {
      SendTxResponseModel? response = await walletRepository.sendTx(reqBody: reqBody.copyWith(contractAddress: ConfigProps.sharedPaymentCreatorAddress), strategy:strategy);
      return response;
    } catch(exception) {
      print(exception);
    }
    return null;
  }


}
