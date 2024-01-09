import 'package:bloc/bloc.dart';
import 'package:social_wallet/api/repositories/wallet_repository.dart';
import 'package:social_wallet/models/send_tx_request_model.dart';
import 'package:social_wallet/models/send_tx_response_model.dart';
import 'package:social_wallet/models/transfer_request_model.dart';

import '../../../../../models/currency_model.dart';
import '../../../../../models/network_info_model.dart';


part 'direct_payment_state.dart';

class DirectPaymentCubit extends Cubit<DirectPaymentState> {

  WalletRepository walletRepository;

  DirectPaymentCubit({
    required this.walletRepository
  }) : super(DirectPaymentState());


  void setContactInfo(String contactName, String address) {
    emit(
      state.copyWith(
        selectedContactName: contactName,
        selectedContactAddress: address
      )
    );
  }

  void updateSelectedNetwork() {
    emit(state);
  }

  void setNetworkId(int networkId) {
    emit(
        state.copyWith(
            selectedNetworkId: networkId
        )
    );
  }

  void setSelectedNetwork(NetworkInfoModel networkInfoModel) {
    emit(
        state.copyWith(
            selectedNetwork: networkInfoModel
        )
    );
  }

  void setSelectedCurrencyModel(CurrencyModel currencyModel) {
    emit(state.copyWith(selectedCurrencyModel: currencyModel));
  }


}
