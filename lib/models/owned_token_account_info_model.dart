import 'package:freezed_annotation/freezed_annotation.dart';


part 'owned_token_account_info_model.freezed.dart';
part 'owned_token_account_info_model.g.dart';

@freezed
class OwnedTokenAccountInfoModel with _$OwnedTokenAccountInfoModel {
  const factory OwnedTokenAccountInfoModel({
    required int id,
    required String jsonrpc,
    required String method,
    required List<dynamic> params,
}) = _OwnedTokenAccountInfoModel;

  factory OwnedTokenAccountInfoModel.fromJson(Map<String, dynamic> json) =>
      _$OwnedTokenAccountInfoModelFromJson(json);
}
