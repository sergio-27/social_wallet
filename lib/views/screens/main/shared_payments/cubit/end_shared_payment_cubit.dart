import 'package:bloc/bloc.dart';
import 'package:social_wallet/models/send_tx_request_model.dart';



part 'end_shared_payment_state.dart';

class EndSharedPaymentCubit extends Cubit<EndSharedPaymentState> {

  EndSharedPaymentCubit() : super(EndSharedPaymentState());


  void submitTx(SendTxRequestModel sendTxRequestModel) {
    emit(state.copyWith(status: EndSharedPaymentStatus.loading));
    try {

    } catch (exception) {
      print(exception);
    }
  }

  void getTxStatus() async {

  }

}
