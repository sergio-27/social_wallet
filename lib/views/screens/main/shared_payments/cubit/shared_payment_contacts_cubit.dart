import 'package:bloc/bloc.dart';
import 'package:social_wallet/models/send_tx_request_model.dart';

import '../../../../../models/shared_contact_model.dart';



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



}
