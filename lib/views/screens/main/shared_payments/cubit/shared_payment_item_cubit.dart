import 'package:bloc/bloc.dart';
import 'package:social_wallet/api/repositories/alchemy_repository.dart';
import 'package:social_wallet/models/tx_status_response_model.dart';

import '../../../../../di/injector.dart';
import '../../../../../models/db/shared_payment_response_model.dart';
import '../../../../../models/db/user.dart';
import '../../../../../models/network_info_model.dart';


part 'shared_payment_item_state.dart';

class SharedPaymentItemCubit extends Cubit<SharedPaymentItemState> {

  AlchemyRepository alchemyRepo;

  SharedPaymentItemCubit({required this.alchemyRepo}) : super(SharedPaymentItemState());


  Future<void> getSharedPaymentTxStatus(int networkId, String txHash) async {
    emit(
        state.copyWith(
          status: SharedPaymentItemStatus.INIT
        )
    );
    try {
      TxStatusResponseModel? txStatusResponseModel = await alchemyRepo.getTxStatus(txHash: txHash, networkId: networkId);

      if (txStatusResponseModel != null) {
        if (txStatusResponseModel.blockHash == null &&
            txStatusResponseModel.blockNumber == null &&
            txStatusResponseModel.transactionIndex == null) {
          emit(
              state.copyWith(
                  status: SharedPaymentItemStatus.PENDING
              )
          );
        } else {
          emit(
              state.copyWith(
                  status: SharedPaymentItemStatus.SUCCESS
              )
          );
        }
      }
    } catch (exception) {
      print(exception);
      emit(state.copyWith(status: SharedPaymentItemStatus.ERROR));
    }
  }
}
