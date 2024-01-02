import 'package:bloc/bloc.dart';
import 'package:social_wallet/api/repositories/wallet_repository.dart';
import 'package:social_wallet/di/injector.dart';
import 'package:social_wallet/models/direct_payment_model.dart';
import 'package:social_wallet/models/send_tx_request_model.dart';
import 'package:social_wallet/models/send_tx_response_model.dart';
import 'package:social_wallet/models/transfer_request_model.dart';

import '../../../../../models/currency_model.dart';
import '../../../../../models/network_info_model.dart';


part 'dirpay_history_state.dart';

class DirPayHistoryCubit extends Cubit<DirPayHistoryState> {


  DirPayHistoryCubit() : super(DirPayHistoryState());

  Future<void> getDirPayHistory(int userId) async {
    emit(
      state.copyWith(
        status: DirPayHistoryStatus.loading
      )
    );
    try {
      List<DirectPaymentModel> dirPaymentHistory = await getDbHelper().retrieveDirectPayments(userId) ?? [];

      emit(
        state.copyWith(
          dirPaymentHistoryList: dirPaymentHistory,
          status: DirPayHistoryStatus.success
        )
      );
    } catch (exception) {
      print(exception);
      emit(state.copyWith(status: DirPayHistoryStatus.error));
    }
  }

}
