import 'dart:convert';

import 'package:social_wallet/models/bc_networks_model.dart';
import 'package:social_wallet/utils/helpers/typedefs.dart';

import 'key_value_storage_base.dart';


class KeyValueStorageService {

  static const _authTokenKey = 'authToken';
  static const _languageKey = 'languageKey';
  static const _refreshTokenKey = 'refreshToken';

  static const _isMainnetEnabled = 'isMainnetEnabled';
  static const _showAgainDeleteNotificationDialog = 'showAgainDeleteNotificationDialog';
  static const _showTeamsDialog = '_showTeamsDialog';
  static const _hasEnterAddAppointmentScreen = 'hasEnterAddAppointmentScreen';
  static const _isUserRegistered = 'isUserRegistered';
  static const _token = 'token';
  static const _networkInfo = 'networkInfo';
  static const _userEmail = 'userEmail';
  static const _userAddress = 'userAddress';

  final _keyValueStorage = KeyValueStorageBase.instance;

  bool getIsMainnetEnabled() {
    return _keyValueStorage.getCommon<bool>(_isMainnetEnabled) ?? false;
  }

   void setMainnetEnabled(bool isMainnetEnabled) {
     _keyValueStorage.setCommon<bool>(_isMainnetEnabled, isMainnetEnabled);
   }

  bool getShowAgainDeleteNotificationDialog() {
    return _keyValueStorage.getCommon<bool>(_showAgainDeleteNotificationDialog) ?? true;
  }

  void setNotShowAgainDeleteNotificationDialog() {
    _keyValueStorage.setCommon<bool>(_showAgainDeleteNotificationDialog, false);
  }

  bool getHasEnterOnAddAppointmentScreen() {
    return _keyValueStorage.getCommon<bool>(_hasEnterAddAppointmentScreen) ?? false;
  }

  void setHasEnterOnAddAppointmentScreen() {
    _keyValueStorage.setCommon<bool>(_hasEnterAddAppointmentScreen, true);
  }

  bool getIsUserRegistered() {
    return _keyValueStorage.getCommon<bool>(_isUserRegistered) ?? false;
  }

  void setIsUserRegistered(bool isUserRegistered) {
    _keyValueStorage.setCommon<bool>(_isUserRegistered, isUserRegistered);
  }

  BCNetworksModel? getNetworkInfo() {
    final json = _keyValueStorage.getCommon<String>(_networkInfo);
    if (json == null) return null;
    return BCNetworksModel.fromJson(jsonDecode(json) as JSON);

  }

  String? getUserEmail() {
    final json = _keyValueStorage.getCommon<String>(_userEmail);
    if (json == null) return null;
    return json;

  }

  void setUserEmail(String userEmail) {
    _keyValueStorage.setCommon<String>(_userEmail, userEmail);
  }

  String? getUserAddress() {
    final json = _keyValueStorage.getCommon<String>(_userAddress);
    if (json == null) return null;
    return json;
  }

  void setUserAddress(String userAddress) {
    _keyValueStorage.setCommon<String>(_userAddress, userAddress);
  }

  void setNetworksInfo(BCNetworksModel networkInfo) {
    String jsonToSave = jsonEncode(networkInfo.toJson());
    _keyValueStorage.setCommon<String>(_networkInfo, jsonToSave);
  }

  Future<String> getToken() async {
    final tokenResponse = await _keyValueStorage.getEncrypted(_token) ?? '';
    return tokenResponse;
  }

  void setToken({required String username, required String password}) async {
    String tokenResponse = base64Encode(utf8.encode('$username:$password'));
    _keyValueStorage.setEncrypted(_token, tokenResponse);
  }


  /// Resets the authentication. Even though these methods are asynchronous, we
  /// don't care about their completion which is why we don't use `await` and
  /// let them execute in the background.
  Future<void> resetKeys() async {
    await _keyValueStorage.clearCommon();
    await _keyValueStorage.clearEncrypted();
  }
}
