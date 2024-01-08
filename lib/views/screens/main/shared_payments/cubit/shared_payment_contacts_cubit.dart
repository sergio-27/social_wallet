import 'package:bloc/bloc.dart';
import 'package:social_wallet/models/db/shared_payment.dart';
import 'package:social_wallet/models/send_tx_request_model.dart';

import '../../../../../di/injector.dart';
import '../../../../../models/db/user.dart';
import '../../../../../models/send_tx_response_model.dart';
import '../../../../../models/shared_contact_model.dart';
import '../../../../../utils/config/config_props.dart';



part 'shared_payment_contacts_state.dart';

class SharedPaymentContactsCubit extends Cubit<SharedPaymentContactsState> {

  SharedPaymentContactsCubit() : super(SharedPaymentContactsState());

  void updateAmount(double totalAmount) {
    emit(state.copyWith(totalAmount: totalAmount));
  }

  void updatePendingAmount(double newAmount) {
    emit(state.copyWith(allSumAmount: newAmount));
  }

  void updateSelectedContactsList(List<SharedContactModel> sharedContactModel) {
    emit(state.copyWith(selectedContactsList: sharedContactModel));
  }

  Future<SendTxResponseModel?> submitTxReq(SendTxRequestModel sendTxRequestModel) async {
    try {
      User? currUser = await getDbHelper().retrieveUserByEmail(getKeyValueStorage().getUserEmail() ?? "");
      if (currUser != null) {
        if (currUser.strategy != null) {
          if (currUser.strategy != 0) {
            SendTxResponseModel? sendTxResponseModel = await getWalletRepository().sendTx(reqBody: sendTxRequestModel.copyWith(contractAddress: ConfigProps.sharedPaymentCreatorAddress), strategy: currUser.strategy!);

            return sendTxResponseModel;
          }
        }
      }
    } catch (exception) {
      print(exception);
      return null;
    }
  }

  Future<int?> updateSharedPaymentStatus(
      SharedPayment sharedPayment,
      String status
      ) async {
   return await getDbHelper().updateSharedPaymentStatus(sharedPayment.id ?? 0, sharedPayment.ownerId, status);

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

}
