import 'package:social_wallet/models/alchemy_request_body.dart';
import 'package:social_wallet/models/balance_response_model.dart';

import '../../services/network/api_endpoint.dart';
import '../../services/network/api_service.dart';

class AlchemyRepository {

  final ApiService _apiService;


  AlchemyRepository({
    required ApiService apiService
  }) : _apiService = apiService;


  Future<BalanceResponseModel?> getTokenInfoOwnedByAddress({
    required String userAddress
  }) async {
    try {
      final response = await _apiService.post(
          endpoint: ApiEndpoint.alchemyAPIUrl,
          data: AlchemyRequestBody(
              id: 1,
              jsonrpc: "2.0",
              method: "alchemy_getTokenBalances",
              params: [
                userAddress,
                "erc20"
              ]
          ).toJson(),
          converter: (response) => BalanceResponseModel.fromJson(response)
      );
      return response;
    } catch(ex) {
      return null;
    }
  }
}