import 'package:bloc/bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:social_wallet/api/repositories/alchemy_repository.dart';
import 'package:social_wallet/api/repositories/balance_repository.dart';
import 'package:social_wallet/api/repositories/wallet_repository.dart';
import 'package:social_wallet/api/repositories/web3_core_repository.dart';
import 'package:social_wallet/di/injector.dart';
import 'package:social_wallet/models/available_contract_specs_model.dart';
import 'package:social_wallet/models/create_erc721_request_model.dart';
import 'package:social_wallet/models/deployed_sc_response_model.dart';
import 'package:social_wallet/models/owned_nfts_data.dart';
import 'package:social_wallet/models/owned_token_account_info_model.dart';
import 'package:social_wallet/models/owned_nfts_response.dart';
import 'package:social_wallet/models/send_tx_request_model.dart';
import 'package:social_wallet/models/user_nfts_model.dart';
import 'package:social_wallet/models/wallet_hash_request_model.dart';
import 'package:social_wallet/models/wallet_hash_response_model.dart';
import 'package:social_wallet/utils/app_constants.dart';
import 'package:social_wallet/utils/config/config_props.dart';

import '../../../../../models/custodied_wallets_info_response.dart';
import '../../../../../models/db/user.dart';
import '../../../../../models/network_info_model.dart';

part 'available_contract_state.dart';

class AvailableContractCubit extends Cubit<AvailableContractState> {

  Web3CoreRepository web3CoreRepository;

  AvailableContractCubit({
    required this.web3CoreRepository,
  }) : super(AvailableContractState());

  void getAvailableContractsFromVottunPlatform() async {
    emit(state.copyWith(
      status: AvailableContractStatus.loading
    ));
    try {
      List<AvailableContractSpecsModel> response = await web3CoreRepository.getAvailableContractSpecs() ?? [];
      emit(state.copyWith(
          status: AvailableContractStatus.success,
          availableContractsList: response.where((element) => element.owned == true).toList().reversed.toList()
      ));
    } catch (exception) {
      print(exception);
      emit(state.copyWith(
          status: AvailableContractStatus.error,
          availableContractsList: []
      ));
    }
  }
}
