import 'package:social_wallet/models/balance_response_model.dart';

import '../../services/network/api_endpoint.dart';
import '../../services/network/api_service.dart';

class BalanceRepository {

  final ApiService _apiService;

  BalanceRepository({
    required ApiService apiService
  }) : _apiService = apiService;


  Future<BalanceResponseModel?> getNativeCryptoBalance({
    required String accountAddress,
    required int networkId
  }) async {
    try {
      final response = await _apiService.get(
          endpoint: ApiEndpoint.balance(BalanceEndpoint.getNativeBalance, accountAddress: accountAddress, networkId: networkId),
          converter: (response) => BalanceResponseModel.fromJson(response)
      );
      return response;
    } catch(ex) {
      return null;
    }
  }
}