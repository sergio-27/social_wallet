import 'package:bloc/bloc.dart';

import '../../../../../di/injector.dart';
import '../../../../../models/db/shared_payment_response_model.dart';
import '../../../../../models/db/user.dart';
import '../../../../../models/network_info_model.dart';


part 'shared_payment_state.dart';

class SharedPaymentCubit extends Cubit<SharedPaymentState> {

  SharedPaymentCubit() : super(SharedPaymentState());

  Future<void> getUserSharedPayments() async {
    User? currUser = await getDbHelper().retrieveUserByEmail(getKeyValueStorage().getUserEmail() ?? "");
    if (currUser != null) {
      List<SharedPaymentResponseModel>? result = await getDbHelper().retrieveUserSharedPayments(currUser.id ?? 0);
      emit(state.copyWith(
          sharedPaymentResponseModel: result
      ));
    } else {
      emit(state.copyWith(
          status: SharedPaymentStatus.error,
          sharedPaymentResponseModel: null
      ));
    }

  }

  void setSelectedNetwork(NetworkInfoModel networkInfoModel) {
    emit(
        state.copyWith(
          selectedNetwork: networkInfoModel
        )
    );
  }

}
