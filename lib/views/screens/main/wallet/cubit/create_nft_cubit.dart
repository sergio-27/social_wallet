import 'package:bloc/bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:social_wallet/api/repositories/alchemy_repository.dart';
import 'package:social_wallet/api/repositories/balance_repository.dart';
import 'package:social_wallet/api/repositories/wallet_repository.dart';
import 'package:social_wallet/api/repositories/web3_core_repository.dart';
import 'package:social_wallet/di/injector.dart';
import 'package:social_wallet/models/create_erc721_request_model.dart';
import 'package:social_wallet/models/deployed_sc_response_model.dart';
import 'package:social_wallet/models/owned_nfts_data.dart';
import 'package:social_wallet/models/owned_token_account_info_model.dart';
import 'package:social_wallet/models/owned_nfts_response.dart';
import 'package:social_wallet/models/user_nfts_model.dart';
import 'package:social_wallet/models/wallet_hash_request_model.dart';
import 'package:social_wallet/models/wallet_hash_response_model.dart';
import 'package:social_wallet/utils/app_constants.dart';

import '../../../../../models/custodied_wallets_info_response.dart';
import '../../../../../models/db/user.dart';
import '../../../../../models/network_info_model.dart';

part 'create_nft_state.dart';

class CreateNftCubit extends Cubit<CreateNftState> {
  Web3CoreRepository web3CoreRepository;

  CreateNftCubit({
    required this.web3CoreRepository,
  }) : super(CreateNftState());

  void createERC721({
    required String name,
    required String symbol,
    String? alias,
    required int network,
  }) async {
    emit(state.copyWith(status: CreateNftStatus.loading));
    try {
      User? currUser = AppConstants.getCurrentUser();
      await Future.delayed(Duration(seconds: 2));
      DeployedSCResponseModel? response = await web3CoreRepository
          .createERC721(CreateErc721RequestModel(name: name, symbol: symbol, alias: alias, network: network, gasLimit: 6000000));

      if (response != null && currUser != null) {
        int? result = await getDbHelper().upsertUserNFT(
            userNfTsModel: UserNfTsModel(
                contractAddress: response.contractAddress,
                creationTxHash: response.txHash,
                ownerId: currUser.id ?? 0,
                nftName: name,
                nftSymbol: symbol,
                networkId: network,
                creationTimestamp: DateTime.now().millisecondsSinceEpoch));
        if (result != null) {
          emit(state.copyWith(status: CreateNftStatus.success, deployedSCResponseModel: response));
        } else {
          emit(state.copyWith(status: CreateNftStatus.success, deployedSCResponseModel: null));
        }
      } else {
        emit(state.copyWith(status: CreateNftStatus.success, deployedSCResponseModel: null));
      }
    } catch (exception) {
      print(exception);
      emit(state.copyWith(status: CreateNftStatus.error, deployedSCResponseModel: null));
    }
  }

  void setSelectedUserNftModel(UserNfTsModel userNfTsModel) {
    emit(state.copyWith(
      selectedUserNftModel: userNfTsModel
    ));
  }

  void setSelectedFile(List<PlatformFile> selectedFiles) {
    emit(state.copyWith(
        selectedFile: selectedFiles
    ));
  }

  Future<List<UserNfTsModel>> getCreatedUserNfts() async {
    try {
      User? currUser = AppConstants.getCurrentUser();
      if (currUser != null) {
        if (currUser.id != null) {
          if (currUser.id != 0) {
            List<UserNfTsModel> response = await getDbHelper().getErc721CreatedByUser(currUser.id ?? 0);
            return response;
          }
        }
      }
      return [];
    } catch (exception) {
      print(exception);
      return [];
    }
  }
}
