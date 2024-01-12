import 'package:freezed_annotation/freezed_annotation.dart';


part 'owner_nfts_response.freezed.dart';
part 'owner_nfts_response.g.dart';

@freezed
class OwnerNFTsResponse with _$OwnerNFTsResponse {
  const factory OwnerNFTsResponse({
    required double balance,
}) = _OwnerNFTsResponse;

  factory OwnerNFTsResponse.fromJson(Map<String, dynamic> json) =>
      _$OwnerNFTsResponseFromJson(json);
}
