import 'package:social_wallet/models/deployed_sc_response_model.dart';
import 'package:social_wallet/models/send_tx_request_model.dart';

import '../../models/bc_networks_model.dart';
import '../../models/deploy_smart_contract_model.dart';
import '../../models/tx_status_response_model.dart';
import '../../services/network/api_endpoint.dart';
import '../../services/network/api_service.dart';

class Web3CoreRepository {


  final ApiService _apiService;


  Web3CoreRepository({
    required ApiService apiService
  }) : _apiService = apiService;


  Future<BCNetworksModel?> getAvailableNetworksInfo() async {
    try {
      final response = await _apiService.get(
          endpoint: ApiEndpoint.network(NetworkEndpoint.getAvailableNetworks),
          converter: (response) => BCNetworksModel.fromJson(response)
      );
      return response;
    } catch(ex) {
      return null;
    }
  }

  Future<TxStatusResponseModel?> getTxStatus({
    required String txHash,
    required int networkId
  }) async {
    try {
      final response = await _apiService.get(
          endpoint: ApiEndpoint.network(NetworkEndpoint.getTxStatus, txHash: txHash, networkId: networkId.toString()),
          converter: (response) => TxStatusResponseModel.fromJson(response)
      );
      return response;
    } catch(ex) {
      return null;
    }
  }

  Future<DeployedSCResponseModel?> createSmartContractSharedPayment(DeploySmartContractModel deploySmartContractModel) async {
    try {
      final response = await _apiService.post(
          endpoint: ApiEndpoint.smartContract(SmartContractEndpoint.deploySmartContract),
          data: deploySmartContractModel.toJson(),
          converter: (response) => DeployedSCResponseModel.fromJson(response)
      );
      return response;
    } catch(ex) {
      return null;
    }
  }

  Future<dynamic> querySmartContract(SendTxRequestModel sendTxRequestModel) async {
    try {
      final response = await _apiService.getFromSmartContract(
          endpoint: ApiEndpoint.smartContract(SmartContractEndpoint.querySmartContract),
          body: sendTxRequestModel.toJson(),
          converter: (response) => response
      );
      return response;
    } catch(ex) {
      return null;
    }
  }
}