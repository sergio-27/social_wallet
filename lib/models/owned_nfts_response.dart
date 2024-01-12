import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:social_wallet/models/nft_media_model.dart';
import 'package:social_wallet/models/owned_nfts_data.dart';
import 'package:social_wallet/models/token_uri_model.dart';


part 'owned_nfts_response.freezed.dart';
part 'owned_nfts_response.g.dart';

@freezed
class OwnedNFTsResponse with _$OwnedNFTsResponse {
  const factory OwnedNFTsResponse({
    required List<OwnedNFTsData> ownedNfts
}) = _OwnedNFTsResponse;

  factory OwnedNFTsResponse.fromJson(Map<String, dynamic> json) =>
      _$OwnedNFTsResponseFromJson(json);
}
