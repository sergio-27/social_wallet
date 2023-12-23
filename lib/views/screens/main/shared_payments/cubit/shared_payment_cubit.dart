import 'package:bloc/bloc.dart';

import '../../../../../models/network_info_model.dart';


part 'shared_payment_state.dart';

class SharedPaymentCubit extends Cubit<SharedPaymentState> {

  SharedPaymentCubit() : super(SharedPaymentState());

  void setSelectedNetwork(NetworkInfoModel networkInfoModel) {
    emit(
        state.copyWith(
          selectedNetwork: networkInfoModel
        )
    );
  }

}
