import '../../models/bc_networks_model.dart';
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
}